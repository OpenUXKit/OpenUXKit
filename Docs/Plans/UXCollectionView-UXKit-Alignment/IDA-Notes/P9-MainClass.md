# P9 阶段反编译笔记：UXCollectionView 主类 + 视图层次对齐

> P9 phase — S8 主类粘合层。本笔记随反编译推进增量更新；每完成一个方法组立即落盘。
>
> 反编译来源：`/Volumes/Code/Dump/DyldSharedCaches/macOS/26.4/UXKit.i64`（session `uxkit_26_4`；`/Volumes/RE` 卷本次未挂载，使用 CLAUDE.md 第 2 优先级路径）。
> 导出头来源：`/Volumes/Code/Dump/DyldSharedCaches/macOS/26.4/UXKit/ObjCHeaders/`。

---

## 1. 类层次与 ivar 矩阵（D/A 步，已冻结）

### 1.1 视图层次（26.4 导出头确认）

| UXKit 类 | 继承 | OpenUXKit 现状 | 对齐 |
|---|---|---|---|
| `UXCollectionView` | `NSScrollView`（ivar 起始 offset 1168） | 同（`NSScrollView` 子类） | ✅ 形态一致 |
| `_UXCollectionView` | `UXCollectionView <_UXCollectionViewOverdraw>`，空壳转发 | 同（documentClass → `_UXCollectionDocumentView`，overdrawEnabled 转发 documentView） | ✅ |
| `UXCollectionDocumentView` | `NSView`，weak `collectionView` | 同 | ✅ |
| `_UXCollectionDocumentView` | `UXCollectionDocumentView`，`overdrawEnabled` BOOL | 同 | ✅ |
| `UXCollectionClipView` | `NSClipView`（导出头无成员） | 同（额外覆写 `_invalidateFocus` no-op） | ✅ |

### 1.2 UXCollectionView 主类 ivar 矩阵（导出头 offset 1168–1768）

OpenUXKit class extension 与导出头顺序逐一对应（P0 已对齐命名）。差异项：

| UXKit ivar (offset) | OpenUXKit 现状 | 判定 |
|---|---|---|
| `_contentSize` (1528) | 拆成 `_explicitContentSize` + `_hasExplicitContentSize` 两个 ivar | ⚠️ OpenUXKit-only 形态差（contentSize getter 语义需反编译核对） |
| `_doneFirstLayout` BOOL (1504) **且** flags.doneFirstLayout bit | OpenUXKit 仅有 BOOL `_doneFirstLayout` | ⚠️ UXKit 两处都有，bit 与 BOOL 的分工需反编译核对 |
| `_lassoInvertsSelection` (1704) | @property 合成 | ✅ |
| `_layoutSubviewsOnSetNeedsLayout` (1705) | @property 合成 | ✅ |
| `_collectionViewFlags` 位段 (1760) 45 bits | **无位段**；部分用独立 BOOL（`_needsReload`、`_needsVisibleCellsUpdate`、`_needsVisibleCellsLayoutAttributesUpdate`），26 个 delegate/dataSource respondsTo 缓存 bit 完全缺失（每次动态 `respondsToSelector:`） | ❌ 最大形态差距 |
| `_minReusedViewSize` (1488) | 有 | ✅ |
| `_normalizedSavedScrollViewPosition` (1648) | 有（未使用？待查） | ✅ 形态 |

### 1.3 `_collectionViewFlags` 45-bit 位段全表（导出头 offset 1760）

```
bit  0 delegateWillBeginScrolling
bit  1 delegateDidScroll
bit  2 delegateDidEndScrolling
bit  3 delegateDidEndScrollingAnimation
bit  4 delegateWillBeginDeceleratingTargetContentOffset
bit  5 delegateDidEndDecelerating
bit  6 delegateShouldSelectItemAtIndexPath
bit  7 delegateShouldDeselectItemAtIndexPath
bit  8 delegateDidSelectItemAtIndexPath
bit  9 delegateDidDeselectItemAtIndexPath
bit 10 delegateSelectionWillAddAndRemove
bit 11 delegateSelectionDidAddAndRemove
bit 12 delegateSectionsForSelectAllAction
bit 13 delegateMouseDownWithEvent
bit 14 delegateItemWasDoubleClickedAtIndexPathWithEvent
bit 15 delegateItemWasRightClickedAtIndexPathWithEvent
bit 16 delegateWillDisplayCell
bit 17 delegateDidEndDisplayingCellForItemAtIndexPath
bit 18 delegateDidEndDisplayingSupplementaryViewForElementOfKindAtIndexPath
bit 19 delegateDidPrepareForOverdraw
bit 20 delegateTargetContentOffsetForProposedContentOffset
bit 21 delegateTargetContentOffsetOnResizeForProposedContentOffset
bit 22 delegateAllowedDropPositionsForItemsAtIndexPathsMovedToIndexPath
bit 23 delegateDragOperationForItemsAtIndexPathsMovedOntoItemAtIndexPath
bit 24 dataSourceNumberOfSections
bit 25 dataSourceViewForSupplementaryElement
bit 26 reloadSkippedDuringSuspension
bit 27 scheduledUpdateVisibleCells
bit 28 scheduledUpdateVisibleCellLayoutAttributes
bit 29 allowsSelection            （注意：与 @synthesize _allowsSelection 并存，分工待核对）
bit 30 allowsMultipleSelection    （同上）
bit 31 fadeCellsForBoundsChange
bit 32 updatingLayout
bit 33 needsReload
bit 34 reloading
bit 35 skipLayoutDuringSnapshotting
bit 36 skipCellsUpdateDuringResizing
bit 37 layoutInvalidatedSinceLastCellUpdate
bit 38 doneFirstLayout
bit 39 loadingOffscreenViews
bit 40 updating
bit 41 accessibilityDelegateShouldPrepareAccessibilitySection
bit 42 accessibilityDelegateAXRoleDescription
bit 43 viewIsPrepared
bit 44 performingHitTest
```

OpenUXKit 现状映射：bit 26→无（`reloadData` 在挂起时直接置 `_needsReload`）、bit 27/28→`_needsVisibleCellsUpdate`/`_needsVisibleCellsLayoutAttributesUpdate`、bit 33→`_needsReload`、bit 38→`_doneFirstLayout`、其余 40 个 bit 缺失。

### 1.4 OpenUXKit 现状的主要功能性简化（D 步盘点，R 步处理）

1. `_updateWithItems:` → 直接 `reloadData`（注释承认是占位）
2. `_viewAnimationsForCurrentUpdate` → 自创算法（遍历 allVisibleViewsDict 对比新旧 attributes），不消费 `_currentUpdate` 的 oldGlobalItemMap/newGlobalItemMap/gaps，不使用 AnimationContext
3. `_setupCellAnimations` → 仅为 upcoming attributes 建 view，无快照、无 UpdateGap.beginningRect/endingRect 写入
4. `_updateVisibleCellsNow:` → 直接 `_updateCellsInRect:[self documentVisibleRect]`，忽略 `now` 参数与 scheduled flags
5. `performBatchUpdates:` 主链与 UXKit 9 步顺序不一致（无 `_updateWithItems:` 调用、`_prepareLayoutForUpdates` 不在链中、completion 自行计数而非 `_updateAnimationDidStop:`）
6. 无 delegate flags 缓存（`setDelegate:`/`setDataSource:` 覆写缺失）
7. `layoutSubviews` 仅做 first-layout reload，无完整布局管线

## 2. 方法算法对照（M 步，增量填写）

### 2.1 batchUpdates 主链（M1，已全部反编译）

UXKit 真实调用拓扑（与 OpenUXKit 现状完全不同）：

