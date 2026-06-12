# P11 — Accessibility 子系统对齐笔记（UXKit 26.4）

> 基准：`/Volumes/Code/Dump/DyldSharedCaches/macOS/26.4/UXKit.i64`（session `uxkit_26_4`）。
> RuntimeViewer 不可用 → fallback 至导出 ObjCHeaders（`.../UXKit/ObjCHeaders/`）取接口，地址由 IDA 解析 ObjC 方法符号（确定性符号，非模糊搜索）。
> 涉及两类：`UXCollectionViewLayoutAccessibility`（NSAccessibilityElement，340 行）+ `UXCollectionViewLayoutSectionAccessibility`（NSAccessibilityElement，212 行）。

---

## 0. 结论摘要

两类**逐方法反编译比对**（Layout 28 个方法 + Section 24 个方法），发现 **~20 处真实算法分歧**，全部修正。核心模型与 OpenUXKit 原实现的根本差异：

- **UXKit 的 children 模型是「行数驱动 + 懒 dequeue」**，不是「visibleChildren 数组」。`accessibilityArrayAttributeCount:`/`Values:` 走 `accessibilityRowCount`（= `numberOfSections`）/ `numberOfItemsInSection:` + `_dequeueSectionWithIndex:` / `cellForItemAtIndexPath:`，**只认 `NSAccessibilityChildrenAttribute`**（不认 VisibleChildren，落 super）。
- **section/sibling 导航是几何驱动**，不是数组索引：Layout 的 next/previous 用 `[section sectionIndex]` + rowCount + **末尾回绕**；Section 的 sibling 用 layout 的 `indexPathOfItem{Before,After,Above,Below}:`。
- **hitTest 先 `NSPointInRect(point, child.accessibilityFrame)` 命中才下钻**，不是无条件下钻。
- **role 都是 `NSAccessibilityListRole`**（非 LayoutArea / Row）。
- **frame 是子元素并集**（Section）。

修正后：`swift build` 0 错误 0 warning；`swift test` 30/30 通过。

---

## 1. UXCollectionViewLayoutAccessibility

### 1.1 已确认对齐（零改动）

| 方法 | addr | 备注 |
|---|---|---|
| `_dequeueSectionWithIndex:` | 0x1dbbbe5a4 | 占位符插入/前后扩容/cacheIndex=`index-effectiveOffset`/懒建 section/`setAccessibilityIndex:`/回写 offset/`_notifyAccessibilityDelegateToPrepareSection:`，逐句一致 |
| `_trimSectionCacheToVisibleSections:` | 0x1dbbbe758 | 三分支决策树：`count<dropCount`→全替换 NSNull；`dropCount<6`→部分替换；`dropCount≥6`→`removeObjectsInRange`。`count>=dropCount` ⟺ `NOT(dropCount>count)`，与 UXKit 等价。尾部 `lastVisible+1` 裁剪一致 |
| `_visibleSections` | 0x1dbbbe9ac | items + supplementary 双扫，`containsIndex:` 去重 addIndex |
| `_dumpVisibleChildren` | 0x1dbbbfa20 | 清 `_accessibilityVisibleChildren` + `_visibleSections` + `_trimSectionCacheToVisibleSections:` |
| `accessibilityVisibleChildren` | 0x1dbbbf194 | 枚举 `_dequeueSectionWithIndex:` → `sortUsingSelector:@selector(compare:)`（sel 0x1FA172460）→ trim |
| `accessibilityChildren` | 0x1dbbbf104 | `UIAOverrideAccessibilityChildren` default 存在则返回 visibleChildren，否则 nil |
| `accessibilityFrame` | 0x1dbbbf3d0 | 纯 `[super accessibilityFrame]` |
| `accessibilityLabel` / `accessibilityRoleDescription` | 0x1dbbbf450 / 0x1dbbbf4a8 | `[self.layout accessibilityLabel/RoleDescription]` |
| `accessibilityIdentifier` | 0x1dbbbf500 | `layout.accessibilityIdentifier ?: [super …]` |
| `accessibilityColumnCount` | 0x1dbbbf408 | 常量 1 |
| `accessibilityRowCount` | 0x1dbbbf410 | `[collectionView numberOfSections]` |
| `accessibilityParent` | 0x1dbbbf600 | tail-call `collectionView` |
| `accessibilitySubrole` | 0x1dbbbf5b0 | nil |

### 1.2 已修正分歧

