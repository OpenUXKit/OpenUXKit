#import "UXCollectionView+Private.h"

@implementation UXCollectionView (BatchUpdates)

#pragma mark - Reload / batch updates

- (void)reloadData {
    if (_reloadingSuspendedCount > 0) {
        _collectionViewFlags.reloadSkippedDuringSuspension = YES;
        return;
    }
    _collectionViewFlags.reloading = YES;
    [self _suspendReloads];

    NSMutableDictionary *animatingViews = [NSMutableDictionary dictionary];
    for (_UXCollectionViewItemKey *key in _allVisibleViewsDict.copy) {
        UXCollectionReusableView *view = _allVisibleViewsDict[key];
        if ([view _isInUpdateAnimation]) {
            animatingViews[key] = view;
        } else if ([[(id)view _layoutAttributes] _isCell]) {
            [self _reuseCell:(UXCollectionViewCell *)view];
        } else {
            [self _reuseSupplementaryView:view];
        }
    }
    [_supplementaryElementKinds removeAllObjects];
    [_allVisibleViewsDict removeAllObjects];
    [_allVisibleViewsDict addEntriesFromDictionary:animatingViews];
    [_indexPathsForSelectedItems removeAllIndexPaths];
    _pendingSelectionIndexPath = nil;
    _pendingDeselectionIndexPaths = nil;
    _lastSelectionAnchorIndexPath = nil;
    _keyboardRangeSelectionPreviouslySelectedItems = nil;
    _keyboardRangeSelectionFirstSelectedItem = nil;
    _keyboardRangeSelectionLastSelectedItem = nil;

    [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:YES];
    [self _invalidateLayoutIfNecessary];
    [_collectionViewData invalidate:NO];
    _collectionViewFlags.needsReload = NO;
    _collectionViewFlags.reloading = NO;

    if (![self allowsEmptySelection]) {
        NSIndexPath *firstSelectableIndexPath = [self _firstSelectableItemIndexPath];
        if (firstSelectableIndexPath) {
            UXCollectionViewIndexPathsSet *selectionSet = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPath:firstSelectableIndexPath];
            // The scroll position literal 64 matches the UXKit binary (a position
            // bit above the public mask); it falls through every position check
            // and therefore scrolls nowhere while still passing a key item.
            if ([self _selectItemsInIndexPathsSet:selectionSet
                             byExtendingSelection:NO
                                         animated:NO
                                 scrollingKeyItem:firstSelectableIndexPath
                                       toPosition:(UXCollectionViewScrollPosition)64
                                   notifyDelegate:YES]) {
                _lastSelectionAnchorIndexPath = firstSelectableIndexPath;
                _keyboardRangeSelectionPreviouslySelectedItems = selectionSet;
                _keyboardRangeSelectionFirstSelectedItem = firstSelectableIndexPath;
                _keyboardRangeSelectionLastSelectedItem = firstSelectableIndexPath;
            }
        }
    }
    [self _resumeReloads];
}

- (void)_reloadDataIfNeeded {
    if (_collectionViewFlags.needsReload && _reloadingSuspendedCount == 0 && !_collectionViewFlags.reloading) {
        [self reloadData];
    }
}

- (void)_suspendReloads {
    _reloadingSuspendedCount++;
}

- (void)_resumeReloads {
    _reloadingSuspendedCount--;
    if (_reloadingSuspendedCount == 0) {
        if (_collectionViewFlags.reloadSkippedDuringSuspension) {
            _collectionViewFlags.reloadSkippedDuringSuspension = NO;
            [self reloadData];
        } else if (_collectionViewFlags.scheduledUpdateVisibleCells) {
            [self setNeedsLayout];
        }
    }
}

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion {
    if (![self _visible]) {
        _collectionViewFlags.needsReload = YES;
        if (updates) {
            updates();
        }
        if (completion) {
            completion(YES);
        }
        return;
    }

    void (^previousCompletionHandler)(BOOL) = _updateCompletionHandler;
    _updateCompletionHandler = [^(BOOL finished) {
        if (previousCompletionHandler) {
            previousCompletionHandler(finished);
        }
        if (completion) {
            completion(finished);
        }
    } copy];

    [self _beginUpdates];
    if (updates) {
        updates();
        if (![_collectionViewData layoutIsPrepared]) {
            [_collectionViewData validateLayoutInRect:[self _visibleBounds]];
            [_collectionViewData _prepareToLoadData];
        }
    }
    [self _endUpdates];
}

- (void)_beginUpdates {
    if (_updateCount == 0) {
        [self _setupCellAnimations];
    }
    _updateCount++;
}

- (void)_endUpdates {
    _updateCount--;
    if (_updateCount == 0) {
        [self _endItemAnimations];
    }
}

- (void)_setupCellAnimations {
    [self _updateVisibleCellsNow:NO];
    [_collectionViewData _prepareToLoadData];
    _collectionViewFlags.updating = YES;
    [self _suspendReloads];
}

