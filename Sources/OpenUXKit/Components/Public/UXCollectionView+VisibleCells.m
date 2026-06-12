#import "UXCollectionView+Private.h"

@implementation UXCollectionView (VisibleCells)

#pragma mark - Dequeue

- (__kindof UXCollectionReusableView *)_dequeueReusableViewOfKind:(NSString *)kind withIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath viewCategory:(NSUInteger)viewCategory {
    NSMutableDictionary *reuseQueues = (viewCategory == 1) ? _cellReuseQueues : _supplementaryViewReuseQueues;
    NSString *reuseKey = (viewCategory == 1) ? identifier : [[self class] _reuseKeyForSupplementaryViewOfKind:kind withReuseIdentifier:identifier];

    // UXKit keeps recycled views in per-identifier NSMutableSets; any member is
    // an equally valid candidate, so dequeue pulls anyObject.
    NSMutableSet *queue = reuseQueues[reuseKey];
    UXCollectionReusableView *view = nil;
    if (queue.count > 0) {
        view = [queue anyObject];
        [queue removeObject:view];
    }

    if (!view) {
        NSDictionary *classDict = (viewCategory == 1) ? _cellClassDict : _supplementaryViewClassDict;
        NSDictionary *nibDict = (viewCategory == 1) ? _cellNibDict : _supplementaryViewNibDict;
        NSString *lookupKey = (viewCategory == 1) ? identifier : reuseKey;

        Class viewClass = classDict[lookupKey];
        NSNib *nib = nibDict[lookupKey];

        if (nib) {
            NSArray *objects = nil;
            if ([nib instantiateWithOwner:self topLevelObjects:&objects]) {
                for (id object in objects) {
                    if ([object isKindOfClass:[UXCollectionReusableView class]]) {
                        view = object;
                        break;
                    }
                }
            }
        } else if (viewClass) {
            view = [[viewClass alloc] initWithFrame:CGRectZero];
        }
    }

    if (view) {
        [(id)view _setReuseIdentifier:identifier];
        [(id)view _setCollectionView:self];
        [(id)view _markAsDequeued];
        [view prepareForReuse];
    }
    return view;
}

- (__kindof UXCollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    NSAssert(identifier.length > 0, @"must pass a valid reuse identifier to -[UXCollectionView %@]", NSStringFromSelector(_cmd));
    return [self _dequeueReusableViewOfKind:UXCollectionElementKindCell withIdentifier:identifier forIndexPath:indexPath viewCategory:1];
}

- (__kindof UXCollectionReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    NSAssert(identifier.length > 0, @"must pass a valid reuse identifier to -[UXCollectionView %@]", NSStringFromSelector(_cmd));
    return [self _dequeueReusableViewOfKind:kind withIdentifier:identifier forIndexPath:indexPath viewCategory:2];
}

- (NSInteger)_reuseQueueCapacityForViewSize:(CGSize)viewSize {
    // Shrink the running minimum reused-view size, then cap the recycle pool by
    // how many such views could possibly cover eight screens (UXKit's
    // _maxNumberOfReusedViews heuristic). A larger pool is allowed for smaller
    // cells; a single huge cell keeps the pool tiny.
    _minReusedViewSize.width = MIN(_minReusedViewSize.width, viewSize.width);
    _minReusedViewSize.height = MIN(_minReusedViewSize.height, viewSize.height);
    CGSize frameSize = self.frame.size;
    return (NSInteger)(ceil(frameSize.width * frameSize.height * 8.0 / fmax(_minReusedViewSize.width * _minReusedViewSize.height, 1.0)) + 1.0);
}

- (void)_recycleView:(UXCollectionReusableView *)view intoQueue:(NSMutableSet *)queue registeredClass:(Class)registeredClass {
    NSInteger capacity = [self _reuseQueueCapacityForViewSize:view.frame.size];
    if ((NSInteger)queue.count < capacity && ![queue containsObject:view] && [view class] == registeredClass) {
        // UXKit parks recycled views as hidden subviews rather than removing
        // them, avoiding add/remove churn on the next dequeue.
        [queue addObject:view];
        view.hidden = YES;
        [(id)view _setLayoutAttributes:nil];
    } else {
        [view removeFromSuperview];
    }
}

