# P0 阶段反编译总结：UXKit 26.4 关键方法对照

> 反编译来源：`/Volumes/RE/Dyld-Shared-Cache/macOS/26.4/UXKit.i64` (session `uxkit_26_4`)
>
> **核心结论**：OpenUXKit 当前的 batchUpdates 与 Data 子系统**已经事实上对齐 UXKit**——算法结构、状态字段、assertion 文本、调用顺序、ivar 用法全部一致。真正的偏差点在 FlowLayout 几何子系统（`_UXFlowLayoutInfo` 未在 OpenUXKit 中以独立类实现）以及主类粘合层的细节。

---

## 1. UXCollectionViewUpdate 子系统（3 个 compute 方法）

### 1.1 调用入口

UXKit 真实 init 调用链：
```
init → _computeSectionUpdates → _computeItemUpdates → _computeGaps
```
**不调** `_computeSupplementaryUpdates`——该方法仅有 ObjC method list ref，由外部消费者动态调用（推测在 UXCollectionView 主类的 `_setupCellAnimations` 阶段）。

OpenUXKit 当前 init 调用链：**完全一致**（`UXCollectionViewUpdate.m:64-66`）。

### 1.2 `_computeSectionUpdates` (0x1dbc0997c, 1072 bytes)

| 维度 | UXKit | OpenUXKit `:111-190` | 对齐 |
|---|---|---|---|
| oldSectionMap/newSectionMap 双数组（malloc + free） | ✅ | ✅ | ✅ |
| 初始化 oldMap[i]=i, newMap[i]=NSNotFound (`memset_pattern16` w/ `unk_1DBC16D20`) | ✅ | ✅（用 for loop 等价） | ✅ |
| 遍历 updateItems，仅处理 item==NSNotFound 的 section operations | ✅ | ✅ | ✅ |
| DELETE: 标 NSNotFound + 加 _deletedSections + 后续 section--shift | ✅ | ✅ | ✅ |
| INSERT: 加 _insertedSections + 把 >=section 的 map 向上 shift（跳 movedSections）+ 加 insertedTracking | ✅ | ✅ | ✅ |
| MOVE: oldMap[from]=to + 加 _movedSections + 加 movedSourceSections + 设 hasMoves | ✅ | ✅ | ✅ |
| 有 moves 时的 reconcile：填入 newMap 中未 moved/inserted 的位置 | ✅ | ✅ | ✅ |
| 最终用 oldMap 反推 newSectionMap | ✅ | ✅ | ✅ |
| Assertion: line 215 "out of bounds access to _oldSectionMap" | ✅ | ✅ | ✅ |

### 1.3 `_computeItemUpdates` (0x1dbc0939c, 1504 bytes)

| 维度 | UXKit | OpenUXKit `:194-316` | 对齐 |
|---|---|---|---|
| oldGlobalItemMap/newGlobalItemMap C 数组 + assert count >=0 | ✅ | ✅ | ✅ |
| model 选择：DELETE/MOVE→oldModel, INSERT→newModel, default→nil | ✅ | ✅ | ✅ |
| 复用 `affectedItems` (`v7` in IDA) 临时 NSMutableIndexSet | ✅ | ✅ | ✅ |
| section operation（item==NSNotFound）走 `numberOfItemsBeforeSection:` + `numberOfItemsInSection:` 范围 | ✅ | ✅ | ✅ |
| 单 item 走 `globalIndexForItemAtIndexPath:`，return NSNotFound 时 continue | ✅ | ✅ | ✅ |
| MOVE 的 destinationGlobalIndex 计算（含 isSectionOperation 校正） | ✅ | ✅ | ✅ |
| 内层 globalItem 循环：DELETE/INSERT/MOVE 三分支 | ✅ | ✅ | ✅ |
| Assertions: line 311 "row is out of bounds", line 318 "newGlobalRowForDestination is out of bounds" | ✅ | ✅ | ✅ |
| buildNewMap reconcile（含 hasMoves 时填补 newMap 空位） | ✅ | ✅ | ✅ |

