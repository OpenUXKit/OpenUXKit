# P5 阶段反编译笔记：UXCollectionViewData 数据缓存子系统对齐

> P5 phase — verify `UXCollectionViewData`（S3a 子系统）的 ivar 布局、4 bit flag 状态机与全部 51 个方法的算法对齐 UXKit 26.4。
>
> **结论**：OpenUXKit 此前的实现只对齐了「计数 / flag 状态机 / 基础缓存」骨架，**整个 screen-page 分页缓存子系统是缺失的**——`_screenPageMap` 的 key/value 语义、`__pageDimension` 全局、`validateLayoutInRect:` 的页对齐滑动窗口 + 5 页淘汰、`layoutAttributesForElementsInRect:` 的页索引聚合 + zIndex 排序全部与 UXKit 不同。本阶段共发现 **19 处偏差，修复 16 处**，保留 3 处（OpenUXKit 防御性增强 / ObjC ARC 桥接限制），全部记录如下。
>
> **P5 阶段代码改动**（`git show --stat c1c0208` 核对）：6 个文件，+703 / -138 行。
> - `Sources/OpenUXKit/Components/Private/UXCollectionViewData.m`：+634/-138 中的主体（重写）
> - `Sources/OpenUXKit/Components/Private/UXCollectionViewData.h`：4 行（`invalidateSupplementaryViews:` 签名）
> - `Sources/OpenUXKit/Components/Private/UXCollectionViewData+Internal.h`：新增 38 行
> - `Sources/OpenUXKit/PrivateHeaders/OpenUXKit/UXCollectionViewData+Internal.h`：新增 symlink
> - `Tests/.../FlowLayoutGeometryTests.swift`：+155 行（启用 P4 遗留的 4 个几何测试）
> - `Tests/.../UXCollectionViewFlowLayoutFixture.swift`：+9 行（接线 layout 属性）

---

## 1. ivar 矩阵（P5 冻结）

来源：导出头 `/Volumes/RE/Dyld-Shared-Cache/macOS/26.4/UXKit/ObjCHeaders/UXCollectionViewData.h` + `initWithCollectionView:layout:` (0x1dbbc4bbc) / `dealloc` (0x1dbbc4b04) 反编译。

| UXKit offset | UXKit ivar | OpenUXKit ivar | 对齐 |
|---|---|---|---|
| 8 | `_collectionView`（assign，不 retain） | `__unsafe_unretained` | ✅ |
| 16 | `_layout`（retain） | strong | ✅ |
| 24 | `_screenPageMap`（NSMapTable，key=1282 / value=0） | **已修复**：key `IntegerPersonality\|OpaqueMemory` (1282)，value `ObjectPersonality\|StrongMemory` (0) | ✅ |
| 32 | `_globalItems`（`id *` C 数组，存 attrs **copy**） | `__strong id *` | ✅ |
| 40 | `_supplementaryLayoutAttributes`（kind→{indexPath→attrs}） | 同 | ✅ |
| 48 | `_decorationLayoutAttributes` | 同 | ✅ |
| 56 | `_invalidatedSupplementaryViews`（kind→NSArray<NSIndexPath*>） | **已修复**（原为 kind→NSMutableSet） | ✅ |
| 64-95 | `_validLayoutRect`（CGRect） | 同 | ✅ |
| 96 | `_numItems` | 同 | ✅ |
| 104 | `_numSections` | 同 | ✅ |
| 112 | `_sectionItemCounts`（`NSInteger *` C 数组） | 同 | ✅ |
| 120 | `_lastSectionTestedForNumberOfItemsBeforeSection`（init = NSNotFound） | 同 | ✅ |
| 128 | `_lastResultForNumberOfItemsBeforeSection`（**init = 0**，xmmword_1DBC16CB0 = {0x7FFF…, 0x0}） | **已修复**（原 init NSNotFound） | ✅ |
| 136-151 | `_contentSize`（CGSize） | 同 | ✅ |
| 152 | `_collectionViewDataFlags`（4 bit 位段） | `uint8_t` | ✅ |
| 160 | `_clonedLayoutAttributes`（NSMutableArray） | 同 | ✅ |

### 1.1 `_collectionViewDataFlags` 4 bit 状态机（已全部 verify）

