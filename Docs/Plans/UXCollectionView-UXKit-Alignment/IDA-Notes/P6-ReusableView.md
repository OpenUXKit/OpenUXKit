# P6 阶段反编译笔记：ReusableView 生命周期子系统（S1b）对齐

> P6 phase — verify `UXCollectionReusableView` / `UXCollectionViewCell` / `_UXCollectionSnapshotView`（S1b 子系统）的 ivar 布局、`_reusableViewFlags` 位段与全部方法的算法对齐 UXKit 26.4。
>
> **结论**：生命周期核心（init / reuse / 两阶段 layoutAttributes 应用 / flag 位段 / snapshot 位图）OpenUXKit **此前已基本对齐**——`_setLayoutAttributes:` / `_setBaseLayoutAttributes:` / `_addUpdateAnimation` 系列 / `prepareForReuse` / `_snapshot:` 全部逐方法 verify 一致。真正的偏差集中在 **Accessibility 表面**（OpenUXKit 此前是自创的兜底实现）与 3 处小杂项（`description` 格式 / `_collectionView` 所有权 / `_commonInit` 选择子形态）。本阶段共发现 **13 处偏差，修复 10 处，保留 3 处**（含 1 处推断性结论），全部记录如下。
>
> **重要更正**：Plan §S1a/P6 假设「`applyLayoutAttributes:` 分两阶段：`_setBaseLayoutAttributes:` 应用 frame/bounds/center/transform/alpha/hidden/zIndex + 子类 hook」**与实测相反**——见 §5。
>
> **P6 阶段代码改动**（`git show --stat 2fe5331` 核对）：4 个文件，+125 / -61 行。
> - `Sources/OpenUXKit/Components/Public/UXCollectionReusableView.m`：90 行改动（accessibility 重写 + description + 所有权）
> - `Sources/OpenUXKit/Components/Public/UXCollectionViewCell.m`：+83 行级改动（CommonInit 函数化 + cell accessibility 表面）
> - `Sources/OpenUXKit/Components/Private/UXCollectionReusableView+Internal.h`：+9（`_snapshot:` 与 4 个 AX helper 声明上移）
> - `Sources/OpenUXKit/Components/Private/UXCollectionViewCell+Internal.h`：ivar 顺序对齐

---

## 1. `UXCollectionReusableView` ivar 矩阵（P6 冻结）

来源：导出头 + `initWithFrame:` (0x1dbb9ff60) / `dealloc` (0x1dbba37e0) / `initWithCoder:` (0x1dbbee0d4) 反编译。

| UXKit offset | UXKit ivar | OpenUXKit ivar | 对齐 |
|---|---|---|---|
| 536 | `_layoutAttributes`（retain，存 **copy**） | strong，存 `.copy` | ✅ |
| 544 | `_reuseIdentifier`（导出头漏列；init 置 0、dealloc release、coder 直存） | 同 | ✅ |
| 552 | `_collectionView`（**plain assign**，无 weak 注册，setter 0x1dbbede48 仅裸存指针） | **已修复**：`__weak` → `__unsafe_unretained` | ✅ |
| 560 | `_reusableViewFlags`（int32 位段） | `uint32_t` 位段 | ✅ |
| 564 | `_isFloatingPinned`（BOOL，synthesized） | 同 | ✅ |

### 1.1 `_reusableViewFlags` 位段（已逐位 verify）

| Bit | UXKit 含义 | 读写点 | 对齐 |
|---|---|---|---|
| bit 0-4 (`& 0x1F`) | `updateAnimationCount`（5 bit 计数器，上限 31） | `_addUpdateAnimation` (0x1dbbedd04)：`(~flags & 0x1F)==0` → assert(file "UXCollectionViewCell.m" line 209) 后仍 +1 wrap；`_clearUpdateAnimation` (0x1dbbedc74)：`(flags & 0x1F)==0` → assert(line 215) 后仍 -1 wrap；`_isInUpdateAnimation` (0x1dbbedd98)：`(flags & 0x1F) != 0` | ✅（assert 文件名/行号/文案逐字一致；OpenUXKit `(count±1) & 0x1F` 与 UXKit `flags&0xE0 \| (flags±1)&0x1F` 等价） |
| bit 5 (`0x20`) | `wasDequeued` | `_markAsDequeued` (0x1dbbedc5c)：`\|= 0x20`；`_wasDequeued` (0x1dbbedc48)：`(flags >> 5) & 1` | ✅ |
| bit 6+ | 未使用 | — | ✅ |

