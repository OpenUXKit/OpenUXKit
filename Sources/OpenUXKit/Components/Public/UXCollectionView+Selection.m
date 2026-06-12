#import "UXCollectionView+Private.h"

@implementation UXCollectionView (Selection)

#pragma mark - Selection

- (NSArray<NSIndexPath *> *)indexPathsForSelectedItems {
    return [_indexPathsForSelectedItems allIndexPaths];
}

- (NSUInteger)numberOfSelectedItems {
    return [_indexPathsForSelectedItems count];
}

- (BOOL)selectedItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_indexPathsForSelectedItems containsIndexPath:indexPath];
}

- (BOOL)selectableItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!_allowsSelection) {
        return NO;
    }
    id<UXCollectionViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(collectionView:shouldSelectItemAtIndexPath:)]) {
        return [delegate collectionView:self shouldSelectItemAtIndexPath:indexPath];
    }
    return YES;
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UXCollectionViewScrollPosition)scrollPosition {
    if (!indexPath) {
        [self deselectAllItems:animated];
        return;
    }
    [self selectItemsAtIndexPaths:@[indexPath] byExtendingSelection:NO animated:animated];
    if (scrollPosition != UXCollectionViewScrollPositionNone) {
        [self scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
    }
}

- (void)selectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths byExtendingSelection:(BOOL)extend animated:(BOOL)animated {
    [self selectItemsAtIndexPaths:indexPaths byExtendingSelection:extend animated:animated scrollItemAtIndex:nil toPosition:UXCollectionViewScrollPositionNone];
}

- (void)selectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths byExtendingSelection:(BOOL)extend animated:(BOOL)animated scrollItemAtIndex:(NSIndexPath *)indexPath toPosition:(UXCollectionViewScrollPosition)position {
    UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPaths:indexPaths ?: @[]];
    [self _selectItemsInIndexPathsSet:set byExtendingSelection:extend animated:animated scrollingKeyItem:indexPath toPosition:position notifyDelegate:NO];
}

- (void)_postSelectionAccessibilityNotification {
    id layoutAccessibility = [_layout layoutAccessibility];
    if ([layoutAccessibility respondsToSelector:@selector(accessibilityPostNotification:)]) {
        [layoutAccessibility accessibilityPostNotification:NSAccessibilitySelectedCellsChangedNotification];
    }
}