- (void)_reuseCell:(UXCollectionViewCell *)cell {
    if (!cell) {
        return;
    }
    NSString *identifier = cell.reuseIdentifier;
    NSMutableSet *queue = _cellReuseQueues[identifier];
    if (!queue) {
        queue = [NSMutableSet set];
        if (identifier) {
            _cellReuseQueues[identifier] = queue;
        }
    }
    [self _recycleView:cell intoQueue:queue registeredClass:_cellClassDict[identifier]];
    [self _notifyDidEndDisplayingCellIfNeeded:cell forIndexPath:[[(id)cell _layoutAttributes] indexPath]];
}

- (void)_reuseSupplementaryView:(UXCollectionReusableView *)view {
    if (!view) {
        return;
    }
    NSString *identifier = view.reuseIdentifier;
    UXCollectionViewLayoutAttributes *attributes = [(id)view _layoutAttributes];
    NSString *elementKind = [attributes _elementKind];
    NSString *key = (elementKind && identifier) ? [[self class] _reuseKeyForSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier] : nil;
    NSMutableSet *queue = key ? _supplementaryViewReuseQueues[key] : nil;
    if (key && !queue) {
        queue = [NSMutableSet set];
        _supplementaryViewReuseQueues[key] = queue;
    }
    if (queue) {
        [self _recycleView:view intoQueue:queue registeredClass:_supplementaryViewClassDict[key]];
    } else {
        [view removeFromSuperview];
    }
    if (_collectionViewFlags.delegateDidEndDisplayingSupplementaryViewForElementOfKindAtIndexPath && elementKind) {
        [self.delegate collectionView:self didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:attributes.indexPath];
    }
}

- (NSInteger)_numberOfReusedViewsForIdentifier:(NSString *)identifier {
    return (NSInteger)[_cellReuseQueues[identifier] count];
}

- (NSInteger)_maxNumberOfReusedViews {
    CGSize frameSize = self.frame.size;
    return (NSInteger)(ceil(frameSize.width * frameSize.height * 8.0 / fmax(_minReusedViewSize.width * _minReusedViewSize.height, 1.0)) + 1.0);
}

#pragma mark - Cell preparation pipeline

- (__kindof UXCollectionViewCell *)_createPreparedCellForItemAtIndexPath:(NSIndexPath *)indexPath withLayoutAttributes:(UXCollectionViewLayoutAttributes *)layoutAttributes applyAttributes:(BOOL)applyAttributes {
    if (![self.dataSource respondsToSelector:@selector(collectionView:cellForItemAtIndexPath:)]) {
        return nil;
    }
    UXCollectionViewCell *cell = [self.dataSource collectionView:self cellForItemAtIndexPath:indexPath];
    if (!cell) {
        return nil;
    }
    [(id)cell _setCollectionView:self];
    if (applyAttributes && layoutAttributes) {
        [(id)cell _setLayoutAttributes:layoutAttributes];
    }
    if ([_indexPathsForSelectedItems containsIndexPath:indexPath]) {
        cell.selected = YES;
    } else {
        cell.selected = NO;
    }
    [self _notifyWillDisplayCellIfNeeded:cell forIndexPath:indexPath];
    return cell;
}

- (__kindof UXCollectionReusableView *)_createPreparedSupplementaryViewForElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath withLayoutAttributes:(UXCollectionViewLayoutAttributes *)layoutAttributes applyAttributes:(BOOL)applyAttributes {
    if (![self.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
        return nil;
    }
    UXCollectionReusableView *view = [self.dataSource collectionView:self viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    if (!view) {
        return nil;
    }
    [(id)view _setCollectionView:self];
    if (applyAttributes && layoutAttributes) {
        [(id)view _setLayoutAttributes:layoutAttributes];
    }
    return view;
}

- (void)_notifyWillDisplayCellIfNeeded:(UXCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    if (!cell || [_notifiedDisplayedCells containsObject:cell]) {
        return;
    }
    [_notifiedDisplayedCells addObject:cell];
    id<UXCollectionViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(collectionView:willDisplayCell:forItemAtIndexPath:)]) {
        [delegate collectionView:self willDisplayCell:cell forItemAtIndexPath:indexPath];
    }
}

- (void)_notifyDidEndDisplayingCellIfNeeded:(UXCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    if (!cell || ![_notifiedDisplayedCells containsObject:cell]) {
        return;
    }
    [_notifiedDisplayedCells removeObject:cell];
    id<UXCollectionViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)]) {
        [delegate collectionView:self didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    }
}