- (NSArray *)_viewAnimationsForCurrentUpdate {
    UXCollectionViewUpdate *update = _currentUpdate;
    UXCollectionViewData *oldModel = [update _oldModel];
    UXCollectionViewData *newModel = [update _newModel];
    NSArray *previouslyVisibleViews = [_allVisibleViewsDict allValues];
    NSMutableDictionary *newVisibleViewsDict = [[NSMutableDictionary alloc] init];

    // Stage 0: migrate the surviving entries of _allVisibleViewsDict to their
    // post-update keys (cells through the global item map, supplementary views
    // through the section map; one-index keys move unchanged).
    [_allVisibleViewsDict enumerateKeysAndObjectsUsingBlock:^(_UXCollectionViewItemKey *key, UXCollectionReusableView *view, BOOL *stop) {
        if (key.type == UXCollectionViewItemTypeCell) {
            NSInteger oldGlobalIndex = [oldModel globalIndexForItemAtIndexPath:key.indexPath];
            if (oldGlobalIndex == NSNotFound) {
                return;
            }
            NSInteger newGlobalIndex = [update _oldGlobalItemMapValueAtIndex:oldGlobalIndex];
            if (newGlobalIndex == NSNotFound) {
                return;
            }
            NSIndexPath *newIndexPath = [newModel indexPathForItemAtGlobalIndex:newGlobalIndex];
            _UXCollectionViewItemKey *newKey = [[_UXCollectionViewItemKey alloc] initWithType:UXCollectionViewItemTypeCell
                                                                                    indexPath:newIndexPath
                                                                                   identifier:key.identifier
                                                                                        clone:key.isClone];
            newVisibleViewsDict[newKey] = view;
        } else if (key.indexPath.length == 1) {
            newVisibleViewsDict[key] = view;
        } else {
            NSInteger newSection = [update _oldSectionMapValueAtIndex:key.indexPath.section];
            if (newSection == NSNotFound) {
                return;
            }
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:key.indexPath.item inSection:newSection];
            _UXCollectionViewItemKey *newKey = [[_UXCollectionViewItemKey alloc] initWithType:key.type
                                                                                    indexPath:newIndexPath
                                                                                   identifier:key.identifier
                                                                                        clone:key.isClone];
            newVisibleViewsDict[newKey] = view;
        }
    }];

    NSMutableArray<UXCollectionViewAnimation *> *animations = [[NSMutableArray alloc] init];
    NSMutableIndexSet *processedOldGlobalIndexes = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet *animatedNewGlobalIndexes = [[NSMutableIndexSet alloc] init];
    CGRect animationRect = [update _newVisibleBounds];
    animationRect.size = [self _visibleBounds].size;

    void (^deleteCellAnimation)(NSInteger) = ^(NSInteger oldGlobalIndex) {
        if (oldGlobalIndex == NSNotFound) {
            return;
        }
        NSIndexPath *oldIndexPath = [oldModel indexPathForItemAtGlobalIndex:oldGlobalIndex];
        _UXCollectionViewItemKey *oldKey = [_UXCollectionViewItemKey collectionItemKeyForCellWithIndexPath:oldIndexPath];
        UXCollectionReusableView *view = self->_allVisibleViewsDict[oldKey];
        if (!view) {
            return;
        }
        UXCollectionViewLayoutAttributes *finalAttributes = [self->_layout finalLayoutAttributesForDisappearingItemAtIndexPath:oldIndexPath];
        if (!finalAttributes) {
            finalAttributes = [[(id)view _layoutAttributes] copy];
            finalAttributes.alpha = 0.0;
        }
        UXCollectionViewAnimation *animation = [[UXCollectionViewAnimation alloc] initWithView:view
                                                                                      viewType:UXCollectionViewItemTypeCell
                                                                         finalLayoutAttributes:finalAttributes
                                                                                 startFraction:0.0
                                                                                   endFraction:1.0
                                                                    animateFromCurrentPosition:YES
                                                                          deleteAfterAnimation:YES
                                                                              customAnimations:[self->_layout _animationForReusableView:view toLayoutAttributes:finalAttributes type:2]];
        [self->_allVisibleViewsDict removeObjectForKey:oldKey];
        [animations addObject:animation];
    };

    // Stage 1: deletions (cells through the old model; whole sections also pull
    // their supplementary views out of the visible dictionary).
    for (UXCollectionViewUpdateItem *deleteItem in _deleteItems) {
        if ([deleteItem _isSectionOperation]) {
            NSInteger section = [[deleteItem _indexPath] section];
            NSInteger itemCount = [oldModel numberOfItemsInSection:section];
            if (itemCount >= 1) {
                NSInteger firstGlobalIndex = [oldModel globalIndexForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
                NSAssert(firstGlobalIndex != NSNotFound, @"unexpected global item index for the first item in section %ld", (long)section);
                for (NSInteger itemOffset = 0; itemOffset < itemCount; itemOffset++) {
                    deleteCellAnimation(firstGlobalIndex + itemOffset);
                }
            }
            for (UXCollectionViewLayoutAttributes *attributes in [oldModel existingSupplementaryLayoutAttributesInSection:section]) {
                _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:attributes];
                UXCollectionReusableView *view = _allVisibleViewsDict[key];
                if (!view) {
                    continue;
                }
                UXCollectionViewLayoutAttributes *finalAttributes = [attributes _isDecorationView]
                    ? [_layout finalLayoutAttributesForDisappearingDecorationElementOfKind:[attributes _elementKind] atIndexPath:attributes.indexPath]
                    : [_layout finalLayoutAttributesForDisappearingSupplementaryElementOfKind:[attributes _elementKind] atIndexPath:attributes.indexPath];
                if (!finalAttributes) {
                    finalAttributes = [attributes copy];
                    finalAttributes.alpha = 0.0;
                }
                UXCollectionViewAnimation *animation = [[UXCollectionViewAnimation alloc] initWithView:view
                                                                                              viewType:UXCollectionViewItemTypeSupplementaryView
                                                                                 finalLayoutAttributes:finalAttributes
                                                                                         startFraction:0.0
                                                                                           endFraction:1.0
                                                                            animateFromCurrentPosition:YES
                                                                                  deleteAfterAnimation:YES
                                                                                      customAnimations:[_layout _animationForReusableView:view toLayoutAttributes:finalAttributes type:2]];
                [_allVisibleViewsDict removeObjectForKey:key];
                [animations addObject:animation];
            }
        } else {
            deleteCellAnimation([oldModel globalIndexForItemAtIndexPath:[deleteItem _indexPath]]);
        }
    }

    UXCollectionViewAnimation *(^appearSupplementaryAnimation)(UXCollectionViewLayoutAttributes *) = ^UXCollectionViewAnimation *(UXCollectionViewLayoutAttributes *attributes) {
        BOOL isDecorationView = [attributes _isDecorationView];
        NSString *elementKind = [attributes _elementKind];
        NSIndexPath *indexPath = attributes.indexPath;
        UXCollectionViewLayoutAttributes *initialAttributes = isDecorationView
            ? [self->_layout initialLayoutAttributesForAppearingDecorationElementOfKind:elementKind atIndexPath:indexPath]
            : [self->_layout initialLayoutAttributesForAppearingSupplementaryElementOfKind:elementKind atIndexPath:indexPath];
        if (!CGRectIntersectsRect(animationRect, CGRectUnion(initialAttributes.frame, attributes.frame))) {
            return nil;
        }
        UXCollectionReusableView *view = [self _createPreparedSupplementaryViewForElementOfKind:elementKind
                                                                                    atIndexPath:indexPath
                                                                           withLayoutAttributes:initialAttributes
                                                                                applyAttributes:YES];
        if (!view) {
            return nil;
        }
        _UXCollectionViewItemKey *key = isDecorationView
            ? [_UXCollectionViewItemKey collectionItemKeyForDecorationViewOfKind:elementKind andIndexPath:indexPath]
            : [_UXCollectionViewItemKey collectionItemKeyForSupplementaryViewOfKind:elementKind andIndexPath:indexPath];
        newVisibleViewsDict[key] = view;
        [self _addControlled:YES subview:view atZIndex:attributes.zIndex];
        return [[UXCollectionViewAnimation alloc] initWithView:view
                                                      viewType:UXCollectionViewItemTypeSupplementaryView
                                         finalLayoutAttributes:attributes
                                                 startFraction:0.0
                                                   endFraction:1.0
                                    animateFromCurrentPosition:NO
                                          deleteAfterAnimation:NO
                                              customAnimations:[self->_layout _animationForReusableView:view toLayoutAttributes:attributes type:2]];
    };

    void (^insertCellAnimation)(NSInteger) = ^(NSInteger newGlobalIndex) {
        NSIndexPath *newIndexPath = [newModel indexPathForItemAtGlobalIndex:newGlobalIndex];
        UXCollectionViewLayoutAttributes *initialAttributes = [self->_layout initialLayoutAttributesForAppearingItemAtIndexPath:newIndexPath];
        UXCollectionViewLayoutAttributes *targetAttributes = [newModel layoutAttributesForItemAtIndexPath:newIndexPath];
        if (!initialAttributes) {
            initialAttributes = [targetAttributes copy];
            initialAttributes.alpha = 0.0;
        }
        if (!CGRectIntersectsRect(animationRect, CGRectUnion(initialAttributes.frame, targetAttributes.frame))) {
            return;
        }
        if (initialAttributes.isHidden && targetAttributes.isHidden) {
            return;
        }
        UXCollectionViewCell *cell = [self _createPreparedCellForItemAtIndexPath:newIndexPath
                                                            withLayoutAttributes:initialAttributes
                                                                 applyAttributes:YES];
        if (!cell) {
            return;
        }
        UXCollectionViewAnimation *animation = [[UXCollectionViewAnimation alloc] initWithView:cell
                                                                                      viewType:UXCollectionViewItemTypeCell
                                                                         finalLayoutAttributes:targetAttributes
                                                                                 startFraction:0.0
                                                                                   endFraction:1.0
                                                                    animateFromCurrentPosition:NO
                                                                          deleteAfterAnimation:NO
                                                                              customAnimations:[self->_layout _animationForReusableView:cell toLayoutAttributes:targetAttributes type:2]];
        [animations addObject:animation];
        newVisibleViewsDict[[_UXCollectionViewItemKey collectionItemKeyForCellWithIndexPath:newIndexPath]] = cell;
    };

    // Stage 2: insertions (cells through the new model; whole sections also
    // bring their supplementary views in).
    for (UXCollectionViewUpdateItem *insertItem in _insertItems) {
        if ([insertItem _isSectionOperation]) {
            NSInteger section = [[insertItem _indexPath] section];
            NSInteger itemCount = [newModel numberOfItemsInSection:section];
            if (itemCount >= 1) {
                NSInteger firstGlobalIndex = [newModel globalIndexForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
                NSAssert(firstGlobalIndex != NSNotFound, @"unexpected global item index for the first item in section %ld", (long)section);
                for (NSInteger itemOffset = 0; itemOffset < itemCount; itemOffset++) {
                    insertCellAnimation(firstGlobalIndex + itemOffset);
                }
            }
            for (UXCollectionViewLayoutAttributes *attributes in [newModel existingSupplementaryLayoutAttributesInSection:section]) {
                UXCollectionViewAnimation *animation = appearSupplementaryAnimation(attributes);
                if (animation) {
                    [animations addObject:animation];
                }
            }
        } else {
            insertCellAnimation([newModel globalIndexForItemAtIndexPath:[insertItem _indexPath]]);
        }
    }

    // Stage 3: collect target attributes for the cells that survive the update
    // (still visible) or scroll into the new visible bounds.
    NSMutableArray<UXCollectionViewLayoutAttributes *> *movedAttributesList = [[NSMutableArray alloc] init];
    for (UXCollectionReusableView *view in _allVisibleViewsDict.objectEnumerator) {
        if (![previouslyVisibleViews containsObject:view]) {
            continue;
        }
        UXCollectionViewLayoutAttributes *attributes = [(id)view _layoutAttributes];
        if (![attributes _isCell]) {
            continue;
        }
        NSInteger oldGlobalIndex = [oldModel globalIndexForItemAtIndexPath:attributes.indexPath];
        if (oldGlobalIndex == NSNotFound) {
            continue;
        }
        NSInteger newGlobalIndex = [update _oldGlobalItemMapValueAtIndex:oldGlobalIndex];
        if (newGlobalIndex != NSNotFound) {
            UXCollectionViewLayoutAttributes *newAttributes = [newModel layoutAttributesForGlobalItemIndex:newGlobalIndex];
            if (newAttributes) {
                [movedAttributesList addObject:newAttributes];
            }
        }
        [processedOldGlobalIndexes addIndex:(NSUInteger)oldGlobalIndex];
    }
    for (UXCollectionViewLayoutAttributes *attributes in [newModel layoutAttributesForElementsInRect:animationRect]) {
        if (![attributes _isCell]) {
            continue;
        }
        NSInteger newGlobalIndex = [newModel globalIndexForItemAtIndexPath:attributes.indexPath];
        if (newGlobalIndex == NSNotFound) {
            continue;
        }
        NSInteger oldGlobalIndex = [update _newGlobalItemMapValueAtIndex:newGlobalIndex];
        if (oldGlobalIndex == NSNotFound || [processedOldGlobalIndexes containsIndex:(NSUInteger)oldGlobalIndex]) {
            continue;
        }
        [movedAttributesList addObject:attributes];
    }

    // Stage 4: double-sided animations for every surviving cell.
    for (UXCollectionViewLayoutAttributes *targetAttributes in movedAttributesList) {
        if (![targetAttributes _isCell]) {
            continue;
        }
        NSIndexPath *newIndexPath = targetAttributes.indexPath;
        NSInteger newGlobalIndex = [newModel globalIndexForItemAtIndexPath:newIndexPath];
        if (newGlobalIndex == NSNotFound) {
            continue;
        }
        NSInteger oldGlobalIndex = [update _newGlobalItemMapValueAtIndex:newGlobalIndex];
        UXCollectionViewLayoutAttributes *startingAttributes = [oldModel layoutAttributesForGlobalItemIndex:oldGlobalIndex];
        _UXCollectionViewItemKey *oldKey = [_UXCollectionViewItemKey collectionItemKeyForCellWithIndexPath:[oldModel indexPathForItemAtGlobalIndex:oldGlobalIndex]];
        if (!startingAttributes) {
            startingAttributes = [(id)_allVisibleViewsDict[oldKey] _layoutAttributes];
            if (!startingAttributes) {
                startingAttributes = [_layout initialLayoutAttributesForAppearingItemAtIndexPath:[newModel indexPathForItemAtGlobalIndex:newGlobalIndex]];
                if (!startingAttributes) {
                    startingAttributes = [targetAttributes copy];
                    startingAttributes.alpha = 0.0;
                }
            }
        }
        if (!CGRectIntersectsRect(animationRect, CGRectUnion(startingAttributes.frame, targetAttributes.frame))) {
            continue;
        }
        UXCollectionReusableView *view = _allVisibleViewsDict[oldKey];
        if (!view) {
            if (startingAttributes.isHidden && targetAttributes.isHidden) {
                continue;
            }
            view = [self _createPreparedCellForItemAtIndexPath:newIndexPath withLayoutAttributes:startingAttributes applyAttributes:YES];
            if (!view) {
                continue;
            }
            newVisibleViewsDict[[_UXCollectionViewItemKey collectionItemKeyForCellWithIndexPath:newIndexPath]] = view;
        }
        if (targetAttributes.zIndex != [(id)view _layoutAttributes].zIndex) {
            [self _addControlled:YES subview:view atZIndex:targetAttributes.zIndex];
        }
        [animations addObjectsFromArray:[self _doubleSidedAnimationsForView:view
                                               withStartingLayoutAttributes:startingAttributes
                                                             startingLayout:_layout
                                                     endingLayoutAttributes:targetAttributes
                                                               endingLayout:_layout
                                                         withAnimationSetup:nil
                                                        animationCompletion:nil
                                                     enableCustomAnimations:YES
                                                       customAnimationsType:2]];
        NSAssert(![animatedNewGlobalIndexes containsIndex:(NSUInteger)newGlobalIndex],
                 @"attempt to create two animations for new global item index %ld", (long)newGlobalIndex);
        [animatedNewGlobalIndexes addIndex:(NSUInteger)newGlobalIndex];
    }

    // Stage 5: surviving and deleted supplementary views from the old model.
    for (UXCollectionViewLayoutAttributes *oldAttributes in [oldModel existingSupplementaryLayoutAttributes]) {
        NSIndexPath *oldIndexPath = oldAttributes.indexPath;
        NSInteger oldSection = (oldIndexPath.length < 2) ? NSNotFound : oldIndexPath.section;
        if ([[update _deletedSections] containsIndex:(NSUInteger)oldSection]) {
            continue;
        }
        NSString *elementKind = [oldAttributes _elementKind];
        BOOL isDecorationView = [oldAttributes _isDecorationView];
        BOOL deleted;
        if (oldSection == NSNotFound) {
            deleted = [[update _deletedSupplementaryTopLevelIndexesDict][elementKind] containsIndex:[oldIndexPath indexAtPosition:0]];
        } else {
            deleted = [[[update _deletedSupplementaryIndexesSectionArray][oldSection] valueForKey:elementKind] containsIndex:(NSUInteger)oldIndexPath.item];
        }
        if (!deleted) {
            NSIndexPath *newIndexPath = [update newIndexPathForSupplementaryElementOfKind:elementKind oldIndexPath:oldIndexPath];
            if (!newIndexPath) {
                continue;
            }
            CGRect newRect = isDecorationView
                ? [newModel rectForDecorationElementOfKind:elementKind atIndexPath:newIndexPath]
                : [newModel rectForSupplementaryElementOfKind:elementKind atIndexPath:newIndexPath];
            if (!CGRectIntersectsRect(animationRect, CGRectUnion(oldAttributes.frame, newRect))) {
                continue;
            }
            UXCollectionReusableView *view = [self _visibleSupplementaryViewOfKind:elementKind atIndexPath:oldIndexPath isDecorationView:isDecorationView];
            UXCollectionViewLayoutAttributes *newAttributes = isDecorationView
                ? [newModel layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:newIndexPath]
                : [newModel layoutAttributesForSupplementaryElementOfKind:elementKind atIndexPath:newIndexPath];
            if (!view) {
                if (oldAttributes.isHidden && newAttributes.isHidden) {
                    continue;
                }
                view = [self _createPreparedSupplementaryViewForElementOfKind:elementKind
                                                                  atIndexPath:newIndexPath
                                                         withLayoutAttributes:oldAttributes
                                                              applyAttributes:YES];
                if (!view) {
                    continue;
                }
                _UXCollectionViewItemKey *newKey = isDecorationView
                    ? [_UXCollectionViewItemKey collectionItemKeyForDecorationViewOfKind:elementKind andIndexPath:newIndexPath]
                    : [_UXCollectionViewItemKey collectionItemKeyForSupplementaryViewOfKind:elementKind andIndexPath:newIndexPath];
                newVisibleViewsDict[newKey] = view;
            }
            if (newAttributes.isFloating != [(id)view isFloatingPinned]
                || (![(id)view isFloatingPinned] && newAttributes.zIndex != [(id)view _layoutAttributes].zIndex)) {
                [self _addControlled:YES subview:view atZIndex:newAttributes.zIndex];
            }
            if (newAttributes) {
                [animations addObjectsFromArray:[self _doubleSidedAnimationsForView:view
                                                       withStartingLayoutAttributes:oldAttributes
                                                                     startingLayout:_layout
                                                             endingLayoutAttributes:newAttributes
                                                                       endingLayout:_layout
                                                                 withAnimationSetup:nil
                                                                animationCompletion:nil
                                                             enableCustomAnimations:YES
                                                               customAnimationsType:2]];
            } else {
                UXCollectionViewLayoutAttributes *finalAttributes = isDecorationView
                    ? [_layout finalLayoutAttributesForDisappearingDecorationElementOfKind:elementKind atIndexPath:oldIndexPath]
                    : [_layout finalLayoutAttributesForDisappearingSupplementaryElementOfKind:elementKind atIndexPath:oldIndexPath];
                UXCollectionViewAnimation *animation = [[UXCollectionViewAnimation alloc] initWithView:view
                                                                                              viewType:UXCollectionViewItemTypeSupplementaryView
                                                                                 finalLayoutAttributes:finalAttributes
                                                                                         startFraction:0.0
                                                                                           endFraction:1.0
                                                                            animateFromCurrentPosition:YES
                                                                                  deleteAfterAnimation:YES
                                                                                      customAnimations:[_layout _animationForReusableView:view toLayoutAttributes:finalAttributes type:2]];
                [animations addObject:animation];
                [_allVisibleViewsDict removeObjectForKey:[_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:oldAttributes]];
            }
        } else {
            UXCollectionViewLayoutAttributes *finalAttributes = isDecorationView
                ? [_layout finalLayoutAttributesForDisappearingDecorationElementOfKind:elementKind atIndexPath:oldIndexPath]
                : [_layout finalLayoutAttributesForDisappearingSupplementaryElementOfKind:elementKind atIndexPath:oldIndexPath];
            if (!CGRectIntersectsRect(animationRect, CGRectUnion(oldAttributes.frame, finalAttributes.frame))) {
                continue;
            }
            UXCollectionReusableView *view = [self _visibleSupplementaryViewOfKind:elementKind atIndexPath:oldIndexPath isDecorationView:isDecorationView];
            if (!view) {
                continue;
            }
            UXCollectionViewAnimation *animation = [[UXCollectionViewAnimation alloc] initWithView:view
                                                                                          viewType:UXCollectionViewItemTypeSupplementaryView
                                                                             finalLayoutAttributes:finalAttributes
                                                                                     startFraction:0.0
                                                                                       endFraction:1.0
                                                                        animateFromCurrentPosition:YES
                                                                              deleteAfterAnimation:YES
                                                                                  customAnimations:[_layout _animationForReusableView:view toLayoutAttributes:finalAttributes type:2]];
            [animations addObject:animation];
            [_allVisibleViewsDict removeObjectForKey:[_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:oldAttributes]];
        }
    }

    // Stage 6: supplementary views inserted by the update (per-section table,
    // then the top-level one-index table).
    NSInteger newSectionCount = [newModel numberOfSections];
    NSArray *insertedSectionArray = [update _insertedSupplementaryIndexesSectionArray];
    for (UXCollectionViewLayoutAttributes *attributes in [newModel existingSupplementaryLayoutAttributesWithMinimalIndexPathLength:2]) {
        NSIndexPath *indexPath = attributes.indexPath;
        if (indexPath.section >= newSectionCount) {
            continue;
        }
        if (![[insertedSectionArray[indexPath.section] valueForKey:[attributes _elementKind]] containsIndex:(NSUInteger)indexPath.item]) {
            continue;
        }
        UXCollectionViewAnimation *animation = appearSupplementaryAnimation(attributes);
        if (animation) {
            [animations addObject:animation];
        }
    }
    [[update _insertedSupplementaryTopLevelIndexesDict] enumerateKeysAndObjectsUsingBlock:^(NSString *elementKind, NSIndexSet *indexes, BOOL *stop) {
        BOOL isDecorationView = [[newModel knownDecorationElementKinds] containsObject:elementKind];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *innerStop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:index];
            UXCollectionViewLayoutAttributes *attributes = isDecorationView
                ? [newModel layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath]
                : [newModel layoutAttributesForSupplementaryElementOfKind:elementKind atIndexPath:indexPath];
            UXCollectionViewAnimation *animation = appearSupplementaryAnimation(attributes);
            if (animation) {
                [animations addObject:animation];
            }
        }];
    }];

    _allVisibleViewsDict = newVisibleViewsDict;
    return animations;
}

