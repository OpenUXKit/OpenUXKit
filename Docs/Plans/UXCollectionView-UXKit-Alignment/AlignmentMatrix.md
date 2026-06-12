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
| **37** | 12 | 20 | 5 | 0 | 0 |

> 注：另有 4 个未导出头的 FlowLayout 隐藏内部类（`_UXFlowLayout*`，见下文专节）不计入 37，当前均为 🟡（P4 已算法对齐，保留 2 处 OpenUXKit-only 简化待 P9 评估）。

**关键修订**：原 plan 假设的"`_UXFlowLayoutInfo` 4 个类需新建"**不成立**——OpenUXKit 已实现 `_UXFlowLayoutInfo / _UXFlowLayoutSection / _UXFlowLayoutRow / _UXFlowLayoutItem` 4 个类，总计 772 行实现。痛点降级为"算法实现细节对齐"。

---

## S1a 叶子 token

| UXKit 类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `UXCollectionViewUpdateItem` | `Components/Public/UXCollectionViewUpdateItem.{h,m}` + `Private/UXCollectionViewUpdateItem+Internal.h` | ✅ | `_action` 编码与 UXKit 一致（0=INSERT/1=DELETE/2=RELOAD/3=MOVE）；P1 阶段需 verify `compareIndexPaths:` block。 |
| `_UXCollectionViewItemKey` | `Components/Private/_UXCollectionViewItemKey.{h,m}` | 🟢 | 已存在；P1 verify `_hash` 缓存策略与 `copyAsClone:`。 |
| `_UXCollectionViewSectionItemIndexes` | `Components/Private/_UXCollectionViewSectionItemIndexes.{h,m}` (152 行 .m) | ✅ | **P7 已对齐**（见 `IDA-Notes/P7-IndexPathsSet.md`）：25 个函数全部反编译比对，`adjustForDeletion*`（删除位 + `shift(item+1, -1)`；批量按 range 逆序）/ `adjustForInsertion*`（`shift(item, +1)`；批量按 range 正序）逐句一致，零代码修改。无 sorted-array 缓存。 |

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
| `UXCollectionViewUpdate` | `Components/Private/UXCollectionViewUpdate.{h,m}` (521 行) + `+Internal.h` | ✅ | P0 反编译验证 4 个 `_compute*` 主体；**P8 复核补漏**（见 `IDA-Notes/P8-UpdateAnimation.md`）：修复 `_computeGaps` 两处方向性 bug（contiguous 几何判定 `MaxY(lower)==MinY(upper)`、insert 并入 delete-gap 的 `first<=adjusted<=last` 区间判定），`updateItemsSortedByIndexPaths` lazy 缓存 ivar @0xD8 确认。 |
| `UXCollectionViewUpdateGap` | `Components/Private/UXCollectionViewUpdateGap.{h,m}` | ✅ | **P8 已对齐**：9 个函数全部反编译比对（ivar 布局 @8-@72、`addUpdateItem:` assertion "UXCollectionViewUpdate.m" line 57、description 格式），零代码修改。`beginningRect`/`endingRect` 写入点在主类（P9 接线）。 |

---

## S4 IndexPathsSet 选区数据

| UXKit 类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `UXCollectionViewIndexPathsSet` | `Components/Private/UXCollectionViewIndexPathsSet.{h,m}` (293 行) + `+Internal.h` | ✅ | **P7 已对齐**（见 `IDA-Notes/P7-IndexPathsSet.md`）：35 个函数全部反编译比对，双层结构（`_sectionIndexes` @8 + `_sectionToItemIndexesMap` @16）、空 section 清理、`copyWithZone:` 返回 self、`mutableCopyWithZone:` 经 `allIndexPaths` 重建、assertion 行号（410/564/582）全部一致，零代码修改。 |
| `UXCollectionViewMutableIndexPathsSet` | `Components/Private/UXCollectionViewMutableIndexPathsSet.{h,m}` (213 行) | ✅ | **P7 已对齐**：25 个函数全部反编译比对；`intersectIndexPathsSet:` 实为对称差补集法（plan 假设的"先 section 求交"机制不成立，结果语义相同）；`_adjustForDeletionOfSection:` 升序搬 key + `shift(section+1, -1)`、`_adjustForInsertionOfSection:` 降序搬 key + `shift(section, +1)` 逐句一致，零代码修改。调用面合同（CommonInit / 选择 / lasso / `_updateWithItems:` 重建）见笔记 §6，P8/P9 接线。 |

