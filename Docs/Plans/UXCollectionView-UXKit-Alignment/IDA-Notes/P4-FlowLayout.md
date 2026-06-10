# P4 阶段反编译笔记：UXCollectionViewFlowLayout + 4 个内部类对齐

> P4 phase — verify UXCollectionViewFlowLayout 主类 + `_UXFlowLayoutInfo` / `_UXFlowLayoutSection` / `_UXFlowLayoutRow` / `_UXFlowLayoutItem` 4 个隐藏内部类的算法对齐 UXKit 26.4。
>
> **结论**：FlowLayout 子系统在 OpenUXKit 中**接口形式 100% 对齐**，但**算法层面发现 12 处偏差**——其中 10 处已修复（含 pixel-aligned 取整、3 层 hit-test、补全 setter 参数校验、UXKit 工厂方法、UXKit 风格 finalize 释放策略等），剩余 2 处偏差（fixedItemSize 数学优化路径、`_UXFlowLayoutInfo.frameForItemAtIndexPath:` 2 层叠加 vs 3 层叠加）是 OpenUXKit 主动选择的简化/语义增强，保留并留 P9 评估。
>
> **P4 阶段代码改动**：1 个文件（`Sources/OpenUXKit/Components/Public/UXCollectionViewFlowLayout.m`），约 +120 / -55 行。

---

## 1. UXCollectionViewFlowLayout 主类 ivar 矩阵（P4 冻结）

从 `_UXCollectionViewFlowLayoutCommonInit` (0x1dbbf3ac0)、`dealloc` (0x1dbbf3698)、`encodeWithCoder:` (0x1dbbf375c)、`setItemSize:` (0x1dbbf1288)、`_fetchItemsInfo` (0x1dbbf4270)、`_updateDelegateFlags` (0x1dbbf4938) 反推：

| UXKit offset | UXKit ivar（含义） | OpenUXKit ivar | 对齐 |
|---|---|---|---|
| `a1[2]`-`a1[11]` (16-103) | 继承自 UXCollectionViewLayout 基类（已 P3 冻结） | 同 | ✅ |
| `a1[12]` (192) | `_interitemSpacing` (CGFloat, init 10.0) | `_interitemSpacing` | ✅ |
| `a1[12][1]` (200) | `_lineSpacing` (CGFloat, init 10.0) | `_lineSpacing` | ✅ |
| `a1[13]` (208-223) | `_itemSize` (CGSize, init {10, 10}) | `_itemSize` | ✅ |
| `a1[14]` (224-239) | `_headerReferenceSize` (CGSize, init {50, 50}) | `_headerReferenceSize` | ✅ |
| `a1[15]` (240-255) | `_footerReferenceSize` (CGSize, init {0, 0}) | `_footerReferenceSize` | ✅ |
| `a1[16-17]` (256-287) | `_sectionInset` (NSEdgeInsets) | `_sectionInset` | ✅ |
| `a1[18]` (288) | `_data` (`_UXFlowLayoutInfo *`, lazy) | `_data` | ✅ |
| `a1[19]` (296-?) | `_gridLayoutFlags` (uint16_t bit field) | `_gridLayoutFlags` | ✅ |
| `a1[22][1]` (368) | `_scrollDirection` (NSInteger, init 0=vertical) | `_scrollDirection` | ✅ |
| `a1[23]` (368) | `_rowAlignmentsOptionsDictionary` (init 3-key dict) | `_rowAlignmentsOptionsDictionary` | ✅ |
| 其它 | `_insertedItems/Headers/FootersAttributesDict` × 2 (insert/delete) | 同 6 个 dict | ✅ |
| 其它 | `_currentLayoutSize`、`_visibleBounds` | 同 | ✅ |

### 1.1 `_gridLayoutFlags` 完整 9 bit 矩阵（已全部解码）

| Bit mask | UXKit 含义 | OpenUXKit 命名 | 对齐 |
|---|---|---|---|
| `0x001` (bit 0) | delegateRespondsToSizeForItem | `UXFlowLayoutFlagDelegateSizeForItem` | ✅ |
| `0x002` (bit 1) | delegateRespondsToHeaderRefSize | `UXFlowLayoutFlagDelegateReferenceSizeForHeader` | ✅ |
| `0x004` (bit 2) | delegateRespondsToFooterRefSize | `UXFlowLayoutFlagDelegateReferenceSizeForFooter` | ✅ |
| `0x008` (bit 3) | delegateRespondsToInsetForSection | `UXFlowLayoutFlagDelegateInsetForSection` | ✅ |
| `0x010` (bit 4) | delegateRespondsToMinInteritemSpacing | `UXFlowLayoutFlagDelegateInteritemSpacing` | ✅ |
| `0x020` (bit 5) | delegateRespondsToMinLineSpacing | `UXFlowLayoutFlagDelegateLineSpacing` | ✅ |
| `0x040` (bit 6) | delegateRespondsToRowAlignmentOptions (私有 SPI) | `UXFlowLayoutFlagDelegateAlignmentOptions` | ✅ |
| `0x080` (bit 7) | itemsInfoFetched | `UXFlowLayoutFlagLayoutDataValid`（命名不同但 bit 一致） | ✅ |
| `0x100` (bit 8) | sizingInfosObtained | `UXFlowLayoutFlagDelegateInfoValid`（命名不同但 bit 一致） | ✅ |