- (BOOL)_selectItemsInIndexPathsSet:(UXCollectionViewIndexPathsSet *)set byExtendingSelection:(BOOL)extend animated:(BOOL)animated scrollingKeyItem:(NSIndexPath *)keyItem toPosition:(UXCollectionViewScrollPosition)position notifyDelegate:(BOOL)notifyDelegate {
    id<UXCollectionViewDelegate> delegate = self.delegate;
    UXCollectionViewIndexPathsSet *oldSelection = [_indexPathsForSelectedItems copy];

    // Build the requested selection: gated by allowsSelection, filtered through
    // the shouldSelect: delegate, optionally extended over the current
    // selection, and collapsed to a single item when multiple selection is off.
    UXCollectionViewMutableIndexPathsSet *requestedSelection;
    if (!set || !self.allowsSelection) {
        requestedSelection = [UXCollectionViewMutableIndexPathsSet indexPathsSet];
    } else {
        requestedSelection = [set mutableCopy];
        if (_collectionViewFlags.delegateShouldSelectItemAtIndexPath) {
            [set enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
                if (![delegate collectionView:self shouldSelectItemAtIndexPath:indexPath]) {
                    [requestedSelection removeIndexPath:indexPath];
                }
            }];
        }
        if (extend) {
            [requestedSelection addIndexPathsSet:oldSelection];
        }
        if (!self.allowsMultipleSelection && requestedSelection.count >= 2) {
            NSIndexPath *survivor = [requestedSelection firstIndexPath];
            if (keyItem && [requestedSelection containsIndexPath:keyItem]) {
                survivor = keyItem;
            }
            [requestedSelection removeAllIndexPaths];
            if (survivor) {
                [requestedSelection addIndexPath:survivor];
            }
        }
    }

    // Diff the requested selection against the live one.
    UXCollectionViewMutableIndexPathsSet *added = [requestedSelection mutableCopy];
    [added removeIndexPathsSet:oldSelection];
    UXCollectionViewMutableIndexPathsSet *removed = [oldSelection mutableCopy];
    [removed removeIndexPathsSet:requestedSelection];
    if (_collectionViewFlags.delegateShouldDeselectItemAtIndexPath) {
        [[removed copy] enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
            if (![delegate collectionView:self shouldDeselectItemAtIndexPath:indexPath]) {
                [removed removeIndexPath:indexPath];
            }
        }];
    }

    // Apply the diff to a working copy of the live selection and forbid an
    // empty result when allowsEmptySelection is off.
    UXCollectionViewMutableIndexPathsSet *workingSelection = [_indexPathsForSelectedItems mutableCopy];
    [workingSelection removeIndexPathsSet:removed];
    [workingSelection addIndexPathsSet:added];
    if (workingSelection.count == 0 && !self.allowsEmptySelection) {
        if (requestedSelection.count == 0) {
            return NO;
        }
        NSIndexPath *firstSelectable = [self _firstSelectableItemIndexPath];
        if (!firstSelectable) {
            return NO;
        }
        if ([removed containsIndexPath:firstSelectable]) {
            [removed removeIndexPath:firstSelectable];
        } else {
            [added addIndexPath:firstSelectable];
        }
        [workingSelection addIndexPath:firstSelectable];
        [requestedSelection addIndexPath:firstSelectable];
    }

    if (added.count + removed.count == 0) {
        return NO;
    }

    NSArray<NSIndexPath *> *addedArray = nil;
    NSArray<NSIndexPath *> *removedArray = nil;
    if (notifyDelegate) {
        if (_collectionViewFlags.delegateSelectionWillAddAndRemove || _collectionViewFlags.delegateSelectionDidAddAndRemove) {
            addedArray = added.allIndexPaths;
            removedArray = removed.allIndexPaths;
        }
        if (_collectionViewFlags.delegateSelectionWillAddAndRemove) {
            NSAssert(addedArray && removedArray, @"item arrays have not been populated");
            [delegate collectionView:self indexPathsForSelectedItemsWillAdd:addedArray remove:removedArray animated:animated];
        }
    }

    // Commit, then update only the currently-visible cells' selected state.
    [_indexPathsForSelectedItems removeAllIndexPaths];
    [_indexPathsForSelectedItems addIndexPathsSet:workingSelection];
    NSAssert([requestedSelection isEqual:_indexPathsForSelectedItems], @"selected items synchronicity failure");

    [[self _dictionaryOfIndexPathsAndContentCells] enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UXCollectionViewCell *cell, BOOL *stop) {
        BOOL nowSelected = [added containsIndexPath:indexPath];
        if (nowSelected || [removed containsIndexPath:indexPath]) {
            [(id)cell _setSelected:nowSelected animated:animated];
        }
    }];

    if (notifyDelegate) {
        if (_collectionViewFlags.delegateDidDeselectItemAtIndexPath) {
            [removed enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
                [delegate collectionView:self didDeselectItemAtIndexPath:indexPath];
            }];
        }
        if (_collectionViewFlags.delegateDidSelectItemAtIndexPath) {
            [added enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
                [delegate collectionView:self didSelectItemAtIndexPath:indexPath];
            }];
        }
        if (_collectionViewFlags.delegateSelectionDidAddAndRemove) {
            NSAssert(addedArray && removedArray, @"item arrays have not been populated");
            [delegate collectionView:self indexPathsForSelectedItemsDidAdd:addedArray remove:removedArray animated:animated];
        }
    }

    if (keyItem && position != UXCollectionViewScrollPositionNone) {
        [self scrollToItemAtIndexPath:keyItem atScrollPosition:position animated:animated];
    }
    [self _postSelectionAccessibilityNotification];
    return YES;
}

- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self deselectItemsAtIndexPaths:@[indexPath] animated:animated];
}

- (void)deselectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths animated:(BOOL)animated {
    [self _deselectItemsAtIndexPaths:indexPaths animated:animated notifyDelegate:NO];
}