- (NSArray *)_doubleSidedAnimationsForView:(UXCollectionReusableView *)view
                withStartingLayoutAttributes:(UXCollectionViewLayoutAttributes *)startAttributes
                              startingLayout:(UXCollectionViewLayout *)startLayout
                       endingLayoutAttributes:(UXCollectionViewLayoutAttributes *)endAttributes
                                endingLayout:(UXCollectionViewLayout *)endLayout
                          withAnimationSetup:(void (^)(void))animationSetup
                          animationCompletion:(void (^)(BOOL))animationCompletion
                        enableCustomAnimations:(BOOL)enableCustomAnimations
                          customAnimationsType:(NSUInteger)customAnimationsType {
    UXCollectionViewLayoutAttributes *finalAttributes = nil;
    UXCollectionViewLayoutAttributes *initialAttributes = nil;
    if ([startAttributes _isCell]) {
        finalAttributes = [startLayout finalLayoutAttributesForDisappearingItemAtIndexPath:startAttributes.indexPath];
        initialAttributes = [endLayout initialLayoutAttributesForAppearingItemAtIndexPath:endAttributes.indexPath];
    } else if ([startAttributes _isDecorationView]) {
        finalAttributes = [[startLayout finalLayoutAttributesForDisappearingDecorationElementOfKind:[startAttributes _elementKind] atIndexPath:startAttributes.indexPath] copy];
        initialAttributes = [endLayout initialLayoutAttributesForAppearingDecorationElementOfKind:[startAttributes _elementKind] atIndexPath:endAttributes.indexPath];
    } else {
        finalAttributes = [startLayout finalLayoutAttributesForDisappearingSupplementaryElementOfKind:[startAttributes _elementKind] atIndexPath:startAttributes.indexPath];
        initialAttributes = [endLayout initialLayoutAttributesForAppearingSupplementaryElementOfKind:[startAttributes _elementKind] atIndexPath:endAttributes.indexPath];
    }
    if (!finalAttributes) {
        if (endAttributes && [initialAttributes _isEquivalentTo:startAttributes]) {
            finalAttributes = endAttributes;
        } else {
            finalAttributes = [startAttributes copy];
            finalAttributes.alpha = 0.0;
        }
    }

    NSUInteger viewType = [endAttributes _isCell] ? UXCollectionViewItemTypeCell : UXCollectionViewItemTypeSupplementaryView;
    id customAnimations = nil;
    if (enableCustomAnimations) {
        customAnimations = [endLayout _animationForReusableView:view toLayoutAttributes:endAttributes type:customAnimationsType];
    }
    UXCollectionViewAnimation *animation = [[UXCollectionViewAnimation alloc] initWithView:view
                                                                                  viewType:viewType
                                                                     finalLayoutAttributes:endAttributes
                                                                             startFraction:0.0
                                                                               endFraction:1.0
                                                                animateFromCurrentPosition:NO
                                                                      deleteAfterAnimation:NO
                                                                          customAnimations:customAnimations];
    if (animationSetup) {
        [animation addStartupHandler:animationSetup];
    }
    if (animationCompletion) {
        [animation addCompletionHandler:^{
            animationCompletion(YES);
        }];
    }
    return @[animation];
}