| Bit mask | UXKit 含义 | OpenUXKit 命名 | 读/写点一致性 |
|---|---|---|---|
| `0x1` (bit 0) | `contentSizeIsValid` | `UXCollectionViewDataFlagContentSizeValid` | ✅ 置位：`_validateContentSize`；清位：`invalidate:`（mask 0xF0/0xF2 均清）、**`validateLayoutInRect:` 的 load block 末尾**（P5 新发现并补齐） |
| `0x2` (bit 1) | `itemCountsAreValid` | `UXCollectionViewDataFlagItemCountsValid` | ✅ 置位：`_updateItemCounts`；清位：`invalidate:NO`（0xF0）；`invalidate:YES`（0xF2）保留 |
| `0x4` (bit 2) | `layoutIsPrepared` | `UXCollectionViewDataFlagLayoutPrepared` | ✅ 置位：`_prepareToLoadData`；清位：`invalidate:` |
| `0x8` (bit 3) | `layoutLocked` | `UXCollectionViewDataFlagLayoutLocked` | ✅ 读位点 9 处全部对齐（见 §2 各方法行）；写位仅 `setLayoutLocked:` |

### 1.2 `__pageDimension` 全局 + `+initialize`（P5 新增）

UXKit `+initialize` (0x1dbbc4ca4)：`__pageDimension = CGRectGetHeight(NSScreen.mainScreen.frame)`，为 0 时 `NSLog(@"Incorrect screen size for %@ in UXCollectionViewData")` 并 fallback `1024.0`。OpenUXKit 原先完全没有此机制，已按 1:1 补齐（静态 `UXCollectionViewDataPageDimension`）。

### 1.3 screen-page key 公式（P5 新增）

`_screenPageForPoint:` (0x1dbbc4168)：`key = ~((uint16)(point.y / dim) | ((uint16)(point.x / dim) << 16))`。取反保证 key 永不为 0（NSMapTable 不允许 NULL key）。value 为该页注册的 global item index 的 `NSMutableIndexSet`。页 rect 与 `_validLayoutRect` 不相交时返回 nil（不创建）。OpenUXKit 原实现（documentVisibleRect 页尺寸 + NSValue key/value 缓存 NSPoint）与 UXKit 完全无关，已整体重写。

---

## 2. 方法算法对照（51 个函数全部反编译）