- (BOOL)_deselectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths animated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate {
    id<UXCollectionViewDelegate> delegate = self.delegate;
    UXCollectionViewMutableIndexPathsSet *toDeselect = [[UXCollectionViewMutableIndexPathsSet alloc] init];
    for (NSIndexPath *indexPath in indexPaths) {
        [toDeselect addIndexPath:indexPath];
    }
    if (_collectionViewFlags.delegateShouldDeselectItemAtIndexPath) {
        for (NSIndexPath *indexPath in indexPaths) {
            if (![delegate collectionView:self shouldDeselectItemAtIndexPath:indexPath]) {
                [toDeselect removeIndexPath:indexPath];
            }
        }
    }
    if (toDeselect.count == 0) {
        return NO;
    }

    // UXKit implements deselection as "select the complement": compute the
    // surviving selection, guard the non-empty invariant, then route through
    // _selectItemsInIndexPathsSet: so the diff/notify path stays single-sourced.
    NSIndexPath *anchorIndexPath = _lastSelectionAnchorIndexPath;
    UXCollectionViewMutableIndexPathsSet *survivingSelection = [_indexPathsForSelectedItems mutableCopy];
    [survivingSelection removeIndexPathsSet:toDeselect];
    if (survivingSelection.count == 0 && !self.allowsEmptySelection) {
        NSIndexPath *fallback = [indexPaths lastObject];
        if (!fallback || ![toDeselect containsIndexPath:fallback]) {
            fallback = [self _firstSelectableItemIndexPath];
            if (!fallback) {
                return NO;
            }
        }
        anchorIndexPath = fallback;
        [survivingSelection addIndexPath:fallback];
        NSAssert(survivingSelection.count > 0, @"unable to define a non-empty selection for %@ after deselecting %@", self, toDeselect);
    }
    if (anchorIndexPath && ![survivingSelection containsIndexPath:anchorIndexPath]) {
        anchorIndexPath = [survivingSelection firstIndexPath];
    }
    if ([self _selectItemsInIndexPathsSet:survivingSelection
                     byExtendingSelection:NO
                                 animated:animated
                         scrollingKeyItem:nil
                               toPosition:UXCollectionViewScrollPositionNone
                           notifyDelegate:notifyDelegate]) {
        _lastSelectionAnchorIndexPath = anchorIndexPath;
        [self _postSelectionAccessibilityNotification];
        return YES;
    }
    return NO;
}

- (void)_deselectAllAnimated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate {
    _lastSelectionAnchorIndexPath = nil;
    [self _selectItemsInIndexPathsSet:nil
                 byExtendingSelection:NO
                             animated:animated
                     scrollingKeyItem:nil
                           toPosition:UXCollectionViewScrollPositionNone
                       notifyDelegate:notifyDelegate];
}

- (BOOL)_toggleSelectionStateOfItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate {
    if (!indexPath) {
        return NO;
    }
    BOOL wasSelected = [_indexPathsForSelectedItems containsIndexPath:indexPath];
    UXCollectionViewIndexPathsSet *single = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPath:indexPath];
    if (wasSelected) {
        if (![self _deselectItemsAtIndexPaths:@[indexPath] animated:animated notifyDelegate:notifyDelegate]) {
            return NO;
        }
        if (![_lastSelectionAnchorIndexPath isEqual:indexPath]) {
            return YES;
        }
        _lastSelectionAnchorIndexPath = [self _keyItemIndexPathForItemIndexPathsSet:_indexPathsForSelectedItems];
    } else {
        if (![self _selectItemsInIndexPathsSet:single
                          byExtendingSelection:YES
                                      animated:animated
                              scrollingKeyItem:indexPath
                                    toPosition:(UXCollectionViewScrollPosition)64
                                notifyDelegate:notifyDelegate]) {
            return NO;
        }
        _lastSelectionAnchorIndexPath = indexPath;
    }
    return YES;
}

- (BOOL)_selectRangeOfItemsFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath byExtendingSelection:(BOOL)extend animated:(BOOL)animated scroll:(BOOL)scroll toPosition:(UXCollectionViewScrollPosition)position notifyDelegate:(BOOL)notifyDelegate candidateLastSelectedItemIndexPath:(NSIndexPath *__autoreleasing  _Nullable *)candidate {
    if (candidate) {
        *candidate = nil;
    }
    NSArray<NSIndexPath *> *range = [_layout indexPathsForItemRangeSelectionFrom:fromIndexPath to:toIndexPath];
    NSIndexPath *keyItem = scroll ? [self _keyItemIndexPathForItemIndexPaths:range] : nil;
    UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPaths:range];
    BOOL changed = [self _selectItemsInIndexPathsSet:set byExtendingSelection:extend animated:animated scrollingKeyItem:keyItem toPosition:position notifyDelegate:notifyDelegate];
    if (candidate && changed) {
        // Report the deepest range item (excluding the anchor) that ended up
        // selected, so the caller can advance its selection anchor.
        NSMutableArray<NSIndexPath *> *remainingRange = [range mutableCopy];
        [remainingRange removeObject:fromIndexPath];
        NSIndexPath *candidateIndexPath = nil;
        while (remainingRange.count > 0) {
            candidateIndexPath = [self _keyItemIndexPathForItemIndexPaths:remainingRange];
            if (!candidateIndexPath) {
                break;
            }
            if ([_indexPathsForSelectedItems containsIndexPath:candidateIndexPath]) {
                break;
            }
            [remainingRange removeObject:candidateIndexPath];
        }
        *candidate = candidateIndexPath;
    }
    return changed;
}