```
performBatchUpdates:completion: (0x1dbbd3a50, 0x16c)
 ├─ if (![self _visible]):
 │    flags |= bit33(needsReload); updates(); completion(YES); return   ← 不可见快速路径
 ├─ _updateCompletionHandler = copy( ^(BOOL f){ old(f); completion(); } )   ← 与旧 handler 组合（block 0x1dbbd3bbc）
 ├─ _beginUpdates
 ├─ updates()
 ├─ if (!_collectionViewData.layoutIsPrepared):
 │    [_collectionViewData validateLayoutInRect:[self _visibleBounds]]
 │    [_collectionViewData _prepareToLoadData]
 └─ _endUpdates

_beginUpdates (0x1dbbd3cdc)
 ├─ if (_updateCount@1376 == 0) [self _setupCellAnimations]
 └─ _updateCount++

_endUpdates (0x1dbbd3cbc)
 └─ if (--_updateCount == 0) [self _endItemAnimations]

_setupCellAnimations (0x1dbbd856c, 仅 0x60)   ← 与 OpenUXKit 职责完全不同：只做准备
 ├─ [self _updateVisibleCellsNow:NO]
 ├─ [_collectionViewData _prepareToLoadData]
 ├─ flags |= bit40(updating)
 └─ [self _suspendReloads]

_endItemAnimations (0x1dbbd6b70, 0x19fc)   ← 真正的 9 步主战场（见 §2.2）

_updateRowsAtIndexPaths:updateAction: (0x1dbbd8694) / _updateSections:updateAction: (0x1dbbd88c0)
 ├─ if (![self _visible]) { flags |= bit33(needsReload); return; }
 ├─ [self _reloadDataIfNeeded]
 ├─ BOOL wasUpdating = flags & bit40(updating)
 ├─ if (!wasUpdating) [self _setupCellAnimations]      ← 不经 _begin/_endUpdates！
 ├─ 逐个 [UXCollectionViewUpdateItem initWithAction:forIndexPath:] 加入 _arrayForUpdateAction:
 │    · section 操作的 indexPath = [NSIndexPath indexPathForItem:NSNotFound inSection:section]（双层，非单层 indexPathWithIndex:）
 └─ if (!wasUpdating) [self _endItemAnimations]

_arrayForUpdateAction: (0x1dbbd8a04)
 └─ 懒初始化：0→_insertItems@1384 / 1→_deleteItems@1392 / 2→_reloadItems@1400 / 3→_moveItems@1408；
    无效 action → NSAssert（file "UXCollectionView.m" line 5190, "Invalid update action encountered %ld"）

_prepareLayoutForUpdates (0x1dbbd6a88)
 └─ [_layout prepareForCollectionViewUpdates:
       sorted(_originalDeleteItems@1424) + sorted(_originalInsertItems@1416)
     + sorted(_reloadItems@1400) + sorted(_moveItems@1408)]
    （sortedArrayUsingSelector: 同 P8 未映射 selector 0x1FA0BE260，推定 compareIndexPaths:）

_updateWithItems: (0x1dbbd40e0, 0x330)   ← batchUpdates 收尾粘合（由 _endItemAnimations 调用）
 ├─ 用 _currentUpdate 的 _oldGlobalItemMap（Update ivar @152，C 数组）建 indexPath 重映射 block（0x1dbbd4410）：
 │    adjust(ip) = oldMap[oldModel(@24).globalIndexForItemAtIndexPath:ip] == NSNotFound
 │                 ? nil : [_collectionViewData indexPathForItemAtGlobalIndex:newGlobalIndex]
 │    （此时 _collectionViewData 已是新 model）
 ├─ 用 adjust 重建 4 个 IndexPathsSet 容器（0x1dbbd4494：新建 mutable set 枚举旧 set，非 nil 才 add）：
 │    @1184 _indexPathsForSelectedItems / @1264 _pendingDeselectionIndexPaths
 │    / @1696 _lassoInitiallySelectedItems / @1712 _keyboardRangeSelectionPreviouslySelectedItems
 ├─ 用 adjust 重映射 4 个 NSIndexPath：
 │    @1256 _pendingSelectionIndexPath / @1248 _lastSelectionAnchorIndexPath
 │    / @1720/_1728 keyboardRangeSelectionFirst/LastSelectedItem
 ├─ [self _prepareLayoutForUpdates]
 ├─ [_currentUpdate _computeSupplementaryUpdates]        ← ★ P8 合同解决：唯一触发点
 ├─ proposed = _currentUpdate@72/@80（CGPoint）
 │    → [_layout updatesContentOffsetForProposedContentOffset:]
 │    → [_layout targetContentOffsetForProposedContentOffset:]
 │    → if (flags bit20) [delegate _collectionView:targetContentOffsetForProposedContentOffset:]
 │    → 写回 _currentUpdate@72/@80
 ├─ context = [UXCollectionViewAnimationContext initWithCompletionHandler:_updateCompletionHandler]；
 │    _updateCompletionHandler = nil
 ├─ ++_suspendClipViewBoundsDidChange@1752
 ├─ [NSAnimationContext runAnimationGroup:block_615 completionHandler:block_619]
 └─ _currentUpdate = nil（在动画组提交后立即清空！）

block_615（动画组主体 0x1dbbd453c）：
 ├─ if (![CATransaction disableActions]) { ctx.allowsImplicitAnimation=YES; ctx.duration=0.25; }
 ├─ if (!ctx.timingFunction) ctx.timingFunction = Linear
 ├─ ++_updateAnimationCount@1224；context.animationCount++       ← 哨兵计数（防 animationCount 提前归零）
 ├─ [self setContentSize:[_layout collectionViewContentSize]]
 ├─ [self.contentView setBoundsOrigin:_currentUpdate@72/@80]      ← 应用 targetContentOffset
 ├─ 嵌套 [NSAnimationContext runAnimationGroup:block_616 completionHandler:nil]：
 │    block_616（0x1dbbd4a48）: { ctx.allowsImplicitAnimation=NO; ctx.duration=0;
 │      context.viewAnimations = [self _viewAnimationsForCurrentUpdate]; }   ← ★ P8 合同解决：viewAnimations 组装点（零时长嵌套组内）
 ├─ remaining = [NSMutableSet setWithArray:_allVisibleViewsDict.allValues]；[dict removeAllObjects]
 ├─ for animation in context.viewAnimations:
 │    view = animation.view
 │    if (![view isKindOfClass:_UXCollectionSnapshotView]):
 │        [view _addUpdateAnimation]；[remaining removeObject:view]
 │        if (!animation.deleteAfterAnimation):
 │            dict[[_UXCollectionViewItemKey keyForLayoutAttributes:animation.finalLayoutAttributes]] = view   ← ★ deleteAfterAnimation 消费点 1
 │    context.animationCount++；++_updateAnimationCount@1224
 │    [animation addCompletionHandler: ^{ [self _updateAnimationDidStop:nil finished:@(f) context:context] }]（block_3 0x1dbbd4aa4）
 │    [animation start]
 ├─ for view in remaining：
 │    [view _isInUpdateAnimation] ? dict[keyFor(view._layoutAttributes)] = view
 │                                : (_isCell ? _reuseCell: : _reuseSupplementaryView:)
 └─ [_layout finalizeCollectionViewUpdates]

block_619（动画组 completion 0x1dbbd49dc）：
 └─ --_suspendClipViewBoundsDidChange；[self _updateAnimationDidStop:nil finished:@YES context:context]   ← 哨兵的配对递减

_updateAnimationDidStop:finished:context: (0x1dbbd3d20, 0x368)   ← ★ P8 合同解决：4 flag 消费顺序
 ├─ context.animationCount--；--_updateAnimationCount@1224
 ├─ if (context.animationCount != 0) return            ← 最后一个动画才收尾
 ├─ for animation in context.viewAnimations（跳过 _UXCollectionSnapshotView）:
 │    [view _clearUpdateAnimation]
 │    if (animation.resetRasterizationAfterAnimation)
 │        view.layer.shouldRasterize = animation.rasterizeAfterAnimation   ← flag 消费点
 │    if (![view _isInUpdateAnimation] && !animation.deleteAfterAnimation
 │        && !CGRectIntersectsRect(view.frame, [self _visibleBounds]))
 │        [dict removeObjectForKey:keyFor(view._layoutAttributes)]          ← 移出可见区的存活 view 出表
 │    if (![dict.allValues containsObject:view] && ![view _isInUpdateAnimation])
 │        viewType==1 ? _reuseCell: / viewType==2 ? _reuseSupplementaryView:
 │        / else NSAssert（line 6249，文本 “UICollectionView finished animating a view of unknown type: %@” ← UXKit 源码自 UIKit 移植的直接痕迹，保留原文）
 ├─ [self performWithoutAnimation:block]（0x1dbbd4088，待反编译）
 └─ handler = context.completionHandler；if (handler) handler(finished.boolValue)
```

### 2.2 `_endItemAnimations` (0x1dbbd6b70, 0x19fc) —— batchUpdates 真身（9 步）