- (void)_updateCellsInRect:(CGRect)rect createIfNecessary:(BOOL)createIfNecessary {
    if (_reloadingSuspendedCount > 0 || _updateAnimationCount > 0) {
        return;
    }
    if (_collectionViewFlags.updatingLayout || _collectionViewFlags.skipCellsUpdateDuringResizing) {
        return;
    }

    if ([NSAnimationContext respondsToSelector:@selector(_hasActiveGrouping)] && [NSAnimationContext _hasActiveGrouping]) {
        if (_collectionViewFlags.layoutInvalidatedSinceLastCellUpdate) {
            _collectionViewFlags.fadeCellsForBoundsChange = YES;
        }
    }
    [self _suspendReloads];

    if (_collectionViewFlags.fadeCellsForBoundsChange) {
        [_layout prepareForAnimatedBoundsChange:_previousBounds];
        CGPoint targetContentOffset = [_layout targetContentOffsetForProposedContentOffset:[self contentOffset]];
        if (_collectionViewFlags.delegateTargetContentOffsetForProposedContentOffset) {
            targetContentOffset = [(id)self.delegate _collectionView:self targetContentOffsetForProposedContentOffset:targetContentOffset];
        }
        if (!CGPointEqualToPoint(_lastContentOffset, targetContentOffset)) {
            _lastContentOffset = targetContentOffset;
            [self.contentView setBoundsOrigin:targetContentOffset];
            rect = [self _visibleBounds];
        }
    }

    NSArray<UXCollectionViewLayoutAttributes *> *attributesList = [_collectionViewData layoutAttributesForElementsInRect:rect];
    if (![self inLiveResize] && !_scrolling
        && [self extraNumberOfCellsToPreloadWhenScrollingStopped] > 0 && attributesList.count > 0) {
        CGFloat preloadRatio = (CGFloat)[self extraNumberOfCellsToPreloadWhenScrollingStopped] / (CGFloat)attributesList.count;
        rect = CGRectInset(rect, -(rect.size.width * preloadRatio), -(rect.size.height * preloadRatio));
        attributesList = [_collectionViewData layoutAttributesForElementsInRect:rect];
    }

    BOOL fadeCells = _collectionViewFlags.fadeCellsForBoundsChange;
    if (createIfNecessary) {
        _collectionViewFlags.scheduledUpdateVisibleCells = NO;
        _collectionViewFlags.fadeCellsForBoundsChange = NO;
    }
    [self setContentSize:[_collectionViewData collectionViewContentRect].size];

    if (fadeCells) {
        NSMutableArray<UXCollectionViewLayoutAttributes *> *previousAttributesList = [[NSMutableArray alloc] init];
        for (UXCollectionReusableView *view in _allVisibleViewsDict.allValues) {
            UXCollectionViewLayoutAttributes *attributesCopy = [[(id)view _layoutAttributes] copy];
            if (attributesCopy) {
                [previousAttributesList addObject:attributesCopy];
            }
        }
        [previousAttributesList sortUsingComparator:^NSComparisonResult(UXCollectionViewLayoutAttributes *first, UXCollectionViewLayoutAttributes *second) {
            if (first.zIndex < second.zIndex) {
                return NSOrderedAscending;
            }
            if (first.zIndex > second.zIndex) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        NSArray *upcomingAttributesList = [[NSArray alloc] initWithArray:attributesList copyItems:YES];
        [_layout _prepareToAnimateFromCollectionViewItems:previousAttributesList
                                          atContentOffset:_lastContentOffset
                                                  toItems:upcomingAttributesList
                                          atContentOffset:[self contentOffset]];
    }

    void (^resizeAnimationSetup)(void) = ^{
        self->_resizeAnimationCount++;
    };
    void (^resizeAnimationCompletion)(BOOL) = ^(BOOL finished) {
        self->_resizeAnimationCount--;
        if (self->_resizeAnimationCount == 0) {
            self->_resizeBoundsOffset = CGPointZero;
            [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:YES];
            self->_lastLayoutOffset = [self contentOffset];
        }
    };

    NSMutableDictionary *leftoverViewsDict = [_allVisibleViewsDict mutableCopy];
    NSMutableArray<UXCollectionViewLayoutAttributes *> *missingAttributesList = [[NSMutableArray alloc] init];
    NSMutableArray<UXCollectionReusableView *> *existingViews = [[NSMutableArray alloc] init];
    for (UXCollectionViewLayoutAttributes *attributes in attributesList) {
        _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:attributes];
        UXCollectionReusableView *view = _allVisibleViewsDict[key];
        if (view) {
            [existingViews addObject:view];
            [leftoverViewsDict removeObjectForKey:key];
        } else {
            [missingAttributesList addObject:attributes];
        }
    }

    if (![self inLiveResize]) {
        NSUInteger totalViewCount = existingViews.count + leftoverViewsDict.count + missingAttributesList.count;
        if (totalViewCount < [self purgingCellsThreshold]) {
            [existingViews addObjectsFromArray:leftoverViewsDict.allValues];
            leftoverViewsDict = nil;
        }
    }

    [leftoverViewsDict enumerateKeysAndObjectsUsingBlock:^(_UXCollectionViewItemKey *key, UXCollectionReusableView *view, BOOL *stop) {
        if ([view _isInUpdateAnimation]) {
            return;
        }
        [self->_allVisibleViewsDict removeObjectForKey:key];
        void (^recycleView)(void) = ^{
            if (key.type == UXCollectionViewItemTypeCell) {
                [self _reuseCell:(UXCollectionViewCell *)view];
            } else {
                [self _reuseSupplementaryView:view];
            }
        };
        if (!fadeCells) {
            recycleView();
            return;
        }
        UXCollectionViewLayoutAttributes *finalAttributes = nil;
        switch (key.type) {
            case UXCollectionViewItemTypeCell:
                finalAttributes = [self->_layout finalLayoutAttributesForDisappearingItemAtIndexPath:key.indexPath];
                break;
            case UXCollectionViewItemTypeSupplementaryView:
                finalAttributes = [self->_layout finalLayoutAttributesForDisappearingSupplementaryElementOfKind:key.identifier atIndexPath:key.indexPath];
                break;
            case UXCollectionViewItemTypeDecorationView:
                finalAttributes = [self->_layout finalLayoutAttributesForDisappearingDecorationElementOfKind:key.identifier atIndexPath:key.indexPath];
                break;
        }
        if (!finalAttributes) {
            finalAttributes = [[(id)view _layoutAttributes] copy];
            finalAttributes.alpha = 0.0;
        }
        resizeAnimationSetup();
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [(id)view _setLayoutAttributes:finalAttributes];
        } completionHandler:^{
            recycleView();
            resizeAnimationCompletion(YES);
        }];
    }];

    if (createIfNecessary) {
        for (UXCollectionViewLayoutAttributes *attributes in missingAttributesList) {
            _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:attributes];
            if (fadeCells) {
                UXCollectionViewLayoutAttributes *initialAttributes = nil;
                if ([attributes _isCell]) {
                    initialAttributes = [_layout initialLayoutAttributesForAppearingItemAtIndexPath:key.indexPath];
                } else if ([attributes _isDecorationView]) {
                    initialAttributes = [_layout initialLayoutAttributesForAppearingDecorationElementOfKind:key.identifier atIndexPath:key.indexPath];
                } else {
                    initialAttributes = [_layout initialLayoutAttributesForAppearingSupplementaryElementOfKind:key.identifier atIndexPath:key.indexPath];
                }
                if (!initialAttributes) {
                    initialAttributes = [attributes copy];
                    initialAttributes.alpha = 0.0;
                }
                if (initialAttributes.isHidden && attributes.isHidden) {
                    continue;
                }
                UXCollectionReusableView *view = [attributes _isCell]
                    ? [self _createPreparedCellForItemAtIndexPath:key.indexPath withLayoutAttributes:initialAttributes applyAttributes:YES]
                    : [self _createPreparedSupplementaryViewForElementOfKind:key.identifier atIndexPath:key.indexPath withLayoutAttributes:initialAttributes applyAttributes:YES];
                if (!view) {
                    continue;
                }
                resizeAnimationSetup();
                [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
                    [(id)view _setLayoutAttributes:attributes];
                } completionHandler:^{
                    resizeAnimationCompletion(YES);
                }];
                _allVisibleViewsDict[key] = view;
            } else {
                if (attributes.isHidden) {
                    continue;
                }
                UXCollectionReusableView *view = [attributes _isCell]
                    ? [self _createPreparedCellForItemAtIndexPath:key.indexPath withLayoutAttributes:attributes applyAttributes:NO]
                    : [self _createPreparedSupplementaryViewForElementOfKind:key.identifier atIndexPath:key.indexPath withLayoutAttributes:attributes applyAttributes:NO];
                if (!view) {
                    continue;
                }
                [self performWithoutAnimation:^{
                    [(id)view _setLayoutAttributes:attributes];
                    [self _addControlled:!attributes.isFloating subview:view atZIndex:[(id)view _layoutAttributes].zIndex];
                }];
                _allVisibleViewsDict[key] = view;
            }
        }
    }

    if (!_collectionViewFlags.reloadSkippedDuringSuspension) {
        _visibleBounds = [self documentVisibleRect];
        if (_collectionViewFlags.scheduledUpdateVisibleCellLayoutAttributes) {
            for (UXCollectionReusableView *view in existingViews) {
                _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:[(id)view _layoutAttributes]];
                UXCollectionViewLayoutAttributes *currentAttributes = [(id)_allVisibleViewsDict[key] _layoutAttributes];
                UXCollectionViewLayoutAttributes *newAttributes = nil;
                switch (key.type) {
                    case UXCollectionViewItemTypeCell:
                        newAttributes = [_collectionViewData layoutAttributesForItemAtIndexPath:key.indexPath];
                        break;
                    case UXCollectionViewItemTypeSupplementaryView:
                        newAttributes = [_collectionViewData layoutAttributesForSupplementaryElementOfKind:key.identifier atIndexPath:key.indexPath];
                        break;
                    case UXCollectionViewItemTypeDecorationView:
                        newAttributes = [_collectionViewData layoutAttributesForDecorationViewOfKind:key.identifier atIndexPath:key.indexPath];
                        break;
                }
                if (!fadeCells || currentAttributes.isFloating || newAttributes.isFloating) {
                    if (newAttributes.isHidden) {
                        [_allVisibleViewsDict removeObjectForKey:key];
                        if ([view _isInUpdateAnimation]) {
                            _allVisibleViewsDict[key] = view;
                        } else if ([newAttributes _isCell]) {
                            [self _reuseCell:(UXCollectionViewCell *)view];
                        } else {
                            [self _reuseSupplementaryView:view];
                        }
                    } else {
                        [self performWithoutAnimation:^{
                            [(id)view _setLayoutAttributes:newAttributes];
                            [self _addControlled:!newAttributes.isFloating subview:view atZIndex:newAttributes.zIndex];
                        }];
                    }
                } else {
                    if (newAttributes.isFloating != [(id)view isFloatingPinned]
                        || (![(id)view isFloatingPinned] && newAttributes.zIndex != [(id)view _layoutAttributes].zIndex)) {
                        [(id)view _setLayoutAttributes:[currentAttributes copy]];
                        [self _addControlled:YES subview:view atZIndex:newAttributes.zIndex];
                    }
                    NSArray *resizeAnimations = [self _doubleSidedAnimationsForView:view
                                                       withStartingLayoutAttributes:currentAttributes
                                                                     startingLayout:_layout
                                                             endingLayoutAttributes:newAttributes
                                                                       endingLayout:_layout
                                                                 withAnimationSetup:resizeAnimationSetup
                                                                animationCompletion:resizeAnimationCompletion
                                                             enableCustomAnimations:NO
                                                               customAnimationsType:0];
                    for (UXCollectionViewAnimation *animation in resizeAnimations) {
                        [animation start];
                    }
                }
            }
        }
        if (fadeCells) {
            [_layout _finalizeCollectionViewItemAnimations];
            [_layout finalizeAnimatedBoundsChange];
        }
        _collectionViewFlags.scheduledUpdateVisibleCellLayoutAttributes = NO;
    }

    _lastLayoutOffset = [self contentOffset];
    _collectionViewFlags.layoutInvalidatedSinceLastCellUpdate = NO;
    [self _resumeReloads];
}