注：UXKit 源文件名 assert 显示为 `UXCollectionViewCell.m`——UXKit 把 ReusableView 与 Cell 写在同一个源文件里，OpenUXKit 已原样复刻该文件名与行号。

## 2. `UXCollectionViewCell` ivar 矩阵

来源：`_OBJC_IVAR_$_` 符号实测（get_int）。

| UXKit offset | UXKit ivar | OpenUXKit | 对齐 |
|---|---|---|---|
| 568 | `_contentView`（retain） | 同 | ✅ |
| 576 | `_selected` | 同 | ✅ |
| 577 | `_selectionBorderShouldUsePrimaryColor` | **已修复**（原与 `_highlighted` 顺序互换） | ✅ |
| 578 | `_highlighted` | 同 | ✅ |

## 3. `_UXCollectionSnapshotView`

UXKit 中该类**零方法、零 ivar**（`list_funcs` 过滤结果为空；导出头仅 `@interface _UXCollectionSnapshotView : UXCollectionReusableView @end`），是纯标记子类。OpenUXKit 空实现即为 1:1 对齐，**零改动**。

**使用合同**（`xrefs_to _OBJC_CLASS_$__UXCollectionSnapshotView`，全部在 P8/P9 范围）：

| 创建点 | 用途 |
|---|---|
| `-[UXCollectionView _updateWithItems:]_block_invoke.615` | batchUpdates 删除项的快照容器 |
| `-[UXCollectionView _updateAnimationDidStop:finished:context:]` | 动画结束清理（`isKindOfClass` 判定 + removeFromSuperview） |
| `_doubleSidedAnimationsForView:…`_block_invoke (0x1dbbdf3c0) | 双面动画：`initWithFrame:view.frame` → `wantsLayer=YES` → `layerContentsRedrawPolicy=1` → `autoresizingMask=0` + `translates…=YES` → **`_markAsDequeued`** → 内嵌 NSView（`layer.contents = [view _snapshot:NO]`，`autoresizingMask=18` 即 W+H sizable）→ 包进 `UXCollectionViewAnimation`（viewType 0，deleteAfterAnimation） |

## 4. 方法算法对照（全部反编译）

### 4.1 `UXCollectionReusableView`（22 个方法 + 1 block）