- (void)deselectAllItems:(BOOL)animated {
    [self _deselectAllAnimated:animated notifyDelegate:NO];
}

- (void)selectAllItems:(BOOL)animated {
    [self _selectAllItems:YES notifyDelegate:NO];
}

- (void)_selectAllItems:(BOOL)selectAll notifyDelegate:(BOOL)notifyDelegate {
    [self _reloadDataIfNeeded];
    UXCollectionViewMutableIndexPathsSet *targetSelection = [UXCollectionViewMutableIndexPathsSet indexPathsSet];
    NSInteger sectionCount = [self numberOfSections];
    NSIndexSet *sections = nil;
    if (_collectionViewFlags.delegateSectionsForSelectAllAction) {
        sections = [(id)self.delegate sectionsForSelectAllActionInCollectionView:self];
    }
    if (!sections) {
        sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, (NSUInteger)sectionCount)];
    }
    [sections enumerateIndexesInRange:NSMakeRange(0, (NSUInteger)sectionCount) options:0 usingBlock:^(NSUInteger section, BOOL *stop) {
        NSInteger itemCount = [self numberOfItemsInSection:(NSInteger)section];
        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:(NSInteger)section];
            if ([self selectableItemAtIndexPath:indexPath]) {
                [targetSelection addIndexPath:indexPath];
            }
        }
    }];
    if ([self _selectItemsInIndexPathsSet:targetSelection
                     byExtendingSelection:NO
                                 animated:NO
                         scrollingKeyItem:nil
                               toPosition:UXCollectionViewScrollPositionNone
                           notifyDelegate:notifyDelegate]) {
        _lastSelectionAnchorIndexPath = [self _keyItemIndexPathForItemIndexPathsSet:_indexPathsForSelectedItems];
    }
}

- (IBAction)selectAll:(id)sender {
    [self _selectAllItems:YES notifyDelegate:YES];
}

- (IBAction)deselectAll:(id)sender {
    [self _deselectAllAnimated:NO notifyDelegate:YES];
}

- (NSIndexPath *)_firstSelectableItemIndexPath {
    NSInteger sectionCount = [self numberOfSections];
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self numberOfItemsInSection:section];
        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *candidate = [NSIndexPath indexPathForItem:item inSection:section];
            if ([self selectableItemAtIndexPath:candidate]) {
                return candidate;
            }
        }
    }
    return nil;
}

- (NSIndexPath *)_lastSelectableItemIndexPath {
    NSInteger sectionCount = [self numberOfSections];
    for (NSInteger section = sectionCount - 1; section >= 0; section--) {
        NSInteger itemCount = [self numberOfItemsInSection:section];
        for (NSInteger item = itemCount - 1; item >= 0; item--) {
            NSIndexPath *candidate = [NSIndexPath indexPathForItem:item inSection:section];
            if ([self selectableItemAtIndexPath:candidate]) {
                return candidate;
            }
        }
    }
    return nil;
}

- (NSIndexPath *)_keyItemIndexPathForItemIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    return [indexPaths lastObject];
}

- (NSIndexPath *)_keyItemIndexPathForItemIndexPathsSet:(UXCollectionViewIndexPathsSet *)indexPathsSet {
    return [indexPathsSet lastIndexPath];
}

- (NSIndexPath *)_selectableIndexPathForItemContainingHitView:(NSView *)hitView {
    NSView *currentView = hitView;
    while (currentView) {
        if ([currentView isKindOfClass:[UXCollectionViewCell class]] || [currentView isKindOfClass:[UXCollectionView class]]) {
            break;
        }
        currentView = currentView.superview;
    }
    if (![currentView isKindOfClass:[UXCollectionViewCell class]]) {
        return nil;
    }
    return [self indexPathForCell:(UXCollectionViewCell *)currentView];
}