- (void)_updateVisibleCellsNow:(BOOL)now {
    [self _updateCellsInRect:[self documentVisibleRect] createIfNecessary:now];
}

#pragma mark - Visible cells

- (NSArray<__kindof UXCollectionViewCell *> *)visibleCells {
    NSMutableArray *cells = [NSMutableArray array];
    for (id view in _allVisibleViewsDict.objectEnumerator) {
        if ([view isKindOfClass:[UXCollectionViewCell class]]) {
            [cells addObject:view];
        }
    }
    return cells;
}

- (NSArray<__kindof UXCollectionViewCell *> *)contentCells {
    return [self visibleCells];
}

- (NSArray<__kindof UXCollectionReusableView *> *)visibleSupplementaryViews {
    NSMutableArray *views = [NSMutableArray array];
    for (id view in _allVisibleViewsDict.objectEnumerator) {
        if ([view isKindOfClass:[UXCollectionReusableView class]] && ![view isKindOfClass:[UXCollectionViewCell class]]) {
            [views addObject:view];
        }
    }
    return views;
}

- (NSArray<__kindof UXCollectionReusableView *> *)contentSupplementaryViews {
    return [self visibleSupplementaryViews];
}

- (NSArray<__kindof UXCollectionReusableView *> *)visibleSupplementaryViewsOfKind:(NSString *)kind {
    return [self _visibleSupplementaryViewsOfKind:kind];
}