---

## S5 Animation

| UXKit 类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `UXCollectionViewAnimation` | `Components/Private/UXCollectionViewAnimation.{h,m}` | ✅ | **P8 已对齐**（见 `IDA-Notes/P8-UpdateAnimation.md`）：13 个函数全部反编译比对；ivar 布局 @8-@72 与 4-bit 位段（含 UXKit 原始拼写 `deleteAterAnimation`）一致；3 处 assertion 行号（403/479/489）一致；修复默认 timingFunction（Default → **Linear**）。`deleteAfterAnimation` / `rasterize*` flag 仅存储，消费在主类（P9 接线）。 |
| `UXCollectionViewAnimationContext` | `Components/Private/UXCollectionViewAnimationContext.{h,m}` | ✅ | **P8 已对齐，P9a 修正**：纯数据袋（3 ivar @8/@16/@24）。P9a 把 `completionHandler` 签名修正为 `void(^)(BOOL finished)`（消费侧 `_updateAnimationDidStop:` 以 finished 调用，P8 时无消费者信息）；`viewAnimations` 组装点确认为 `_updateWithItems:` 的零时长嵌套动画组（P9 笔记 §2.1）。 |

---

## S6 Rearranging 拖放

| UXKit 类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `_UXCollectionViewRearrangingCoordinator` | `Components/Private/_UXCollectionViewRearrangingCoordinator.{h,m}` (668 行) | 🟡 | **P10a 已反编译核心状态机**（见 `IDA-Notes/P10-Rearranging.md`）：`_gestureRecognized:`/`_beginRearrangingItemsWithIndexPaths:`/`_updateRearrangingStateForLocation:`/`_finishRearrangingForLocation:shouldComplete:`/`_moveItemsAtIndexPaths:toIndexPaths:`/`_indexPathsFromRange`/draggingEntered/Updated/performDrag 全部反编译;ivar 矩阵已对齐;`_moveItemsAtIndexPaths:toIndexPaths:` 空 stub 转正。**架构差异**：UXKit 走真实 NSDraggingSession,OpenUXKit 现为手势直驱近似版。**P10b 余量**：按 §2/§4 完整重写 NSDragging 流(需交互拖放验证,含 finish 的 exchange 死分支核实)。 |
| `UXCollectionViewPanGestureRecognizer` | `Components/Private/UXCollectionViewPanGestureRecognizer.{h,m}` | 🟢 | P10 verify `mouseDownEvent` / `uxCancel`。 |
| `UXCollectionViewFilePromiseProvider` | `Components/Private/UXCollectionViewFilePromiseProvider.{h,m}` | 🟢 | P10 verify `auxiliaryFilePromiseProviders` 注入。 |

---

## S7 Accessibility

| UXKit 类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `UXCollectionViewLayoutAccessibility` | `Components/Private/UXCollectionViewLayoutAccessibility.{h,m}` | ✅ | **P11 已对齐**（见 `IDA-Notes/P11-Accessibility.md`）：28 方法全部反编译比对。`_dequeueSectionWithIndex:`/`_trimSectionCacheToVisibleSections:`（滑动窗口三分支）/`_visibleSections`/`accessibilityVisibleChildren` 原已一致；修正 children 模型为「rowCount 驱动 + 懒 dequeue」（array attr count/values 仅 Children、`accessibilityRowCount`、index 恒定 dequeue 循环）、role→ListRole、`accessibilityIndexOfChild:`→`[child accessibilityIndex]`、hitTest 加 NSPointInRect、next/previous section 改 sectionIndex+rowCount+回绕+dequeue、parentForCell/ReusableView 经 indexPath→section、frameInParentSpace 阈值→FLT_EPSILON、postNotification nil 守卫、生命周期加 `AXCollectionViewEnumerateSections` 转发。 |
| `UXCollectionViewLayoutSectionAccessibility` | `Components/Private/UXCollectionViewLayoutSectionAccessibility.{h,m}` | ✅ | **P11 已对齐**：24 方法全部反编译比对。`compare:`/`accessibilityActionDescription:`/`accessibilityPerformAction:` 原已一致；修正 role→ListRole、frame→子元素 `NSUnionRect` 并集、visibleChildren 加 frame 中点（10pt 桶）`sortUsingComparator:`、visibleCells 改 `indexPathsForVisibleItemsInSections:`+isAccessibilityElement、visibleSupplementary 加 `NSAccessibilityUnignoredChildren`+isAccessibilityElement+非零 bounds、array attr count/values 仅 Children（`numberOfItemsInSection:`/单 cell）、`accessibilityIndexOfChild:`→indexPathForCell.item、hitTest 迭代 accessibilityChildren+NSPointInRect、actionNames→`@[@"AXScrollToVisible"]`、`_siblingInDirection:` 改 layout 几何导航（above/below 修正为方向 2/3）、scrollToVisible 优先首个 visible item+position 64。 |

