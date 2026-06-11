# UXCollectionView 37 类对照矩阵（UXKit 26.4 ↔ OpenUXKit）

> **基准**：`/Volumes/RE/Dyld-Shared-Cache/macOS/26.4/UXKit/ObjCHeaders/` 共 37 个 `.h` 文件。
> **OpenUXKit 来源**：`Sources/OpenUXKit/Components/{Public,Private}/`、`Sources/OpenUXKit/Protocols/{Public,Private}/`、`Sources/OpenUXKit/Categories/Public/`。
>
> **状态编码**：
> - ✅ **已对齐**：接口完整对应 + 实现已 P0 反编译验证一致
> - 🟢 **形式对齐**：接口已对应、文件已存在，但实现细节未逐方法 verify
> - 🟡 **部分对齐**：核心接口对应，但已知有缺失字段/方法/算法
> - 🔴 **缺失**：OpenUXKit 中暂无对应文件
> - ⚪ **桥接**：通过其它机制提供（如 ObjC 动态分派）

---

## 概要统计

| 总计 | ✅ 已对齐 | 🟢 形式对齐 | 🟡 部分对齐 | 🔴 缺失 | ⚪ 桥接 |
|---|---|---|---|---|---|
| **37** | 7 | 25 | 5 | 0 | 0 |

> 注：另有 4 个未导出头的 FlowLayout 隐藏内部类（`_UXFlowLayout*`，见下文专节）不计入 37，当前均为 🟡（P4 已算法对齐，保留 2 处 OpenUXKit-only 简化待 P9 评估）。

**关键修订**：原 plan 假设的"`_UXFlowLayoutInfo` 4 个类需新建"**不成立**——OpenUXKit 已实现 `_UXFlowLayoutInfo / _UXFlowLayoutSection / _UXFlowLayoutRow / _UXFlowLayoutItem` 4 个类，总计 772 行实现。痛点降级为"算法实现细节对齐"。

---

## S1a 叶子 token

| UXKit 类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `UXCollectionViewUpdateItem` | `Components/Public/UXCollectionViewUpdateItem.{h,m}` + `Private/UXCollectionViewUpdateItem+Internal.h` | ✅ | `_action` 编码与 UXKit 一致（0=INSERT/1=DELETE/2=RELOAD/3=MOVE）；P1 阶段需 verify `compareIndexPaths:` block。 |
| `_UXCollectionViewItemKey` | `Components/Private/_UXCollectionViewItemKey.{h,m}` | 🟢 | 已存在；P1 verify `_hash` 缓存策略与 `copyAsClone:`。 |
| `_UXCollectionViewSectionItemIndexes` | `Components/Private/_UXCollectionViewSectionItemIndexes.{h,m}` (152 行 .m) | 🟢 | 已存在；P7 与 IndexPathsSet 一起对齐 `adjustForDeletion*` / `adjustForInsertion*` 算法。 |

---

## S1b ReusableView 生命周期

| UXKit 类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `UXCollectionReusableView` | `Components/Public/UXCollectionReusableView.{h,m}` + `Private/UXCollectionReusableView+Internal.h` | ✅ | **P6 已对齐**（见 `IDA-Notes/P6-ReusableView.md`）：22 方法全部反编译比对；位段（`updateAnimationCount:5` + `wasDequeued:1`）与两阶段 `_setLayoutAttributes:`/`_setBaseLayoutAttributes:` 原已一致；修复 `description` 格式 / `_collectionView` 改 `__unsafe_unretained` / accessibility 表面（role=Group、dynamicParent 经 layoutAccessibility、scrollToVisible position 64）。5 个 legacy AX 非正式协议 override 遗留 P11。 |
| `UXCollectionViewCell` | `Components/Public/UXCollectionViewCell.{h,m}` + `Private/UXCollectionViewCell+Internal.h` | ✅ | **P6 已对齐**：`_setSelected:animated:` / `prepareForReuse` / `resizeSubviewsWithOldSize:` 原已一致；`_commonInit` 改为 UXKit 的静态 `UXCollectionViewCellCommonInit` C 函数；ivar 顺序对齐（576/577/578）；补齐 cell accessibility 表面（CellRole / isAccessibilitySelected / setAccessibilitySelected: / accessibilityPerformPress / `_axSimulateClick:` 真实 NSEvent）。`selectionBorderShouldUsePrimaryColor` 仅为存储位，渲染由主类消费（P9）。 |
| `_UXCollectionSnapshotView` | `Components/Private/_UXCollectionSnapshotView.{h,m}` | ✅ | **P6 已确认**：UXKit 中零方法零 ivar 的纯标记子类，OpenUXKit 空实现即 1:1；3 个创建点合同（双面动画 / batchUpdates / 动画清理）已记录在 P6 笔记 §3，P8/P9 接线。 |