- (NSArray<__kindof UXCollectionReusableView *> *)_visibleSupplementaryViewsOfKind:(NSString *)kind {
    NSMutableArray *views = [NSMutableArray array];
    for (id view in _allVisibleViewsDict.objectEnumerator) {
        if (![view isKindOfClass:[UXCollectionReusableView class]] || [view isKindOfClass:[UXCollectionViewCell class]]) {
            continue;
        }
        UXCollectionViewLayoutAttributes *attributes = [(id)view _layoutAttributes];
        if ([[attributes _elementKind] isEqualToString:kind]) {
            [views addObject:view];
        }
    }
    return views;
}

- (NSArray<__kindof UXCollectionReusableView *> *)_supplementaryViewsIncludingOverdrawArea:(BOOL)overdrawArea identifier:(NSString *)identifier {
    return [self _visibleSupplementaryViewsOfKind:identifier];
}

- (void)_enumerateSupplementaryViewsIncludingOverdrawArea:(BOOL)overdrawArea identifier:(NSString *)identifier usingBlock:(void (^)(UXCollectionReusableView *view, BOOL *stop))block {
    BOOL stop = NO;
    NSArray<UXCollectionReusableView *> *views = [self _supplementaryViewsIncludingOverdrawArea:overdrawArea identifier:identifier];
    for (UXCollectionReusableView *view in views) {
        block(view, &stop);
        if (stop) {
            return;
        }
    }
}