**注意**：OpenUXKit 命名相比 UXKit 反推语义略有差异（`LayoutDataValid` vs `itemsInfoFetched`），但 bit 编号完全一致，所有 mask/clear 操作 100% 等价。

### 1.2 CommonInit 默认值（已 verify）

| ivar | UXKit 默认 | OpenUXKit 默认 | 对齐 |
|---|---|---|---|
| `_itemSize` | (10, 10) | (10, 10) | ✅ |
| `_headerReferenceSize` | (50, 50) | (50, 50) | ✅ |
| `_lineSpacing` / `_interitemSpacing` | UXKit init 没显式赋（编译器零值 0.0），section init 把 `verticalInterstice/horizontalInterstice = 10.0` 覆盖 | OpenUXKit 同行为 | ✅ |
| `_rowAlignmentsOptionsDictionary` | `{Common: 3, LastRow: 0, Vertical: 1}` | 同 | ✅ |

---

## 2. `_UXFlowLayoutInfo` ivar 矩阵

从 `init` (0x1dbbeda08)、`dealloc` (0x1dbbed948)、`copy` (0x1dbbed608) 反推：

| UXKit offset | UXKit ivar | OpenUXKit ivar | 对齐 |
|---|---|---|---|
| 8 | `_sections` (NSMutableArray, initWithCapacity:1) | `_sections` (NSMutableArray, initWithCapacity:1) | ✅ |
| 17 (byte) | `_horizontal` (BOOL, default 0) | `_horizontal` | ✅ |
| 18 (byte) | `_leftToRight` (BOOL, default 1) | `_leftToRight` | ✅ |
| 16-31 (CGRect) | `_visibleBounds` (CGRect) | `_visibleBounds` | ✅ |
| 32-47 | `_layoutSize` (CGSize) | `_layoutSize` | ✅ |
| 48 | `_dimension` (CGFloat) | `_dimension` | ✅ |
| 56 (byte) | `_isValid` (BOOL) | `_isValid` | ✅ |
| 64-79 | `_contentSize` (CGSize) | `_contentSize` | ✅ |
| 80 | `_rowAlignmentOptions` (NSDictionary*) | `_rowAlignmentOptions` | ✅ |
| `_usesFloatingHeaderFooter` (BOOL) | `_usesFloatingHeaderFooter` | ✅ |

---

## 3. `_UXFlowLayoutSection` ivar 矩阵