---

## S8 主类粘合层

| UXKit 类 | OpenUXKit 文件 | 状态 | 备注 |
|---|---|---|---|
| `UXCollectionView` | `Components/Public/UXCollectionView.{h,m}` (~3000 行) + `Private/UXCollectionView+Internal.h` | 🟡 | **P9a 已对齐 batchUpdates + 可见视图管线**（见 `IDA-Notes/P9-MainClass.md`）：45-bit `_collectionViewFlags` 位段 + 26 个 delegate/dataSource respondsTo 缓存、batchUpdates 全链（`_setupCellAnimations` 准备 / `_endItemAnimations` 9 步 / `_updateWithItems:` 粘合 / `_viewAnimationsForCurrentUpdate` 6 段 / `_updateAnimationDidStop:` 收尾）、可见视图管线（`_updateCellsInRect:` 差集+回收策略+fade 路径、`layoutSubviews`、`reloadData` 延迟重建、懒 `_arrayForUpdateAction:`）、几何/滚动粘合（`setContentSize:` 驱动 document frame、`documentContentRect`、`_visibleBounds`、`clipViewBoundsDidChange:` 速度/减速检测、`_addControlled:` z 序 + floating header）按 26.4 反编译重写。**P9b 已对齐 Selection 核心**：`_selectItemsInIndexPathsSet:`/`_deselectItemsAtIndexPaths:`/`_toggleSelectionStateOfItemAtIndexPath:`/`_selectRangeOfItemsFromIndexPath:`/`_deselectAllAnimated:`/`_selectAllItems:` 重写为集合代数（shouldSelect/shouldDeselect 过滤、单选折叠、空选区保护、仅可见 cell `_setSelected:animated:`、4 委托 bit、AX 通知）；`_createPrepared*`/`_reuse*`/`_dequeue*` 已反编译（§2.8）。**P9c 已对齐**（§2.9/§3c）：dequeue/reuse set 化 + 动态阈值（`_maxNumberOfReusedViews` 公式、`_minReusedViewSize` 收缩）、`scrollWheel:` 写 `_involvesScrollWheel`（激活滚轮减速检测）、`_willStartScrolling:` 对齐、非动画 layout transition 快路径对齐；`UpdateGap.beginningRect/endingRect` 确认零代码调用点（纯外部 API）、`Animation` completion 确认 `void(^)(void)`（无需改）。**P9d 已对齐事件路由**（见 `IDA-Notes/P9-MainClass.md` §7）：`_performItemSelectionForMouseEvent:`（重置键盘 range、selected/未选/shift 三分支用 toggle/select+scrollKey+candidate-anchor、AX 通知）与 `_performItemSelectionForKey:`（layout 几何导航 + RTL、无 anchor 时 Up/Left→last·Down/Right→first、toPosition:64、删死方法 `_indexPathByMovingFromIndexPath:`）按 26.4 反编译重写。**P9d 余量**：动画式跨布局 transition 主链（`_setCollectionViewLayout:animated:isInteractive:completion:` 全链已反编译记录为 spec，§7.3；无 showcase 触发点，待移植）、reuse-pool 专项测试（reuse 池本身 P9c 已对齐，仅缺集成测试）。 |
| `UXCollectionViewController` | `Components/Public/UXCollectionViewController.{h,m}` + `Private/UXCollectionViewController+Internal.h` | 🟢 | P9b 末班车，10 行级 verify。 |
| `_UXCollectionView` | `Components/Private/_UXCollectionView.{h,m}` (18 行 .m) | 🟡 | UXKit 仅有 `_UXCollectionViewOverdraw` 协议实现；OpenUXKit 当前为空壳，P9b 补齐。 |
| `UXCollectionDocumentView` | `Components/Private/UXCollectionDocumentView.{h,m}` | 🟢 | **P9a**：`layout` 改为空实现（UXKit 0x4 字节实测）、`prepareContentInRect:` 去 respondsTo 包装；frame 由主类 `setContentSize:` 驱动。 |
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
- ✅ T6 Tests 脚手架（`Tests/OpenUXKitTests/Collection/` 6 个 swift 文件 + FlowLayout fixture，30 用例）
- ⬜ T7 Showcase 视觉基线（需用户手动操作）
- ✅ T8 公开 API 合同（13 符号）