- (NSArray<__kindof UXCollectionViewCell *> *)_cellsIncludingOverdrawArea:(BOOL)overdrawArea {
    return [self visibleCells];
}

- (NSDictionary<NSIndexPath *, __kindof UXCollectionViewCell *> *)_dictionaryOfIndexPathsAndContentCells {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [_allVisibleViewsDict enumerateKeysAndObjectsUsingBlock:^(_UXCollectionViewItemKey *key, id view, BOOL *stop) {
        if ([view isKindOfClass:[UXCollectionViewCell class]] && [key type] == UXCollectionViewItemTypeCell) {
            result[[key indexPath]] = view;
        }
    }];
    return result;
}

- (NSArray<NSIndexPath *> *)indexPathsForVisibleItems {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (_UXCollectionViewItemKey *key in _allVisibleViewsDict.keyEnumerator) {
        if ([key type] == UXCollectionViewItemTypeCell) {
            [indexPaths addObject:[key indexPath]];
        }
    }
    return indexPaths;
}

- (NSArray<NSIndexPath *> *)indexPathsForContentItems {
    return [self indexPathsForVisibleItems];
}

- (NSArray<NSIndexPath *> *)indexPathsForVisibleItemsInSections:(NSIndexSet *)sections {
    NSMutableArray *result = [NSMutableArray array];
    for (NSIndexPath *indexPath in [self indexPathsForVisibleItems]) {
        if ([sections containsIndex:(NSUInteger)indexPath.section]) {
            [result addObject:indexPath];
        }
    }
    return result;
}

- (NSArray<NSIndexPath *> *)indexPathsForContentItemsInSections:(NSIndexSet *)sections {
    return [self indexPathsForVisibleItemsInSections:sections];
}

- (NSArray<NSIndexPath *> *)_indexPathsForItemsInSections:(NSIndexSet *)sections includingOverdrawArea:(BOOL)overdrawArea {
    return [self indexPathsForVisibleItemsInSections:sections];
}