| 方法 | 地址 | UXKit 关键算法 | OpenUXKit 修复前 | 对齐 |
|---|---|---|---|---|
| `initWithFrame:` | 0x1dbb9ff60 | clipsToBounds=YES → autoresizingMask=0 → translates=YES → wantsLayer=YES → redrawPolicy=1 → accessibilityElement=YES → 3 个对象 ivar 置 nil | 同 | ✅ |
| `initWithCoder:` / `encodeWithCoder:` | 0x1dbbee0d4 / 0x1dbbee06c | key `NSReuseIdentifier`，encode 仅在非 nil 时 | 同 | ✅ |
| `dealloc` | 0x1dbba37e0 | `[self.layer removeAllAnimations]` + release ×2 | 同（ARC） | ✅ |
| `description` | 0x1dbbeda94 | `<%@: %p; frame = %@, reuseIdentifier = %@>`（NSStringFromRect） | `<%@: %p reuseIdentifier:%@>` | ✅ 已修 |
| `wantsUpdateLayer` | 0x1dbbb2020 | return YES | 同 | ✅ |
| `reuseIdentifier` / `_setReuseIdentifier:` | 0x1dbbeda84 / 0x1dbbede68 | 指针比较 `!=` 后存 copy | 同 | ✅ |
| `_collectionView` / `_setCollectionView:` | 0x1dbbede58 / 0x1dbbede48 | 裸指针读写（assign） | `__weak` | ✅ 已修 |
| `_layoutAttributes` / `_setLayoutAttributes:` | 0x1dbbedea8 / 0x1dbbedeb8 | 见 §5 | 同 | ✅（原已对齐） |
| `_setBaseLayoutAttributes:` | 0x1dbbedfa0 | 见 §5 | 同 | ✅（原已对齐） |
| `setIsFloatingPinned:` / `isFloatingPinned` | 0x1dbbeddb0 / 0x1dbbeda74 | 变化时按 `isFloating && pinned` 选 floatingFrame/frame 重设 frame（attrs 为 nil 时 `[nil frame]` = CGRectZero，UXKit 同样行为） | 同 | ✅ |
| `_addUpdateAnimation` / `_clearUpdateAnimation` / `_isInUpdateAnimation` | 见 §1.1 | 见 §1.1 | 同 | ✅ |
| `_wasDequeued` / `_markAsDequeued` | 见 §1.1 | 见 §1.1 | 同 | ✅ |
| `prepareForReuse` | 0x1dbbee038 | `removeAllAnimations` + `_isFloatingPinned = NO`（**不**清 layoutAttributes / reuseIdentifier） | 同 | ✅ |
| `applyLayoutAttributes:` / `willTransition…` / `didTransition…` | 0x1dbbee034 / 030 / 02c | 空方法（4 字节 ret，子类 hook） | 同 | ✅ |
| `_snapshot:` | 0x1dbbedb04 | dispatch_once 静态 DeviceRGB；bitmapInfo = flipped ? 0x2006 (NoneSkipFirst\|32Host) : 0x2002 (PremultipliedFirst\|32Host)；presentationLayer `contentsAreFlipped` → CTM (1,0,0,-1,0,h)；`renderInContext:` 后 CreateImage | 同 | ✅ |
| `_accessibilityIndexPath` | 0x1dbbeb344 | **仅** `[_collectionView indexPathForSupplementaryView:self]`（cell 路径由子类 override） | cell 优先 + supplementary 兜底 + `_layoutAttributes.indexPath` 兜底 + 冗余 respondsToSelector 检查 | ✅ 已修 |
| `_accessibilityDefaultRole` | 0x1dbbeb3a4 | `NSAccessibilityGroupRole`（0x1E553AC20，已实测解符号） | 同 | ✅ |
| `_dynamicAccessibilityParent` | 0x1dbbeb3e8 | `collectionView.collectionViewLayout.layoutAccessibility accessibilityParentForReusableView:self` | 直接返回 `_collectionView` | ✅ 已修 |
| `_layoutSectionAccessibility` | 0x1dbbeb2cc | `accessibilityParent` isKindOfClass `UXCollectionViewLayoutSectionAccessibility` ? parent : nil | 恒 nil | ✅ 已修 |
| `accessibilityRole` | 0x1dbbeba3c | super 为 nil 或 `NSAccessibilityUnknownRole`（0x1E553B0E0，已实测）→ `_accessibilityDefaultRole` | 无 override | ✅ 已补 |
| `accessibilityParent` | 0x1dbbebadc | super 为 nil 或 == `_collectionView` → `_dynamicAccessibilityParent` | 无 override | ✅ 已补 |
| `accessibilityPerformScrollToVisible` | 0x1dbbeb480 | `scrollToItemAtIndexPath:_accessibilityIndexPath atScrollPosition:64 animated:YES`，**无条件 return YES**（无 nil 守卫） | position 0 / animated NO / 带守卫条件返回 | ✅ 已修（64 的语义见 §6.6） |
| `accessibilityPerformAction:` / `accessibilityActionDescription:` / `accessibilityActionNames` / `accessibilityAttributeValue:` / `accessibilityAttributeNames` | 0x1dbbeb4e8-0x1dbbeb8a8 | 10.10 起废弃的 legacy NSAccessibility 非正式协议 override：暴露 `AXScrollToVisible` 自定义 action 与 `AXPreviousContentSibling` / `AXNextContentSibling` / `AXContentSiblingAbove` / `AXContentSiblingBelow` 4 个 sibling 导航属性（经 `_layoutSectionAccessibility` 的 `siblingBefore/After/Above/BelowItem:`） | 缺失 | 🟡 保留缺失，遗留 P11（见 §7-K1） |