```
- (void)_endItemAnimations {
    ++_updateCount@1376;                       // 重入保护（整个函数体内 begin/end 不再触发）
    _doubleClickContext@1736 = nil;
    if (!_collectionViewData@1272) goto cleanup;

    // === 步 1：模型换代 ===
    oldModel = _collectionViewData; [oldModel setLayoutLocked:YES];
    _collectionViewData = [[UXCollectionViewData alloc] initWithCollectionView:self layout:_layout];

    // === 步 2：取出并排序四族（汇编确认 selector）===
    sortedDeletes = [[self _arrayForUpdateAction:1] sortedArrayUsingSelector:SEL@0x1FA020260]   // 降序（inverseCompareIndexPaths: 推定）
    sortedInserts = [[self _arrayForUpdateAction:0] sortedArrayUsingSelector:SEL@0x1FA0BE260]   // 升序（compareIndexPaths: 推定）
    reloadMutable = [[_reloadItems sorted:升序] mutableCopy]; moveMutable = [[_moveItems sorted:升序] mutableCopy];
    _originalDeleteItems@1424 = [sortedDeletes copy];        // ← 降序快照
    _originalInsertItems@1416 = [sortedInserts copy];        // ← 升序快照

    // === 步 3：reload → delete+insert 拆解 ===
    for (reloadItem in reloadMutable) {
        section = ip.section, item = ip.item;
        for (deleteItem in sortedDeletes) {                  // 按既有 delete 左移
            if ([dip isEqual:ip]) assert(5356 "attempt to delete and reload the same index path (%@)");
            if (deleteItem._isSectionOperation && dip.section == ip.section) continue;
            if (deleteItem._isSectionOperation) section -= (dip.section <= section);
            if (!reloadItem._isSectionOperation && !deleteItem._isSectionOperation && dip.section == section)
                item -= (dip.item <= item);
        }
        for (insertItem in sortedInserts) {                  // 按既有 insert 右移
            if (insertItem._isSectionOperation && iip.section <= section) ++section;
            if (!reloadItem._isSectionOperation && !insertItem._isSectionOperation
                && iip.section == section && iip.item <= item) ++item;
        }
        [_deleteItems addObject:[UpdateItem initWithAction:1 forIndexPath:原 ip]];
        insertItem = [UpdateItem initWithAction:0 forIndexPath:(item, section)调整后];
        [reloadItem _setNewIndexPath:insertItem._indexPath];
        [_insertItems addObject:insertItem];
    }

    // === 步 4：合并重排 ===
    deletesAll = [[_deleteItems sorted:0x1FA020260 降序] mutableCopy];
    insertsAll = [[_insertItems sorted:0x1FA0BE260 升序] mutableCopy];

    // === 步 5：三族验证（assert 行号/文本全表）===
    // deletes（对 oldModel）：
    //   5397 "attempt to delete section %ld, but there are only %ld sections before the update"
    //   （section-delete 时把同 section 的 item-delete 从 deletesAll 中移除）
    //   5418 "attempt to perform a delete and a move from the same section (%ld)"
    //   5421 "attempt to perform a delete and a move from the same index path (%@)"
    //   5425 "cannot move an item from a deleted section (%ld)"
    //   5433 "attempt to delete item %ld from section %ld, but there are only %ld sections before the update"
    //   5437 "attempt to delete item %ld from section %ld which only contains %ld items before the update"
    // inserts（对 newModel = _collectionViewData）：
    //   5447 "attempt to insert section %ld but there are only %ld sections after the update"
    //   （section-insert 时移除同 section 的 item-insert）
    //   5468 "attempt to perform an insert and a move to the same section (%ld)"（对 move._newIndexPath）
    //   5471 "attempt to perform an insert and a move to the same index path (%@)"
    //   5475 "cannot move an item into a newly inserted section (%ld)"
    //   5481 "attempt to insert item %ld into section %ld, but there are only %ld sections after the update"
    //   5482 "attempt to insert item %ld into section %ld, but there are only %ld items in section %ld after the update"
    // moves（from 对 oldModel / to 对 newModel）：
    //   5494/5495（section move 越界 before/after）、5498/5499/5500/5501（item move 越界）
    //   完全重复 move → 静默去重；部分重复 →
    //   5516 "attempt to move section %ld to both section %ld and section %ld"
    //   5519 "attempt to move item at index path %@ to both %@ and %@"
    //   5525 "attempt to move both section %ld and section %ld to section %ld"
    //   5528 "attempt to move both item at index path %@ and %@ to %@"

    // === 步 6：组装总 updateItems ===
    allItems = sorted(deletesAll, 0x1FA020260 降序) + moveMutable + sorted(insertsAll, 0x1FA0BE260 升序);
    // → P8 _computeGaps 输入顺序之源：降序 deletes + moves + 升序 inserts

    // === 步 7：layout 失效化 + 新模型装载 ===
    ctx = [[[_layout class] invalidationContextClass] new];
    [ctx _setInvalidateDataSourceCounts:YES];
    [ctx _setUpdateItems:allItems];
    [_layout _invalidateLayoutUsingContext:ctx];
    [_collectionViewData _prepareToLoadData];
    [_collectionViewData validateLayoutInRect:[self _visibleBounds]];

    // === 步 8：计算 newVisibleBounds（视口贴边修正）===
    visible = [self documentVisibleRect];
    content = [_collectionViewData collectionViewContentRect]; content.size += contentInsets（宽高各加两侧）;
    newOrigin = visible.origin;
    if (!CGRectContainsRect(content, visible)) {
        if (MaxY(visible) > MaxY(content) && Height(content) > Height(visible)) newOrigin.y -= MaxY(visible)-MaxY(content);
        if (MaxX(visible) > MaxX(content) && Width(content) > Width(visible))  newOrigin.x -= MaxX(visible)-MaxX(content);
    }

    // === 步 9：建 Update、双重计数一致性验证、收尾 ===
    _currentUpdate@1280 = [[UXCollectionViewUpdate alloc] initWithCollectionView:self updateItems:allItems
                            oldModel:oldModel newModel:_collectionViewData
                            oldVisibleBounds:visible newVisibleBounds:{newOrigin, visible.size}];
    // C 数组统计：oldCounts[] / insertedPerSection[]（以新 section 索引）/ deletedPerSection[]（旧）
    //            / movedInPerSection[]（新）/ movedOutPerSection[]（旧）
    // section 总数验证：assert 5623 "Invalid update: invalid number of sections. …(%d inserted, %d deleted)."
    // 逐 section（经 _currentUpdate ivar @144 的 new→old section map，NSNotFound 跳过）：
    //   assert 5635 "…Attempt to delete more items than exist in section."（newCount < 0）
    //   assert 5639 "…(%d moved in, %d moved out)."（newCount != old + ins - del + movedIn - movedOut）
    // 验证失败 → 不调用 _updateWithItems:（直接 cleanup；_currentUpdate 残留由后续覆盖）
    if (ok) [self _updateWithItems:allItems];

cleanup:
    --_updateCount;
    _insertItems = _deleteItems = _reloadItems = _moveItems = nil;
    _originalDeleteItems = _originalInsertItems = nil;
    flags &= ~bit40(updating);
    [self _resumeReloads];
}
```

### 2.3 `_viewAnimationsForCurrentUpdate` (0x1dbbd4b5c, 0x1668) —— 动画生成核心（6 段）

依赖 `_currentUpdate`（U）的 ivar：@24 oldModel / @32 newModel / @72,@80 newVisibleBounds.origin /
@120 deletedSections(NSIndexSet) / @136 old→new sectionMap(C 数组) / @144 new→old sectionMap /
@152 oldGlobalItemMap(old→new) / @160 newGlobalItemMap(new→old) /
@168 deletedSupplementaryIndexesSectionArray / @176 insertedSupplementaryIndexesSectionArray /
@184 deletedGlobalSupplementary(kind→indexSet，单层 indexPath) / @192 insertedGlobalSupplementary(kind→indexSet)。

动画判定矩形 `animRect = {U@72, U@80, _visibleBounds.size}`（新 origin + 当前可见 size）。

```
- (NSArray *)_viewAnimationsForCurrentUpdate {
    oldViews = dict.allValues;  newDict = [NSMutableDictionary new];
    // 段 0：初始迁移（block 0x1dbbd61c4）——对 dict 每项：
    //   cell：oldGlobal→U@152→newGlobal（NSNotFound 丢弃）→ newKey(newIP, type/identifier/isClone 保留) → newDict
    //   supplementary：indexPath.length==1 原样搬；否则 section 经 U@136 重映射（NSNotFound 丢弃）
    animations = []; processedOldGlobals = [NSMutableIndexSet]; animatedNewGlobals = [NSMutableIndexSet];

    // 段 1：DELETE（遍历 _deleteItems）
    //   item op → deleteCell(oldGlobal)（block_584）：
    //     view = dict[keyForCell(oldIP)]; 无 view 跳过
    //     final = [_layout finalLayoutAttributesForDisappearingItemAtIndexPath:] ?: copy(view._layoutAttributes)+alpha0
    //     Animation(view, viewType:1, final, 0→1, fromCurrent:YES, deleteAfter:YES,
    //               custom:[_layout _animationForReusableView:view toLayoutAttributes:final type:2])
    //     [dict removeObjectForKey:]; [animations add]
    //   section op → 对该 section 旧 items 逐个 deleteCell（global 连续段，assert 5758）
    //     + 对 [oldModel existingSupplementaryLayoutAttributesInSection:] 中有 view 的生成同款消失动画（viewType:2）

    // 段 2：INSERT（遍历 _insertItems）
    //   item op → insertCell(newGlobal)（block_591）：
    //     initial = [_layout initialLayoutAttributesForAppearingItemAtIndexPath:] ?: copy(newAttrs)+alpha0
    //     过滤：CGRectIntersectsRect(animRect, union(initial.frame,newAttrs.frame)) && !(initial.hidden && newAttrs.hidden)
    //     view = _createPreparedCellForItemAtIndexPath:withLayoutAttributes:initial applyAttributes:YES
    //     Animation(view, viewType:1, final=newAttrs, 0→1, fromCurrent:NO, deleteAfter:NO, custom:…)
    //     newDict[keyForCell(newIP)] = view
    //   section op → 新 section 逐 item insertCell（assert 5815）+ 新 section supplementary 同构（viewType:2）

    // 段 3：存活/move cell 收集（movedAttributes 数组）
    //   3a. 旧 dict 中存活 view（仍在 oldViews 且 _isCell）：oldGlobal→U@152 仍存在 → addObject(newModel attrs)；
    //       processedOldGlobals += oldGlobal（无论是否存活）
    //   3b. [newModel layoutAttributesForElementsInRect:animRect] 中的 cell：
    //       newGlobal→U@160 有旧位（≠NSNotFound）且旧位不在 processedOldGlobals → addObject（滚动进入的 move）

    // 段 4：movedAttributes → 双侧动画
    //   oldAttrs = [oldModel layoutAttributesForGlobalItemIndex:oldGlobal]
    //              ?: dict[oldKey]._layoutAttributes ?: [_layout initialLayoutAttributesForAppearingItemAtIndexPath:newIP] ?: copy(newAttrs)+alpha0
    //   过滤同段 2；view = dict[oldKey] ?: _createPreparedCell(newIP, oldAttrs)（双 hidden 跳过；新建登记 newDict）
    //   zIndex 变化 → [_addControlled:YES subview:view atZIndex:newAttrs.zIndex]
    //   animations += [_doubleSidedAnimationsForView:view withStarting:oldAttrs startingLayout:_layout
    //                  ending:newAttrs endingLayout:_layout setup:nil completion:nil
    //                  enableCustomAnimations:YES customAnimationsType:2]
    //   assert(!animatedNewGlobals.contains, 5934 "attempt to create two animations for new global item index %ld")

    // 段 5：存活/删除 supplementary（遍历 [oldModel existingSupplementaryLayoutAttributes]）
    //   section 已删（U@120）→ 跳过（section 整删时段 1 已处理）
    //   deleted 判定：单层 → U@184[kind] 含 index；双层 → U@168[section][kind] 含 item
    //   未删：newIP = [U newIndexPathForSupplementaryElementOfKind:kind oldIndexPath:ip]   ← P0 悬案：调用点在此
    //     newRect = [newModel rectFor(Supp|Deco)ElementOfKind:atIndexPath:newIP]；过滤同上
    //     view = [_visibleSupplementaryViewOfKind:kind atIndexPath:旧 ip isDecorationView:] ?: _createPrepared(newIP, oldAttrs)（登记 newDict）
    //     floating/zIndex 变化 → _addControlled:
    //     newAttrs 非 nil → 双侧动画；nil → 消失动画（final=finalLayoutAttributesForDisappearing…，deleteAfter:YES）+ dict 移除
    //   已删：final = finalLayoutAttributesForDisappearing(Supp|Deco)…；交可见区且有 view → 消失动画 + dict 移除

    // 段 6：新插入 supplementary
    //   per-section 表：遍历 [newModel existingSupplementaryLayoutAttributesWithMinimalIndexPathLength:2]，
    //     section < newModel.numberOfSections 且 U@176[section][kind] 含 item → appearAnimation（block_597）：
    //       initial = initialLayoutAttributesForAppearing(Supp|Deco)…（无 ?:copy+alpha0 回退？有——nil 时直接用？
    //       注意 block_597 无 nil 回退分支：initial 为 nil 时 union 用 zero rect）
    //       过滤交可见区 → _createPrepared(ip, initial) → newDict 登记 → 无条件 _addControlled:YES atZIndex:attrs.zIndex
    //       → Animation(view, viewType:2, final=attrs, 0→1, fromCurrent:NO, deleteAfter:NO, custom:…)
    //   全局表：U@192 enumerate（block_601）：每 kind 的 indexSet 逐 index，
    //     kind ∈ newModel.knownDecorationElementKinds ? Deco : Supp 取 attrs（indexPathWithIndex:），调 block_597

    _allVisibleViewsDict = newDict;        // ← 整体替换（注意旧 dict 中未迁移项已在 block_615 的 remaining 集合处理）
    return animations;
}
```