- (NSArray<NSIndexPath *> *)indexPathsForVisibleSupplementaryElementsOfKind:(NSString *)kind {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (_UXCollectionViewItemKey *key in _allVisibleViewsDict.keyEnumerator) {
        if ([key type] != UXCollectionViewItemTypeSupplementaryView) {
            continue;
        }
        if ([[key identifier] isEqualToString:kind]) {
            [indexPaths addObject:[key indexPath]];
        }
    }
    return indexPaths;
}

- (NSArray<NSIndexPath *> *)_indexPathsForVisibleSupplementaryViewsOfKind:(NSString *)kind {
    return [self indexPathsForVisibleSupplementaryElementsOfKind:kind];
}

- (UXCollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForCellWithIndexPath:indexPath];
    id view = _allVisibleViewsDict[key];
    if ([view isKindOfClass:[UXCollectionViewCell class]]) {
        return view;
    }
    return nil;
}

- (UXCollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForSupplementaryViewOfKind:kind andIndexPath:indexPath];
    return _allVisibleViewsDict[key];
}

- (__kindof UXCollectionReusableView *)_visibleSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [self _visibleSupplementaryViewOfKind:kind atIndexPath:indexPath isDecorationView:NO];
}

- (__kindof UXCollectionReusableView *)_visibleSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath isDecorationView:(BOOL)isDecorationView {
    _UXCollectionViewItemKey *key = isDecorationView
        ? [_UXCollectionViewItemKey collectionItemKeyForDecorationViewOfKind:kind andIndexPath:indexPath]
        : [_UXCollectionViewItemKey collectionItemKeyForSupplementaryViewOfKind:kind andIndexPath:indexPath];
    return _allVisibleViewsDict[key];
}

- (__kindof UXCollectionReusableView *)_visibleDecorationViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [self _visibleSupplementaryViewOfKind:kind atIndexPath:indexPath isDecorationView:YES];
}

- (NSIndexPath *)indexPathForCell:(UXCollectionViewCell *)cell {
    for (_UXCollectionViewItemKey *key in _allVisibleViewsDict) {
        if (_allVisibleViewsDict[key] == cell && [key type] == UXCollectionViewItemTypeCell) {
            return [key indexPath];
        }
    }
    return nil;
}

- (NSIndexPath *)indexPathForSupplementaryView:(UXCollectionReusableView *)supplementaryView {
    for (_UXCollectionViewItemKey *key in _allVisibleViewsDict) {
        if (_allVisibleViewsDict[key] == supplementaryView && [key type] != UXCollectionViewItemTypeCell) {
            return [key indexPath];
        }
    }
    return nil;
}

- (NSIndexPath *)_indexPathForView:(NSView *)view ofType:(NSUInteger)type {
    for (_UXCollectionViewItemKey *key in _allVisibleViewsDict) {
        id candidate = _allVisibleViewsDict[key];
        if (candidate == view && [key type] == type) {
            return [key indexPath];
        }
    }
    return nil;
}

- (NSArray<UXCollectionViewLayoutAttributes *> *)_layoutAttributesForItemsInRect:(CGRect)rect {
    NSArray<UXCollectionViewLayoutAttributes *> *all = [_collectionViewData layoutAttributesForElementsInRect:rect];
    NSMutableArray<UXCollectionViewLayoutAttributes *> *cells = [NSMutableArray array];
    for (UXCollectionViewLayoutAttributes *attributes in all) {
        if ([attributes _isCell]) {
            [cells addObject:attributes];
        }
    }
    return cells;
}

#pragma mark - Hit testing

- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point {
    if (!_doneFirstLayout) {
        [self reloadData];
        _doneFirstLayout = YES;
    }
    CGRect probeRect = CGRectMake(point.x, point.y, 1.0, 1.0);
    NSArray<UXCollectionViewLayoutAttributes *> *attributesInRect = [_collectionViewData layoutAttributesForElementsInRect:probeRect];
    __block NSIndexPath *foundIndexPath = nil;
    [attributesInRect enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UXCollectionViewLayoutAttributes *attributes, NSUInteger index, BOOL *stop) {
        if (attributes.representedElementCategory == UXCollectionElementCategoryCell) {
            foundIndexPath = attributes.indexPath;
            *stop = YES;
        }
    }];
    return foundIndexPath;
}