### 4.2 `UXCollectionViewCell`（17 个方法 + 1 block + 1 C 函数）

| 方法 | 地址 | UXKit 关键算法 | OpenUXKit 修复前 | 对齐 |
|---|---|---|---|---|
| `UXCollectionViewCellCommonInit` | 0x1dbbee3f8 | **静态 C 函数**（非 ObjC 方法）：autoresizingMask=0 → translates=YES → 建 contentView（frame=bounds 尺寸）→ role=Group + element=NO + autoresizing 同 + wantsLayer + redrawPolicy=1 → addSubview | `_commonInit` ObjC 方法（污染选择子命名空间） | ✅ 已修（函数化） |
| `initWithFrame:` / `initWithCoder:` | 0x1dbbee510 / 0x1dbbee3a4 | super + CommonInit | 同 | ✅ |
| `dealloc` | 0x1dbbee344 | `contentView.layer removeAllAnimations` + release | 同（ARC） | ✅ |
| `wantsUpdateLayer` | 0x1dbbee33c | return YES（与基类重复 override，UXKit 原样） | 同 | ✅ |
| 4 对 getter/setter | 0x1dbbee144-1a4 | 纯 ivar 读写，**无副作用**（选中渲染由主类驱动） | 同 | ✅ |
| `_setSelected:animated:` | 0x1dbbee1b4 | animated → CATransaction(0.25s + 空 completionBlock) 包裹 `setSelected:`；否则直调 | 同 | ✅ |
| `prepareForReuse` | 0x1dbbee258 | super → `setSelected:NO` → contentView.layer removeAllAnimations（**不**清 highlighted） | 同 | ✅ |
| `resizeSubviewsWithOldSize:` | 0x1dbbee2bc | super → contentView.frame = {0,0,bounds.size} | 同 | ✅ |
| `_accessibilityIndexPath` | 0x1dbbeafe4 | `[_collectionView indexPathForCell:self]` | （基类混合逻辑） | ✅ 已修 |
| `_accessibilityDefaultRole` | 0x1dbbeb044 | `NSAccessibilityCellRole`（0x1E553AA60，已实测解符号） | 缺失 | ✅ 已补 |
| `_dynamicAccessibilityParent` | 0x1dbbeb088 | `layoutAccessibility accessibilityParentForCell:self` | 缺失 | ✅ 已补 |
| `isAccessibilitySelected` | 0x1dbbeb25c | `[cv selectedItemAtIndexPath:[cv indexPathForCell:self]]`（无 nil 守卫） | 缺失 | ✅ 已补 |
| `setAccessibilitySelected:` | 0x1dbbeb120 | indexPath 非 nil 时：YES → `selectItemAtIndexPath:animated:YES scrollPosition:0`；NO → `deselectItemAtIndexPath:animated:YES` | 缺失 | ✅ 已补 |
| `isAccessibilitySelectorAllowed:` | 0x1dbbeb1b0 | 目标选择子（推断为 `setAccessibilitySelected:`，见 §7-K3）→ `selectableItemAtIndexPath:`；其它走 super | 缺失 | ✅ 已补 |
| `accessibilityPerformPress` | 0x1dbbee680 | `mouseDown:[_axSimulateClick:1 …]` + `mouseUp:[_axSimulateClick:2 …]` → return YES | 缺失 | ✅ 已补 |
| `_axSimulateClick:withNumberOfClicks:` | 0x1dbbee564 | bounds 中点 `convertPoint:toView:nil` → `+[NSEvent mouseEventWithType:clickType location:… modifierFlags:0 timestamp:+[NSDate timeIntervalSinceReferenceDate] windowNumber:… context:0 eventNumber:0 clickCount:1 pressure:1.0]`；**clicks 参数被忽略（反汇编实证 `MOV W7,#1`）** | stub return nil | ✅ 已修（保留 UXKit 的 clicks 忽略行为） |
| `_axPerformDoubleClick` | 0x1dbbee634 | `[_collectionView accessibilityPerformPressWithItemAtIndexPath:[… indexPathForCell:self]]` | 调 `_axSimulateClick:0 withNumberOfClicks:2`（自创且无效） | ✅ 已修 |