- (NSIndexPath *)_indexPathOfSelectableItemHitByEvent:(NSEvent *)event {
    NSView *documentSuperview = [_collectionDocumentView superview];
    NSPoint pointInWindow = event.locationInWindow;
    NSPoint pointInSuperview = [documentSuperview convertPoint:pointInWindow fromView:nil];
    NSView *hitView = [_collectionDocumentView hitTest:pointInSuperview];
    if (!hitView) {
        return nil;
    }
    return [self _selectableIndexPathForItemContainingHitView:hitView];
}

#pragma mark - Accessibility selection

- (void)accessibilitySelectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPaths:indexPaths];
    [self _selectItemsInIndexPathsSet:set byExtendingSelection:NO animated:NO scrollingKeyItem:nil toPosition:UXCollectionViewScrollPositionNone notifyDelegate:YES];
}

- (void)accessibilitySelected:(BOOL)selected itemAtIndexPath:(NSIndexPath *)indexPath {
    if (selected) {
        UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPath:indexPath];
        [self _selectItemsInIndexPathsSet:set byExtendingSelection:_allowsMultipleSelection animated:NO scrollingKeyItem:nil toPosition:UXCollectionViewScrollPositionNone notifyDelegate:YES];
    } else {
        [self _deselectItemsAtIndexPaths:@[indexPath] animated:NO notifyDelegate:YES];
    }
}

- (BOOL)accessibilityPerformPressWithItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![self selectableItemAtIndexPath:indexPath]) {
        return NO;
    }
    [self accessibilitySelected:YES itemAtIndexPath:indexPath];
    return YES;
}

#pragma mark - Mouse / Key Selection

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)mouseDown:(NSEvent *)event {
    id<UXCollectionViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(collectionView:mouseDownWithEvent:)]) {
        [delegate collectionView:self mouseDownWithEvent:event];
    }
    NSIndexPath *hitIndexPath = [self _indexPathOfSelectableItemHitByEvent:event];
    if (hitIndexPath) {
        UXCollectionViewCell *cell = [self cellForItemAtIndexPath:hitIndexPath];
        [self _performItemSelectionForMouseEvent:event onCell:cell atIndexPath:hitIndexPath];
        if (event.clickCount == 2 && [delegate respondsToSelector:@selector(collectionView:itemWasDoubleClickedAtIndexPath:withEvent:)]) {
            [delegate collectionView:self itemWasDoubleClickedAtIndexPath:hitIndexPath withEvent:event];
        }
        [super mouseDown:event];
        return;
    }

    NSEventModifierFlags modifiers = event.modifierFlags;
    BOOL shiftHeld = (modifiers & NSEventModifierFlagShift) != 0;

    if (_allowsLassoSelection && _allowsMultipleSelection) {
        [self _beginLassoSelectionAtEvent:event extending:shiftHeld];
        [super mouseDown:event];
        return;
    }
    if (_allowsPaintingSelection && _allowsMultipleSelection) {
        [self _beginPaintingSelectionAtEvent:event];
        [super mouseDown:event];
        return;
    }

    if (_allowsEmptySelection && !shiftHeld) {
        [self _deselectAllAnimated:YES notifyDelegate:YES];
    }
    [super mouseDown:event];
}

- (void)mouseDragged:(NSEvent *)event {
    if (_lassoSelectionLayer) {
        [self _updateLassoSelectionAtEvent:event];
        return;
    }
    if (_isPaintingSelectionRunning) {
        [self _updatePaintingSelectionAtEvent:event];
        return;
    }
    [super mouseDragged:event];
}

- (void)mouseUp:(NSEvent *)event {
    if (_lassoSelectionLayer) {
        [self _endLassoSelectionAtEvent:event];
        return;
    }
    if (_isPaintingSelectionRunning) {
        [self _endPaintingSelectionAtEvent:event];
        return;
    }
    [super mouseUp:event];
}

#pragma mark - Lasso selection

- (NSPoint)_lassoPointForEvent:(NSEvent *)event {
    return [_collectionDocumentView convertPoint:event.locationInWindow fromView:nil];
}