### 1.4 `_computeSupplementaryUpdates` (0x1dbc08f04, 1176 bytes)

| 维度 | UXKit | OpenUXKit `:320-369` | 对齐 |
|---|---|---|---|
| 初始化 4 容器：2 TopLevelIndexesDict + 2 IndexesSectionArray | ✅ | ✅ | ✅ |
| 给每个 section 预填空 NSMutableDictionary | ✅ | ✅ | ✅ |
| `allKinds = oldModel.knownSupplementaryElementKinds ∪ newModel.knownSupplementaryElementKinds` | ✅ | ✅ | ✅ |
| 对每个 kind：从 collectionView.collectionViewLayout 拿 4 个 indexPaths 数组（delete/insert × supplementary/decoration） | ✅ | ✅ | ✅ |
| 合并 supplementary+decoration 后 union 到目标字典 | ✅ | ✅ | ✅ |
| indexPath.length==1 走 TopLevelIndexesDict，否则走 IndexesSectionArray[section] | ✅ | ✅ | ✅ |
| 字典 key=kind，value=NSMutableIndexSet | ✅ | ✅ | ✅ |

### 1.5 `_computeGaps` (0x1dbc086b4, 956 bytes)

见独立笔记 [`_computeGaps.md`](_computeGaps.md)。**已对齐**。

### 1.6 待 P8 阶段验证的小项

- `_updateItem:isContiguousWith:` 与 UXKit `block_invoke (0x1dbc08a70)` 的逐字段对照（OpenUXKit 用了 `_frameForUpdateItem:usingData:` 比较 frame 的 maxY/minY，需验证 UXKit 是否同算法）
- `_adjustedIndexPathForGapMergeUsingIndexPath:` 与 UXKit `block_invoke.87 (0x1dbc08b30)` 的对照
- 4 个 compute 方法的单元测试用 5+3+4+3 用例覆盖

---

## 2. UXCollectionViewData 子系统（2 个核心方法）

### 2.1 `_loadEverything` (0x1dbbc39a8, 320 bytes)

```
1. _prepareToLoadData
2. v11 = UIMutableIndexPath.initWithIndexes:length:({0,0}, 2)   ⚠️
3. for i in 0..<_numItems:
     if _globalItems[i] == nil:
         if (_collectionViewDataFlags & 8) != 0:
             NSAssertionHandler "trying to load collection view layout data when layout is locked" (line 336)
         _setupMutableIndexPath:v11 forGlobalItemIndex:i
         attrs = layout.layoutAttributesForItemAtIndexPath:v11
         _setLayoutAttributes:attrs atGlobalItemIndex:i
4. _validLayoutRect = collectionViewContentRect
```

**⚠️ 关键发现**：UXKit 使用 **`UIMutableIndexPath`** （UIKit 私有类）以**复用同一个 indexPath 对象**避免反复分配。OpenUXKit 当前可能：
- 用 NSIndexPath 每次新建（性能差但功能等价）
- 或自己有等价的 mutable 实现

待验证：`rg 'UIMutableIndexPath|MutableIndexPath' Sources/`，决定是否需要新建 OpenUXKit 等价物（属于 S1a 子系统的 P1 阶段处理）。

**`_collectionViewDataFlags` bit 含义（已推出）**：
- bit 0 (mask `1`)：`contentSizeIsValid`
- bit 3 (mask `8`)：`layoutLocked`

### 2.2 `_validateContentSize` (0x1dbbc4378, 124 bytes)

```
if (flags & 1) == 0:                                       # contentSizeIsValid == NO
    if (flags & 8) != 0:                                   # layoutLocked
        NSAssertionHandler "trying to load collection view layout data when layout is locked" (line 253)
    _contentSize = layout.collectionViewContentSize
    flags |= 1                                             # mark contentSizeIsValid
```

### 2.3 P5 阶段任务清单