---

## S2 Layout 几何与失效化

| UXKit 类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `UXCollectionViewLayoutAttributes` | `Components/Public/UXCollectionViewLayoutAttributes.{h,m}` + `Private/UXCollectionViewLayoutAttributes+Internal.h` | 🟢 | P2 是全局 fan-out 节点；verify 22 ivar + `_isEquivalentTo:` / `_isTransitionVisibleTo:` 语义。 |
| `UXCollectionViewLayoutInvalidationContext` | `Components/Public/UXCollectionViewLayoutInvalidationContext.{h,m}` + `Private/UXCollectionViewLayoutInvalidationContext+Internal.h` | 🟢 | P2 verify `_invalidatedSupplementaryViews` 写入路径与单例聚合策略。 |
| `UXCollectionViewLayout` | `Components/Public/UXCollectionViewLayout.{h,m}` + `Private/UXCollectionViewLayout+Internal.h` | 🟢 | P3 verify 13 ivar（含 `_invalidationContext` 单例字段）+ `prepareForTransition*` 双阶段语义。 |
| `UXCollectionViewFlowLayout` | `Components/Public/UXCollectionViewFlowLayout.{h,m}` + `Private/UXCollectionViewFlowLayout+Internal.h` (827 行 .m) | 🟡 | **P4 痛点核心**：`_fetchItemsInfo` / `_getSizingInfos` / `_updateItemsLayout` 算法已 P0 反编译，需 1:1 对齐实现。`_gridLayoutFlags` 9 bit 位段含义已全部解码。 |
| `UXCollectionViewFlowLayoutInvalidationContext` | `Components/Public/UXCollectionViewFlowLayoutInvalidationContext.{h,m}` + `Private/UXCollectionViewFlowLayoutInvalidationContext+Internal.h` | 🟢 | P4 verify `invalidateFlowLayoutDelegateMetrics` / `invalidateFlowLayoutAttributes` 2 BOOL。 |
| `_UXCollectionViewLayoutProxy` | `Components/Private/_UXCollectionViewLayoutProxy.{h,m}` | 🟢 | P10 与 Rearranging 一起处理。 |

---

## S2 隐藏数据结构（FlowLayout 内部 4 类）