- (void)_updateAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(UXCollectionViewAnimationContext *)context {
    context.animationCount--;
    _updateAnimationCount--;
    if (context.animationCount != 0) {
        return;
    }
    for (UXCollectionViewAnimation *animation in context.viewAnimations) {
        NSView *animationView = animation.view;
        if ([animationView isKindOfClass:[_UXCollectionSnapshotView class]]) {
            continue;
        }
        [(id)animationView _clearUpdateAnimation];
        if (animation.resetRasterizationAfterAnimation) {
            animationView.layer.shouldRasterize = animation.rasterizeAfterAnimation;
        }
        if (![(id)animationView _isInUpdateAnimation] && !animation.deleteAfterAnimation) {
            if (!CGRectIntersectsRect(animationView.frame, [self _visibleBounds])) {
                [_allVisibleViewsDict removeObjectForKey:[_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:[(id)animationView _layoutAttributes]]];
            }
        }
        if (![_allVisibleViewsDict.allValues containsObject:animationView] && ![(id)animationView _isInUpdateAnimation]) {
            if (animation.viewType == UXCollectionViewItemTypeCell) {
                [self _reuseCell:(UXCollectionViewCell *)animationView];
            } else if (animation.viewType == UXCollectionViewItemTypeSupplementaryView) {
                [self _reuseSupplementaryView:(UXCollectionReusableView *)animationView];
            } else {
                NSAssert(NO, @"UICollectionView finished animating a view of unknown type: %@", animationView);
            }
        }
    }
    [self performWithoutAnimation:^{
        [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:NO];
    }];
    void (^completionHandler)(BOOL) = context.completionHandler;
    if (completionHandler) {
        completionHandler([finished boolValue]);
    }
}