## 5. 两阶段 layoutAttributes 协议（P6 核心产出，更正 Plan 假设）

UXKit 0x1dbbedeb8 / 0x1dbbedfa0 实测：

```
_setLayoutAttributes:attrs              # 常规路径（dequeue / visible-cells diff / 布局切换）
1. if ([_layoutAttributes isEqual:attrs]) return        # 与 P5 §6.2 呼应：比较的是 Data 缓存 copy
2. _layoutAttributes = [attrs copy]                     # view 自持一份 copy
3. if (copy == nil) return                              # nil 只清存储，不动视图
4. if (attrs._reuseIdentifier) _setReuseIdentifier:
5. frame = (attrs.isFloating && _isFloatingPinned) ? attrs.floatingFrame : attrs.frame
6. alphaValue = attrs.alpha
7. [self applyLayoutAttributes:attrs]                   # 子类 hook，传入【原对象】而非 copy

_setBaseLayoutAttributes:attrs          # 仅动画路径
1. 同样的 isEqual: 短路 + copy 存储
2. 只同步 _reuseIdentifier —— 不碰 frame/alpha，也不调 applyLayoutAttributes:
```

- **Plan 的假设是反的**：`_setBaseLayoutAttributes:` 不应用任何几何属性；应用 frame/alpha + 调子类 hook 的是 `_setLayoutAttributes:`。且 macOS UXKit 的应用面只有 **frame + alpha**（无 UIKit 的 bounds/center/transform/hidden/zIndex view 应用；zIndex 由主类 `_addControlled:subview:atZIndex:` 排序消费）。
- **等价性短路就是普通 `isEqual:`**（0x1dbbe7470），没有 `_isEquivalentTo:` 参与。
- **UXKit 内部调用面**（`xrefs_to` 选择子 stub）：`_setBaseLayoutAttributes:` 唯一调用方是 `-[UXCollectionViewAnimation start]`（动画自己改 frame，故只刷新存储不触发 re-apply）；`_setLayoutAttributes:` 有 17 个调用点（dequeue block / `_reuseCell:` 与 `_reuseSupplementaryView:` 传 nil 清存储 / `_updateCellsInRect:` / layout 切换 / `_decorationViewForLayoutAttributes:` 等）。OpenUXKit 的 `UXCollectionViewAnimation.m:140` 已正确使用 `_setBaseLayoutAttributes:`，合同一致。
- OpenUXKit 该两方法此前已逐行对齐，P6 零改动。

## 6. 关键发现

### 6.1 生命周期核心原已对齐

S1b 的「重头」（flag 位段、两阶段 attrs、reuse 链、snapshot 位图参数）在此前 phase 的实现中已经 1:1，P6 的实际增量在 Accessibility 表面——这与矩阵预测（🟢 形式对齐）一致。

### 6.2 update-animation 计数器的主类合同（P8/P9 接线参考）