- 验证 OpenUXKit 当前 `UXCollectionViewData._loadEverything` 是否走 `UIMutableIndexPath` 路径
- 验证 `_collectionViewDataFlags` 的 4 个 bit 完整对照（plan 中提到的 4 个：contentSizeIsValid / itemCountsAreValid / layoutIsPrepared / layoutLocked）
- 反编译剩余方法：`_prepareToLoadData` / `_setupMutableIndexPath:forGlobalItemIndex:` / `_setLayoutAttributes:atGlobalItemIndex:` 验证 ivar 写入路径

---

## 3. UXCollectionViewFlowLayout 子系统（3 个 Internal 方法）

### 3.1 `_fetchItemsInfo` (0x1dbbf4270, 244 bytes)

```
if (_gridLayoutFlags & 0x80):                              # itemsInfoFetched，return
    return

v3 = self.collectionView
_visibleBounds = v3.bounds

dimension = scrollDirection==horizontal ?
            (bounds.height - contentInsets.top - contentInsets.bottom) :
            (bounds.width  - contentInsets.left - contentInsets.right)
clamp dimension to [0, ∞)

if dimension > 0:
    _updateDelegateFlags
    if (_gridLayoutFlags & 0x100) == 0:                    # sizingInfosObtained == NO
        _getSizingInfos
        _gridLayoutFlags |= 0x100
    _updateItemsLayout
    _gridLayoutFlags |= 0x80
```

### 3.2 `_updateItemsLayout` (0x1dbbf4364, 484 bytes)

```
data = self->_data                                          # _UXFlowLayoutInfo *
if data:
    horizontal = data.horizontal
    v5 = self.collectionView
    dimension = horizontal ?
                (bounds.width - contentInsets.left - contentInsets.right) :
                (bounds.height - contentInsets.top - contentInsets.bottom)
    clamp to [0, ∞)

    if dimension > 0:
        data.setDimension:dimension
        _currentLayoutSize = .zero
        offset = 0.0
        for section in data.sections:
            section.computeLayout
            sectionFrame = section.frame
            origin = horizontal ? (offset, sectionFrame.y) : (sectionFrame.x, offset)
            offset += horizontal ? sectionFrame.width : sectionFrame.height
            section.frame = ...(origin)
        _currentLayoutSize = horizontal ? (offset, data.dimension) : (data.dimension, offset)
        data.contentSize = _currentLayoutSize
```

**⚠️ 关键发现**：`self->_data` 是 **`_UXFlowLayoutInfo *`** 类型——这正是 plan 中提到的"FlowLayout 头文件未暴露但 ivar 真实存在"的内部数据结构。OpenUXKit 必须新建此类，否则 FlowLayout 几何无法 1:1 对齐。

**已知 `_UXFlowLayoutInfo` 接口**（从 _updateItemsLayout / _frameForItemAtSection: 反推）：
- `BOOL horizontal` (getter/setter 同名)
- `CGFloat dimension` (getter/setter via `setDimension:`)
- `NSArray<_UXFlowLayoutSection *> *sections` (readonly)
- `CGSize contentSize` (getter/setter via `setContentSize:`)

**`_UXFlowLayoutSection` 接口**（推出）：
- `CGRect frame`
- `NSArray<_UXFlowLayoutItem *> *items`
- `- (void)computeLayout`

**`_UXFlowLayoutItem` 接口**（推出）：
- `CGRect itemFrame`
- `_UXFlowLayoutRow *rowObject`

**`_UXFlowLayoutRow` 接口**（推出）：
- `CGRect rowFrame`

### 3.3 `_frameForItemAtSection:andRow:usingData:` (0x1dbbf4160, 272 bytes)

```
sectionFrame = data.sections[section].frame
item = data.sections[section].items[row]
itemFrame  = item.itemFrame
rowFrame   = item.rowObject.rowFrame
finalFrame = CGRect(
    x = sectionFrame.origin.x + itemFrame.origin.x + rowFrame.origin.x,
    y = sectionFrame.origin.y + itemFrame.origin.y + rowFrame.origin.y,
    width  = itemFrame.size.width,
    height = itemFrame.size.height
)
# 对 origin 做 backing-aligned 取整：用全局 _AdjustToScale.__s（屏幕缩放因子）做 round(value * scale) / scale
```