OpenUXKit 现状差距（M1 结论）：
1. ❌ `performBatchUpdates:` 自建管线（手动建新 Data/Update、自行计数 completion），与 UXKit 拓扑完全不同
2. ❌ `_setupCellAnimations` 职责错位（OpenUXKit 在其中创建 upcoming views——UXKit 这是 `_viewAnimationsForCurrentUpdate` 的事）
3. ❌ `_endItemAnimations` 退化为一行（真身 6.6KB 在 OpenUXKit 完全缺失）
4. ❌ `_updateWithItems:` 退化为 reloadData
5. ❌ `insertItems…/deleteItems…` 等公开方法包了一层 performBatchUpdates（UXKit 直接走 `_updateRows…`，靠 updating bit 决定独立/批量）
6. ❌ section 操作 indexPath 形态（单层 vs item=NSNotFound 双层）
7. ❌ `_arrayForUpdateAction:` 预分配 vs 懒初始化 + assert
8. ❌ completion 组合链、AnimationContext、`_updateAnimationDidStop:` 全缺位

### 2.4 可见视图管线（M2）

```
_updateVisibleCellsNow: (0x1dbbe0da0)
 └─ [self _updateCellsInRect:[self documentVisibleRect] createIfNecessary:now]   ← now 参数透传为 create！

layoutSubviews (0x1dbbdd92c)
 ├─ if (flags & (bit32 updatingLayout | bit35 skipLayoutDuringSnapshotting)) return
 ├─ [self _reloadDataIfNeeded]
 ├─ [_collectionViewData validateLayoutInRect:[self _visibleBounds]]
 ├─ if ((flags & bit27 scheduledUpdateVisibleCells) && _reloadingSuspendedCount == 0)
 │    @autoreleasepool { [self _updateVisibleCellsNow:YES] }
 └─ flags |= bit38 doneFirstLayout

setNeedsLayout (0x1dbbe2434)
 └─ layoutSubviewsOnSetNeedsLayout ? [self layoutSubviews] : [self setNeedsLayout:YES]

_setNeedsVisibleCellsUpdate:withLayoutAttributes: (0x1dbbe2390)
 ├─ bit27 |= needsUpdate；bit28 |= withAttributes（OR 累积，不清除）
 └─ if (bit27|bit28 最终非零) [self setNeedsLayout]

reloadData (0x1dbbe2074)
 ├─ if (_reloadingSuspendedCount > 0) { flags |= bit26 reloadSkippedDuringSuspension; return }
 ├─ flags |= bit34 reloading；[self _suspendReloads]
 ├─ 回收所有非 _isInUpdateAnimation 的 view（cell→_reuseCell:，其余→_reuseSupplementaryView:）；动画中的保留在 dict
 ├─ [@1472 removeAllObjects]（_supplementaryElementKinds——UXKit 把它当“当前出现过的 kinds”缓存清空）
 ├─ 清 _indexPathsForSelectedItems / _pendingSelection / _pendingDeselection / _lastSelectionAnchor / keyboardRange 三件套
 ├─ [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:YES]；[self _invalidateLayoutIfNecessary]
 ├─ [_collectionViewData invalidate:NO]
 ├─ flags &= ~(bit33 needsReload | bit34 reloading)
 ├─ if (!allowsEmptySelection)：选第一个 selectable（toPosition:64，notifyDelegate:YES，成功后回填 anchor + keyboardRange 三件套）
 └─ [self _resumeReloads]
 ※ UXKit reloadData 不直接重建 view、不改 document frame —— 重建延迟到 layoutSubviews→_updateVisibleCellsNow:YES

_reloadDataIfNeeded (0x1dbbe3ce4)
 └─ if ((flags & bit33) && !(_reloadingSuspendedCount || (flags & bit34))) [self reloadData]

_suspendReloads / _resumeReloads (0x1dbbe241c / 0x1dbbe23dc)
 ├─ ++count / --count（无下限保护）
 └─ resume 归零时：bit26 置位 → 清 bit26 + reloadData；否则 bit27 置位 → setNeedsLayout

_updateCellsInRect:createIfNecessary: (0x1dbbdf818, 0xe1c) —— 滚动/布局核心循环
 ├─ 守卫：_reloadingSuspendedCount>0 / _updateAnimationCount>0 / flags&(bit32|bit36) → return
 ├─ if ([NSAnimationContext _hasActiveGrouping]) flags.bit31(fade) |= flags.bit37(layoutInvalidatedSinceLastCellUpdate)
 ├─ [self _suspendReloads]
 ├─ fade 路径前置：[_layout prepareForAnimatedBoundsChange:_previousBounds]；
 │    target = [_layout targetContentOffsetForProposedContentOffset:contentOffset]（bit20 → delegate 覆写）；
 │    与 _lastContentOffset@1512 不同 → 写回 + setBoundsOrigin + rect=[self _visibleBounds]
 ├─ attrs = [data layoutAttributesForElementsInRect:rect]
 ├─ overdraw 扩展：!inLiveResize && !_scrolling@1552 && extraPreload>0 && attrs.count>0 →
 │    rect 按 -(size*extra/count) CGRectInset 后重取 attrs
 ├─ if (create) flags &= ~(bit27|bit31)；[self setContentSize:[data collectionViewContentRect].size]
 ├─ fade：收集旧 attrs（copy+sort 比较器 block 2822）+新 attrs deep copy →
 │    [_layout _prepareToAnimateFromCollectionViewItems:atContentOffset:_lastContentOffset toItems:atContentOffset:contentOffset]
 ├─ 差集三组：existing（dict 命中）/ leftover（dict 剩余）/ newAttrs（无 view）
 ├─ 回收策略：!inLiveResize && existing+leftover+new < purgingCellsThreshold → leftover 并回 existing 不回收
 ├─ leftover 回收（block 342）：跳过动画中的；fade → final attrs + 双侧动画后 reuse（block 350）；否则直接 reuse
 ├─ if (create)：对 newAttrs 逐个
 │    fade → initial(layout 钩子 ?: copy+alpha0)，双 hidden 跳过，createPrepared(…, initial, applyAttributes:YES) + block_4 动画
 │    非 fade → attrs.isHidden 跳过，createPrepared(…, attrs, applyAttributes:NO)，
 │      performWithoutAnimation:{ [view _setLayoutAttributes:attrs]；[self _addControlled:!attrs.isFloating subview:view atZIndex:attrs.zIndex] }
 │      （block 354；controlled = !isFloating）→ dict 登记
 ├─ if (flags & bit26) goto cleanup（即将整体 reload，不必刷新）
 ├─ _visibleBounds@1288 = [self documentVisibleRect]      ← _visibleBounds 唯一系统写入点
 ├─ if (flags & bit28)：对 existing 逐个取新 attrs（按 key.type 1/2/3 分派 item/supp/deco）
 │    非 fade（或任一 floating）：newA.isHidden → 移出 dict（动画中的放回）+ reuse；否则 performWithoutAnimation 应用（block 356）
 │    fade：floating/zIndex 变化 → _addControlled:YES…；_doubleSidedAnimationsForView(setup=++_resizeAnimationCount@1368,
 │      completion=--count，归零时 _resizeBoundsOffset@1352=Zero + _setNeedsVisibleCellsUpdate:YES,YES + _lastLayoutOffset=contentOffset,
 │      enableCustomAnimations:NO type:0) 全部 start
 ├─ fade 收尾：[_layout _finalizeCollectionViewItemAnimations]；[_layout finalizeAnimatedBoundsChange]
 ├─ flags &= ~bit28
 └─ cleanup：_lastLayoutOffset@1768 = contentOffset；flags &= ~bit37；[self _resumeReloads]
```

### 2.5 基础设施方法（M2 补充）