| 方法 | 地址 | UXKit 关键算法 | OpenUXKit 修复前 | 对齐 |
|---|---|---|---|---|
| `+initialize` | 0x1dbbc4ca4 | `__pageDimension` = 主屏高度，fallback 1024 + NSLog | 缺失 | ✅ 已补 |
| `initWithCollectionView:layout:` | 0x1dbbc4bbc | map table 选项 1282/0；`_lastResult…` 初值 0 | key/value 选项均 0；lastResult=NSNotFound | ✅ 已修 |
| `dealloc` | 0x1dbbc4b04 | release 全部对象 ivar + free 2 个 C 数组 | ARC 等价 | ✅ |
| `_validateItemCounts` | 0x1dbbc43f4 | `!(flags & 2)` → `_updateItemCounts` | 同 | ✅ |
| `_updateItemCounts` | 0x1dbbc4404 | 释放 globalItems 旧项 → dataSource 计数 → realloc `_sectionItemCounts` → 负数 assert(line 226) 后钳 0 → realloc+bzero `_globalItems`（仅 numItems>0）→ flags\|=2 → 重置 cache 对 {NSNotFound, 0} | lastResult 重置成 NSNotFound | ✅ 已修 |
| `_validateContentSize` | 0x1dbbc4378 | `!(flags&1)` → locked assert(line 253) → `layout.collectionViewContentSize` → flags\|=1 | NSAssert 风格 | ✅（统一为 NSAssertionHandler + UXKit 行号） |
| `_prepareToLoadData` | 0x1dbbc42e8 | `!(flags&4)` → locked assert(line 262) → prepareLayout → flags\|=4 → validate counts → validate contentSize | 同 | ✅ |
| `numberOfSections` / `numberOfItems` | 0x1dbbc2dc8 / 2da0 | validate + 返回 ivar | 同 | ✅ |
| `numberOfItemsInSection:` | 0x1dbbc2d14 | assert(line 529)；UXKit assert 后**仍读数组**（潜在 OOB） | OpenUXKit assert 后 return 0 | 🟢 保留防御性 return（见 §5-K1） |
| `numberOfItemsBeforeSection:` | 0x1dbbc2c50 | `lastTested <= section` 用缓存续算，否则从 0 起；assert(line 537) | 多一个 `!= NSNotFound` 判断（等价） | ✅ 已简化为 UXKit 形式 |
| `globalIndexForItemAtIndexPath:` | 0x1dbbc2bc8 | section/item 越界 → NSNotFound | 同 | ✅ |
| `indexPathForItemAtGlobalIndex:` | 0x1dbbc2ac8 | 逐 section 递减；assert(line 627) ×2 | 同 | ✅ |
| `collectionViewContentRect` | 0x1dbbc2a60 | **`_prepareToLoadData`** + {0,0,contentSize} | 仅 `_validateContentSize` | ✅ 已修 |
| `rectForItemAtIndexPath:` | 0x1dbbc2a94 | attrs nil → **CGRectNull** | `[nil frame]` = CGRectZero | ✅ 已修 |
| `rectForGlobalItemIndex:` | 0x1dbbc2a24 | indexPath → `rectForItemAtIndexPath:` | 走 layoutAttributesForGlobalItemIndex | ✅ 已修（调用链一致） |
| `rectForSupplementaryElementOfKind:atIndexPath:` | 0x1dbbc2944 | `length != 1 && section >= _numSections` → assert(line 655)；nil → CGRectNull | 无 assert；CGRectZero | ✅ 已修 |
| `rectForDecorationElementOfKind:atIndexPath:` | 0x1dbbc2864 | 同上 assert(line 667) | 同上 | ✅ 已修 |
| `layoutAttributesForItemAtIndexPath:` | 0x1dbbc27d0 | cache miss 时：**locked → `initialLayoutAttributesForAppearingItemAtIndexPath:`**，否则常规；随后 `_setLayoutAttributes:` | 无 locked 分支 | ✅ 已修 |
| `layoutAttributesForGlobalItemIndex:` | 0x1dbbc2794 | indexPath → item 查询 | 同 | ✅ |
| `_setLayoutAttributes:atGlobalItemIndex:` | 0x1dbbc3f10 | assert(line 308) 非法 index；同对象跳过；**存 `[attrs copy]`**；按 frame 以 `__pageDimension` 步长把 globalIndex 注册进所有覆盖页（内部点 + 每列底边 + 右下角，边界取 max-1.0） | 直接存引用、无 copy、无页注册、无 assert | ✅ 已修 |
| `layoutAttributesForElementsInRect:` | 0x1dbbc1cf0 | `validateLayoutInRect:` → 扫描 rect 覆盖页聚合 `NSMutableIndexSet`（do/while 各超扫一页）→ `_globalItems[idx]` frame 相交过滤 → supplementary/decoration 缓存遍历（`isFloating` 用 `documentView convertRect:fromView:` + contentInsets (left, top) 偏移）→ **zIndex→section→item 三级排序** | 直接透传 `[_layout layoutAttributesForElementsInRect:]` | ✅ 已重写 |
| `layoutAttributesForElementsInSection:` | 0x1dbbc2400 | items 逐个查询 + supplementary **和 decoration** 两字典按 key 过滤（length≥2 && section==） | 缺 decoration | ✅ 已修 |
| `layoutAttributesForSupplementaryElementOfKind:atIndexPath:` | 0x1dbbc1384 | **`section >= _numSections` → 删缓存项 + return nil**；miss 时 locked → `initial…Supplementary…`；缓存 | 两分支都缺 | ✅ 已修 |
| `layoutAttributesForDecorationViewOfKind:atIndexPath:` | 0x1dbbc12cc | miss 时 locked → `initial…Decoration…` | 缺 locked 分支 | ✅ 已修 |
| `existingSupplementaryLayoutAttributes` | 0x1dbbc154c | supplementary **+ decoration** 全部 values | 仅 supplementary | ✅ 已修 |
| `existingSupplementaryLayoutAttributesWithMinimalIndexPathLength:` | 0x1dbbc16f8 | 双字典，按 **value.indexPath.length** 过滤 | 仅 supplementary、按 key 过滤 | ✅ 已修 |
| `existingSupplementaryLayoutAttributesInSection:` | 0x1dbbc19d8 | 双字典，value.indexPath `section== && length>=2` | 仅 supplementary | ✅ 已修 |
| `knownSupplementaryElementKinds` | 0x1dbbc14ac | **supplementary ∪ decoration keys** | 仅 supplementary | ✅ 已修 |
| `knownDecorationElementKinds` | 0x1dbbc1468 | decoration keys | 同 | ✅ |
| `validateLayoutInRect:` | 0x1dbbc2df0 (0x6a4) | 见 §3 | 朴素「未包含则整块加载 + union」 | ✅ 已重写 |
| `validateSupplementaryViews` | 0x1dbbc4638 | **locked 守卫**；对每个 kind/indexPath：先 `removeObjectForKey:` 再走缓存查询方法重建；最后置 nil | 无守卫、直查 `_layout` 不删旧项 | ✅ 已修 |
| `invalidate:` | 0x1dbbc45b4 | locked 守卫；mask 0xF2/0xF0；`_validLayoutRect = CGRectNull`；清两字典 + invalidated + pageMap | 同 | ✅（原已对齐） |
| `invalidateSupplementaryViews:` | 0x1dbbc4800 | **参数是 NSDictionary<kind, NSArray<indexPath>>**；locked 守卫；已有 pending 字典则按 kind 集合并集合并，否则 `initWithDictionary:` 浅拷贝 | 参数是 NSSet<kind>，立即把现缓存搬进 pending | ✅ 已修（签名+算法，与 `UXCollectionViewLayoutInvalidationContext._invalidatedSupplementaryViews` 的 P2 合同吻合） |
| `_loadEverything` | 0x1dbbc39a8 | `_prepareToLoadData` → 建 UIMutableIndexPath{0,0} → 仅填 `_globalItems` 空槽（locked assert line 336；`_setupMutableIndexPath:` + layout 查询 + `_setLayoutAttributes:`）→ **`_validLayoutRect = collectionViewContentRect`** | 按 section/item 全量走高层查询；不设 validLayoutRect | ✅ 已修 |
| `_screenPageForPoint:` | 0x1dbbc4168 | 见 §1.3 | NSValue 缓存（完全无关） | ✅ 已重写 |
| `_setupMutableIndexPath:forGlobalItemIndex:` | 0x1dbbc4220 | 累加 `_sectionItemCounts` 求 (section, item)，写入 `id *` 出参；越界则**不动出参**静默返回 | 经 `indexPathForItemAtGlobalIndex:`（越界会 assert）+ 拷贝 helper | ✅ 已修（桥接见 §6.3） |
| `description` | 0x1dbbc496c | items/sections/itemsCounts + 4 个 flag 名拼接 | 缺失 | ✅ 已补 |
| `clonedLayoutAttributes` / `layoutIsPrepared` / `isLayoutLocked` / `setLayoutLocked:` | 0x1dbbc128c-12c0 | 直读/写 ivar/bit | 同 | ✅ |