- (void)_endItemAnimations {
    _updateCount++;
    [_doubleClickContext removeAllObjects];
    if (_collectionViewData) {
        // Step 1: retire the old model and build the new one.
        UXCollectionViewData *oldModel = _collectionViewData;
        [oldModel setLayoutLocked:YES];
        _collectionViewData = [[UXCollectionViewData alloc] initWithCollectionView:self layout:_layout];

        // Step 2: sort the four families (deletes descending, the rest ascending).
        NSArray *sortedDeletes = [[self _arrayForUpdateAction:UXCollectionUpdateActionDelete] sortedArrayUsingSelector:@selector(inverseCompareIndexPaths:)];
        NSArray *sortedInserts = [[self _arrayForUpdateAction:UXCollectionUpdateActionInsert] sortedArrayUsingSelector:@selector(compareIndexPaths:)];
        NSMutableArray *reloadItems = [[_reloadItems sortedArrayUsingSelector:@selector(compareIndexPaths:)] mutableCopy];
        NSMutableArray *moveItems = [[_moveItems sortedArrayUsingSelector:@selector(compareIndexPaths:)] mutableCopy];
        _originalDeleteItems = [sortedDeletes copy];
        _originalInsertItems = [sortedInserts copy];

        // Step 3: decompose every reload into a delete at the old position and
        // an insert at the position adjusted by the other pending operations.
        for (UXCollectionViewUpdateItem *reloadItem in reloadItems) {
            NSIndexPath *reloadIndexPath = [reloadItem _indexPath];
            NSInteger adjustedSection = reloadIndexPath.section;
            NSInteger adjustedItem = reloadIndexPath.item;
            for (UXCollectionViewUpdateItem *deleteItem in sortedDeletes) {
                NSIndexPath *deleteIndexPath = [deleteItem _indexPath];
                NSAssert(![deleteIndexPath isEqual:reloadIndexPath],
                         @"attempt to delete and reload the same index path (%@)", deleteIndexPath);
                if ([deleteItem _isSectionOperation] && deleteIndexPath.section == reloadIndexPath.section) {
                    continue;
                }
                if ([deleteItem _isSectionOperation]) {
                    adjustedSection -= (deleteIndexPath.section <= adjustedSection);
                }
                if (![reloadItem _isSectionOperation] && ![deleteItem _isSectionOperation]
                    && deleteIndexPath.section == adjustedSection) {
                    adjustedItem -= (deleteIndexPath.item <= adjustedItem);
                }
            }
            for (UXCollectionViewUpdateItem *insertItem in sortedInserts) {
                NSIndexPath *insertIndexPath = [insertItem _indexPath];
                if ([insertItem _isSectionOperation] && insertIndexPath.section <= adjustedSection) {
                    adjustedSection++;
                }
                if (![reloadItem _isSectionOperation] && ![insertItem _isSectionOperation]
                    && insertIndexPath.section == adjustedSection && insertIndexPath.item <= adjustedItem) {
                    adjustedItem++;
                }
            }
            UXCollectionViewUpdateItem *decomposedDelete = [[UXCollectionViewUpdateItem alloc] initWithAction:UXCollectionUpdateActionDelete
                                                                                                 forIndexPath:[NSIndexPath indexPathForItem:reloadIndexPath.item inSection:reloadIndexPath.section]];
            [_deleteItems addObject:decomposedDelete];
            UXCollectionViewUpdateItem *decomposedInsert = [[UXCollectionViewUpdateItem alloc] initWithAction:UXCollectionUpdateActionInsert
                                                                                                 forIndexPath:[NSIndexPath indexPathForItem:adjustedItem inSection:adjustedSection]];
            [reloadItem _setNewIndexPath:[decomposedInsert _indexPath]];
            [_insertItems addObject:decomposedInsert];
        }

        // Step 4: re-sort the merged families.
        NSMutableArray *allDeletes = [[_deleteItems sortedArrayUsingSelector:@selector(inverseCompareIndexPaths:)] mutableCopy];
        NSMutableArray *allInserts = [[_insertItems sortedArrayUsingSelector:@selector(compareIndexPaths:)] mutableCopy];

        // Step 5a: validate deletes against the old model.
        for (NSUInteger deleteIndex = 0; deleteIndex < allDeletes.count; deleteIndex++) {
            UXCollectionViewUpdateItem *deleteItem = allDeletes[deleteIndex];
            NSIndexPath *deleteIndexPath = [deleteItem _indexPath];
            if ([deleteItem _isSectionOperation]) {
                NSAssert(deleteIndexPath.section < [oldModel numberOfSections],
                         @"attempt to delete section %ld, but there are only %ld sections before the update",
                         (long)deleteIndexPath.section, (long)[oldModel numberOfSections]);
                for (NSUInteger scanIndex = 0; scanIndex < allDeletes.count;) {
                    UXCollectionViewUpdateItem *scanItem = allDeletes[scanIndex];
                    if (![scanItem _isSectionOperation]
                        && [[scanItem _indexPath] section] == deleteIndexPath.section) {
                        [allDeletes removeObjectAtIndex:scanIndex];
                        if (scanIndex < deleteIndex) {
                            deleteIndex--;
                        }
                    } else {
                        scanIndex++;
                    }
                }
                for (UXCollectionViewUpdateItem *moveItem in moveItems) {
                    NSIndexPath *moveIndexPath = [moveItem _indexPath];
                    if ([moveIndexPath isEqual:deleteIndexPath]) {
                        if ([moveItem _isSectionOperation]) {
                            NSAssert(NO, @"attempt to perform a delete and a move from the same section (%ld)", (long)deleteIndexPath.section);
                        } else {
                            NSAssert(NO, @"attempt to perform a delete and a move from the same index path (%@)", deleteIndexPath);
                        }
                    } else if ([deleteItem _isSectionOperation]
                               && deleteIndexPath.section == moveIndexPath.section) {
                        NSAssert(NO, @"cannot move an item from a deleted section (%ld)", (long)deleteIndexPath.section);
                    }
                }
            } else {
                NSAssert(deleteIndexPath.section < [oldModel numberOfSections],
                         @"attempt to delete item %ld from section %ld, but there are only %ld sections before the update",
                         (long)deleteIndexPath.item, (long)deleteIndexPath.section, (long)[oldModel numberOfSections]);
                NSAssert(deleteIndexPath.item < [oldModel numberOfItemsInSection:deleteIndexPath.section],
                         @"attempt to delete item %ld from section %ld which only contains %ld items before the update",
                         (long)deleteIndexPath.item, (long)deleteIndexPath.section,
                         (long)[oldModel numberOfItemsInSection:deleteIndexPath.section]);
            }
        }

        // Step 5b: validate inserts against the new model.
        for (NSUInteger insertIndex = 0; insertIndex < allInserts.count; insertIndex++) {
            UXCollectionViewUpdateItem *insertItem = allInserts[insertIndex];
            NSIndexPath *insertIndexPath = [insertItem _indexPath];
            if ([insertItem _isSectionOperation]) {
                NSAssert(insertIndexPath.section < [_collectionViewData numberOfSections],
                         @"attempt to insert section %ld but there are only %ld sections after the update",
                         (long)insertIndexPath.section, (long)[_collectionViewData numberOfSections]);
                for (NSUInteger scanIndex = 0; scanIndex < allInserts.count;) {
                    UXCollectionViewUpdateItem *scanItem = allInserts[scanIndex];
                    if (![scanItem _isSectionOperation]
                        && [[scanItem _indexPath] section] == insertIndexPath.section) {
                        [allInserts removeObjectAtIndex:scanIndex];
                        if (scanIndex < insertIndex) {
                            insertIndex--;
                        }
                    } else {
                        scanIndex++;
                    }
                }
                for (UXCollectionViewUpdateItem *moveItem in moveItems) {
                    if ([[moveItem _newIndexPath] isEqual:insertIndexPath]) {
                        if ([moveItem _isSectionOperation]) {
                            NSAssert(NO, @"attempt to perform an insert and a move to the same section (%ld)", (long)insertIndexPath.section);
                        } else {
                            NSAssert(NO, @"attempt to perform an insert and a move to the same index path (%@)", insertIndexPath);
                        }
                    } else if ([insertItem _isSectionOperation]
                               && insertIndexPath.section == [[moveItem _newIndexPath] section]) {
                        NSAssert(NO, @"cannot move an item into a newly inserted section (%ld)", (long)insertIndexPath.section);
                    }
                }
            } else {
                NSAssert(insertIndexPath.section < [_collectionViewData numberOfSections],
                         @"attempt to insert item %ld into section %ld, but there are only %ld sections after the update",
                         (long)insertIndexPath.item, (long)insertIndexPath.section, (long)[_collectionViewData numberOfSections]);
                NSAssert(insertIndexPath.item < [_collectionViewData numberOfItemsInSection:insertIndexPath.section],
                         @"attempt to insert item %ld into section %ld, but there are only %ld items in section %ld after the update",
                         (long)insertIndexPath.item, (long)insertIndexPath.section,
                         (long)[_collectionViewData numberOfItemsInSection:insertIndexPath.section], (long)insertIndexPath.section);
            }
        }

        // Step 5c: validate moves on both sides and drop exact duplicates.
        for (NSUInteger moveIndex = 0; moveIndex < moveItems.count; moveIndex++) {
            UXCollectionViewUpdateItem *moveItem = moveItems[moveIndex];
            NSIndexPath *fromIndexPath = [moveItem _indexPath];
            NSIndexPath *toIndexPath = [moveItem _newIndexPath];
            if ([moveItem _isSectionOperation]) {
                NSAssert(fromIndexPath.section < [oldModel numberOfSections],
                         @"attempt to move section %ld, but there are only %ld sections before the update",
                         (long)fromIndexPath.section, (long)[oldModel numberOfSections]);
                NSAssert(toIndexPath.section < [_collectionViewData numberOfSections],
                         @"attempt to to move section %ld to section %ld, but there are only %ld sections after the update",
                         (long)fromIndexPath.section, (long)toIndexPath.section, (long)[_collectionViewData numberOfSections]);
            } else {
                NSAssert(fromIndexPath.section < [oldModel numberOfSections],
                         @"attempt to move index path (%@) from a section that does not exist - there are only %ld sections before the update",
                         fromIndexPath, (long)[oldModel numberOfSections]);
                NSAssert(fromIndexPath.item < [oldModel numberOfItemsInSection:fromIndexPath.section],
                         @"attempt to move index path (%@) that does not exist - there are only %ld items in section %ld before the update",
                         fromIndexPath, (long)[oldModel numberOfItemsInSection:fromIndexPath.section], (long)fromIndexPath.section);
                NSAssert(toIndexPath.section < [_collectionViewData numberOfSections],
                         @"attempt to move index path (%@) to index path (%@) in section that does not exist - there are only %ld sections after the update",
                         fromIndexPath, toIndexPath, (long)[_collectionViewData numberOfSections]);
                NSAssert(toIndexPath.item < [_collectionViewData numberOfItemsInSection:toIndexPath.section],
                         @"attempt to move index path (%@) to index path (%@) that does not exist - there are only %ld items in section %ld after the update",
                         fromIndexPath, toIndexPath, (long)[_collectionViewData numberOfItemsInSection:toIndexPath.section], (long)toIndexPath.section);
            }
            for (NSUInteger scanIndex = moveIndex + 1; scanIndex < moveItems.count;) {
                UXCollectionViewUpdateItem *scanItem = moveItems[scanIndex];
                BOOL sameSource = [fromIndexPath isEqual:[scanItem _indexPath]];
                BOOL sameDestination = [toIndexPath isEqual:[scanItem _newIndexPath]];
                if (sameSource && sameDestination) {
                    [moveItems removeObjectAtIndex:scanIndex];
                    continue;
                }
                if (sameSource) {
                    if ([moveItem _isSectionOperation]) {
                        NSAssert(NO, @"attempt to move section %ld to both section %ld and section %ld",
                                 (long)fromIndexPath.section, (long)toIndexPath.section, (long)[[scanItem _newIndexPath] section]);
                    } else {
                        NSAssert(NO, @"attempt to move item at index path %@ to both %@ and %@",
                                 fromIndexPath, toIndexPath, [scanItem _newIndexPath]);
                    }
                } else if (sameDestination) {
                    if ([moveItem _isSectionOperation]) {
                        NSAssert(NO, @"attempt to move both section %ld and section %ld to section %ld",
                                 (long)fromIndexPath.section, (long)[[scanItem _indexPath] section], (long)toIndexPath.section);
                    } else {
                        NSAssert(NO, @"attempt to move both item at index path %@ and %@ to %@",
                                 fromIndexPath, [scanItem _indexPath], toIndexPath);
                    }
                }
                scanIndex++;
            }
        }

        // Step 6: assemble the final update vector — descending deletes, moves,
        // ascending inserts. This ordering is what _computeGaps expects.
        NSMutableArray *allUpdateItems = [[NSMutableArray alloc] init];
        [allUpdateItems addObjectsFromArray:[allDeletes sortedArrayUsingSelector:@selector(inverseCompareIndexPaths:)]];
        [allUpdateItems addObjectsFromArray:moveItems];
        [allUpdateItems addObjectsFromArray:[allInserts sortedArrayUsingSelector:@selector(compareIndexPaths:)]];

        // Step 7: invalidate the layout with the update items and load the new model.
        UXCollectionViewLayoutInvalidationContext *invalidationContext = [[[[_layout class] invalidationContextClass] alloc] init];
        [invalidationContext _setInvalidateDataSourceCounts:YES];
        [invalidationContext _setUpdateItems:allUpdateItems];
        [_layout _invalidateLayoutUsingContext:invalidationContext];
        [_collectionViewData _prepareToLoadData];
        [_collectionViewData validateLayoutInRect:[self _visibleBounds]];

        // Step 8: compute the new visible bounds, pulling the viewport back in
        // when it now hangs past the shrunken content rect.
        CGRect oldVisibleBounds = [self documentVisibleRect];
        CGRect contentRect = [_collectionViewData collectionViewContentRect];
        NSEdgeInsets contentInsets = [self contentInsets];
        contentRect.size.width += contentInsets.left + contentInsets.right;
        contentRect.size.height += contentInsets.top + contentInsets.bottom;
        CGPoint newVisibleOrigin = oldVisibleBounds.origin;
        if (!CGRectContainsRect(contentRect, oldVisibleBounds)) {
            if (CGRectGetMaxY(oldVisibleBounds) > CGRectGetMaxY(contentRect)
                && CGRectGetHeight(contentRect) > CGRectGetHeight(oldVisibleBounds)) {
                newVisibleOrigin.y -= CGRectGetMaxY(oldVisibleBounds) - CGRectGetMaxY(contentRect);
            }
            if (CGRectGetMaxX(oldVisibleBounds) > CGRectGetMaxX(contentRect)
                && CGRectGetWidth(contentRect) > CGRectGetWidth(oldVisibleBounds)) {
                newVisibleOrigin.x -= CGRectGetMaxX(oldVisibleBounds) - CGRectGetMaxX(contentRect);
            }
        }

        // Step 9: build the update object, run the count consistency checks and
        // hand over to _updateWithItems:.
        _currentUpdate = [[UXCollectionViewUpdate alloc] initWithCollectionView:self
                                                                    updateItems:allUpdateItems
                                                                       oldModel:oldModel
                                                                       newModel:_collectionViewData
                                                               oldVisibleBounds:oldVisibleBounds
                                                               newVisibleBounds:CGRectMake(newVisibleOrigin.x, newVisibleOrigin.y,
                                                                                           oldVisibleBounds.size.width, oldVisibleBounds.size.height)];

        NSInteger oldSectionCount = [oldModel numberOfSections];
        NSInteger newSectionCount = [_collectionViewData numberOfSections];
        NSInteger *oldItemCounts = calloc((size_t)MAX(oldSectionCount, 1), sizeof(NSInteger));
        NSInteger *insertedCounts = calloc((size_t)MAX(newSectionCount, 1), sizeof(NSInteger));
        NSInteger *deletedCounts = calloc((size_t)MAX(oldSectionCount, 1), sizeof(NSInteger));
        NSInteger *movedInCounts = calloc((size_t)MAX(newSectionCount, 1), sizeof(NSInteger));
        NSInteger *movedOutCounts = calloc((size_t)MAX(oldSectionCount, 1), sizeof(NSInteger));
        for (NSInteger section = 0; section < oldSectionCount; section++) {
            oldItemCounts[section] = [oldModel numberOfItemsInSection:section];
        }
        NSInteger insertedSectionCount = 0;
        NSInteger deletedSectionCount = 0;
        NSInteger expectedSectionCount = oldSectionCount;
        for (UXCollectionViewUpdateItem *updateItem in allUpdateItems) {
            NSInteger section = [[updateItem _indexPath] section];
            if ([updateItem _isSectionOperation]) {
                if ([updateItem _action] == UXCollectionUpdateActionInsert) {
                    insertedSectionCount++;
                    expectedSectionCount++;
                } else if ([updateItem _action] == UXCollectionUpdateActionDelete) {
                    deletedSectionCount++;
                    expectedSectionCount--;
                }
            } else if ([updateItem _action] == UXCollectionUpdateActionInsert) {
                insertedCounts[section]++;
            } else if ([updateItem _action] == UXCollectionUpdateActionDelete) {
                deletedCounts[section]++;
            } else if ([updateItem _action] == UXCollectionUpdateActionMove) {
                NSInteger destinationSection = [[updateItem _newIndexPath] section];
                if (section != destinationSection) {
                    movedOutCounts[section]++;
                    movedInCounts[destinationSection]++;
                }
            }
        }
        BOOL updateIsValid = YES;
        if (expectedSectionCount != newSectionCount) {
            NSAssert(NO, @"Invalid update: invalid number of sections.  The number of sections contained in the collection view after the update (%ld) must be equal to the number of sections contained in the collection view before the update (%ld), plus or minus the number of sections inserted or deleted (%ld inserted, %ld deleted).",
                     (long)newSectionCount, (long)oldSectionCount, (long)insertedSectionCount, (long)deletedSectionCount);
        }
        for (NSInteger newSection = 0; newSection < newSectionCount; newSection++) {
            NSInteger oldSection = [_currentUpdate _newSectionMapValueAtIndex:newSection];
            if (oldSection == NSNotFound) {
                continue;
            }
            NSInteger newItemCount = [_collectionViewData numberOfItemsInSection:newSection];
            if (newItemCount < 0) {
                NSAssert(NO, @"Invalid update: invalid number of items in section %ld.  Attempt to delete more items than exist in section.", (long)oldSection);
                updateIsValid = NO;
            }
            NSInteger expectedItemCount = oldItemCounts[oldSection] + insertedCounts[newSection] + movedInCounts[newSection]
                                        - (deletedCounts[oldSection] + movedOutCounts[oldSection]);
            if (newItemCount != expectedItemCount) {
                NSAssert(NO, @"Invalid update: invalid number of items in section %ld.  The number of items contained in an existing section after the update (%ld) must be equal to the number of items contained in that section before the update (%ld), plus or minus the number of items inserted or deleted from that section (%ld inserted, %ld deleted) and plus or minus the number of items moved into or out of that section (%ld moved in, %ld moved out).",
                         (long)newSection, (long)newItemCount, (long)oldItemCounts[oldSection],
                         (long)insertedCounts[newSection], (long)deletedCounts[oldSection],
                         (long)movedInCounts[newSection], (long)movedOutCounts[oldSection]);
                updateIsValid = NO;
            }
        }
        free(oldItemCounts);
        free(insertedCounts);
        free(deletedCounts);
        free(movedInCounts);
        free(movedOutCounts);

        if (updateIsValid) {
            [self _updateWithItems:allUpdateItems];
        }
    }
    _updateCount--;
    _insertItems = nil;
    _deleteItems = nil;
    _reloadItems = nil;
    _moveItems = nil;
    _originalDeleteItems = nil;
    _originalInsertItems = nil;
    _collectionViewFlags.updating = NO;
    [self _resumeReloads];
}