**关键发现 #1**：每个 item 的最终 frame 是 **3 层 origin 叠加**（section + item-in-row + row-in-section）。如果 OpenUXKit 当前是 2 层（section + item-flattened），那么所有几何都会偏。

**关键发现 #2**：origin 的 backing-aligned 取整必须用 `AdjustToScale` 模式（一次性 dispatch_once 缓存的 main screen scale）。这是 layout pixel-perfect 对齐 的关键。

### 3.4 `_getSizingInfos` (0x1dbbf4548, 1008 bytes) — FlowLayout 痛点核心

```
v3 = self.collectionView
v4 = v3.delegate

if (_data == nil):
    _data = [_UXFlowLayoutInfo new]
    _data.setLeftToRight:(v3.userInterfaceLayoutDirection == 0)
_data.setHorizontal:(self->_scrollDirection == 1)

numSections = v3.numberOfSections
for section in 0..<numSections:
    sectionObj = _data.addSection                                  # _UXFlowLayoutSection *
    itemCount = v3.numberOfItemsInSection:section
    sectionObj.setItemsCount:itemCount

    # Step 1: 检测是否所有 item size 都相同（用于 fixedItemSize 优化）
    if (gridLayoutFlags & 1):                                       # delegate 实现了 sizeForItem
        allEqual = YES, currentSize = .zero
        for itemIdx in 0..<itemCount:
            itemObj = sectionObj.addItem                            # _UXFlowLayoutItem *
            if delegate 实现了 sizeForItem:
                size = delegate.collectionView:layout:sizeForItemAtIndexPath:[section,itemIdx]
                if size.width <= 0: raise "negative or zero sizes are not supported"
            else:
                size = self.itemSize
            allEqual = allEqual && (size == currentSize 或 currentSize == .zero)
            currentSize = size
            itemObj.setItemFrame:(0, 0, size.w, size.h)
        if allEqual:
            sectionObj.items.removeAllObjects                       # 优化：清掉逐 item frame
            sectionObj.setItemSize:currentSize
            sectionObj.setFixedItemSize:YES

    # Step 2: 拉 sectionInset（delegate 或 self.sectionInset）
    margins = (gridLayoutFlags & 8) ?
        delegate.collectionView:layout:insetForSectionAtIndex:section :
        self.sectionInset
    sectionObj.setSectionMargins:margins

    # Step 3: 拉 horizontalInterstice (minimumInteritemSpacing)
    interitem = (gridLayoutFlags & 0x10) ?
        delegate.collectionView:layout:minimumInteritemSpacingForSectionAtIndex:section :
        self.minimumInteritemSpacing
    sectionObj.setHorizontalInterstice:interitem

    # Step 4: 拉 verticalInterstice (minimumLineSpacing)
    lineSpacing = (gridLayoutFlags & 0x20) ?
        delegate.collectionView:layout:minimumLineSpacingForSectionAtIndex:section :
        self.minimumLineSpacing
    sectionObj.setVerticalInterstice:lineSpacing

    # Step 5: delegate 未实现 sizeForItem → 全段固定 itemSize
    if !(gridLayoutFlags & 1):
        sectionObj.setFixedItemSize:YES
        sectionObj.setItemSize:self.itemSize

    # Step 6: 拉 row alignment options（私有 delegate 方法）
    rowOpts = (gridLayoutFlags & 0x40) ?
        delegate._collectionView:layout:flowLayoutRowAlignmentOptionsForSection:section :
        self._rowAlignmentsOptionsDictionary
    sectionObj.setRowAlignmentOptions:rowOpts

    # Step 7: 拉 header/footer dimension（注意 vertical=height, horizontal=width）
    if (gridLayoutFlags & 2):
        headerSize = delegate.collectionView:layout:referenceSizeForHeaderInSection:section
    else:
        headerSize = self.headerReferenceSize
    headerDim = (scrollDirection==vertical) ? headerSize.height : headerSize.width
    sectionObj.setHeaderDimension:headerDim

    # 同上 footer
```