---

## 3. `validateLayoutInRect:` 滑动窗口算法（P5 核心产出）

UXKit 0x1dbbc2df0 + 2 个 block（0x1dbbc3494 load / 0x1dbbc37e8 pageAlign）：

```
1. _prepareToLoadData
2. if (_invalidatedSupplementaryViews) validateSupplementaryViews
3. _validateContentSize
4. clipped = CGRectIntersection({0,0,contentSize}, rect)
   if (clipped == CGRectZero || CGRectContainsRect(_validLayoutRect, clipped)) return
5. [_clonedLayoutAttributes removeAllObjects]
6. aligned = pageAlign(rect)        # origin 向下取页边界、size 向上取整页、maxX/maxY 钳到 contentSize
7. if ((rect.width == valid.width && rect.minX == valid.minX) ||
       (rect.height == valid.height && rect.minY == valid.minY)):     # 沿轴滑动
     if (valid.minX == rect.minX):                                    # 纵向
       if (valid.minY <= rect.minY):   # 向下滚
         overlap = valid.maxY - aligned.minY
         if overlap >= 0: aligned.y += overlap; aligned.height -= overlap
         if valid.height > 5*pageDim: valid.y += pageDim; valid.height -= pageDim   # 淘汰顶页
       else:                           # 向上滚
         overlap = aligned.maxY - valid.minY
         if overlap >= 0: aligned.height -= overlap
         if valid.height > 5*pageDim: valid.height -= pageDim                       # 淘汰底页
     else: （横向对称，x/width）
     reAligned = pageAlign(aligned)
     if !empty(reAligned):
       valid = (overlap >= 0) ? union(valid, reAligned) : reAligned   # 不连续跳页则重置窗口
       loadBlock(reAligned)
   else:                                                              # 全新窗口
     valid = aligned; loadBlock(aligned)
8. 遍历 _screenPageMap copy 的 keys，从 key 反解页 rect，与 valid 不相交者删除
```