- (NSIndexPath *)indexPathForSupplementaryElementOfKind:(NSString *)kind atPoint:(CGPoint)point {
    CGRect probeRect = CGRectMake(point.x, point.y, 1.0, 1.0);
    NSArray<UXCollectionViewLayoutAttributes *> *attributesInRect = [_collectionViewData layoutAttributesForElementsInRect:probeRect];
    for (UXCollectionViewLayoutAttributes *attributes in attributesInRect.reverseObjectEnumerator) {
        if (attributes.representedElementCategory == UXCollectionElementCategorySupplementaryView && [[attributes _elementKind] isEqualToString:kind]) {
            return attributes.indexPath;
        }
    }
    return nil;
}

- (NSIndexPath *)indexPathForSupplementaryElementOfKind:(NSString *)kind hitByEvent:(NSEvent *)event {
    return [self _indexPathForSupplementaryElementOfKind:kind hitByEvent:event];
}

- (NSIndexPath *)_indexPathForSupplementaryElementOfKind:(NSString *)kind hitByEvent:(NSEvent *)event {
    NSPoint pointInWindow = event.locationInWindow;
    NSPoint pointInDocument = [_collectionDocumentView convertPoint:pointInWindow fromView:nil];
    return [self indexPathForSupplementaryElementOfKind:kind atPoint:pointInDocument];
}

- (NSIndexPath *)indexPathForItemHitByEvent:(NSEvent *)event {
    NSPoint pointInWindow = event.locationInWindow;
    NSPoint pointInDocument = [_collectionDocumentView convertPoint:pointInWindow fromView:nil];
    return [self indexPathForItemAtPoint:pointInDocument];
}

- (NSView *)_validateHitTest:(NSView *)view {
    if (!view) {
        return nil;
    }
    NSView *candidate = view;
    while (candidate) {
        if ([candidate isKindOfClass:[UXCollectionReusableView class]] || candidate == self || candidate == _collectionDocumentView) {
            break;
        }
        candidate = candidate.superview;
    }
    return candidate;
}

#pragma mark - Layout attribute queries

- (UXCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionViewData layoutAttributesForItemAtIndexPath:indexPath];
}

- (UXCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [_collectionViewData layoutAttributesForSupplementaryElementOfKind:kind atIndexPath:indexPath];
}

#pragma mark - Overdraw

- (void)_prepareCellsForOverdraw:(CGRect)rect {
    if (CGRectEqualToRect(rect, _lastPreparedOverdrawContentRect)) {
        return;
    }
    _lastPreparedOverdrawContentRect = rect;
    if (_collectionViewFlags.delegateDidPrepareForOverdraw) {
        [self.delegate collectionView:self didPrepareForOverdraw:rect];
    }
}

#pragma mark - Controlled subviews + z-order

- (void)_addControlled:(BOOL)controlled subview:(NSView *)subview atZIndex:(NSInteger)zIndex {
    if (controlled) {
        [(id)subview setIsFloatingPinned:NO];
        [subview setHidden:NO];
        if (subview.superview == _collectionDocumentView) {
            return;
        }
        NSArray<NSView *> *siblings = _collectionDocumentView.subviews;
        if (siblings.count == 0) {
            [_collectionDocumentView addSubview:subview positioned:NSWindowBelow relativeTo:nil];
            return;
        }
        NSView *topSibling = siblings.lastObject;
        if ([topSibling isKindOfClass:[UXCollectionReusableView class]]
            && [(id)topSibling _layoutAttributes].zIndex <= zIndex
            && !topSibling.isHidden) {
            [_collectionDocumentView addSubview:subview];
            return;
        }
        for (NSView *sibling in siblings.reverseObjectEnumerator) {
            if ([sibling isKindOfClass:[UXCollectionReusableView class]]
                && !sibling.isHidden
                && [(id)sibling _layoutAttributes].zIndex <= zIndex) {
                [_collectionDocumentView addSubview:subview positioned:NSWindowAbove relativeTo:sibling];
                return;
            }
        }
        [_collectionDocumentView addSubview:subview positioned:NSWindowBelow relativeTo:nil];
    } else if (![(id)subview isFloatingPinned]) {
        [(id)subview setIsFloatingPinned:YES];
        [subview setHidden:NO];
        [self addFloatingSubview:subview forAxis:NSEventGestureAxisVertical];
    }
}

@end