**`_gridLayoutFlags` 完整 bit 含义（全部推出！）**：

| Bit mask | 含义 |
|---|---|
| `0x1` (bit 0) | delegateRespondsToSizeForItem |
| `0x2` (bit 1) | delegateRespondsToHeaderRefSize |
| `0x4` (bit 2) | delegateRespondsToFooterRefSize |
| `0x8` (bit 3) | delegateRespondsToInsetForSection |
| `0x10` (bit 4) | delegateRespondsToMinInteritemSpacing |
| `0x20` (bit 5) | delegateRespondsToMinLineSpacing |
| `0x40` (bit 6) | delegateRespondsToRowAlignmentOptions（私有 SPI） |
| `0x80` (bit 7) | itemsInfoFetched |
| `0x100` (bit 8) | sizingInfosObtained |

**`_UXFlowLayoutSection` 完整接口（已知）**：
```objc
- (void)setItemsCount:(NSInteger)count;
- (_UXFlowLayoutItem *)addItem;
- (NSArray<_UXFlowLayoutItem *> *)items;
- (void)setSectionMargins:(NSEdgeInsets)margins;
- (void)setHorizontalInterstice:(CGFloat)spacing;
- (void)setVerticalInterstice:(CGFloat)spacing;
- (void)setItemSize:(CGSize)size;
- (void)setFixedItemSize:(BOOL)fixed;
- (void)setRowAlignmentOptions:(NSDictionary *)options;
- (void)setHeaderDimension:(CGFloat)dim;
- (void)setFooterDimension:(CGFloat)dim;
- (void)computeLayout;                  // 内部计算 row wrap
- (CGRect)frame;
- (void)setFrame:(CGRect)frame;
```

**`_UXFlowLayoutInfo` 完整接口（已知）**：
```objc
@property BOOL leftToRight;             // setLeftToRight: only
@property BOOL horizontal;
@property CGFloat dimension;
@property CGSize contentSize;
@property (readonly) NSArray<_UXFlowLayoutSection *> *sections;
- (_UXFlowLayoutSection *)addSection;
```

**`_UXFlowLayoutItem` 完整接口（已知）**：
```objc
@property CGRect itemFrame;
@property _UXFlowLayoutRow *rowObject;
```

**`_UXFlowLayoutRow` 完整接口（已知）**：
```objc
@property CGRect rowFrame;
```

### 3.5 算法亮点（OpenUXKit 当前可能漏的细节）

1. **`fixedItemSize` 优化**：如果检测所有 item 尺寸相同，UXKit 会清空 items 数组（`items.removeAllObjects`）并仅保留一个 itemSize。如果 OpenUXKit 不做此优化，对每个 cell 都存独立 itemFrame，会浪费内存但功能等价。
2. **私有 delegate SPI**：`_collectionView:layout:flowLayoutRowAlignmentOptionsForSection:` 是 UXKit 私有方法（前导下划线），OpenUXKit 公开协议可能没有，需要决定是否补。
3. **scrollDirection 对 header/footer 维度的影响**：vertical 时 header 用 `height`，horizontal 时用 `width`——这与 plan 中提到的"FlowLayout 痛点几何/对齐有偏差"完全吻合。
4. **`_data` 的 leftToRight 由 `userInterfaceLayoutDirection` 决定**：RTL 语言下 cells 顺序会镜像。
5. **`_rowAlignmentsOptionsDictionary`**：OpenUXKit 当前可能没有此 ivar，需要补。

### 3.5 P4 阶段任务清单（核心）