**loadBlock**（line 367 locked assert）：`[_layout layoutAttributesForElementsInRect:]` 逐项分发——`_isClone` → `_clonedLayoutAttributes`；`_isCell` → 越界 assert(line 379，UXKit 原文带 "UICollectionView recieved…" 拼写错误，已原样保留) + `_setLayoutAttributes:`；否则按 `_isDecorationView` 选字典，已存在且不相等 → assert(line 390)，kind 为 nil → assert(line 393)；**结尾 `flags &= ~1`（清 contentSizeIsValid）**。

**反汇编修正**：pageAlign block 的 Hex-Rays 伪代码显示高度钳制结果被丢弃，但 0x1dbbc395c 处 `FSUB D9, D9, D0` 证明 height 与 width 一样被钳制——OpenUXKit 实现两轴都钳。

---

## 4. P5 已修复的偏差清单（16 处）

| ID | 偏差 | 决策 |
|---|---|---|
| **D1** | `_screenPageMap` pointer functions（1282/0 vs 0/0）+ key/value 语义 | ✅ 重写 |
| **D2** | `__pageDimension` 全局与 `+initialize` 缺失 | ✅ 补齐 |
| **D3** | `_setLayoutAttributes:` 无 copy / 无页注册 / 无 assert | ✅ 重写 |
| **D4** | `_loadEverything` 不走 global-index 空槽路径、不设 `_validLayoutRect` | ✅ 重写 |
| **D5** | `_setupMutableIndexPath:forGlobalItemIndex:` 走高层查询、越界行为不同 | ✅ 重写（见 §6.3） |
| **D6** | `layoutAttributesForItemAtIndexPath:` 缺 layoutLocked → initial 分支 | ✅ 补齐 |
| **D7** | `layoutAttributesForSupplementaryElementOfKind:` 缺 section 越界删缓存 + locked 分支 | ✅ 补齐 |
| **D8** | `layoutAttributesForDecorationViewOfKind:` 缺 locked 分支 | ✅ 补齐 |
| **D9** | `layoutAttributesForElementsInRect:` 透传 layout（无页缓存/无排序/无 floating 转换） | ✅ 重写 |
| **D10** | `validateLayoutInRect:` 无页对齐滑动窗口 / 5 页淘汰 / clone 收集 / 页修剪 / 清 contentSizeIsValid | ✅ 重写 |
| **D11** | `validateSupplementaryViews` 无 locked 守卫、直查 layout 不删旧项 | ✅ 重写 |
| **D12** | `invalidateSupplementaryViews:` 参数契约（NSSet vs NSDictionary）与合并算法 | ✅ 重写（无现存调用方，P9 接线主类时直接用新契约） |
| **D13** | `existingSupplementaryLayoutAttributes*` 3 个方法不含 decoration 缓存 | ✅ 补齐 |
| **D14** | `knownSupplementaryElementKinds` 不并集 decoration keys | ✅ 补齐 |
| **D15** | `rectFor*` 4 个方法返回 CGRectZero 而非 CGRectNull、缺 2 处 assert | ✅ 修复 |
| **D16** | `collectionViewContentRect` 走 `_validateContentSize` 而非 `_prepareToLoadData`；`_lastResultForNumberOfItemsBeforeSection` 初值/重置应为 0；`description` 缺失 | ✅ 修复/补齐 |

---

## 5. P5 保留的偏差（3 处）