---

## Phase 完成总览（截至 P11 + P9d 事件路由）

> 状态：✅ 反编译逐方法验证 ｜ 🟡 部分对齐（主体已对齐，有记录在案的余量）｜ 🟢 形式对齐（接口对应，未逐方法 verify）

| Phase | 子系统 | 状态 | 关键产物 / 余量 |
|---|---|---|---|
| **P0** | 脚手架 | ✅ | 矩阵 + 9 反编译笔记 + Tests 脚手架（30 用例）+ API 合同；T7 视觉基线待用户手动 |
| **P1** | S1a 叶子 token | ✅ | UpdateItem `_action`/compare、SectionItemIndexes（P7 一并）；ItemKey `_hash` 形式对齐 |
| **P2** | S2 LayoutAttributes/InvCtx | 🟢 | 接口/ivar 对应，`_isEquivalentTo:`/`_isTransitionVisibleTo:` 未逐句 verify |
| **P3** | S2 Layout 基类 | 🟢 | 13 ivar + transition 双阶段形式对齐 |
| **P4** | S2 FlowLayout + `_UXFlowLayout*` 4 类 | 🟡 | 算法已对齐，保留 2 处 OpenUXKit-only 简化 |
| **P5** | S3a Data 缓存 | ✅ | `IDA-Notes/P5-Data.md`，51 方法 + screen-page 缓存 |
| **P6** | S1b ReusableView/Cell/Snapshot | ✅ | `IDA-Notes/P6-ReusableView.md` |
| **P7** | S4 IndexPathsSet（+ SectionItemIndexes） | ✅ | `IDA-Notes/P7-IndexPathsSet.md`，60 方法 |
| **P8** | S3b Update/Gap + S5 Animation | ✅ | `IDA-Notes/P8-UpdateAnimation.md`，`_computeGaps` 两处方向性 bug 修复 |
| **P9** | S8 主类 | 🟡 | P9a/b/c（batchUpdates / 可见视图 / Selection 集合代数 / reuse 池 / scroll）+ **P9d 事件路由**（§7）已对齐；**余量**：动画跨布局 transition（§7.3 spec，无 showcase 触发，未移植） |
| **P10** | S6 Rearranging | 🟡 | P10a 状态机已反编译；**余量 P10b**：NSDraggingSession 完整重写（需交互拖放验证） |
| **P11** | S7 Accessibility | ✅ | `IDA-Notes/P11-Accessibility.md`，2 类 52 方法、~20 处分歧修正 |

**当前覆盖**：12 个 phase 中 **P0/P1/P5/P6/P7/P8/P11 完全反编译验证**，P4/P9/P10 主体对齐留明确余量，P2/P3 形式对齐。

### 剩余工作（均需我无法自主提供的验证条件）

1. **P9d 动画跨布局 transition** — 全链已反编译为 spec（`P9-MainClass.md` §7.3）；无 showcase 触发点，移植后需自建 layout-swap 用例间接验证。
2. **P10b Rearranging NSDragging 重写** — 状态机 P10a 已备；需交互拖放手测。
3. **reuse-pool 专项集成测试** — 池本身 P9c 已对齐；集成测试涉 scroll/timing 模拟，易 flaky。
4. **P2/P3 逐方法 verify、P4 两处简化收口** — 形式已对齐，深度 verify 为可选加固。
5. **T7 Showcase 视觉基线** — 需用户手动录屏/截图。