| 方法 | addr | UXKit 行为 | OpenUXKit 原状 |
|---|---|---|---|
| `accessibilityArrayAttributeCount:` | 0x1dbbbf074 | **仅 Children**，返回 `accessibilityRowCount` | Children+VisibleChildren，返回 `visibleChildren.count` |
| `accessibilityArrayAttributeValues:index:maxCount:` | 0x1dbbbef50 | **仅 Children**；`count=MIN(maxCount, rowCount-index)`；循环 `_dequeueSectionWithIndex:index`（**index 恒定、不自增**，汇编 `loc_1DBBBEFD4` 处 `MOV X2,X20` 验证）→ 同 section 入数组 count 次 | subarray of visibleChildren |
| `accessibilityRole` | 0x1dbbbf5bc | `NSAccessibilityListRole` | `NSAccessibilityLayoutAreaRole` |
| `accessibilityIndexOfChild:` | 0x1dbbbf0fc | `[child accessibilityIndex]` | `NSNotFound` |
| `accessibilityHitTest:` | 0x1dbbbf604 | 迭代 visibleChildren，**`NSPointInRect(point, child.accessibilityFrame)` 命中才** `return [child accessibilityHitTest:]` | 无条件下钻取首个非 nil |
| `nextSectionForSection:` | 0x1dbbbf790 | rowCount<2→nil；`next=(sectionIndex+1<rowCount)?sectionIndex+1:0`（**回绕 0**）→`_dequeueSectionWithIndex:` | visibleChildren 数组下一个 |
| `previousSectionForSection:` | 0x1dbbbf824 | rowCount<2→nil；`base=(sectionIndex==0?rowCount:sectionIndex)`；`_dequeueSectionWithIndex:base-1`（**回绕末尾**） | visibleChildren 数组上一个 |
| `accessibilityParentForCell:` | 0x1dbbbf8b8 | `indexPathForCell:` → `_dequeueSectionWithIndex:[indexPath section]` | 返回 self |
| `accessibilityParentForReusableView:` | 0x1dbbbf96c | `indexPathForSupplementaryView:` → `_dequeueSectionWithIndex:[indexPath section]` | 返回 self |
| `accessibilityFrameInParentSpace` | 0x1dbbbf324 | 阈值 `FLT_EPSILON`（0.00000011920929） | `1.0e-7` |
| `accessibilityPostNotification:` | 0x1dbbbebfc | `if(notification) NSAccessibilityPostNotification(...)` | 无 nil 守卫 |
| `accessibilityPrepareLayout` / `InvalidateLayout` / `DidEndScrolling` / `PrepareForCollectionViewUpdates:` | 0x1dbbbfa88 / fc28 / fc78 / fccc | `_dumpVisibleChildren` + **`AXCollectionViewEnumerateSections(__sectionCache, block)`** 向每个非 NSNull section 转发对应生命周期方法（block.6/.4/.2/.868，invoke 形如 `[section accessibilityPrepareLayout]`） | 仅 `_dumpVisibleChildren` |

#### AXCollectionViewEnumerateSections（0x1dbbbfad0）
私有 C 助手：遍历 section 缓存，跳过 `[NSNull null]`，对每个 live section 调 `block(block, section)`。在 OpenUXKit 以静态函数 `UXCollectionViewLayoutAccessibilityEnumerateSections(NSArray*, void(^)(id))` 复刻；生命周期方法读**原始 ivar `__sectionCache`**（非懒 getter，nil 时枚举空转）。**注**：Section 生命周期方法均为空 `{}`，故转发无可观测副作用，仅为结构 1:1。

---

## 2. UXCollectionViewLayoutSectionAccessibility

### 2.1 已确认对齐（零改动）

| 方法 | addr | 备注 |
|---|---|---|
| `compare:` | 0x1dbbcfe68 | `sectionIndex` 三态比较 |
| `accessibilityActionDescription:` | 0x1dbbcf21c | `"AXScrollToVisible"` → `NSAccessibilityActionDescription` |
| `accessibilityPerformAction:` | 0x1dbbcf1c4 | `"AXScrollToVisible"` → `accessibilityPerformScrollToVisible` |
| `accessibilityChildren` | 0x1dbbcf9a4 | 同 Layout，UIAOverride 控制 |
| `accessibilitySubrole` | 0x1dbbcfc8c | nil |
| `siblingBefore/After/Above/BelowItem:` | 0x1dbbd00f0/e4/d8/cc | tail-call `_siblingInDirection:` 方向 **0/1/2/3**（汇编确认） |
| `accessibilityPrepareLayout` 等生命周期 | 0x1dbbd04a4 | 空 `{}`（4 字节） |

### 2.2 已修正分歧