- (void)_prepareLayoutForUpdates {
    NSMutableArray *sortedUpdateItems = [[NSMutableArray alloc] init];
    [sortedUpdateItems addObjectsFromArray:[_originalDeleteItems sortedArrayUsingSelector:@selector(compareIndexPaths:)]];
    [sortedUpdateItems addObjectsFromArray:[_originalInsertItems sortedArrayUsingSelector:@selector(compareIndexPaths:)]];
    [sortedUpdateItems addObjectsFromArray:[_reloadItems sortedArrayUsingSelector:@selector(compareIndexPaths:)]];
    [sortedUpdateItems addObjectsFromArray:[_moveItems sortedArrayUsingSelector:@selector(compareIndexPaths:)]];
    [_layout prepareForCollectionViewUpdates:sortedUpdateItems];
}

- (NSMutableArray *)_arrayForUpdateAction:(NSInteger)updateAction {
    switch (updateAction) {
        case UXCollectionUpdateActionInsert:
            if (!_insertItems) {
                _insertItems = [[NSMutableArray alloc] init];
            }
            return _insertItems;
        case UXCollectionUpdateActionDelete:
            if (!_deleteItems) {
                _deleteItems = [[NSMutableArray alloc] init];
            }
            return _deleteItems;
        case UXCollectionUpdateActionReload:
            if (!_reloadItems) {
                _reloadItems = [[NSMutableArray alloc] init];
            }
            return _reloadItems;
        case UXCollectionUpdateActionMove:
            if (!_moveItems) {
                _moveItems = [[NSMutableArray alloc] init];
            }
            return _moveItems;
        default:
            NSAssert(NO, @"Invalid update action encountered %ld", (long)updateAction);
            return nil;
    }
}