UXKit 中 `_addUpdateAnimation` 仅由 `_updateWithItems:` block 调用、`_clearUpdateAnimation` 仅由 `_updateAnimationDidStop:finished:context:` 调用、`_wasDequeued` 仅由 `_createPreparedCellForItemAtIndexPath:withLayoutAttributes:applyAttributes:` 消费、`prepareForReuse` 仅由 `_dequeueReusableViewOfKind:withIdentifier:forIndexPath:viewCategory:` 触发、`setIsFloatingPinned:` 仅由 `_addControlled:subview:atZIndex:` 调用。P9 重写主类时按此接线。

### 6.3 GOT 槽解符号新方法（替代 P5-K3 的「无法确认」）

P5 留过「`.i64` 中 GOT 槽未绑定无法确认符号」的尾巴。本阶段实测可用 `ipsw dyld a2s <cache> <addr>` 直接从 dyld shared cache 反解：`0x1E553AC20 = NSAccessibilityGroupRole`、`0x1E553AA60 = NSAccessibilityCellRole`、`0x1E553B0E0 = NSAccessibilityUnknownRole`、`0x1E553ADF0 = NSAccessibilityPressAction`。P9 验收时可用同法实测 P5-K3 的 CGRect 哨兵常量。

### 6.4 scroll position 64 是 SPI「nearest」模式

`-[UXCollectionView _scrollAmountForMovingRect:toScrollPosition:inDestinationRect:]` (0x1dbbd8e0c) 对 `position == 64` 有独立分支：目标 rect 已被完全包含 → 返回零位移；否则取 |minX-差| 与 |maxX-差| 中较小者做最小滚动。Accessibility 的 scroll-to-visible 即用此模式。OpenUXKit 的 `_scrollAmountForMovingRect:` 尚无此分支（P9 范围），当前传 64 行为是「不滚动」，与修复前传 0 等效、无回归。

### 6.5 Cell 的 CommonInit 是 C 函数

UXKit 用静态 C 函数 `UXCollectionViewCellCommonInit` 而非 `_commonInit` 选择子——OpenUXKit 原方法形态会向 runtime 暴露多余选择子（potential method collision / KVC probing 差异），已函数化对齐。

## 7. P6 保留的偏差（3 处）

| ID | 偏差 | 处理决策 |
|---|---|---|
| **K1** | ReusableView 的 5 个 legacy NSAccessibility 非正式协议 override（`accessibilityActionNames` / `accessibilityActionDescription:` / `accessibilityPerformAction:` / `accessibilityAttributeNames` / `accessibilityAttributeValue:`，含 AXScrollToVisible action 与 4 个 AXContentSibling 自定义属性）缺失 | **遗留 P11**：这组 API 自 10.10 废弃，super 调用与 `NSAccessibilityActionDescription` 会触发 `-Wdeprecated-declarations` 打破零警告 invariant；其消费端（sibling 导航）恰是 S7 的 `UXCollectionViewLayoutSectionAccessibility`（P11 verify 对象），应与 S7 一并接线。本阶段已把它依赖的 `_layoutSectionAccessibility` 修好。 |
| **K2** | `accessibilityPerformScrollToVisible` 传入的 position 64 在 OpenUXKit 主类中尚未实现「nearest」分支 | **遗留 P9**：64 模式属于 `_scrollAmountForMovingRect:toScrollPosition:inDestinationRect:`（主类滚动算法，见 §6.4）。调用侧已 1:1，主类补分支后自动生效。 |
| **K3** | `isAccessibilitySelectorAllowed:` 中被门控的选择子在 .i64 中位于 dyld 唯一化选择子区（静态不可解），按上下文**推断**为 `setAccessibilitySelected:` | 保留推断实现：该方法是 Cell 唯一实现的 AX setter，且 gate 条件（`selectableItemAtIndexPath:`）语义只对它成立。若 lldb 实测推翻，只需改一行。 |

另有 2 处**等价非偏差**记录在案：CommonInit 中 UXKit 显式置零 `_contentView`/`_selected`（ARC init 已零值，OpenUXKit 不复写）；`_setSelected:animated:` 的空 completionBlock UXKit 用全局 block 字面量、OpenUXKit 用内联空 block（语义相同）。