| UXKit 类（未导出头但 ivar 存在） | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `_UXFlowLayoutInfo` | `Components/Private/_UXFlowLayoutInfo.{h,m}` (101 行 .m) | 🟡 | **P4 验证接口对齐**：UXKit 已知 ivar `_sections` / `_horizontal` / `_dimension` / `_layoutSize` / `_leftToRight` / `_isValid` / `_rowAlignmentOptions` / `_useFloatingHeaderFooter` / `_visibleBounds`（来源：`Sources/UXKit/UXKit.tbd:82-86`）。OpenUXKit 头已含 `usesFloatingHeaderFooter` / `rowAlignmentOptions` / `dimension` / `horizontal` / `contentSize` / `leftToRight` / `sections` / `snapshot` / `frameForItemAtIndexPath:` / `invalidate:` 等。 |
| `_UXFlowLayoutSection` | `Components/Private/_UXFlowLayoutSection.{h,m}` (418 行 .m) | 🟡 | **P4 算法重点**：`computeLayout` / `recomputeFromIndex:` 的 row wrap 算法需对照 UXKit 实现验证；头已含 fixedItemSize / horizontalInterstice / verticalInterstice / sectionMargins / headerDimension / footerDimension / rowAlignmentOptions 等齐全字段。 |
| `_UXFlowLayoutRow` | `Components/Private/_UXFlowLayoutRow.{h,m}` (213 行 .m) | 🟡 | P4 验证 row geometry 计算与 `lastRowIncomplete` 边界。 |
| `_UXFlowLayoutItem` | `Components/Private/_UXFlowLayoutItem.{h,m}` (40 行 .m) | 🟡 | P4 验证 `itemFrame` + `rowObject` 反向引用。 |

---

## S3a Data 缓存

| UXKit 类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `UXCollectionViewData` | `Components/Private/UXCollectionViewData.{h,m}` + `Private/UXCollectionViewData+Internal.h` | ✅ | **P5 已对齐**（见 `IDA-Notes/P5-Data.md`）：51 个方法全部反编译比对；补齐 `__pageDimension` screen-page 缓存子系统（`_screenPageForPoint:` / `_setLayoutAttributes:` 页注册 / `validateLayoutInRect:` 滑动窗口 + 5 页淘汰 / `layoutAttributesForElementsInRect:` 页索引聚合 + zIndex 排序）；4 个 flag bit 与 UXKit 完全一致；`UIMutableIndexPath` 以不可变 NSIndexPath 重建桥接（见笔记 §6.3）。 |

---

## S3b Update / Gap 增量更新

| UXKit 类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `UXCollectionViewUpdate` | `Components/Private/UXCollectionViewUpdate.{h,m}` (522 行) + `+Internal.h` | ✅ | P0 反编译验证：`_computeSectionUpdates` / `_computeItemUpdates` / `_computeSupplementaryUpdates` / `_computeGaps` 全部算法对齐，assertion 行号/文本一致。 |
| `UXCollectionViewUpdateGap` | `Components/Private/UXCollectionViewUpdateGap.{h,m}` | ✅ | `gapWithUpdateItem:` / `addUpdateItem:` / `isDeleteBasedGap` / `firstUpdateItem` / `lastUpdateItem` / `insertItems` 全部对齐。 |

---

## S4 IndexPathsSet 选区数据

| UXKit 类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `UXCollectionViewIndexPathsSet` | `Components/Private/UXCollectionViewIndexPathsSet.{h,m}` (293 行) + `+Internal.h` | 🟢 | P7 verify 双层结构（NSMutableIndexSet + NSMutableDictionary）。 |
| `UXCollectionViewMutableIndexPathsSet` | `Components/Private/UXCollectionViewMutableIndexPathsSet.{h,m}` (213 行) | 🟢 | P7 verify `adjustForDeletionOf*` / `adjustForInsertionOf*` / `intersectIndexPathsSet:` 算法。 |

---

## S5 Animation

| UXKit 类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `UXCollectionViewAnimation` | `Components/Private/UXCollectionViewAnimation.{h,m}` | 🟢 | P8 verify 4 flag（animateFromCurrentPosition / deleteAfterAnimation / rasterizeAfterAnimation / resetRasterizationAfterAnimation）副作用顺序。 |
| `UXCollectionViewAnimationContext` | `Components/Private/UXCollectionViewAnimationContext.{h,m}` | 🟢 | P8 verify viewAnimations 数组、completionHandler。 |

---

## S6 Rearranging 拖放