- ✅ 已识别 `_UXFlowLayoutInfo` / Section / Row / Item 的接口形状（4 个类）
- ⬜ 新建 `Sources/OpenUXKit/Components/Private/_UXFlowLayoutInfo.{h,m}` + 三个子类（Section/Row/Item，可作 inner type）
- ⬜ 反编译 `_getSizingInfos` (1008 bytes，最大) 拉 row/item 几何拼装算法
- ⬜ 反编译 `_updateDelegateFlags` 拉 delegate-respond-to 缓存策略
- ⬜ 反编译 `_invalidateButKeepAllInfo` / `_invalidateButKeepDelegateInfo` 拉两 flag 的失效组合矩阵
- ⬜ 反编译 `layoutAttributesForItemAtIndexPath:usingData:` / `_frameForHeaderInSection:usingData:` / `_frameForFooterInSection:usingData:` 拉 attrs 组装路径

---

## 4. 待继续反编译的高优先级方法（按 P 阶段排序）

| 优先级 | 方法 | 大小 | 地址 | 用于 |
|---|---|---|---|---|
| P0 (现在) | `-[UXCollectionViewFlowLayout(Internal) _getSizingInfos]` | 0x3f0 | 0x1dbbf4548 | FlowLayout 痛点核心 |
| P0 (现在) | `-[UXCollectionViewFlowLayout(Internal) _updateDelegateFlags]` | 0x160 | 0x1dbbf4938 | FlowLayout delegate flag |
| P1 | `-[UXCollectionViewUpdateItem compareIndexPaths:]` | (待 lookup) | — | UpdateItem 排序 |
| P5 | `-[UXCollectionViewData _prepareToLoadData]` | (待 lookup) | — | Data 准备 |
| P5 | `-[UXCollectionViewData _setupMutableIndexPath:forGlobalItemIndex:]` | (已知) | 0x1dbbc4220 | Data hot path |
| P8 | `block_invoke (0x1dbc08a70)` | — | 0x1dbc08a70 | gap contiguous |
| P8 | `block_invoke.87 (0x1dbc08b30)` | — | 0x1dbc08b30 | gap indexPath adjust |
| P9 | UXCollectionView 的 `_setupCellAnimations` | — | (待 lookup) | batchUpdates 后动画起点 |

---

## 5. P0 阶段对 12 周计划的关键修订

基于本次反编译发现，对原 plan 的修订：

1. **batchUpdates 子系统（S3b）痛点优先级降低**：UXCollectionViewUpdate 已经在 OpenUXKit 中事实上 1:1 对齐。P8 主要工作变为：
   - 验证 2 个 contiguous helper 方法的细节
   - 补单元测试覆盖 4 个 compute 方法
   - 反编译主类 `_setupCellAnimations` 看 supplementary updates 触发时机

2. **FlowLayout 子系统（S2）痛点优先级提升**：
   - **必须新建 4 个内部类**：`_UXFlowLayoutInfo` / `_UXFlowLayoutSection` / `_UXFlowLayoutRow` / `_UXFlowLayoutItem`
   - 每个 item 的 frame = 3 层 origin 叠加（section + item + row），如果 OpenUXKit 当前是 2 层就会全偏
   - 必须实现 `AdjustToScale` 模式做 pixel 对齐
   - 这是真正的 batchUpdates 视觉痛点根源

3. **Data 子系统（S3a）的 UIMutableIndexPath 复用**：
   - UXKit 用 UIMutableIndexPath 复用 indexPath 对象
   - OpenUXKit 需要桥接或新建等价物（属 S1a P1 阶段）

4. **Flag bit 矩阵**：已推出 `_collectionViewDataFlags` 2 bit、`_gridLayoutFlags` 2 bit；P5/P4 阶段需补全所有 bit 含义后再动相应 setter/getter。

5. **`UIMutableIndexPath` 用法发现意味着**：UXKit 实际依赖 UIKit 私有类。OpenUXKit 是独立实现，需要：
   - 选 A：用 NSMutableIndexPath（如果存在）
   - 选 B：自己实现 `_UXMutableIndexPath`
   - 选 C：每次新建 NSIndexPath（性能损失小，因为只在 reload 时调用）