| ID | 偏差 | 处理决策 |
|---|---|---|
| **K1** | `numberOfItemsInSection:` / `numberOfItemsBeforeSection:` UXKit assert 后继续执行（越界时读 `_sectionItemCounts` 出界）；OpenUXKit assert 后 `return 0` | 保留防御性 return：默认 NSAssertionHandler 会抛异常，两者行为一致；仅在自定义 handler 吞掉断言时 OpenUXKit 不做 OOB 读。故意不复刻未定义行为。 |
| **K2** | `layoutAttributesForElementsInRect:` 中 `addIndexes:` 入参 UXKit 不判 nil（`objectForKey:` 直接传入）；OpenUXKit 加了 nil 检查 | 保留：`-[NSMutableIndexSet addIndexes:nil]` 在 Foundation 上会抛 NSInvalidArgumentException，UXKit 依赖「页 miss 时刚好不 crash」的运气路径无法照搬；nil 检查语义等价。 |
| **K3** | CGRect 哨兵常量（`MEMORY[0x1E5541B48/B60]`）在 .i64 中 GOT 槽未绑定，无法直接确认符号名 | 依据 UIKit `UICollectionViewData` 同源实现推定 B60=CGRectNull（`invalidate:` 设 `_validLayoutRect`、`rectFor*` fallback）、B48=CGRectZero（clipped 空判定）。若后续 lldb 实测推翻，只需改 2 个常量。 |

---

## 6. 关键发现

### 6.1 screen-page 缓存是 Data 子系统的「第二半」

UXKit 的 `UXCollectionViewData` 不只是计数缓存：`_globalItems` + `_screenPageMap` + `_validLayoutRect` + `__pageDimension` 构成一个以「屏幕高度为页」的二维分页索引。`layoutAttributesForElementsInRect:` 完全从这个索引出，而不是每次转发 layout——这是 UXKit 滚动性能模型的核心（P9 主类的 `_updateVisibleCellsNow:` 依赖它返回排好序的缓存副本）。

### 6.2 `_globalItems` 存的是 copy

`_setLayoutAttributes:atGlobalItemIndex:` 存 `[attrs copy]`，意味着 Data 缓存与 layout 返回的对象**解耦**：layout 之后改自己的 attrs 不影响缓存。P6（ReusableView `_setBaseLayoutAttributes:`）和 P9（visible cells diff）做对照时要记住缓存对象与 layout 对象不是同一实例（`isEqual:` 比较，line 390 的 assert 正是为此存在）。

### 6.3 `UIMutableIndexPath` 桥接策略（结论）

UXKit 内嵌私有类 `UIMutableIndexPath : NSIndexPath`（`_mutableIndexes` buffer @32 + `_locked` BOOL @40），通过 `+setIndex:atPosition:forIndexPath:` 以 `id *` 入参原地改写 index；`_locked == 1` 时先 copy 再改（写时复制，防止已被缓存引用的 indexPath 被改）。OpenUXKit **不复刻该 SPI**：
- 公开 Foundation 无法安全地原地改 NSIndexPath（tagged pointer / 单例缓存）；
- 性能敏感点只有 `_loadEverything` 的批量填充，一次 reload 量级为 O(numItems) 个 NSIndexPath 分配，可接受；
- 因此 `_setupMutableIndexPath:forGlobalItemIndex:` 维持 UXKit 的 `id *` 出参签名与「越界不动出参」语义，但内部用 `+[NSIndexPath indexPathForItem:inSection:]` 整体替换对象。此决策已记录在 `UXCollectionViewData+Internal.h` 注释中，P9 接线时无须特判。

### 6.4 `invalidateSupplementaryViews:` 的真实契约

参数是 `NSDictionary<kind, NSArray<NSIndexPath*>>`——与 P2 已对齐的 `UXCollectionViewLayoutInvalidationContext._invalidatedSupplementaryViews` 字典形状完全一致。UXKit 调用链是 主类 `_invalidateLayoutWithContext:` → `[data invalidateSupplementaryViews:context._invalidatedSupplementaryViews]` → 下次 `validateLayoutInRect:` 进门时 `validateSupplementaryViews` 重建。OpenUXKit 当前主类 `_invalidateLayoutWithContext:` 还是 `invalidate:NO` 一刀切（P9 范围），本阶段已把 Data 侧契约备好。

---