- (void)_beginLassoSelectionAtEvent:(NSEvent *)event extending:(BOOL)extending {
    _lassoSelectionStartPoint = [self _lassoPointForEvent:event];
    _lassoInitiallySelectedItems = extending
        ? [[UXCollectionViewIndexPathsSet alloc] initWithIndexPathsSet:_indexPathsForSelectedItems]
        : [UXCollectionViewIndexPathsSet indexPathsSet];

    if (!extending) {
        [self _deselectAllAnimated:NO notifyDelegate:YES];
    }

    CALayer *layer = [CALayer layer];
    layer.borderColor = [NSColor selectedControlColor].CGColor;
    layer.borderWidth = 1.0;
    layer.backgroundColor = [[NSColor selectedControlColor] colorWithAlphaComponent:0.15].CGColor;
    layer.frame = CGRectMake(_lassoSelectionStartPoint.x, _lassoSelectionStartPoint.y, 0.0, 0.0);
    layer.zPosition = 9999.0;
    _collectionDocumentView.wantsLayer = YES;
    [_collectionDocumentView.layer addSublayer:layer];
    _lassoSelectionLayer = layer;
}

- (void)_updateLassoSelectionAtEvent:(NSEvent *)event {
    NSPoint current = [self _lassoPointForEvent:event];
    CGRect rect = CGRectMake(MIN(_lassoSelectionStartPoint.x, current.x),
                             MIN(_lassoSelectionStartPoint.y, current.y),
                             fabs(current.x - _lassoSelectionStartPoint.x),
                             fabs(current.y - _lassoSelectionStartPoint.y));
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _lassoSelectionLayer.frame = rect;
    [CATransaction commit];

    NSArray<UXCollectionViewLayoutAttributes *> *hits = [_collectionViewData layoutAttributesForElementsInRect:rect];
    UXCollectionViewMutableIndexPathsSet *enclosed = [[UXCollectionViewMutableIndexPathsSet alloc] init];
    for (UXCollectionViewLayoutAttributes *attributes in hits) {
        if (![attributes _isCell]) {
            continue;
        }
        if (![self selectableItemAtIndexPath:attributes.indexPath]) {
            continue;
        }
        [enclosed addIndexPath:attributes.indexPath];
    }

    UXCollectionViewMutableIndexPathsSet *targetSet = [[UXCollectionViewMutableIndexPathsSet alloc] init];
    if (_lassoInvertsSelection) {
        [targetSet addIndexPathsSet:_lassoInitiallySelectedItems];
        [enclosed enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
            if ([targetSet containsIndexPath:indexPath]) {
                [targetSet removeIndexPath:indexPath];
            } else {
                [targetSet addIndexPath:indexPath];
            }
        }];
    } else {
        [targetSet addIndexPathsSet:_lassoInitiallySelectedItems];
        [targetSet addIndexPathsSet:enclosed];
    }

    [self _selectItemsInIndexPathsSet:targetSet
                 byExtendingSelection:NO
                             animated:NO
                     scrollingKeyItem:nil
                           toPosition:UXCollectionViewScrollPositionNone
                       notifyDelegate:YES];
}

- (void)_endLassoSelectionAtEvent:(NSEvent *)event {
    [_lassoSelectionLayer removeFromSuperlayer];
    _lassoSelectionLayer = nil;
    _lassoInitiallySelectedItems = nil;
}

#pragma mark - Painting selection

- (void)_beginPaintingSelectionAtEvent:(NSEvent *)event {
    _isPaintingSelectionRunning = YES;
    NSIndexPath *indexPath = [self _indexPathOfSelectableItemHitByEvent:event];
    if (indexPath) {
        BOOL alreadySelected = [_indexPathsForSelectedItems containsIndexPath:indexPath];
        _paintingSelectionType = !alreadySelected;
        if (_paintingSelectionType) {
            UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPath:indexPath];
            [self _selectItemsInIndexPathsSet:set byExtendingSelection:YES animated:NO scrollingKeyItem:nil toPosition:UXCollectionViewScrollPositionNone notifyDelegate:YES];
        } else {
            [self _deselectItemsAtIndexPaths:@[indexPath] animated:NO notifyDelegate:YES];
        }
    }
}

- (void)_updatePaintingSelectionAtEvent:(NSEvent *)event {
    NSIndexPath *indexPath = [self _indexPathOfSelectableItemHitByEvent:event];
    if (!indexPath) {
        return;
    }
    BOOL alreadySelected = [_indexPathsForSelectedItems containsIndexPath:indexPath];
    if (_paintingSelectionType && !alreadySelected) {
        UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPath:indexPath];
        [self _selectItemsInIndexPathsSet:set byExtendingSelection:YES animated:NO scrollingKeyItem:nil toPosition:UXCollectionViewScrollPositionNone notifyDelegate:YES];
    } else if (!_paintingSelectionType && alreadySelected) {
        [self _deselectItemsAtIndexPaths:@[indexPath] animated:NO notifyDelegate:YES];
    }
}