- (void)_updateRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths updateAction:(NSInteger)updateAction {
    if (![self _visible]) {
        _collectionViewFlags.needsReload = YES;
        return;
    }
    [self _reloadDataIfNeeded];
    BOOL wasUpdating = _collectionViewFlags.updating;
    if (!wasUpdating) {
        [self _setupCellAnimations];
    }
    NSMutableArray *target = [self _arrayForUpdateAction:updateAction];
    for (NSIndexPath *indexPath in indexPaths) {
        UXCollectionViewUpdateItem *item = [[UXCollectionViewUpdateItem alloc] initWithAction:updateAction forIndexPath:indexPath];
        [target addObject:item];
    }
    if (!wasUpdating) {
        [self _endItemAnimations];
    }
}

- (void)_updateSections:(NSIndexSet *)sections updateAction:(NSInteger)updateAction {
    if (![self _visible]) {
        _collectionViewFlags.needsReload = YES;
        return;
    }
    [self _reloadDataIfNeeded];
    BOOL wasUpdating = _collectionViewFlags.updating;
    if (!wasUpdating) {
        [self _setupCellAnimations];
    }
    NSMutableArray *target = [self _arrayForUpdateAction:updateAction];
    [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
        UXCollectionViewUpdateItem *item = [[UXCollectionViewUpdateItem alloc] initWithAction:updateAction
                                                                                 forIndexPath:[NSIndexPath indexPathForItem:NSNotFound inSection:(NSInteger)section]];
        [target addObject:item];
    }];
    if (!wasUpdating) {
        [self _endItemAnimations];
    }
}