## 7. 遗留到后续 phase

| 项 | 所属 | 说明 |
|---|---|---|
| 主类 `_invalidateLayoutWithContext:` 应改为按 context 分流（`invalidateEverything` / `invalidateDataSourceCounts` / `_invalidatedSupplementaryViews` → `[data invalidateSupplementaryViews:]`），而非无条件 `invalidate:NO` | **P9** | `Sources/OpenUXKit/Components/Public/UXCollectionView.m:301`；需要先反编译主类同名方法 |
| `UXCollectionView.m:577` 的 `validateLayoutInRect:` + `layoutAttributesForElementsInRect:` 连续调用现在会重复 validate（幂等无害，但 UXKit 主类可能只调后者） | **P9** | 反编译主类 `_updateCellsInRect:` 后决定 |
| `_loadEverything` 在 OpenUXKit 内尚无调用方；UXKit 中由主类（推测 `reloadData` / 动画准备路径）经 selector 调用 | **P9** | 接线主类时启用 |
| `UXCollectionViewLayout.m:415/428` 经 `_currentUpdate` 调 `existingSupplementaryLayoutAttributesInSection:`，现在会额外拿到 decoration attrs（行为更接近 UXKit，`_finalizeCollectionViewItemAnimations` 即按 `_isDecorationView` 分流），P8 回归 batchUpdates 时确认 | **P8** | 已有分流代码，预期无需改动 |
| CGRect 哨兵常量实测（K3） | **P9 验收** | lldb attach 真 UXKit 验证 B48/B60 |

---

## 8. 测试

- 启用 P4 遗留的 4 个 `FlowLayoutGeometryTests`（vertical / horizontal / mixed-size / multi-metrics），全部以**手推期望值**直接通过（坐标全为整数，规避 `_AdjustToScale` 的 scale 依赖）：
  - vertical：6+4 wrap、justified 4pt gap、last-row 同网格
  - horizontal：9+1 列 wrap、contentSize (100, 450)
  - mixed-size：行高取 max、垂直居中（alignment 1）、justified 15pt gap
  - multi-metrics：双 section 各自 inset、header/footer frame 与 section 堆叠偏移、contentSize (320, 240)
- 几何测试经由 `layout.layoutAttributesForElements(in:)`（FlowLayout 直查路径）；Data 的页缓存路径由主类驱动，留待 P9 的 L2 集成测试覆盖。
- `swift build`：0 errors / 0 warnings；`swift test`：26 个用例 0 failures（5 实跑通过，21 个后续 phase 的 stub 维持 skip）；`xcodebuild OpenUXKit-Example-Swift Debug build`：成功（1 个历史 storyboard warning，与 P5 无关）。

---

## 9. P5 阶段 9 步工作流执行记录

| 步骤 | 执行情况 |
|---|---|
| **D** (Dump) | ✅ `list_funcs *UXCollectionViewData*` 枚举 51 个函数（45 方法 + 6 block）；同步读导出头 |
| **A** (Abstract ivars) | ✅ 16 个 ivar 偏移矩阵 + 4 bit flag 全部读写点 verify；`xmmword_1DBC16CB0` 取值实测（{NSNotFound, 0}） |
| **M** (Method mapping) | ✅ 51 个函数全部反编译；pageAlign block 反汇编二次校验（伪代码丢失 height 钳制） |
| **C** (Compare) | ✅ 逐方法对照，发现 19 处偏差 |
| **B** (Bridge inventory) | ✅ rg 全仓调用面：`layoutAttributesForElementsInRect:`（主类 5 处 + Layout 1 处）、`existingSupplementaryLayoutAttributesInSection:`（Layout 2 处）、`invalidateSupplementaryViews:`（无调用方）、`_screenPageForPoint:`（类内）；确认签名变更零破坏 |
| **R** (Rewrite) | ✅ 修复 16 处；保留 3 处（防御性 / 桥接限制 / 符号未绑定）；新增 `UXCollectionViewData+Internal.h` + symlink |
| **V** (Verify) | ✅ build / test / Example xcodebuild 全绿；4 个几何测试首跑即过 |
| **G** (Git checkpoint) | ✅ `c1c0208` code；docs commit 见本笔记提交 |
| **L** (Log learnings) | ✅ 本笔记 |