```
_doubleSidedAnimationsForView:withStartingLayoutAttributes:startingLayout:endingLayoutAttributes:endingLayout:
    withAnimationSetup:animationCompletion:enableCustomAnimations:customAnimationsType: (0x1dbbdf1a4)
 ├─ final = [startingLayout finalLayoutAttributesForDisappearing(Item|Supp|Deco)…:startAttrs.indexPath]（Deco 取 copy）
 ├─ initial = [endingLayout initialLayoutAttributesForAppearing(Item|Supp|Deco)…:endAttrs.indexPath]
 ├─ final 为 nil：initial 与 startAttrs _isEquivalentTo: 且 endAttrs 非 nil → final=endAttrs；否则 copy(startAttrs)+alpha0
 ├─ initial 为 nil：final 与 endAttrs equivalent 检查后 copy(endAttrs)+alpha0（结果未实际使用——形态保留）
 ├─ viewType = endAttrs._isCell ? 1 : 2
 └─ 返回单元素数组：[block(view, endingLayout, endAttrs, snapshot:NO, 0)]
    block (0x1dbbdf3c0)：
      非 snapshot：custom = enableCustom ? [endingLayout _animationForReusableView:view toLayoutAttributes:endAttrs type:customType] : nil
        Animation(view, viewType, endAttrs, 0→1, fromCurrent:NO, deleteAfter:NO, custom) + addStartupHandler:setup + addCompletionHandler:completion
      snapshot(a5=1，batchUpdates 入口不触发，layout transition 用 → P9b)：
        flags |= bit35；建 _UXCollectionSnapshotView(frame=view.frame, wantsLayer, redrawPolicy=1, _markAsDequeued)
        + 内容 NSView(layer.contents=[view _snapshot:NO], autoresizingMask 18)；flags &= ~bit35
        performWithoutAnimation × 2（接入视图层次/隐藏原 view，block 0x1dbbdf738/0x1dbbdf758）
        Animation(snapshotView, viewType:0, …) + completion(block 0x1dbbdf7ac)

_addControlled:subview:atZIndex: (0x1dbbda984)
 ├─ controlled=YES：view.isFloatingPinned=NO；view.hidden=NO；
 │    已在 documentView 则不动；否则按 zIndex 找插入位置：
 │    末尾 subview 是 ReusableView 且 zIndex<=目标 且非 hidden → addSubview:（顶端）
 │    否则反向枚举找第一个 (ReusableView && !hidden && zIndex<=目标) → addSubview:positioned:NSWindowAbove relativeTo:它
 │    找不到 → addSubview:positioned:NSWindowBelow relativeTo:nil（垫底）
 └─ controlled=NO：未 pinned 时 view.isFloatingPinned=YES；hidden=NO；[self addFloatingSubview:view forAxis:2]
    （floating header 走 NSScrollView 浮动子视图！）

_invalidateLayoutIfNecessary (0x1dbbe1fd8)
 └─ if (_collectionViewData.layoutIsPrepared)：ctx = invalidationContextClass new；
    _setInvalidateDataSourceCounts:YES + _setInvalidateEverything:YES → [_layout _invalidateLayoutUsingContext:ctx]

_invalidateLayoutWithContext: (0x1dbbe1ed4)
 ├─ _minReusedViewSize@1488 = {1024, 1024}
 ├─ flags.bit31 = [NSAnimationContext _hasActiveGrouping]（respondsTo 守卫）
 ├─ ctx._invalidatedSupplementaryViews 非空且 !ctx.invalidateContentSize → [data invalidateSupplementaryViews:]
 │   否则 [data invalidate:(!ctx.invalidateEverything)]
 └─ flags |= bit37；[self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:YES]

setDataSource: (0x1dbbe3dd4)
 ├─ weak @1784；nil 或不同对象才处理
 ├─ bit24 = respondsTo(numberOfSectionsInCollectionView:)；bit25 = respondsTo(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)
 ├─ flags |= bit33 needsReload（无条件）
 └─ [self _invalidateLayoutIfNecessary]

setDelegate: (0x1dbbe3ebc, 0x46c，未逐条反编译)
 └─ 按 §1.3 bit0–23 缓存 UXCollectionViewDelegate 各 optional 方法 respondsTo（协议方法名与 flag 名一一对应）；
    delegate weak ivar @1792。AX delegate bit41/42 同理（setAccessibilityDelegate:）。
```

### 2.6 几何与滚动粘合（M2 收尾）

```
setContentSize: (0x1dbbde8bc)
 └─ rounded = {round(w), round(h)}；与 _contentSize@1528 及 documentSize 均相同则跳过；
    否则 _contentSize = rounded；[[self documentView] setFrameSize:rounded]   ← document frame 唯一驱动

documentContentRect (0x1dbbda878)
 └─ prepared = [documentView preparedContentRect]；visible = [self documentVisibleRect]；
    相交且 prepared.size >= visible.size → 返回 union；否则返回 visible

_visibleBounds (0x1dbbe150c)
 └─ rect = [self documentContentRect]；
    if (flags.bit39 loadingOffscreenViews || [NSAnimationContext _hasActiveGrouping])
        与 _visibleBounds@1288 相交 → union；返回 rect
    （@1288 仅在 _updateCellsInRect 中写为 documentVisibleRect）

updateLayout (0x1dbbdabe0)
 └─ @autoreleasepool { [self _updateVisibleCellsNow:YES] }

-[UXCollectionDocumentView layout] (0x1dbbbe3f0, size 0x4)
 └─ 空实现（不调 super！）——OpenUXKit 的 frame 同步 + _updateVisibleCellsNow 是自创，删

-[UXCollectionDocumentView prepareContentInRect:] (0x1dbbbe35c)
 └─ [super prepareContentInRect:rect]；[collectionView _prepareCellsForOverdraw:rect]

_prepareCellsForOverdraw: (0x1dbbda728)
 └─ 与 _lastPreparedOverdrawContentRect@1616 相同则跳过；否则记录 + (flags.bit19 → [delegate collectionView:didPrepareForOverdraw:])
    ※ 不创建 cell —— overdraw 数据流：prepareContentInRect → preparedContentRect 扩大 → documentContentRect/_visibleBounds 扩大
      → validateLayoutInRect 更大区域；cell 预创建由 _updateCellsInRect 的 extraPreload inset 扩展承担

clipViewBoundsDidChange: (0x1dbbddc8c)
 ├─ newBounds = _currentUpdate ? _currentUpdate._newVisibleBounds(@72 CGRect) : contentView.bounds
 ├─ origin 与 _lastContentOffset@1512 相同 → return
 ├─ !_scrolling@1552 && !_liveScrolling@1553 && _involvesScrollWheel@1576 && !_suspendClipViewBoundsDidChange@1752
 │    → [self _willStartScrolling:self]
 ├─ velocity：_lastScrollingDistance@1584 非零且 _lastScrollingTime@1608 非零 →
 │    _scrollingVelocity@1600(float) = sqrt(dx²+dy²)*0.001/(now-last)
 ├─ deceleration：_scrolling && _canDetectDeceleration@1578 && _involvesScrollWheel && !_decelerating@1577
 │    → _decelerating=YES + (bit4 → [delegate collectionViewWillBeginDecelerating:targetContentOffset:])
 │   else !_scrollingFromExternalControl@1579 && _decelerating → _decelerating=NO + (bit5 → DidEndDecelerating)
 ├─ 写 _lastScrollingDistance/_lastContentOffset/_lastScrollingTime
 ├─ flags.bit28 |= [_layout shouldUpdateVisibleCellLayoutAttributes]
 ├─ [_layout shouldInvalidateLayoutForBoundsChange:newBounds]
 │    ? [_layout _invalidateLayoutUsingContext:[_layout invalidationContextForBoundsChange:newBounds]]
 │    : [self updateLayout]
 ├─ (flags.bit1 && !_suspend) → [delegate collectionViewDidScroll:self]
 └─ _scrolling && !_liveScrolling && _involvesScrollWheel →
      cancel + performSelector:(推定 _didEndScrolling:) withObject:self afterDelay:0.25
      inModes:@[kCFRunLoopCommonModes, NSModalPanelRunLoopMode]（滚轮静默检测）

setContentSize getter：UXKit 无 contentSize getter 方法（导出头确认）。
```

### 2.7 Selection 算法（P9b/M5，全部反编译）

UXKit 的选区核心是**集合代数**，与 OpenUXKit 原先的 add/remove 循环根本不同。