## 8. 遗留到后续 phase

| 项 | 所属 | 说明 |
|---|---|---|
| `_scrollAmountForMovingRect:toScrollPosition:inDestinationRect:` 增加 `position == 64`（nearest）分支 | **P9** | `Sources/OpenUXKit/Components/Public/UXCollectionView.m:1299`；UXKit 算法已在本笔记 §6.4 给出 |
| legacy NSAccessibility 非正式协议 5 方法 + sibling 属性接线 | **P11** | 见 §7-K1；依赖的 `_layoutSectionAccessibility` / `siblingBefore/After/Above/BelowItem:` 基建已就绪 |
| `accessibilityPerformPressWithItemAtIndexPath:` 主类算法 verify（cell 的 `_axPerformDoubleClick` 已接线到它） | **P9** | OpenUXKit 已有实现（`UXCollectionView.m:1176`），本阶段未反编译比对 |
| `_wasDequeued` / `prepareForReuse` / `setIsFloatingPinned:` 的主类调用点按 §6.2 合同接线 | **P9** | dequeue / visible-cells / floating 路径 |
| `_UXCollectionSnapshotView` 三个创建点的双面动画 / batchUpdates 流程 | **P8/P9** | 本笔记 §3 已记录创建合同（含 `_snapshot:NO` + autoresizingMask 18） |

## 9. 测试

- `Tests/OpenUXKitTests/Collection/` 中**无 P6 门控的 stub**（`TODO(uxkit-align)` 标记均属 P7/P8/P9），本阶段无新启用测试。
- `swift build`：0 errors / 0 warnings；`swift test`：26 个用例 0 failures（5 实跑通过，21 个后续 phase stub 维持 skip）；`xcodebuild OpenUXKit-Example-Swift Debug build`：成功（仅 1 个历史 storyboard duplicate 警告，与 P6 无关）。

## 10. P6 阶段 9 步工作流执行记录

| 步骤 | 执行情况 |
|---|---|
| **D** (Dump) | ✅ `list_funcs` 枚举 ReusableView 38 个函数（22 方法 + Accessibility 分类 + 1 block）、Cell 25 个（17 方法 + 分类 + CommonInit C 函数）、SnapshotView 0 个；同步读 3 个导出头 |
| **A** (Abstract ivars) | ✅ ReusableView 5 ivar + 6 bit 位段全部读写点 verify；Cell 4 ivar 偏移经 `_OBJC_IVAR_$_` 符号实测（568/576/577/578） |
| **M** (Method mapping) | ✅ 全部方法反编译；`_axSimulateClick:` 反汇编二次校验（Hex-Rays 局部变量分配失败处，实证 clickCount 硬编码 1、clicks 参数被忽略） |
| **C** (Compare) | ✅ 逐方法对照，发现 13 处偏差 |
| **B** (Bridge inventory) | ✅ UXKit 侧：`_setBaseLayoutAttributes:` 仅 Animation.start、`_setLayoutAttributes:` 17 处、dequeue/floating/update-animation 合同见 §6.2；OpenUXKit 侧：`UXCollectionViewAnimation.m:140`、`UXCollectionViewLayout.m:258/261/797/803`、`UXCollectionView.m` 10+ 处——签名零变更，全部调用面不受影响 |
| **R** (Rewrite) | ✅ 修复 10 处；保留 3 处（P11 范围 / P9 范围 / 静态不可解推断）；`_snapshot:` 与 AX helper 声明上移至 `+Internal.h` 供 Cell 与 P9 主类使用 |
| **V** (Verify) | ✅ build / test / Example xcodebuild 全绿 |
| **G** (Git checkpoint) | ✅ `2fe5331` code；docs commit 见本笔记提交 |
| **L** (Log learnings) | ✅ 本笔记（含 §6.3 的 `ipsw dyld a2s` 解符号新工法） |