- (void)_updateWithItems:(NSArray *)items {
    UXCollectionViewUpdate *update = _currentUpdate;
    UXCollectionViewData *oldModel = [update _oldModel];

    // Remap every selection-related index path container from the old model to
    // the new one through the update's global item map.
    NSIndexPath *(^adjustedIndexPath)(NSIndexPath *) = ^NSIndexPath *(NSIndexPath *indexPath) {
        if (!indexPath) {
            return nil;
        }
        NSInteger oldGlobalIndex = [oldModel globalIndexForItemAtIndexPath:indexPath];
        if (oldGlobalIndex == NSNotFound) {
            return nil;
        }
        NSInteger newGlobalIndex = [update _oldGlobalItemMapValueAtIndex:oldGlobalIndex];
        if (newGlobalIndex == NSNotFound) {
            return nil;
        }
        return [self->_collectionViewData indexPathForItemAtGlobalIndex:newGlobalIndex];
    };
    UXCollectionViewMutableIndexPathsSet *(^adjustedIndexPathsSet)(UXCollectionViewIndexPathsSet *) = ^(UXCollectionViewIndexPathsSet *indexPathsSet) {
        UXCollectionViewMutableIndexPathsSet *adjustedSet = [[UXCollectionViewMutableIndexPathsSet alloc] init];
        [indexPathsSet enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
            NSIndexPath *adjusted = adjustedIndexPath(indexPath);
            if (adjusted) {
                [adjustedSet addIndexPath:adjusted];
            }
        }];
        return adjustedSet;
    };
    _indexPathsForSelectedItems = adjustedIndexPathsSet(_indexPathsForSelectedItems);
    _pendingDeselectionIndexPaths = adjustedIndexPathsSet(_pendingDeselectionIndexPaths);
    _lassoInitiallySelectedItems = adjustedIndexPathsSet(_lassoInitiallySelectedItems);
    _keyboardRangeSelectionPreviouslySelectedItems = adjustedIndexPathsSet(_keyboardRangeSelectionPreviouslySelectedItems);
    _pendingSelectionIndexPath = adjustedIndexPath(_pendingSelectionIndexPath);
    _lastSelectionAnchorIndexPath = adjustedIndexPath(_lastSelectionAnchorIndexPath);
    _keyboardRangeSelectionFirstSelectedItem = adjustedIndexPath(_keyboardRangeSelectionFirstSelectedItem);
    _keyboardRangeSelectionLastSelectedItem = adjustedIndexPath(_keyboardRangeSelectionLastSelectedItem);

    [self _prepareLayoutForUpdates];
    [update _computeSupplementaryUpdates];

    CGPoint proposedContentOffset = [update _newVisibleBounds].origin;
    proposedContentOffset = [_layout updatesContentOffsetForProposedContentOffset:proposedContentOffset];
    proposedContentOffset = [_layout targetContentOffsetForProposedContentOffset:proposedContentOffset];
    if (_collectionViewFlags.delegateTargetContentOffsetForProposedContentOffset) {
        proposedContentOffset = [(id)self.delegate _collectionView:self targetContentOffsetForProposedContentOffset:proposedContentOffset];
    }
    CGRect newVisibleBounds = [update _newVisibleBounds];
    newVisibleBounds.origin = proposedContentOffset;
    [update _setNewVisibleBounds:newVisibleBounds];

    UXCollectionViewAnimationContext *animationContext = [[UXCollectionViewAnimationContext alloc] initWithCompletionHandler:_updateCompletionHandler];
    _updateCompletionHandler = nil;
    _suspendClipViewBoundsDidChange++;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *animationGroupContext) {
        if (![CATransaction disableActions]) {
            animationGroupContext.allowsImplicitAnimation = YES;
            animationGroupContext.duration = 0.25;
        }
        if (!animationGroupContext.timingFunction) {
            animationGroupContext.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        }
        self->_updateAnimationCount++;
        animationContext.animationCount++;
        [self setContentSize:[self->_layout collectionViewContentSize]];
        [self.contentView setBoundsOrigin:[self->_currentUpdate _newVisibleBounds].origin];

        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *innerContext) {
            innerContext.allowsImplicitAnimation = NO;
            innerContext.duration = 0.0;
            animationContext.viewAnimations = [self _viewAnimationsForCurrentUpdate];
        } completionHandler:nil];

        NSMutableSet *remainingViews = [[NSMutableSet alloc] initWithArray:self->_allVisibleViewsDict.allValues];
        [self->_allVisibleViewsDict removeAllObjects];
        for (UXCollectionViewAnimation *animation in animationContext.viewAnimations) {
            NSView *animationView = animation.view;
            if (![animationView isKindOfClass:[_UXCollectionSnapshotView class]]) {
                [(id)animationView _addUpdateAnimation];
                [remainingViews removeObject:animationView];
                if (!animation.deleteAfterAnimation) {
                    self->_allVisibleViewsDict[[_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:animation.finalLayoutAttributes]] = animationView;
                }
            }
            animationContext.animationCount++;
            self->_updateAnimationCount++;
            [animation addCompletionHandler:^{
                [self _updateAnimationDidStop:nil finished:@YES context:animationContext];
            }];
            [animation start];
        }
        for (UXCollectionReusableView *remainingView in remainingViews) {
            if ([remainingView _isInUpdateAnimation]) {
                self->_allVisibleViewsDict[[_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:[(id)remainingView _layoutAttributes]]] = remainingView;
            } else if ([[(id)remainingView _layoutAttributes] _isCell]) {
                [self _reuseCell:(UXCollectionViewCell *)remainingView];
            } else {
                [self _reuseSupplementaryView:remainingView];
            }
        }
        [self->_layout finalizeCollectionViewUpdates];
    } completionHandler:^{
        self->_suspendClipViewBoundsDidChange--;
        [self _updateAnimationDidStop:nil finished:@YES context:animationContext];
    }];
    _currentUpdate = nil;
}

- (void)_addMoveUpdateItemFromIndexPath:(NSIndexPath *)initialIndexPath toIndexPath:(NSIndexPath *)finalIndexPath {
    if (![self _visible]) {
        _collectionViewFlags.needsReload = YES;
        return;
    }
    [self _reloadDataIfNeeded];
    BOOL wasUpdating = _collectionViewFlags.updating;
    if (!wasUpdating) {
        [self _setupCellAnimations];
    }
    UXCollectionViewUpdateItem *item = [[UXCollectionViewUpdateItem alloc] initWithInitialIndexPath:initialIndexPath
                                                                                     finalIndexPath:finalIndexPath
                                                                                       updateAction:UXCollectionUpdateActionMove];
    [[self _arrayForUpdateAction:UXCollectionUpdateActionMove] addObject:item];
    if (!wasUpdating) {
        [self _endItemAnimations];
    }
}

- (void)insertSections:(NSIndexSet *)sections {
    [self _updateSections:sections updateAction:UXCollectionUpdateActionInsert];
}

- (void)deleteSections:(NSIndexSet *)sections {
    [self _updateSections:sections updateAction:UXCollectionUpdateActionDelete];
}

- (void)reloadSections:(NSIndexSet *)sections {
    [self _updateSections:sections updateAction:UXCollectionUpdateActionReload];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    [self _addMoveUpdateItemFromIndexPath:[NSIndexPath indexPathForItem:NSNotFound inSection:section]
                              toIndexPath:[NSIndexPath indexPathForItem:NSNotFound inSection:newSection]];
}

- (void)insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self _updateRowsAtIndexPaths:indexPaths updateAction:UXCollectionUpdateActionInsert];
}

- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self _updateRowsAtIndexPaths:indexPaths updateAction:UXCollectionUpdateActionDelete];
}

- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self _updateRowsAtIndexPaths:indexPaths updateAction:UXCollectionUpdateActionReload];
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self _addMoveUpdateItemFromIndexPath:indexPath toIndexPath:newIndexPath];
}

@end