```
_selectItemsInIndexPathsSet:set byExtendingSelection:extend animated:animated
    scrollingKeyItem:keyItem toPosition:position notifyDelegate:notify (0x1dbbe31c8)
 ├─ old = [_indexPathsForSelectedItems@1184 copy]
 ├─ 构造 requested：
 │    !set || !allowsSelection → 空集
 │    else: requested = [set mutableCopy]
 │      flags bit6(0x40) shouldSelect → 逐项 ![delegate shouldSelect] 则 remove
 │      extend → [requested addIndexPathsSet:old]
 │      !allowsMultipleSelection && requested.count>=2 → 折叠成 1：
 │        survivor = (keyItem && requested.contains(keyItem)) ? keyItem : requested.firstIndexPath
 │        removeAll；survivor 非 nil → add
 ├─ added = requested - old；removed = old - requested
 │    flags bit7(0x80) shouldDeselect → removed 中 ![delegate shouldDeselect] 则从 removed 移除
 ├─ working = [_indexPathsForSelectedItems mutableCopy]；-removed +added
 ├─ working 空 && !allowsEmptySelection：
 │    requested 空 → return NO；first=_firstSelectableItemIndexPath，nil→return NO
 │    removed.contains(first) ? removed.remove : added.add；working.add；requested.add
 ├─ added+removed == 0 → return NO
 ├─ notify：bits 10|11(0xC00) → addedArray/removedArray 物化；bit10(0x400) willAdd → assert 1392 + delegate willAdd
 ├─ commit：_indexPathsForSelectedItems = working；assert 1399 (requested == 实际)
 ├─ 仅可见 cell：[_dictionaryOfIndexPathsAndContentCells] 中 added/removed 命中者 [cell _setSelected:added.contains animated:]
 ├─ notify did：bit9(0x200) didDeselect / bit8(0x100) didSelect / bit11(0x800) didAdd(assert 1427)
 ├─ keyItem && position → scrollTo
 └─ [[_layout layoutAccessibility] accessibilityPostNotification:NSAccessibilitySelectedCellsChangedNotification]；return YES

_deselectItemsAtIndexPaths: (0x1dbbe2a94)  ← 实为"选中补集"
 ├─ toDeselect = a3（IndexPathsSet）经 shouldDeselect 过滤；空 → return NO
 ├─ surviving = _indexPathsForSelectedItems - toDeselect
 │    空 && !allowsEmptySelection：fallback = (a3.lastIndexPath ∈ toDeselect) ? a3.lastIndexPath : _firstSelectableItemIndexPath（nil→return NO）
 │      anchor=fallback；surviving.add(fallback)；assert 1615
 ├─ anchor && !surviving.contains(anchor) → anchor = surviving.firstIndexPath
 └─ [self _selectItemsInIndexPathsSet:surviving extend:NO …]；成功 → _lastSelectionAnchorIndexPath@1248=anchor + AX

_toggleSelectionStateOfItemAtIndexPath: (0x1dbbe299c)
 └─ 已选 → _deselectItems(@[ip])，成功且 anchor==ip → anchor=_keyItemForSet(selection)
    未选 → _selectItemsInIndexPathsSet:single extend:YES keyItem:ip position:64；成功 → anchor=ip

_selectRangeOfItemsFromIndexPath: (0x1dbbe307c)
 ├─ range = [_layout indexPathsForItemRangeSelectionFrom:to:]；keyItem = scroll ? _keyItemForArray(range) : nil
 ├─ [self _selectItemsInIndexPathsSet:range extend:extend keyItem:keyItem …]
 └─ candidate：从 range-去from 逆向取 _keyItemForArray，找到首个仍在选区内的项作为新 anchor 候选

_deselectAllAnimated: (0x1dbbe300c)  → anchor=nil + _selectItemsInIndexPathsSet:nil extend:NO
_selectAllItems: (0x1dbbe272c)  → bit12(byte1761&0x10) sectionsForSelectAllAction 钩子 ?: 全 section；逐 item 选；成功 → anchor=_keyItemForSet
_performItemSelectionForMouseEvent: (0x1dbbd3494)  → 重置 keyboard-range 三件套；painting 起始（无 shift/cmd 时 _isPaintingSelectionRunning=YES）；
    已选→cmd/continuous 走 deselect、否则 anchor=ip；未选→shift 走 _selectRange、cmd/continuous 走 toggle、否则 select(extend:NO keyItem:ip)
_performItemSelectionForKey: (0x1dbbd207c)  → 箭头键 0xF700-0xF703，经 _layout indexPathOfItemAbove/Below/Before/After: + userInterfaceLayoutDirection（RTL 翻转左右）；
    shift → 与 keyboardRangePreviouslySelected(@1712) 合并 _selectRange；非 shift → 单选 + 清三件套

## 2.8 dequeue/reuse 管线（P9b/M6，已反编译，记录待 P9c 精炼）

- reuse 队列实为 **NSMutableDictionary→NSMutableSet**（非 OpenUXKit 现 NSMutableArray），`_reuseCell:`/`_reuseSupplementaryView:` 用 `anyObject`/`removeObject:` 出队。
- purge 阈值**动态**：`count < ceil(frameW·frameH·8 / max(_minReusedViewSize.w·.h, 1)) + 1`；`_minReusedViewSize@1488` 在每次 reuse 时取 `min(当前, view.frame.size)` 收缩（初值 {1024,1024}，`_invalidateLayoutWithContext:` 重置）。超阈值或类不匹配 → `removeFromSuperview`；入队时 `setHidden:YES` + `_setLayoutAttributes:nil`。
- `_createPreparedCellForItemAtIndexPath:`：assert dataSource 非空(2242)/cell 非空(2250)/有 reuseIdentifier(2251)/`_wasDequeued`(2252)；apply 时 `performWithoutAnimation:{ _setLayoutAttributes + _addControlled:YES }`；尾部 `_notifyWillDisplayCellIfNeeded:`。**不恢复 selected 状态**（UXKit 依赖 dataSource；OpenUXKit 保留自有的 selected 恢复，更稳）。
- `_createPreparedSupplementaryViewForElementOfKind:`：decoration 走 `_dequeueReusableViewOfKind:…viewCategory:3` → 失败回退 `[_layout _decorationViewForLayoutAttributes:]`；supplementary 经 bit25(dataSourceViewForSupplementaryElement) gate。
- `_dequeueReusableViewOfKind:`：set 命中 → `anyObject`+`prepareForReuse`+`removeObject`；未命中 → nib（`instantiateWithOwner:`，assert 3709/3710）或 class（`initWithFrame:attrs.frame`），assert 3719；尾部 `performWithoutAnimation:{apply attrs}` + `_markAsDequeued`。
- 结论：OpenUXKit 现 array+固定阈值实现**正确性等价**，差异为容量策略与数据结构，列为 P9c 精炼项（非痛点，当前行为正确）。

## 2.9 layout transition 链 + scroll-wheel + Animation completion（P9c/M8,M10）

**`_setCollectionViewLayout:animated:isInteractive:completion:` (0x1dbbdac28, 0x930)**：
```
 if (layout == _layout) return
 ctx = [[layout.class invalidationContextClass] new]；_setInvalidateEverything:YES + _setInvalidateDataSourceCounts:YES
 [layout _invalidateLayoutUsingContext:ctx]
 // 快路径：!_visible || !(flags bit38 doneFirstLayout)
 ├─ [layout _setCollectionView:self]；[_layout _setCollectionView:nil]；_layout=layout
 ├─ _collectionViewData = new Data；_setNeedsVisibleCellsUpdate:YES,YES；completion(YES)
 // 动画路径（visible && doneFirstLayout && animated）—— 大子系统：
 ├─ newData = new Data + _prepareToLoadData
 ├─ [oldLayout _prepareForTransitionToLayout:newLayout]；[newLayout _prepareForTransitionFromLayout:oldLayout]
 ├─ flags |= bit32 updatingLayout
 ├─ 选区 keys ∩ 屏上 keys → 找 anchor（count==1 用它，否则取新布局下中心距视口中心最近的 cell key）
 ├─ 由 anchor 新 frame 算 target offset（CGRectContainsRect/Intersection 钳制）→ transitionContentOffsetForProposedContentOffset:keyItemIndexPath: → targetContentOffset: → delegate bit20
 ├─ block_435：遍历 allVisibleViewsDict 用新布局 attrs 更新每个 view（_animateView 风格）
 ├─ ++_layoutTransitionAnimationCount@1544
 └─ animated ? runAnimationGroup:block_461 completion:block_465 : 同步 block_440+block_2 + 清 bit32