| UXKit 类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `_UXCollectionViewRearrangingCoordinator` | `Components/Private/_UXCollectionViewRearrangingCoordinator.{h,m}` (668 行) | 🟡 | **P10 痛点**：~80 方法需对齐 NSGestureRecognizerDelegate + NSDraggingSource + NSDraggingDestination 实现。3 种 `initiationMode` 状态机需 verify。 |
| `UXCollectionViewPanGestureRecognizer` | `Components/Private/UXCollectionViewPanGestureRecognizer.{h,m}` | 🟢 | P10 verify `mouseDownEvent` / `uxCancel`。 |
| `UXCollectionViewFilePromiseProvider` | `Components/Private/UXCollectionViewFilePromiseProvider.{h,m}` | 🟢 | P10 verify `auxiliaryFilePromiseProviders` 注入。 |

---

## S7 Accessibility

| UXKit 类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `UXCollectionViewLayoutAccessibility` | `Components/Private/UXCollectionViewLayoutAccessibility.{h,m}` | 🟢 | P11 verify `_sectionCache` 滑动窗口 + `_trimSectionCacheToVisibleSections:`。 |
| `UXCollectionViewLayoutSectionAccessibility` | `Components/Private/UXCollectionViewLayoutSectionAccessibility.{h,m}` | 🟢 | P11 verify 5 个 sibling navigation 方法 + accessibilityArrayAttribute*。 |

---

## S8 主类粘合层

| UXKit 类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `UXCollectionView` | `Components/Public/UXCollectionView.{h,m}` (2571 行) + `Private/UXCollectionView+Internal.h` | 🟡 | **P9 最大块**：`performBatchUpdates:` 9 步、Selection 算法 4 路分支、`_updateVisibleCellsNow:` 核心循环、`_collectionViewFlags` 45+ bit 位段。 |
| `UXCollectionViewController` | `Components/Public/UXCollectionViewController.{h,m}` + `Private/UXCollectionViewController+Internal.h` | 🟢 | P9 末班车，10 行级 verify。 |
| `_UXCollectionView` | `Components/Private/_UXCollectionView.{h,m}` (18 行 .m) | 🟡 | UXKit 仅有 `_UXCollectionViewOverdraw` 协议实现；OpenUXKit 当前为空壳，P9 补齐。 |
| `UXCollectionDocumentView` | `Components/Private/UXCollectionDocumentView.{h,m}` | 🟢 | P9 verify `collectionView` weak back-ref。 |
| `_UXCollectionDocumentView` | `Components/Private/_UXCollectionDocumentView.{h,m}` (12 行 .m) | 🟡 | UXKit 含 `overdrawEnabled` ivar；OpenUXKit 当前为空壳。 |
| `UXCollectionClipView` | `Components/Private/UXCollectionClipView.{h,m}` | 🟢 | UXKit 头无独有方法（仅继承 NSClipView）。 |

---

## 协议（3 个）

| UXKit 协议 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `UXCollectionViewDataSource` | `Protocols/Public/UXCollectionViewDataSource.h` | 🟢 | 必需 + 可选方法都已在 Examples 中实测使用。 |
| `UXCollectionViewDelegate` | `Protocols/Public/UXCollectionViewDelegate.h` | 🟢 | P9 verify 25+ 可选方法签名。 |
| `UXCollectionViewLayoutProxyDelegate` | `Protocols/Private/UXCollectionViewLayoutProxyDelegate.h` | 🟢 | 单方法协议，P10 与 Rearranging 一起。 |
| `_UXCollectionViewOverdraw` | `Protocols/Private/_UXCollectionViewOverdraw.h` | 🟢 | 单 `@property overdrawEnabled`，P9 与 _UXCollectionView 一起。 |

---

## Category（3 个）