- (void)_endPaintingSelectionAtEvent:(NSEvent *)event {
    _isPaintingSelectionRunning = NO;
    _paintingSelectionType = NO;
}

- (void)rightMouseDown:(NSEvent *)event {
    id<UXCollectionViewDelegate> delegate = self.delegate;
    NSIndexPath *hitIndexPath = [self _indexPathOfSelectableItemHitByEvent:event];
    self.lastRightClickedIndexPath = hitIndexPath;
    if (hitIndexPath && [delegate respondsToSelector:@selector(collectionView:itemWasRightClickedAtIndexPath:withEvent:)]) {
        [delegate collectionView:self itemWasRightClickedAtIndexPath:hitIndexPath withEvent:event];
    }
    [super rightMouseDown:event];
}

- (void)keyDown:(NSEvent *)event {
    NSString *characters = event.charactersIgnoringModifiers;
    if (characters.length == 0) {
        [super keyDown:event];
        return;
    }
    unichar keyCharacter = [characters characterAtIndex:0];
    NSEventModifierFlags modifiers = event.modifierFlags;
    if ([self _performScrollingForKey:keyCharacter]) {
        return;
    }
    if (![self _performItemSelectionForKey:keyCharacter withModifiers:modifiers]) {
        [super keyDown:event];
    }
}

- (void)_performItemSelectionForMouseEvent:(NSEvent *)event onCell:(UXCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // A fresh mouse selection invalidates any in-progress keyboard range selection.
    _keyboardRangeSelectionFirstSelectedItem = nil;
    _keyboardRangeSelectionLastSelectedItem = nil;
    _keyboardRangeSelectionPreviouslySelectedItems = nil;

    NSEventModifierFlags modifiers = event.modifierFlags;
    BOOL commandPressed = (modifiers & NSEventModifierFlagCommand) != 0;
    BOOL shiftPressed = (modifiers & NSEventModifierFlagShift) != 0;

    // Arm painting selection on an unmodified click when it is enabled.
    if (_allowsPaintingSelection && !commandPressed && !shiftPressed) {
        _isPaintingSelectionRunning = YES;
    }

    if (cell.selected) {
        if (commandPressed || _allowsContinuousSelection) {
            if ([self _deselectItemsAtIndexPaths:@[indexPath] animated:YES notifyDelegate:YES]) {
                [self _postSelectionAccessibilityNotification];
            }
        } else {
            _lastSelectionAnchorIndexPath = indexPath;
        }
        return;
    }

    if (!shiftPressed) {
        BOOL changed;
        if (commandPressed || _allowsContinuousSelection) {
            changed = [self _toggleSelectionStateOfItemAtIndexPath:indexPath animated:YES notifyDelegate:YES];
        } else {
            UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPath:indexPath];
            changed = [self _selectItemsInIndexPathsSet:set
                                   byExtendingSelection:NO
                                               animated:YES
                                       scrollingKeyItem:indexPath
                                             toPosition:UXCollectionViewScrollPositionNone
                                         notifyDelegate:YES];
        }
        if (!changed) {
            return;
        }
        // Anchor on the clicked item, or on the selection's key item if the click
        // did not end up selecting it (single-selection collapse).
        NSIndexPath *anchorIndexPath = indexPath;
        if (![_indexPathsForSelectedItems containsIndexPath:indexPath]) {
            anchorIndexPath = [self _keyItemIndexPathForItemIndexPathsSet:_indexPathsForSelectedItems];
        }
        _lastSelectionAnchorIndexPath = anchorIndexPath;
        [self _postSelectionAccessibilityNotification];
        return;
    }

    // Shift held: range selection from the anchor (or the clicked item if none).
    NSIndexPath *fromIndexPath = _lastSelectionAnchorIndexPath ?: indexPath;
    NSIndexPath *candidateLastSelectedItem = nil;
    BOOL changed = [self _selectRangeOfItemsFromIndexPath:fromIndexPath
                                              toIndexPath:indexPath
                                     byExtendingSelection:YES
                                                 animated:YES
                                                   scroll:YES
                                               toPosition:UXCollectionViewScrollPositionNone
                                           notifyDelegate:YES
                              candidateLastSelectedItemIndexPath:&candidateLastSelectedItem];
    NSIndexPath *resolvedCandidate = _lastSelectionAnchorIndexPath ? candidateLastSelectedItem : indexPath;
    if (changed && resolvedCandidate) {
        _lastSelectionAnchorIndexPath = resolvedCandidate;
        [self _postSelectionAccessibilityNotification];
    }
}