```
**OpenUXKit 现状**：非动画快路径已对齐（invalidate 新布局 → swap with `_setCollectionView:` 顺序 → 新 Data → `_setNeedsVisibleCellsUpdate:` → completion；不再 reloadData，cell 跨布局保留并重定位、选区保留）。**动画式跨布局 transition 主链（`_prepareForTransition*` + anchor 追踪 + `_animateView:`）未移植 → P9d**（无 showcase 走动画式 layout 切换，影响最低）。

**`setBeginningRect:`/`setEndingRect:` (UpdateGap, 0x1dbc08084/0x1dbc0806c)**：xref **仅 ObjC method-list 数据引用，零代码调用点**——UXKit 内部从不写这两个 rect。P8/P9 悬案就此关闭：纯外部 API，OpenUXKit 无需接线。

**`UXCollectionViewAnimation` completion 签名**：`start` (0x1dbbd0f7c) 的 completion block（0x1dbbd1650）与 block_invoke（0x1dbbd1274）均以**零参数** `(void(^)(void))()` 调用 `_completionHandlers`，BOOL 经 `AnimationContext.completionHandler` 流转。**OpenUXKit `addCompletionHandler:` 的 `void(^)(void)` 本就正确，P9b 的"改 BOOL"是误判，撤销。**

**`scrollWheel:` (0x1dbbde540)**：`_involvesScrollWheel@1576 = YES` 后 `[super scrollWheel:]`——`_involvesScrollWheel` **唯一写入点**。P9a 已接好 `clipViewBoundsDidChange:` 的滚轮减速/静默检测，此前因无写入点而不激活；P9c 补上后激活。

**`_willStartScrolling:` (0x1dbbde49c)**：`[NSObject cancelPreviousPerformRequestsWithTarget:self selector:_didEndScrolling: object:self]` → 未滚动时重置 `_decelerating`/`_lastScrollingDistance`/`_lastScrollingTime` → bit0 delegate willBegin → `_scrolling=YES`。OpenUXKit 已对齐。

## 3. 本阶段代码修复汇总（P9a：batchUpdates + 可见视图管线）

| # | 文件 | 修复 | 性质 |
|---|---|---|---|
| 1 | `UXCollectionView.m` ivar 块 | 引入 `_collectionViewFlags` 45-bit 位段（命名与 UXKit 完全一致）；删 OpenUXKit-only 的 `_needsReload`/`_needsVisibleCellsUpdate`/`_needsVisibleCellsLayoutAttributesUpdate`/`_explicitContentSize`/`_hasExplicitContentSize`；新增 `_contentSize`（UXKit @1528） | 结构对齐 |
| 2 | `UXCollectionView.m` | 自定义 `setDelegate:`/`setDataSource:`/`setAccessibilityDelegate:`，缓存 26 个 respondsTo bit；`setDataSource:` 无条件置 needsReload + `_invalidateLayoutIfNecessary` | 缺失功能 |
| 3 | `UXCollectionView.m` batchUpdates 链 | `performBatchUpdates:`/`_beginUpdates`/`_endUpdates`/`_setupCellAnimations`/`_endItemAnimations`（9 步）/`_updateWithItems:`/`_viewAnimationsForCurrentUpdate`（6 段）/`_updateAnimationDidStop:`/`_doubleSidedAnimationsForView:`/`_prepareLayoutForUpdates`/`_arrayForUpdateAction:`（懒初始化+assert）/`_updateRows…`/`_updateSections…` 全部按 §2.1–2.3 重写；删 OpenUXKit-only 的 `_allUpdateItems`/`_finalizeBatchUpdatesWithFinished:` | **核心重写**：原实现自创管线，不消费 Update 的 maps/gaps/AnimationContext |
| 4 | `UXCollectionView.m` 公开变更方法 | `insertItems…`/`deleteItems…`/`reloadItems…`/`moveItem…`/`insertSections:` 等不再包 `performBatchUpdates:`，直走 `_updateRows…`/`_updateSections…`（updating bit 决定独立/批量）；section 操作 indexPath 改为 `[NSIndexPath indexPathForItem:NSNotFound inSection:]`（双层） | 行为对齐 |
| 5 | `UXCollectionView.m` 可见视图管线 | `_updateCellsInRect:createIfNecessary:` 按 §2.4 重写（差集三组、purgingCellsThreshold 保留策略、fade/bounds-change 路径、bit28 attrs 刷新、preload inset 扩展）；`_updateVisibleCellsNow:` 透传 now→createIfNecessary；`layoutSubviews`/`reloadData`/`_reloadDataIfNeeded`/`_resumeReloads`/`_invalidateLayoutIfNecessary`/`_invalidateLayoutWithContext:`/`updateLayout` 全部按 UXKit 重写 | **核心重写** |
| 6 | `UXCollectionView.m` 几何 | `setContentSize:`（round + documentView setFrameSize，document frame 唯一驱动）/`documentContentRect`（preparedContentRect∪visible）/`_visibleBounds`（loadingOffscreenViews/activeGrouping 时并集）按 UXKit 重写 | 行为对齐 |
| 7 | `UXCollectionView.m` 滚动 | `clipViewBoundsDidChange:` 重写（currentUpdate 短路、速度、减速检测、滚轮静默 perform、shouldInvalidateLayoutForBoundsChange 分派）；`_prepareCellsForOverdraw:` 简化为记录+bit19 通知（cell 预创建实际由 `_updateCellsInRect:` 的 inset 扩展承担） | 行为对齐 |
| 8 | `UXCollectionView.m` `_addControlled:subview:atZIndex:` | 重写为 z 序感知插入（controlled）/ `addFloatingSubview:forAxis:`（floating pinned header） | 缺失功能 |
| 9 | `UXCollectionDocumentView.m` | `layout` 清空（UXKit 实测空实现 0x4 字节）；`prepareContentInRect:` 去 respondsTo 包装 | 行为对齐 |
| 10 | `UXCollectionViewAnimationContext.{h,m}` | `completionHandler` 签名 `void(^)(void)` → `void(^)(BOOL finished)`（消费侧 `_updateAnimationDidStop:` 调 `handler(finished)`，P8 时无消费者信息） | P8 矩阵修正 |
| 11 | `UXCollectionViewUpdate+Internal.h` / `Update.m` | 补主类消费的访问器：`_deletedSections`/`_oldSectionMapValueAtIndex:`/`_newSectionMapValueAtIndex:`/`_deletedSupplementaryTopLevelIndexesDict`/`_insertedSupplementaryTopLevelIndexesDict`/`_newVisibleBounds`(读写)/`_computeSupplementaryUpdates` 声明 | 桥接 |
| 12 | `UXCollectionViewLayout.m` / `+Internal.h` | 基类补 `shouldUpdateVisibleCellLayoutAttributes`（return NO；FlowLayout 已覆写）；声明 `_animationForReusableView:toLayoutAttributes:type:` | P3 小补 |
| 13 | display 通知 | `_notifyWillDisplayCellIfNeeded:` 集中到 `_createPreparedCellForItemAtIndexPath:`，`_notifyDidEndDisplayingCellIfNeeded:` 集中到 `_reuseCell:`（UXKit 的对应埋点在 `_createPreparedCell…` 内部，未反编译，P9b 校验） | 近似（待验证） |
| 14 | `UXCollectionViewFlowLayout.m` `_commonInit` | 补 `[super _commonInit]`（原缺失）；删 `init`/`initWithCoder:` 中冗余的二次 `[self _commonInit]`；基类 `+Internal.h` 声明 `_commonInit NS_REQUIRES_SUPER` | **P9 暴露的潜伏 bug** |

潜伏 bug 详解（#14）：`-[UXCollectionViewLayout init]` 通过 `[self _commonInit]` 动态派发初始化，FlowLayout 覆写了 `_commonInit` 却未调 super，导致基类的 `_insertedSectionsSet` / `_deletedSectionsSet` 等永远为 nil。P9 之前 `_updateWithItems:` 退化为 reloadData，`prepareForCollectionViewUpdates:` 从未以真实管线执行；P9 接通后，`for (section = [nilSet firstIndex]; section != NSNotFound; section = [nilSet indexGreaterThanIndex:section])` 因 nil 消息返回 0（≠ NSNotFound）陷入 `section==0` 死循环（`sample` 定位到 `existingSupplementaryLayoutAttributesInSection:`，`fprintf` 确认 set 为 `(null)`）。修复后 batchUpdates 全链贯通。

## 3b. P9b 代码修复汇总（Selection 集合代数）

| # | 文件 | 修复 | 性质 |
|---|---|---|---|
| 1 | `UXCollectionView.m` `_selectItemsInIndexPathsSet:…` | 整方法重写为 §2.7 集合代数：allowsSelection gate、shouldSelect/shouldDeselect 过滤、单选折叠、空选区保护、added/removed diff、仅可见 cell `_setSelected:animated:`、will/did 通知顺序与 4 个委托 bit、AX 通知 | **核心重写**：原实现为简单 add/remove 循环，无折叠/无 should 过滤/无空选区保护，是 Selection 痛点根源 |
| 2 | `UXCollectionView.m` `_deselectItemsAtIndexPaths:` | 重写为"选中补集"：surviving = 现选区 - toDeselect（含空选区 fallback + anchor 维护），统一经 `_selectItemsInIndexPathsSet:` | 行为对齐 |
| 3 | `UXCollectionView.m` `_toggleSelectionStateOfItemAtIndexPath:` / `_selectRangeOfItemsFromIndexPath:` / `_deselectAllAnimated:` / `_selectAllItems:` | 按 §2.7 重写（anchor 维护、keyItem position 64、candidate 逆向扫描、sectionsForSelectAllAction 钩子） | 行为对齐 |
| 4 | `UXCollectionView.m` SPI category | 声明 `_setSelected:animated:`（cell）/`accessibilityPostNotification:`（layoutAccessibility）/`sectionsForSelectAllActionInCollectionView:`（delegate）；新增 `_postSelectionAccessibilityNotification` 守卫式 helper | 桥接 |

P9b 实现妥协（记录在案）：
- `_performItemSelectionForMouseEvent:` / `_performItemSelectionForKey:` / lasso / painting **事件路由保留 OpenUXKit 现状**（它们调用上面已修正的核心方法，diff/通知/空选区逻辑自动获益）。UXKit 的鼠标 4 分支（cmd/continuous deselect、shift range、plain select，含 painting 内联进 mouseDown）与键盘 RTL 翻转细节见 §2.7，列为 P9c。
- M6 dequeue/reuse 的 set+动态阈值差异（§2.8）正确性等价，列为 P9c 精炼。

## 3c. P9c 代码修复汇总（dequeue set 化 + scroll-wheel + transition 快路径）

| # | 文件 | 修复 | 性质 |
|---|---|---|---|
| 1 | `UXCollectionView.m` reuse 队列 | `_cellReuseQueues`/`_supplementaryViewReuseQueues` 改 NSMutableArray→**NSMutableSet**；`_dequeueReusableViewOfKind:` 用 `anyObject`/`removeObject:`；新增 `_reuseQueueCapacityForViewSize:`（动态阈值 `ceil(frameW·frameH·8/max(minReusedW·minReusedH,1))+1`）+ `_recycleView:intoQueue:registeredClass:`（容量/重复/类匹配三判 → 入队 setHidden:YES+清 attrs，否则 removeFromSuperview）；`_maxNumberOfReusedViews` 用同公式；`_minReusedViewSize` 初值 {1024,1024} | 结构对齐（§2.8） |
| 2 | `UXCollectionView.m` `_reuseSupplementaryView:` | didEndDisplaying supplementary 委托回调用 bit18 缓存 | 行为对齐 |
| 3 | `UXCollectionView.m` `scrollWheel:`（新增）+ `_willStartScrolling:` | `_involvesScrollWheel=YES`（唯一写入点，激活滚轮减速/静默检测）；`_willStartScrolling:` 加 cancelPreviousPerform + 减速状态重置 + bit0 缓存 | 缺失功能 |
| 4 | `UXCollectionView.m` `_setCollectionViewLayout:animated:isInteractive:completion:` | 非动画快路径对齐 UXKit（invalidate 新布局 → `_setCollectionView:` swap 顺序 → 新 Data → `_setNeedsVisibleCellsUpdate:`；删 reloadData，cell 跨布局保留+选区保留） | 行为对齐 |

P9c 实现妥协（记录在案）：
- 动画式跨布局 transition 主链（§2.9）未移植 → **P9d**（无 showcase 触发，影响最低）。
- mouse/keyboard 事件路由 4 分支细化仍为 OpenUXKit 现状（调用已对齐的选区核心）→ P9d。
- reuse-pool 复用的端到端测试需注册型 cell fixture（现 fixture 直接 `UXCollectionViewCell()` 不走 dequeue）；本轮以 30/30 非回归 + delete 回收路径覆盖，专项测试列 P9d。

实现妥协（记录在案）：
- `UXCollectionViewAnimation.addCompletionHandler:` 仍为 `void(^)(void)`（UXKit 为 `void(^)(BOOL)`）；主类 completion 里以 `@YES` 调 `_updateAnimationDidStop:` —— P9b 待办
- assert 文本 1:1，行号为 OpenUXKit 自然行号（无法照抄 UXKit 行号）
- `_involvesScrollWheel` 暂无写入点（UXKit 写入点未定位，M3/M4 范围），滚轮减速/静默分支结构对齐但默认不激活
- `reloadData` 的 `toPosition:64`：UXKit 二进制字面量（高于公开掩码的位），落在所有 position 检查之外
- `dealloc` 中 NSObject cancelPreviousPerformRequests 未加（UXKit 未验证）

## 4. 测试

`Tests/OpenUXKitTests/Collection/SelectionAlgorithmTests.swift` stub 转正（6 个 L2 集成测试，P9b）：单选替换、单选折叠（多请求→1）、多选 extend、deselect 清可见 cell、空选区禁用保护、shouldSelect 委托否决。**红绿验证**：临时禁用单选折叠分支，`test_singleSelection_collapsesMultiRequestToOne` 即从 1 选区变 3 选区而失败。

`Tests/OpenUXKitTests/Collection/PerformBatchUpdatesTests.swift` stub 转正（8 个 L2 集成测试）：
NSWindow 寄宿（满足 `_visible`）+ 手动 `layout()` 驱动首次布局；断言 `visibleCells`/`indexPathsForVisibleItems` 在变更调用返回后立即反映新模型（dict 在动画组内同步重建），completion 经 expectation 异步等待。
覆盖：首次布局 / insert / delete / reload（cell 必须重建）/ move（cell 身份保持）/ 单批 insert+delete / 批内 insertSections / 不可见快速路径（同步 completion(YES)）。

## 5. 调用面合同（P9b / P10 接线依据）

- `UpdateGap.beginningRect/endingRect` 写入点在 Update/Gap/Animation/主类 batchUpdates 链中均未出现 —— 全部反编译过的方法没有调用 setter。待 P9b 反编译 `setCollectionViewLayout:animated:`（layout transition）与 Rearranging 路径时继续追踪。
- `_doubleSidedAnimations` 的 snapshot 路径（`_UXCollectionSnapshotView` + bit35）由 layout transition 触发（P9b）。
- `_addControlled:NO`（floating pinned）的消费者是 FlowLayout 的 floating header attrs（isFloating），P9b 验证 `_updateCellsInRect` 的 floating 行为与 pinned header showcase。

## 6. 待办（后续 phase / P9b）

- [ ] P9b：M3 Selection 算法反编译比对（`_selectItemsInIndexPathsSet:` 4 分支、lasso/painting、键盘导航；bit29/30 与 selection ivar 的分工）
- [ ] P9b：M4 视图层次其余（`_UXCollectionView` overdraw、ClipView、`setCollectionViewLayout:animated:` transition 链、`_involvesScrollWheel` 写入点、`scrollToItemAtIndexPath:` 真实实现）
- [ ] P9b：`UXCollectionViewAnimation.addCompletionHandler:` 签名改 `void(^)(BOOL)` 并回调真实 finished
- [ ] P9b：`_createPreparedCellForItemAtIndexPath:` / `_createPreparedSupplementaryViewForElementOfKind:` 反编译（display 通知埋点、wasDequeued/selected 状态恢复）
- [ ] P9b：`_reuseCell:`/`_reuseSupplementaryView:`/`_dequeueReusableViewOfKind:` 反编译比对（`_minReusedViewSize`/`_maxNumberOfReusedViews` 消费）
- [ ] P10：Rearranging（S6）

---

## 7. P9d — 事件路由 4 分支 + 动画跨布局 transition

### 7.1 鼠标选区路由 `_performItemSelectionForMouseEvent:onCell:atIndexPath:`（0x1dbbd3494）— 已对齐

逐句反编译比对后重写。UXKit 行为：

1. 开头 release/nil 三个 ivar（@1712/@1720/@1728 = `_keyboardRangeSelectionPreviouslySelectedItems`/`First`/`Last`）—— **鼠标选区作废进行中的键盘 range**。
2. `allowsPaintingSelection && !(modifiers & 0x120000)`（无 shift/cmd）→ arm painting 位（@1664）。
3. **cell 已选**：`cmd || allowsContinuousSelection` → `_deselectItemsAtIndexPaths:animated:YES`，成功则 AX 通知；否则 anchor(@1248)=indexPath。
4. **cell 未选 + 无 shift**：`cmd || continuous` → `_toggleSelectionStateOfItemAtIndexPath:`；否则 `_selectItemsInIndexPathsSet:byExtendingSelection:NO animated:YES scrollingKeyItem:indexPath toPosition:0`。成功后 anchor =（selected 含 indexPath ? indexPath : `_keyItemIndexPathForItemIndexPathsSet:`）+ AX 通知。
5. **shift**：`from = anchor ?: indexPath`；`_selectRangeOfItemsFromIndexPath:from toIndexPath:indexPath byExtendingSelection:YES animated:YES scroll:YES toPosition:0 notifyDelegate:YES candidateLastSelectedItemIndexPath:&c`；`resolved =（anchor ? c : indexPath）`；`changed && resolved` → anchor=resolved + AX。

OpenUXKit 原状偏差：未重置键盘 range；selected 非 cmd 分支未设 anchor；未选分支用 `extend=modifier&&multi`、`scrollKey:nil`、未更新 anchor、无 AX；shift 分支要求 anchor 非 nil、`extend:cmd`、`scroll:NO`、`candidate:NULL`、未更新 anchor。已全部修正。
> 注：painting arm（@1664）部分未移植——OpenUXKit 的 painting 在 `mouseDown:` 无 cell 命中分支单独驱动（模型不同），保留现有流。`@1665` 内部标志（OpenUXKit 无对应 ivar）未映射。

### 7.2 键盘选区路由 `_performItemSelectionForKey:withModifiers:`（0x1dbbd207c）— 已对齐

UXKit 行为：

1. `cmd` → 返回 NO。
2. `shift`：首次（`_keyboardRangeSelectionPreviouslySelectedItems` 为 nil）则 = `[_indexPathsForSelectedItems copy]`；`First = Last = _lastSelectionAnchorIndexPath`。
3. **有 First（range 进行中）**：仅箭头键（`(key & 0xFFFC)==0xF700`）；从 `Last` 用 **layout 几何导航** `indexPathOfItem{Above/Below/Before/After}:`（Left/Right 经 `userInterfaceLayoutDirection` RTL 反转），跳过不可选项；跑出边界返回 YES。
4. **无 First（进入列表）**：Up/Left → `[_layout lastSelectableItemIndexPath]`；Down/Right → `[_layout firstSelectableItemIndexPath]`；其它键 NO。`First = Last = target`。
5. **选区**：shift → range=`indexPathsForItemRangeSelectionFrom:First to:target`，并入 `Previously` 的 mutableCopy；否则单项 set。均 `byExtendingSelection:NO animated:NO scrollingKeyItem:target toPosition:64 notifyDelegate:YES`。成功后 shift 更新 `Last=target`；非 shift 清三 ivar + `anchor=target`。末尾 AX 通知。

OpenUXKit 原状偏差：用 `_indexPathByMovingFromIndexPath:delta:`（item±1 而非几何导航）；无 anchor 时双向 fallback firstSelectable（非 Up→last/Down→first）；`toPosition:None`（非 64）；处理 Home/End（实为死代码——`keyDown:` 先调 `_performScrollingForKey:` 消费 Home/End）。已修正并删除死方法 `_indexPathByMovingFromIndexPath:delta:fallback:`。

### 7.3 动画跨布局 transition `_setCollectionViewLayout:animated:isInteractive:completion:`（0x1dbbdac28，0x930）— 已反编译，待移植

**关键发现**：OpenUXKit 现有 fast path 正好等于 UXKit 的「`!_visible || !(flags & doneFirstLayout)`」非动画分支（逐行一致：invalidate everything → `_setCollectionView:` 换层 → 新建 `UXCollectionViewData` → `_setNeedsVisibleCellsUpdate:` → completion(YES)）。但 OpenUXKit **无条件**走它,缺 visible+doneFirstLayout 时的动画分支。

UXKit 动画分支(visible && doneFirstLayout)的完整链(待移植,**无 showcase 触发点,需自建触发用例方可可视化验证**):

1. 早退:`layout == _layout` 直接 return(**不调 completion**——OpenUXKit 现调 completion(YES),细微偏差)。
2. 捕获 `contentView.bounds`;在新 layout 上 invalidate everything。
3. 新建 `data2 = UXCollectionViewData(self, newLayout)` + `_prepareToLoadData`(**不立即赋给 `_collectionViewData`**)。
4. `[oldLayout _prepareForTransitionToLayout:newLayout]` + `[newLayout _prepareForTransitionFromLayout:oldLayout]`;置 transition 位(@1760 bit32)。
5. **anchor 选取**:用选中项 itemKey 集与可见项集求交;`count==1` 取 anyObject,否则取「新数据布局中心距视口中心(MidX,MidY)最近」者(欧氏距离)。
6. **目标偏移**:用 anchor 在新数据的 layoutAttributes 算 `offset =(newCenter - viewportHalf)`;经 `CGRectContainsRect`/`CGRectIntersection` clamp 到新 contentSize;再过 `transitionContentOffsetForProposedContentOffset:keyItemIndexPath:` + `targetContentOffsetForProposedContentOffset:` + delegate `_collectionView:targetContentOffsetForProposedContentOffset:`(若 bit @1762&0x10)。
7. 6 个 block(_435 旧视图、_439、_2、_440 动画体含 `_animateView:` 驱动、_461 setup、_465 completion);`_reloadingSuspendedCount`(@1544)++。
8. `animated` → `[NSAnimationContext runAnimationGroup:_461 completionHandler:_465]`;否则直接 `_440(v89,0)` + `v91(v90)` 同步收尾,清 transition 位。

移植工作量大且不可视化验证,作为 spec 留待后续(同 P10b 的「written-but-not-verified」处境)。