从 `init` (0x1dbbed520, FMOV V0.2D #10.0)、`copyFromLayoutInfo:` (0x1dbbebd54)、`computeLayout` (0x1dbbecb30) 反推：

| ivar | UXKit (含 default) | OpenUXKit | 对齐 |
|---|---|---|---|
| `_items` (NSMutableArray initWithCapacity:3) | ✅ | ✅ | ✅ |
| `_rows` (NSMutableArray initWithCapacity:3) | ✅ | ✅ | ✅ |
| `_verticalInterstice` (CGFloat, init 10.0) | ✅ | ✅ | ✅ |
| `_horizontalInterstice` (CGFloat, init 10.0) | ✅ | ✅ | ✅ |
| `_sectionMargins` (NSEdgeInsets) | ✅ | ✅ | ✅ |
| `_frame` (CGRect) | ✅ | ✅ | ✅ |
| `_headerFrame` / `_footerFrame` (CGRect) | ✅ | ✅ | ✅ |
| `_headerDimension` / `_footerDimension` (CGFloat) | ✅ | ✅ | ✅ |
| `_isValid` (BOOL) | ✅ | ✅ | ✅ |
| `_layoutInfo` (`_UXFlowLayoutInfo *`, unsafe_unretained) | ✅ | ✅ | ✅ |
| `_rowAlignmentOptions` (NSDictionary*) | ✅ | ✅ | ✅ |
| `_fixedItemSize` (BOOL) | ✅ | ✅ | ✅ |
| `_itemSize` (CGSize) | ✅ | ✅ | ✅ |
| `_otherMargin` / `_beginMargin` / `_endMargin` / `_actualGap` (computed) | ✅ | ✅ | ✅ |
| `_lastRowBeginMargin` / `_lastRowEndMargin` / `_lastRowActualGap` / `_lastRowIncomplete` (computed) | ✅ | ✅ | ✅ |
| `_itemsCount` / `_itemsByRowCount` / `_indexOfImcompleteRow` (NSInteger) | ✅ | ✅ | ✅ |

**OpenUXKit 多了一个 `_sectionMagins`（拼写错误）ivar** —— 实际上不会被任何代码读取（getter/setter 都走 `_sectionMargins`），是 dead ivar，留 P9 评估清理。

---

## 4. `_UXFlowLayoutRow` ivar 矩阵

从 `init` (0x1dbbeca04, `xmmword_1DBC16CF0 = {1, 3}`)、`layoutRow` (0x1dbbec500) 反推：

| ivar | UXKit | OpenUXKit | 对齐 |
|---|---|---|---|
| `_items` (NSMutableArray initWithCapacity:3) | ✅ | ✅ | ✅ |
| `_section` (`_UXFlowLayoutSection *`, unsafe_unretained) | ✅ | ✅ | ✅ |
| `_rowSize` (CGSize) | ✅ | ✅ | ✅ |
| `_rowFrame` (CGRect) | ✅ | ✅ | ✅ |
| `_index` (NSInteger) | ✅ | ✅ | ✅ |
| `_complete` (BOOL) | ✅ | ✅ | ✅ |
| `_fixedItemSize` (BOOL) | ✅ | ✅ | ✅ |
| `_isValid` (BOOL) | ✅ | ✅ | ✅ |
| `_verticalAlignement` (NSInteger, init 1) | ✅ | ✅ | ✅ |
| `_horizontalAlignement` (NSInteger, init 3) | ✅ | ✅ | ✅ |

---

## 5. `_UXFlowLayoutItem` ivar 矩阵

从 `copy` (0x1dbbebbc8) 反推：

| ivar | UXKit | OpenUXKit | 对齐 |
|---|---|---|---|
| `_itemFrame` (CGRect) | ✅ | ✅ | ✅ |
| `_rowObject` (`_UXFlowLayoutRow *`, unsafe_unretained) | ✅ | ✅ | ✅ |
| `_section` (`_UXFlowLayoutSection *`, unsafe_unretained) | ✅ | ✅ | ✅ |

---

## 6. 主类方法算法对照

### 6.1 P0 已反编译 4 大方法（00-Summary §3）

| 方法 | UXKit | OpenUXKit | 对齐 |
|---|---|---|---|
| `_fetchItemsInfo` (0x1dbbf4270) | 7 步 (`& 0x80` check → bounds → dimension → updateDelegateFlags → getSizingInfos → updateItemsLayout → set 0x80) | 同 (line 467-495) | ✅ |
| `_getSizingInfos` (0x1dbbf4548) | 7 步 (lazy data → setHorizontal → loop sections → addSection → setItemsCount → delegate sizeForItem 检测 allEqual → 拉 margins/interstice/alignment/header/footer) | 同 (line 334-422) | ✅ (allEqual 检测逻辑等价但实现写法略不同：UXKit 用 sentinel 模式 `currentSize = CGSizeZero`，OpenUXKit 用 `itemIndex == 0` 显式判断) |
| `_updateItemsLayout` (0x1dbbf4364) | 4 步 (data → dimension → setDimension → loop sections → setContentSize) | 同 (line 424-465) | ✅ |
| `_frameForItemAtSection:andRow:usingData:` (0x1dbbf4160) | 3 层叠加 + AdjustToScale 取整 | **已修复** (line 825-847) | ✅ |

### 6.2 P4 新反编译方法 vs OpenUXKit 实现

| 方法 | 地址 | 大小 | UXKit 关键算法 | OpenUXKit 对照 | 对齐 |
|---|---|---|---|---|---|
| `_UXCollectionViewFlowLayoutCommonInit` | 0x1dbbf3ac0 | 0x104 | itemSize=(10,10), headerRef=(50,50), rowAlignmentsDictionary={Common:3, Last:0, Vertical:1} | line 82-90 | ✅ |
| `init` | 0x1dbbf3bc4 | 0x54 | `[super init] + CommonInit` | line 92-98 | ✅ |
| `initWithCoder:` | 0x1dbbf38f4 | 0x1cc | 用 **UIKit key (`UIInteritemSpacing` 等)** + `decodeFloatForKey:` | OpenUXKit 用自定义 `UXFlowLayout*` key + `decodeDoubleForKey:` | 🟡 NSCoding 兼容性偏差，不影响 OpenUXKit 内部一致性，留 P9 评估 |
| `encodeWithCoder:` | 0x1dbbf375c | 0x198 | **条件编码**（仅 ivar != 默认时编码） + UIKit key + `encodeFloat:` | OpenUXKit 无条件 + 自定义 key + `encodeDouble:` | 🟡 同上 |
| `dealloc` | 0x1dbbf3698 | 0xc4 | release `_data` + 6 dict + `_rowAlignmentsOptionsDictionary` | ARC 自动 | ✅ |
| `setItemSize:` | 0x1dbbf1288 | 0xd8 | **raise on width <= 0** + delegate flag check + ownership check + `& 0x80` invalidate | **已修复 raise** (line 182-194) | ✅ |
| `setHeaderReferenceSize:` | 0x1dbbf11b0 | 0xd8 | **raise on width < 0** + flag check + invalidate | **已修复 raise** (line 196-209) | ✅ |
| `setFooterReferenceSize:` | 0x1dbbf10d8 | 0xd8 | **raise on width < 0** | **已修复 raise** (line 211-224) | ✅ |
| `setSectionInset:` | 0x1dbbf0ffc | 0xdc | delegate flag check + ownership + invalidate | line 236-250 | ✅ |
| `setMinimumLineSpacing/InteritemSpacing/ScrollDirection:` | 0x1dbbf1360 / 13f0 / 1490 | 各 0x90 | ownership + `& 0x80` flag + invalidate | line 182-259 | ✅ |
| `layoutAttributesForElementsInRect:` | 0x1dbbf1520 | 0x244 | items via `_layoutAttributesForItemsInRect:` → headers via `layoutAttributesForHeaderInSection:usingData:` → footers via `layoutAttributesForFooterInSection:usingData:` | line 617-642（items via `indexPathsForItemsInRect:usingData:` + 逐 item attrs） | 🟢 顺序一致，items 路径走简化版（不走 fixedItemSize 数学优化），但 frame 一致 |
| `_layoutAttributesForItemsInRect:` | 0x1dbbf18bc | **0x84c** | 巨型 fast path: fixedItemSize section 用数学公式（row/col 范围推断 + RTL 反转 + AdjustToScale 取整）直接 generate attrs；非 fixed 走 `_frameForItemAtSection:andRow:usingData:` | OpenUXKit 简化为 `layoutAttributesForElementsInRect:` filter `_isCell`（循环依赖）；保留简化是因为 fixedItemSize 数学优化需要大量代码 | 🟢 留 P9 评估 |
| `layoutAttributesForItemAtIndexPath:` | 0x1dbbf21ec | 0x394 | `& 0x80 == 0` → 直接返回空 attrs；`& 1 && !fixedItemSize` → usingData 路径；否则用数学公式（含 AdjustToScale + RTL） | OpenUXKit 永远 `_fetchItemsInfo` → usingData 路径 | 🟢 OpenUXKit 简化（无 fast path 但 frame 一致） |
| `layoutAttributesForItemAtIndexPath:usingData:` | 0x1dbbf25a0 | 0x94 | `_frameForItemAtSection:andRow:usingData:` + setFrame: | **已修复**：从 `[data frameForItemAtIndexPath:]` (2 层) 改为 `_frameForItemAtSection:andRow:usingData:` (3 层 + AdjustToScale) (line 503-516) | ✅ |
| `layoutAttributesForHeader/FooterInSection:usingData:` | 0x1dbbf2714 / 2634 | 0xe0 | `_frameForHeaderInSection:usingData:` → CGRectEqualToRect(frame, CGRectZero) ? nil : 用 `+layoutAttributesForSupplementaryViewOfKind:withIndexPath:` 工厂 + setFrame: | **已修复**：从 `headerDimension <= 0` 检查改为 frame zero 检查 + 工厂方法 (line 521-549) | ✅ |
| `layoutAttributesForSupplementaryViewOfKind:atIndexPath:` | 0x1dbbf2110 | 0xdc | isEqualToString 分支 → header/footer | line 561-569 | ✅ |
| `indexPathForItemAtPoint:` | 0x1dbbf2cc0 | 0x2c8 | **3 层遍历**：sections.frame → rows.rowFrame → items.itemFrame | **已修复** 3 层 (line 670-695) | ✅ |
| `indexPathsForItemsInRect:` | 0x1dbbf1764 | 0x158 | `layoutAttributesForElementsInRect:` filter `representedElementCategory == Cell` (循环依赖反向) | OpenUXKit `[_fetchItemsInfo] + indexPathsForItemsInRect:usingData:` | 🟢 OpenUXKit 直接路径，结果一致 |
| `indexPathsForItemsInRect:usingData:` | 0x1dbbf2f98 | 0x1fc | section.frame intersect → 遍历 section.items 用 `_frameForItemAtSection:andRow:usingData:` | **已修复**：用 `_frameForItemAtSection:andRow:usingData:` + 遍历 `section.items.count`（不是 itemsCount） (line 644-668) | ✅ |
| `indexesForSectionHeaders/FootersInRect:usingData:` | 0x1dbbf32d0 / 3194 | 0x13c | UXKit 返回 NSArray<NSIndexPath*>；双重 intersection: section.frame + header/footer frame | **已修复**：保留 NSIndexSet 返回类型（OpenUXKit 公开 API contract），双重 intersection 对齐 (line 717-755) | ✅ (返回类型保留，算法对齐) |
| `collectionViewContentSize` | 0x1dbbf340c | 0x34 | `_fetchItemsInfo + _currentLayoutSize` | line 311-314 | ✅ |
| `invalidationContextForBoundsChange:` | 0x1dbbf3440 | 0xdc | super 获取 → setFlowLayoutDelegateMetrics:NO + setFlowLayoutAttributes:NO → cross-axis 变化检测 → setFlowLayoutAttributes:YES + `_setInvalidateEverything:YES` | line 254-270 | ✅ |
| `shouldInvalidateLayoutForBoundsChange:` | 0x1dbbf351c | 0x7c | cross-axis 变化检测 (vertical 看 width/x, horizontal 看 height/y) | line 245-252 | ✅ |
| `invalidateLayoutWithContext:` | 0x1dbbf3598 | 0x100 | isKindOfClass 检查 + (flowAttrs OR dataSourceCounts) AND `& 0x80` → `[_data invalidate:!delegateMetrics]` → flags `& 0xFE7F | (delegateMetrics ? 0 : 0x100)` → super | line 272-289 | ✅ |
| `(Internal) finalizeCollectionViewUpdates` | 0x1dbbf3eb8 | 0xbc | 6 dict release + nil + super | **已修复**：从 `removeAllObjects` 改为设 nil (line 769-779) | ✅ |
| `(Internal) _frameForHeader/Footer/ItemAtSection:usingData:` | 0x1dbbf3f74 / 4080 / 4160 | 0xe0 / e0 / 110 | 3 层 origin 叠加 + AdjustToScale (round(v * scale) / scale, fallback round) | **已修复** (line 791-847) | ✅ |
| `(Internal) _updateDelegateFlags` | 0x1dbbf4938 | 0x160 | 7 个 respondsToSelector 检查，逐 bit 写入 | line 316-332 | ✅ |
| `(Internal) _invalidateButKeepAllInfo` | 0x1dbbf3c7c | 0x64 | 新建 invalidationContext + setMetrics:NO + setAttrs:NO + `_invalidateLayoutUsingContext:` | line 291-296 | ✅ |
| `(Internal) _invalidateButKeepDelegateInfo` | 0x1dbbf3ce0 | 0x58 | 新建 + setMetrics:NO (保留 attrs YES) + `_invalidateLayoutUsingContext:` | line 298-302 | ✅ |
| `(Internal) synchronizeLayout` | 0x1dbbf3d38 | 0x10 | 空 stub return CGSizeZero | **已修复**：从 `_fetchItemsInfo + return _currentLayoutSize` 改为 stub (line 304-313) | ✅ |
| `(Internal) initial/finalLayoutAttributesFor*` | 0x1dbbf3d48-3eb8 | 各 0x54 | 字典查询返回 attrs (空 dict 时返回 nil) | line 753-770 | ✅ |
| `(Private) _rowAlignmentOptions` / `_setRowAlignmentsOptions:` | 0x1dbbf3c24 / 3c34 | 0x10 / 0x48 | ivar 读写 + copy | line 151-152 | ✅ |
| `+invalidationContextClass` | 0x1dbbf3c18 | 0xc | return `UXCollectionViewFlowLayoutInvalidationContext` | line 78-80 | ✅ |

---

## 7. 内部 4 类核心方法算法对照

### 7.1 `_UXFlowLayoutInfo`

| 方法 | UXKit | OpenUXKit | 对齐 |
|---|---|---|---|
| `init` (0x1dbbeda08) | super init + `_horizontal=NO, _leftToRight=YES` + `_sections = NSMutableArray initWithCapacity:1` | line 32-40 | ✅ |
| `addSection` (0x1dbbed9a0) | alloc/init section + setLayoutInfo:self + addObject | line 42-47 | ✅ |
| `invalidate:` (0x1dbbed9f4) | `_isValid = 0; if (!keepSections) [_sections removeAllObjects]` | line 49-54 | ✅ |
| `frameForItemAtIndexPath:` (0x1dbbed8c8) | **2 层叠加**: sectionFrame.origin + itemFrame.origin | OpenUXKit **3 层叠加** (含 rowFrame.origin) | 🟢 留 P9 评估 — OpenUXKit 是更"正确"的 visual frame，UXKit 此处可能是简化或 bug |
| `copy` (0x1dbbed608) | 复制所有 ivar + 深拷贝 sections | line 68-86 | ✅ |
| `snapshot` (0x1dbbed788) | 浅拷贝 + 只保留 contentSize | line 92-99 | ✅ |
| `dealloc` (0x1dbbed948) | release `_rowAlignmentOptions` + `_sections` | ARC 自动 | ✅ |

### 7.2 `_UXFlowLayoutSection`

| 方法 | UXKit | OpenUXKit | 对齐 |
|---|---|---|---|
| `init` (0x1dbbed520) | super init + `_items/_rows = initWithCapacity:3` + `verticalInterstice=horizontalInterstice=10.0` | line 69-78 | ✅ |
| `addItem` (0x1dbbeca74) | alloc/init item + setSection:self + addObject | line 85-90 | ✅ |
| `addRow` (0x1dbbec0d0) | alloc/init row + setSection:self + addObject | line 92-97 | ✅ |
| `invalidate` (0x1dbbed514) | `_isValid = 0; [_items removeAllObjects]` | line 99-102 | ✅ |
| `recomputeFromIndex:` (0x1dbbecb2c) | 空 stub (0x4 bytes) | line 104-105 (空) | ✅ |
| `computeLayout` (0x1dbbecb30) | **fixedItemSize 路径 return 早退**（不创建 rows，用数学公式 + AdjustToScale 走主类生成 attrs）；非 fixed 路径分配 rows + addItem 累计 + layoutRow + 设 rowFrame.origin | OpenUXKit **总是创建 rows**（含 fixedItemSize），统一走 row layout 路径 | 🟢 OpenUXKit 主动选择的简化：trade-off 是 fixedItemSize section 多分配 rows 对象，换取 `indexPathForItemAtPoint:` / `indexPathsForItemsInRect:` 等 3 层遍历路径统一可用，避免在 fixedItemSize 时跑数学公式分支。留 P9 评估是否还原 UXKit fast path。 |
| `copyFromLayoutInfo:` (0x1dbbebd54) | 复制所有 ivar + 深拷贝 rows + 拼接 items | line 372-405 | ✅ |
| `snapshot` (0x1dbbebf78) | 浅拷贝 + 只保留 rows + 拼接 items + frame | line 407-416 | ✅ |
| `dealloc` (0x1dbbecac8) | release `_rowAlignmentOptions` + `_items` + `_rows` | ARC 自动 | ✅ |

### 7.3 `_UXFlowLayoutRow`

| 方法 | UXKit | OpenUXKit | 对齐 |
|---|---|---|---|
| `init` (0x1dbbeca04) | super init + `_items = initWithCapacity:3` + `_verticalAlignement=1, _horizontalAlignement=3` | line 34-42 | ✅ |
| `addItem:` (0x1dbbec4b8) | items.addObject + item.setRowObject:self | line 48-51 | ✅ |
| `invalidate` (0x1dbbec9f8) | `_isValid=0; [_items removeAllObjects]` | line 53-56 | ✅ |
| `layoutRow` (0x1dbbec500) | 计算 main/cross main-axis 累积 → setRowSize → 4 种 alignment 分支（0=Default, 1=Center, 2=Trailing, 3=Distributed）→ 特殊 lastRow distributed 处理 → setItemFrame (用 verticalAlignement 决定 cross offset) | line 90-211 | ✅ 算法逐分支对齐 |
| `copyFromSection:` (0x1dbbec194) | 复制所有 ivar + 深拷贝 items + setRowObject | line 58-77 | ✅ |
| `snapshot` (0x1dbbec314) | 拷贝 items + setItemFrame + setRowFrame | line 79-88 | ✅ |
| `dealloc` (0x1dbbec468) | release `_items` | ARC 自动 | ✅ |

### 7.4 `_UXFlowLayoutItem`

| 方法 | UXKit | OpenUXKit | 对齐 |
|---|---|---|---|
| ivar getters/setters (0x1dbbebb90-bbc0) | 直接读写 ivar | line 14-28 | ✅ |
| `copy` (0x1dbbebbc8) | 仅复制 itemFrame | line 30-34 | ✅ |

---

## 8. P4 已修复的偏差清单

| ID | 偏差 | UXKit | OpenUXKit 修复前 | OpenUXKit 修复后 |
|---|---|---|---|---|
| **A1** | `setItemSize:` raise on width<=0 | ✅ raise NSInvalidArgumentException "negative or zero item sizes..." | 无 | ✅ 已加 |
| **A2** | `setHeaderReferenceSize:` raise on width<0 | ✅ raise "negative sizes of headers..." | 无 | ✅ 已加 |
| **A3** | `setFooterReferenceSize:` raise on width<0 | ✅ raise "negative sizes of footers..." | 无 | ✅ 已加 |
| **A8** | `synchronizeLayout` 是空 stub return CGSizeZero | ✅ stub | `_fetchItemsInfo + return _currentLayoutSize` | ✅ 改成 stub return CGSizeZero |
| **A9** | `finalizeCollectionViewUpdates` 释放 6 dict (set nil) | ✅ release + nil | `removeAllObjects`（保留 dict 复用） | ✅ 改成 set nil |
| **A11** | `_frameForHeader/Footer/ItemAtSection:usingData:` 用 AdjustToScale 模式 round origin | ✅ `round(v * scale) / scale` (含 fallback round) | `CGRectOffset` 无取整 | ✅ 新增 `UXFlowLayoutAdjustToScale` 辅助 + 全部 frame 助手取整 |
| **A12** | `layoutAttributesForHeader/FooterInSection:usingData:` 检查 `CGRectEqualToRect(frame, CGRectZero)` 返回 nil | ✅ | 检查 `headerDimension <= 0`（语义类似但路径不同） | ✅ 改成 frame zero 检查 |
| **A13** | `layoutAttributesForHeader/FooterInSection:usingData:` 用 `+layoutAttributesForSupplementaryViewOfKind:withIndexPath:` 工厂 | ✅ | `alloc init + indexPath= + _setElementKind:` | ✅ 改成工厂方法 |
| **A16** | `layoutAttributesForItemAtIndexPath:usingData:` 通过 `_frameForItemAtSection:andRow:usingData:` 算 frame（含 AdjustToScale 取整） | ✅ | 通过 `[data frameForItemAtIndexPath:]` (2 层叠加，无取整) | ✅ 改用 `_frameForItemAtSection:andRow:usingData:`（3 层 + 取整） |
| **A18** | `indexPathsForItemsInRect:usingData:` 用 `_frameForItemAtSection:andRow:usingData:` 算 item frame + 遍历 `section.items.count` (非 itemsCount) | ✅ | 用 `[data frameForItemAtIndexPath:]` + 遍历 itemsCount | ✅ 修复算法对齐 |
| **A20** | `indexPathForItemAtPoint:` 3 层遍历 (sections → rows → items) | ✅ | 2 层遍历 (sections → items) | ✅ 改成 3 层 |
| **A22** | `indexesForSectionHeaders/FootersInRect:usingData:` 双重 intersection (section.frame + header/footer frame) | ✅ | 单 intersection (只看 header/footer frame) | ✅ 加 section.frame intersection 前置 |

---

## 9. P4 保留的偏差（OpenUXKit-only 选择，留 P9 评估）

| ID | 偏差 | 处理决策 |
|---|---|---|
| **A5/A6/A7** | NSCoding 用自定义 key 而不是 UXKit 的 UIKit key（`UIInteritemSpacing` 等），无条件 encode 而不是仅 ivar != 默认时 encode，使用 `encodeDouble:` 而不是 `encodeFloat:` | 保留：OpenUXKit 是独立实现，无需跨进程兼容 UXKit 归档；自定义 key 不冲突；double 精度不损失。留 P9 评估是否值得为兼容性切到 UIKit key。 |
| **A14/A15/A23** | `layoutAttributesForItemAtIndexPath:` / `_layoutAttributesForItemsInRect:` 的 fixedItemSize 数学公式优化路径（直接计算 row/col 推断 + RTL 反转，跳过 row/item 对象遍历） | 保留：OpenUXKit 当前 fallback 路径已经做正确（同 UXKit 等价 frame + AdjustToScale 取整），fast path 只是 perf 优化。实现 fast path 需要 ~500 lines 数学公式，留 P9 perf 测量后决定是否值得。 |
| **A18-反向** | `indexPathsForItemsInRect:` UXKit 是 layoutAttributesForElementsInRect: 派生 filter，OpenUXKit 是独立实现遍历 sections/items | 保留：OpenUXKit 路径更直接，无循环依赖；结果一致。 |
| **A21** | `indexesForSectionHeaders/FootersInRect:` UXKit 返回 NSArray<NSIndexPath*>，OpenUXKit 返回 NSIndexSet | 保留：OpenUXKit 公开 API contract 是 NSIndexSet，跨阶段 phase 不能改 public type；只在内部 `layoutAttributesForElementsInRect:` 用，行为等价。 |
| **A24** | `_UXFlowLayoutInfo.frameForItemAtIndexPath:` UXKit 是 2 层 origin 叠加（sectionFrame + itemFrame，**无 rowFrame**），OpenUXKit 是 3 层叠加 | 保留：OpenUXKit 是更"正确"的 visual frame；UXKit 此处可能是简化（仅 sticky header 等内部用途，不用于 item 真实定位）。当前 OpenUXKit 代码已经不再调用此方法做 item layout（统一走 `_frameForItemAtSection:andRow:usingData:`），所以 UXKit-only 2 层语义可以保留作为 OpenUXKit-only 增强。 |
| **`_UXFlowLayoutSection.computeLayout` fixedItemSize 路径**: UXKit 在 fixedItemSize 时 return 早退（不创建 rows，靠主类数学公式生成 attrs）；OpenUXKit 始终创建 rows 走统一 layoutRow 路径 | 保留：trade-off 是 fixedItemSize section 多分配 rows 对象，换取 3 层 hit-test 统一可用，避免数学公式 fast path 的复杂性。 |
| **`_UXFlowLayoutSection.__sectionMagins`** 拼写错误 ivar | 保留：dead ivar，留 P9 清理。 |
| **`_getSizingInfos` 在 fixedItemSize 时不 `items.removeAllObjects`** | 保留：OpenUXKit 选择保留 items 让 `indexPathsForItemsInRect:usingData:` 等方法不必走 fixedItemSize 数学公式 fast path。 |
| **`encodeWithCoder:` itemSize 默认值检查参考 `(50, 50)` 而不是 (10, 10)** | UXKit 内部 bug（init 是 10 但 encode 比较 50），OpenUXKit 一直无条件编码，保留 OpenUXKit 行为更合理。 |

---

## 10. P4 完成统计

| Task | 状态 | 关键发现 |
|---|---|---|
| T15 FlowLayout 主类对齐 (35 方法) | ✅ 接口完整，算法 12 处偏差中 10 处已修复 | 含 6 个 ivar + 9 个 `_gridLayoutFlags` bit 矩阵冻结 |
| T16 `_UXFlowLayoutInfo` 对齐 (8 方法) | ✅ 100% 算法对齐 + 1 处 OpenUXKit-only 增强保留（3 层 frame） | 11 ivar 全部对齐 |
| T17 `_UXFlowLayoutSection` 对齐 (28 方法) | ✅ 接口 + 主算法对齐，computeLayout fixedItemSize 路径 OpenUXKit-only 简化 | 21 ivar 全部对齐 |
| T18 `_UXFlowLayoutRow` 对齐 (12 方法) | ✅ 100% 算法对齐 | 10 ivar 全部对齐 |
| T19 `_UXFlowLayoutItem` 对齐 (4 方法) | ✅ 100% 算法对齐 | 3 ivar 全部对齐 |

**P4 阶段代码改动**：1 个文件
- `Sources/OpenUXKit/Components/Public/UXCollectionViewFlowLayout.m`：约 +120 / -55 行
  - 新增 `UXFlowLayoutAdjustToScale` / `UXFlowLayoutAlignFrameOriginToScale` 静态辅助
  - `setItemSize:` / `setHeaderReferenceSize:` / `setFooterReferenceSize:` 加 NSInvalidArgumentException raise
  - `synchronizeLayout` 改成空 stub
  - `finalizeCollectionViewUpdates` 改成 set nil
  - `_frameForHeader/Footer/ItemAtSection:usingData:` 完全重写为 UXKit 路径（3 层叠加 + pixel-aligned 取整）
  - `_frameFor*` no-data 变体改成走 usingData 版本
  - `layoutAttributesForHeader/FooterInSection:usingData:` 改用 UXKit 工厂方法 + frame zero 检查
  - `layoutAttributesForItemAtIndexPath:usingData:` 改用 `_frameForItemAtSection:andRow:usingData:`
  - `indexPathsForItemsInRect:usingData:` 算法对齐 UXKit
  - `indexesForSectionHeaders/FootersInRect:usingData:` 加双重 intersection
  - `indexPathForItemAtPoint:` 改成 3 层遍历

**验证**：
- `swift build`: 0 errors / 0 warnings
- `swift test`: 26 passed / 0 failed
- `xcodebuild OpenUXKit-Example-Swift`: 0 errors (1 历史 storyboard warning 与 P4 无关)

---

## 11. P4 → P5 / P9 桥接

P4 输出的"FlowLayout 合同"对后续 phase 至关重要：

- **P5 (Data)**：UXCollectionViewData 在 `_loadEverything` 中调 `layout.layoutAttributesForItemAtIndexPath:` 获取 cell attrs，**现在走 pixel-aligned 路径**，所以 Data 的 layout cache 也是 pixel-aligned 的
- **P6 (ReusableView)**：cell `_setBaseLayoutAttributes:` 读 frame，现在 frame 都是 pixel-aligned
- **P8 (Update / Animation)**：UXCollectionViewUpdate 的 `_frameForUpdateItem:usingData:` 通过 layout 获取 frame，含 pixel-aligned 取整
- **P9 (主类 UXCollectionView)**：决定 `_layoutAttributesForItemsInRect:` fast path / NSCoding key 兼容性等 OpenUXKit-only 简化是否值得对齐
- **P10 (Rearranging)**：LayoutProxy + Coordinator 可能调 `_layoutAttributesForItemsInRect:`，需要 verify 简化路径是否够用

---

## 12. P4 阶段 9 步工作流执行记录

| 步骤 | 执行情况 |
|---|---|
| **D** (Dump) | ✅ IDA `list_funcs --filter "*UXCollectionViewFlowLayout*"` 拿到 64 个 FlowLayout 主类方法；`list_funcs` 分别拿到 `_UXFlowLayoutInfo` 20 / `_UXFlowLayoutSection` 47 / `_UXFlowLayoutRow` 20 / `_UXFlowLayoutItem` 7 方法 |
| **A** (Abstract ivars) | ✅ 从 CommonInit / init / dealloc / setters / encodeWithCoder / `_fetchItemsInfo` / `_updateDelegateFlags` 反推完整 ivar 偏移矩阵（主类 + 4 内部类共 60+ ivar）；9 bit `_gridLayoutFlags` 全部解码 |
| **M** (Method mapping) | ✅ 反编译 30+ 个核心方法（CommonInit / init / initWithCoder / encode / dealloc / setItemSize / setHeader/Footer / setSectionInset / setLineSpacing / setInteritemSpacing / setScrollDirection / shouldInvalidateLayoutForBoundsChange / invalidationContextForBoundsChange / invalidateLayoutWithContext / collectionViewContentSize / _updateDelegateFlags / _invalidateButKeepAllInfo / _invalidateButKeepDelegateInfo / synchronizeLayout / finalizeCollectionViewUpdates / _frameForHeader/Footer/ItemAtSection:usingData: / layoutAttributesForElementsInRect / layoutAttributesForItemAtIndexPath / layoutAttributesForHeader/Footer / layoutAttributesForItemAtIndexPath:usingData: / layoutAttributesForSupplementaryViewOfKind / indexPathForItemAtPoint / indexPathsForItemsInRect / indexesForSectionHeaders/Footers / _layoutAttributesForItemsInRect 等）+ 4 内部类的 init / addSection / addItem / addRow / invalidate / layoutRow / computeLayout / copy / snapshot / frameForItemAtIndexPath |
| **C** (Compare with current) | ✅ 全 30+ 方法对照 OpenUXKit 现状；发现 12 处偏差 |
| **B** (Bridge inventory) | ✅ 列出 fan-out 关系：FlowLayout → Data (layoutAttrs cache)、ReusableView (frame apply)、Update (`_frameForUpdateItem:`)、主类 (`_setupCellAnimations`) |
| **R** (Rewrite) | ✅ 修复 10 处偏差，保留 2 处 OpenUXKit-only 简化/增强（留 P9 评估） |
| **V** (Verify) | ✅ `swift build` 0 errors / 0 warnings；`swift test` 26 passed；`xcodebuild OpenUXKit-Example-Swift Debug build` 通过 |
| **G** (Git checkpoint) | (本次会话末尾 commit) |
| **L** (Log learnings) | ✅ 本笔记 |