- (BOOL)_performItemSelectionForKey:(uint16_t)key withModifiers:(NSUInteger)modifiers {
    if ((modifiers & NSEventModifierFlagCommand) != 0) {
        return NO;
    }
    BOOL shiftHeld = (modifiers & NSEventModifierFlagShift) != 0;
    if (shiftHeld) {
        if (!_keyboardRangeSelectionPreviouslySelectedItems) {
            _keyboardRangeSelectionPreviouslySelectedItems = [_indexPathsForSelectedItems copy];
        }
        _keyboardRangeSelectionFirstSelectedItem = _lastSelectionAnchorIndexPath;
        _keyboardRangeSelectionLastSelectedItem = _lastSelectionAnchorIndexPath;
    }

    NSIndexPath *targetIndexPath = nil;
    if (_keyboardRangeSelectionFirstSelectedItem) {
        // Range already underway: navigate from the cursor by layout geometry,
        // skipping non-selectable items until one is found or we run off an edge.
        if ((key & 0xFFFC) != 0xF700) {
            return NO;
        }
        BOOL rightToLeft = self.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft;
        NSIndexPath *cursor = _keyboardRangeSelectionLastSelectedItem;
        while (YES) {
            NSIndexPath *next = nil;
            switch (key) {
                case NSUpArrowFunctionKey:
                    next = [_layout indexPathOfItemAbove:cursor];
                    break;
                case NSLeftArrowFunctionKey:
                    next = rightToLeft ? [_layout indexPathOfItemAfter:cursor] : [_layout indexPathOfItemBefore:cursor];
                    break;
                case NSRightArrowFunctionKey:
                    next = rightToLeft ? [_layout indexPathOfItemBefore:cursor] : [_layout indexPathOfItemAfter:cursor];
                    break;
                default:
                    next = [_layout indexPathOfItemBelow:cursor];
                    break;
            }
            cursor = next;
            if (!next) {
                return YES;
            }
            if ([self selectableItemAtIndexPath:next]) {
                targetIndexPath = next;
                break;
            }
        }
    } else {
        // No range underway: an arrow key enters the list from the matching edge.
        if (key == NSUpArrowFunctionKey || key == NSLeftArrowFunctionKey) {
            targetIndexPath = [_layout lastSelectableItemIndexPath];
        } else if (key == NSDownArrowFunctionKey || key == NSRightArrowFunctionKey) {
            targetIndexPath = [_layout firstSelectableItemIndexPath];
        } else {
            return NO;
        }
        _keyboardRangeSelectionFirstSelectedItem = targetIndexPath;
        _keyboardRangeSelectionLastSelectedItem = targetIndexPath;
        if (!targetIndexPath) {
            return YES;
        }
    }

    if (shiftHeld) {
        NSArray<NSIndexPath *> *range = [_layout indexPathsForItemRangeSelectionFrom:_keyboardRangeSelectionFirstSelectedItem
                                                                                  to:targetIndexPath];
        UXCollectionViewMutableIndexPathsSet *combined = [_keyboardRangeSelectionPreviouslySelectedItems mutableCopy];
        [combined addIndexPaths:range];
        if (![self _selectItemsInIndexPathsSet:combined
                          byExtendingSelection:NO
                                      animated:NO
                              scrollingKeyItem:targetIndexPath
                                    toPosition:(UXCollectionViewScrollPosition)64
                                notifyDelegate:YES]) {
            return YES;
        }
        _keyboardRangeSelectionLastSelectedItem = targetIndexPath;
    } else {
        UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPath:targetIndexPath];
        if (![self _selectItemsInIndexPathsSet:set
                          byExtendingSelection:NO
                                      animated:NO
                              scrollingKeyItem:targetIndexPath
                                    toPosition:(UXCollectionViewScrollPosition)64
                                notifyDelegate:YES]) {
            return YES;
        }
        _keyboardRangeSelectionPreviouslySelectedItems = nil;
        _keyboardRangeSelectionFirstSelectedItem = nil;
        _keyboardRangeSelectionLastSelectedItem = nil;
        _lastSelectionAnchorIndexPath = targetIndexPath;
    }
    [self _postSelectionAccessibilityNotification];
    return YES;
}

@end