| 方法 | addr | UXKit 行为 | OpenUXKit 原状 |
|---|---|---|---|
| `accessibilityRole` | 0x1dbbcfc98 | `NSAccessibilityListRole` | `NSAccessibilityRowRole` |
| `accessibilityFrame` | 0x1dbbcfa34 | visible cells + supplementary 的 `accessibilityFrame` **`NSUnionRect` 并集**（从 CGRectZero 起） | `[super accessibilityFrame]` |
| `accessibilityVisibleChildren` | 0x1dbbcf788 | supplementary→cells 入数组后 **`sortUsingComparator:`**：`midY=(NSUInteger)(y+h*0.5)/10` 升序,同桶按 `midX=(NSUInteger)(x+w*0.5)/10` 升序（block 0x1dbbcf894） | 无排序 |
| `visibleCellsInSection:` | 0x1dbbd00fc | `indexPathsForVisibleItemsInSections:[NSIndexSet indexSetWithIndex:section]` 定向查询；按 `[cell isAccessibilityElement]` 过滤 | 遍历全部 visible items 按 section 筛 + `cell!=nil` |
| `visibleSupplementaryViewsInSection:` | 0x1dbbd02bc | `NSAccessibilityUnignoredChildren(visibleSupplementaryViews)`；按 section + `isAccessibilityElement` + **非零 bounds** 过滤 | 仅按 section |
| `accessibilityArrayAttributeCount:` | 0x1dbbcf618 | **仅 Children**，`[collectionView numberOfItemsInSection:sectionIndex]` | Children+VisibleChildren，`visibleChildren.count` |
| `accessibilityArrayAttributeValues:index:maxCount:` | 0x1dbbcf474 | **仅 Children**；`[NSIndexPath indexPathForItem:index inSection:sectionIndex]` → 单个 `cellForItemAtIndexPath:` 包成 `@[cell]`；两分支末尾 `?:@[]` | subarray of visibleChildren |
| `accessibilityIndexOfChild:` | 0x1dbbcf6d4 | `isKindOf:UXCollectionViewCell` → `[[indexPathForCell:] item]`，否则 NSNotFound | `indexOfObjectIdenticalTo:` |
| `accessibilityHitTest:` | 0x1dbbcfcdc | 迭代 **`accessibilityChildren`**（非 VisibleChildren，常态 nil→返回 self）+ NSPointInRect 命中下钻 | 迭代 visibleChildren 无条件下钻 |
| `accessibilityActionNames` | 0x1dbbcf270 | `@[@"AXScrollToVisible"]`（常量 `NSAccessibilityScrollToVisibleAction` 仅 macOS 26+，用字面量保 macOS 11 目标） | `@[]` |
| `_siblingInDirection:item:` | 0x1dbbcfec8 | `isKindOf:UXCollectionViewCell` → `indexPathForCell:` → layout 几何导航 `indexPathOfItem{Before(0),After(1),Above(2),Below(3)}:` → `cellForItemAtIndexPath:` 按 `isAccessibilityElement` 过滤；**末尾 `[item isEqual:result]` 则归 nil** | 数组索引导航；above/below 误映射 0/1 |
| `accessibilityPerformScrollToVisible` | 0x1dbbcf0bc | 优先该 section 首个 visible item（`indexPathsForVisibleItemsInSections:`.firstObject），否则 `numberOfItemsInSection:>0` 时 item 0，否则 nil；`scrollToItemAtIndexPath:atScrollPosition:64 animated:YES`；恒返回 YES | `scrollToItemsAtIndexPaths:scrollPosition:Top` 固定 item 0 |

#### Section 排序 comparator（block_invoke 0x1dbbcf894）
按 frame 中点分桶排序——`midY=(NSUInteger)(origin.y+size.height*0.5)/10` 主键升序；同桶 `midX=(NSUInteger)(origin.x+size.width*0.5)/10` 次键升序。即阅读顺序（上→下、左→右），10pt 容差。

---

## 3. 支撑方法存在性（UXKit ↔ OpenUXKit）

新调用的支撑方法在 OpenUXKit 侧均已声明，无需新增主类 API：

| 方法 | OpenUXKit 声明位置 |
|---|---|
| `numberOfItemsInSection:` / `indexPathForCell:` / `indexPathForSupplementaryView:` / `indexPathsForVisibleItemsInSections:` / `visibleSupplementaryViews` / `cellForItemAtIndexPath:` / `numberOfSections` | `UXCollectionView.h` / `+Internal.h` |
| `scrollToItemAtIndexPath:atScrollPosition:animated:` | `UXCollectionView.h:140`（position 64 沿用 P6 reusable view 的 `(UXCollectionViewScrollPosition)64` "nearest" SPI 模式） |
| `indexPathOfItem{Above,Below,Before,After}:` | `UXCollectionViewLayout.h:63-66` |

跨类调用经 `NSObject (…SPI)` category 前向声明（collectionView 为前向声明类型，故仍以 respondsToSelector / 直接 SPI 调用）。

---

## 4. P9d / P10b 余量（不在本 phase）

P11 收尾后,UXCollectionView 家族剩余未对齐项：**P9d**（动画式跨布局 transition 主链、mouse/keyboard 事件路由 4 分支细化、reuse-pool 专项测试）、**P10b**（NSDraggingSession 完整重写,需交互拖放验证）。两者均非纯反编译可收尾,留待后续。