| UXKit 分类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `NSIndexPath (UXCollectionViewAdditions)` | `Categories/Public/NSIndexPath+UXCollectionViewAdditions.{h,m}` | 🟢 | `+ indexPathForItem:inSection:` / `+ indexPathForRow:inSection:` / `section` / `item` / `row`，P1 与 UpdateItem 一起 verify。 |
| `NSEvent (UXCollectionViewAdditions)` | `Categories/Public/NSEvent+UXCollectionViewAdditions.{h,m}` | 🟢 | `pointForLayoutOfCollectionView:`，P9 verify。 |
| `NSObject (UXCollectionView)` | `Categories/Public/NSObject+UXCollectionView.{h,m}` | 🟢 | `performWithoutAnimation:` block API，P5/P8 verify。 |

---

## Plan 修订总结（基于 P0 反编译 + 矩阵）

| 原 plan 假设 | 实际情况 | 修订 |
|---|---|---|
| `_UXFlowLayoutInfo` 4 个隐藏类需新建 | 已存在 4 文件共 772 行，接口已对齐 UXKit | **P4 工作量降级**：从"新建 + 实现"变成"算法实现细节对齐" |
| OpenUXKit 漏调 `_computeSupplementaryUpdates` 是 batchUpdates 痛点 | UXKit init 也不调，是外部消费者触发 | **S3b 痛点根源不在 compute** |
| FlowLayout 缺 `_rowAlignmentsOptionsDictionary` ivar | 已在 `_UXFlowLayoutInfo.rowAlignmentOptions` + `_UXFlowLayoutSection.rowAlignmentOptions` | **已存在** |
| `_UXCollectionView` / `_UXCollectionDocumentView` 是空壳 | ✅ 确认空壳，分别 18 / 12 行 | **P9 真补齐** |
| 全部 37 类需新建/重写 | 35 个已存在，仅 `_UXCollectionView` / `_UXCollectionDocumentView` 是空壳 | **真实工作量**：算法对齐而非新建 |

---

## P0 完成状态

- ✅ T1 baseline build 验证
- ✅ T2 commit 路径决定（沿用 wip/uxkit-impl 不开子 feature 分支）
- ✅ T3 .claude/plans/ 脚手架
- ✅ T4 37 类对照矩阵（本文档）
- ✅ T5 9 个核心方法反编译笔记
- ⬜ T6 Tests 脚手架（下一步）
- ⬜ T7 Showcase 视觉基线（需用户手动操作）
- ✅ T8 公开 API 合同（13 符号）

---

## 下一步（按 phase 实际工作量重排序）

| Phase | 工作量（修订） | 关键产物 |
|---|---|---|
| **T6（P0 收尾）** | 0.5 天 | Tests/OpenUXKitTests/Collection/ 下 6 个 swift stub 文件 + 1 个 fixture |
| **P1** | 0.5 天 | UpdateItem `compareIndexPaths:` block 对照 + `_UXCollectionViewItemKey._hash` verify |
| **P2** | 0.5 天 | LayoutAttributes 22 ivar matrix + InvalidationContext 单例聚合 |
| **P3** | 1 天 | Layout 基类 13 ivar verify |
| **P4** | **1 周（重点）** | `_UXFlowLayout*` 4 类算法 1:1 对齐 + FlowLayout 9 个 `_gridLayoutFlags` bit 处理 |
| **P5** | 0.5 周 | Data `_loadEverything` UIMutableIndexPath 桥接策略 |
| **P6** | 0.5 天 | ReusableView `_setBaseLayoutAttributes:` |
| **P7** | 0.5 周 | IndexPathsSet adjust* 算法 |
| **P8** | 0.5 周 | Animation handlers + 验证 2 个 contiguous block |
| **P9** | **2 周（最大块）** | UXCollectionView 主类 2571 行 + 5 视图层次类 + Selection 4 路 + flag 矩阵 |
| **P10** | 1 周 | Rearranging Coordinator 80 方法 |
| **P11** | 0.5 周 | Accessibility 2 类 |

**总计修订**：约 **7-8 周**（原估 12 周），主要因为接口形式已对齐，工作集中在算法对齐而非新建。
