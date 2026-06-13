#import "UXCollectionView+Private.h"

@implementation UXCollectionView (Layout)

#pragma mark - Layout

- (UXCollectionViewLayout *)collectionViewLayout {
    return _layout;
}

- (void)setCollectionViewLayout:(UXCollectionViewLayout *)layout {
    NSAssert(layout != nil, @"layout cannot be nil in setCollectionViewLayout:");
    [self setCollectionViewLayout:layout animated:NO completion:nil];
}

- (void)setCollectionViewLayout:(UXCollectionViewLayout *)layout animated:(BOOL)animated {
    [self setCollectionViewLayout:layout animated:animated completion:nil];
}

- (void)setCollectionViewLayout:(UXCollectionViewLayout *)layout animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    [self _setCollectionViewLayout:layout animated:animated isInteractive:NO completion:completion];
}

- (void)_setCollectionViewLayout:(UXCollectionViewLayout *)layout animated:(BOOL)animated isInteractive:(BOOL)isInteractive completion:(void (^)(BOOL))completion {
    if (_layout == layout) {
        // UXKit returns without invoking the completion handler when the layout
        // is unchanged, so match that rather than calling completion(YES).
        return;
    }

    // Capture the viewport before anything mutates the geometry; the animated
    // branch uses it to pick an anchor item and compute a target content offset.
    CGRect bounds = self.contentView.bounds;

    // Invalidate the incoming layout before it goes live so its first prepare
    // pass rebuilds from the data source.
    UXCollectionViewLayoutInvalidationContext *invalidationContext = [[[[layout class] invalidationContextClass] alloc] init];
    [invalidationContext _setInvalidateEverything:YES];
    [invalidationContext _setInvalidateDataSourceCounts:YES];
    [layout _invalidateLayoutUsingContext:invalidationContext];

    // Fast path: with nothing on screen there is nothing to animate, so swap the
    // layout synchronously. UXKit uses this whenever the view is offscreen or has
    // not completed its first layout.
    if (![self _visible] || !_collectionViewFlags.doneFirstLayout) {
        [layout _setCollectionView:self];
        [(id)_layout _setCollectionView:nil];
        _layout = layout;
        _collectionViewData = [[UXCollectionViewData alloc] initWithCollectionView:self layout:layout];
        [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:YES];
        if (completion) {
            completion(YES);
        }
        return;
    }

    [self _performLayoutTransitionToLayout:layout animated:animated fromBounds:bounds completion:completion];
}

// Animated (and synchronous-but-visible) cross-layout transition, aligned with
// -[UXCollectionView _setCollectionViewLayout:animated:isInteractive:completion:]
// (UXKit 26.4). The new data is built on the side and only swapped in once every
// per-view animation has resolved; an anchor item keeps the viewport stable
// across the geometry change.
- (void)_performLayoutTransitionToLayout:(UXCollectionViewLayout *)newLayout animated:(BOOL)animated fromBounds:(CGRect)bounds completion:(void (^)(BOOL))completion {
    UXCollectionViewLayout *oldLayout = _layout;

    UXCollectionViewData *newData = [[UXCollectionViewData alloc] initWithCollectionView:self layout:newLayout];
    // OpenUXKit's flow-layout geometry reads its dimension from the collection
    // view's bounds (-_fetchItemsInfo bails when there is no collection view), so
    // the incoming layout must be wired up before any geometry is computed below.
    // The owning collection view is rebound to it again, and the old layout
    // released, once the transition finalizes.
    [newLayout _setCollectionView:self];
    [newData _prepareToLoadData];

    [oldLayout _prepareForTransitionToLayout:newLayout];
    [newLayout _prepareForTransitionFromLayout:oldLayout];
    _collectionViewFlags.updatingLayout = YES;

    // Item keys for the current selection.
    NSArray<NSIndexPath *> *selectedIndexPaths = [self indexPathsForSelectedItems];
    NSMutableSet *selectedItemKeys = [NSMutableSet setWithCapacity:selectedIndexPaths.count];
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        [selectedItemKeys addObject:[_UXCollectionViewItemKey collectionItemKeyForCellWithIndexPath:indexPath]];
    }

    // Item keys for views whose current frame intersects the viewport.
    NSMutableSet *onscreenItemKeys = [NSMutableSet set];
    [_allVisibleViewsDict enumerateKeysAndObjectsUsingBlock:^(_UXCollectionViewItemKey *key, UXCollectionReusableView *view, BOOL *stop) {
        if (CGRectIntersectsRect(view.frame, bounds)) {
            [onscreenItemKeys addObject:key];
        }
    }];

    // Anchor candidates: the onscreen keys, narrowed to the selection when the
    // selection has anything onscreen.
    NSSet *onscreenSnapshot = [NSSet setWithSet:onscreenItemKeys];
    NSMutableSet *anchorCandidates = [NSMutableSet setWithSet:onscreenItemKeys];
    if ([onscreenSnapshot intersectsSet:selectedItemKeys]) {
        [anchorCandidates intersectSet:selectedItemKeys];
    }

    CGFloat midX = CGRectGetMidX(bounds);
    CGFloat midY = CGRectGetMidY(bounds);
    NSUInteger anchorCandidateCount = anchorCandidates.count;

    _UXCollectionViewItemKey *anchorKey = nil;
    if (anchorCandidateCount == 1) {
        anchorKey = anchorCandidates.anyObject;
    } else {
        CGFloat nearestDistance = (CGFloat)FLT_MAX;
        for (_UXCollectionViewItemKey *key in anchorCandidates) {
            if (key.type == UXCollectionViewItemTypeCell) {
                CGRect frame = [_collectionViewData layoutAttributesForItemAtIndexPath:key.indexPath].frame;
                CGFloat centerX = CGRectGetMinX(frame) + frame.size.width * 0.5;
                CGFloat centerY = CGRectGetMinY(frame) + frame.size.height * 0.5;
                CGFloat distance = (CGFloat)sqrtf((float)((centerY - midY) * (centerY - midY) + (centerX - midX) * (centerX - midX)));
                if (nearestDistance > distance) {
                    nearestDistance = distance;
                    anchorKey = key;
                }
            }
        }
    }

    // Offset that keeps the anchor item centered under the new layout, or the
    // current scroll position when there is no anchor.
    CGFloat proposedX;
    CGFloat proposedY;
    if (anchorKey) {
        CGRect frame = [newData layoutAttributesForItemAtIndexPath:anchorKey.indexPath].frame;
        proposedX = CGRectGetMinX(frame) + frame.size.width * 0.5 - bounds.size.width * 0.5;
        proposedY = CGRectGetMinY(frame) + frame.size.height * 0.5 - bounds.size.height * 0.5;
    } else {
        proposedX = bounds.origin.x;
        proposedY = bounds.origin.y;
    }

    // Clamp the proposed offset to the new content size.
    CGSize newContentSize = [newLayout collectionViewContentSize];
    CGRect contentRect = CGRectMake(0.0, 0.0, newContentSize.width, newContentSize.height);
    CGRect proposedRect = CGRectMake(proposedX, proposedY, bounds.size.width, bounds.size.height);
    CGFloat clampedX = 0.0;
    if (CGRectContainsRect(contentRect, proposedRect)) {
        clampedX = proposedX;
    } else {
        CGRect intersection = CGRectIntersection(contentRect, proposedRect);
        if (newContentSize.width > bounds.size.width) {
            if (intersection.size.width >= bounds.size.width) {
                clampedX = proposedX;
            } else {
                CGFloat missingWidth = bounds.size.width - intersection.size.width;
                clampedX = proposedX + (intersection.origin.x <= proposedX ? -missingWidth : missingWidth);
            }
        }
        if (newContentSize.height > bounds.size.height) {
            if (intersection.size.height < bounds.size.height) {
                CGFloat missingHeight = bounds.size.height - intersection.size.height;
                proposedY += (intersection.origin.y <= proposedY ? -missingHeight : missingHeight);
            }
        } else {
            proposedY = 0.0;
        }
    }
    if (anchorCandidateCount == 0) {
        clampedX = 0.0;
        proposedY = 0.0;
    }

    // Run the proposed offset through the layout and delegate content-offset hooks.
    CGPoint targetContentOffset = [newLayout transitionContentOffsetForProposedContentOffset:CGPointMake(clampedX, proposedY) keyItemIndexPath:anchorKey.indexPath];
    targetContentOffset = [newLayout targetContentOffsetForProposedContentOffset:targetContentOffset];
    if (_collectionViewFlags.delegateTargetContentOffsetForProposedContentOffset) {
        targetContentOffset = [(id)self.delegate _collectionView:self targetContentOffsetForProposedContentOffset:targetContentOffset];
    }

    // Tell the currently-visible views a transition is starting.
    [_allVisibleViewsDict enumerateKeysAndObjectsUsingBlock:^(_UXCollectionViewItemKey *key, UXCollectionReusableView *view, BOOL *stop) {
        [view willTransitionFromLayout:oldLayout toLayout:newLayout];
    }];

    // Finalize: swap layout/data once every in-flight per-view animation resolves.
    void (^finalizeTransition)(void) = ^{
        self->_layoutTransitionAnimationCount -= 1;
        if (self->_layoutTransitionAnimationCount != 0) {
            return;
        }
        [self->_allVisibleViewsDict enumerateKeysAndObjectsUsingBlock:^(_UXCollectionViewItemKey *key, UXCollectionReusableView *view, BOOL *stop) {
            [view didTransitionFromLayout:oldLayout toLayout:newLayout];
        }];
        [newLayout _setCollectionView:self];
        [oldLayout _setCollectionView:nil];
        self->_layout = newLayout;
        self->_collectionViewData = newData;
        [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:YES];
        [self resetScrollingOverdraw];
        [oldLayout _finalizeLayoutTransition];
        [newLayout _finalizeLayoutTransition];
        if (completion) {
            // UXKit invokes the completion handler with NO at the end of an
            // animated layout transition.
            completion(NO);
        }
    };

    void (^animationBody)(BOOL) = ^(BOOL runAnimated) {
        [self setContentSize:[newLayout collectionViewContentSize]];
        [self.contentView setBoundsOrigin:CGPointMake(targetContentOffset.x, targetContentOffset.y)];

        NSArray<UXCollectionViewLayoutAttributes *> *newAttributes =
            [newLayout layoutAttributesForElementsInRect:CGRectMake(targetContentOffset.x, targetContentOffset.y, bounds.size.width, bounds.size.height)];

        NSMutableDictionary *disappearingViews = [self->_allVisibleViewsDict mutableCopy];
        NSMutableArray<UXCollectionViewLayoutAttributes *> *appearingAttributes = [NSMutableArray array];
        NSMutableArray<UXCollectionReusableView *> *persistingViews = [NSMutableArray array];

        for (UXCollectionViewLayoutAttributes *attributes in newAttributes) {
            _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:attributes];
            UXCollectionReusableView *existing = [self->_allVisibleViewsDict objectForKey:key];
            if (existing) {
                [persistingViews addObject:existing];
                [disappearingViews removeObjectForKey:key];
            } else {
                [appearingAttributes addObject:attributes];
            }
        }

        // Views the new layout no longer keeps onscreen.
        [disappearingViews enumerateKeysAndObjectsUsingBlock:^(_UXCollectionViewItemKey *key, UXCollectionReusableView *view, BOOL *stop) {
            [self->_allVisibleViewsDict removeObjectForKey:key];
            UXCollectionViewItemType type = key.type;
            void (^reuseView)(void) = ^{
                if (type == UXCollectionViewItemTypeSupplementaryView) {
                    [self _reuseSupplementaryView:view];
                } else if (type == UXCollectionViewItemTypeCell) {
                    [self _reuseCell:(UXCollectionViewCell *)view];
                }
            };
            if (!runAnimated || ![onscreenItemKeys containsObject:key]) {
                [self performWithoutAnimation:reuseView];
                return;
            }
            UXCollectionViewLayoutAttributes *finalAttributes = nil;
            if (type == UXCollectionViewItemTypeSupplementaryView) {
                finalAttributes = [newLayout finalLayoutAttributesForDisappearingSupplementaryElementOfKind:key.identifier atIndexPath:key.indexPath];
            } else if (type == UXCollectionViewItemTypeCell) {
                finalAttributes = [newLayout finalLayoutAttributesForDisappearingItemAtIndexPath:key.indexPath];
            }
            if (!finalAttributes) {
                finalAttributes = [[view _layoutAttributes] copy];
                finalAttributes.alpha = 0.0;
            }
            self->_layoutTransitionAnimationCount += 1;
            [newLayout _animateView:view withAction:1 fromLayoutAttributes:[view _layoutAttributes] toLayoutAttributes:finalAttributes fromLayout:oldLayout withCompletionHandler:^(BOOL finished) {
                [view _setLayoutAttributes:finalAttributes];
                reuseView();
                finalizeTransition();
            }];
        }];

        // Views the new layout introduces onscreen.
        for (UXCollectionViewLayoutAttributes *attributes in appearingAttributes) {
            _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:attributes];
            __block UXCollectionReusableView *createdView = nil;
            if (runAnimated) {
                UXCollectionViewLayoutAttributes *initialAttributes = nil;
                if (attributes._isCell) {
                    initialAttributes = [newLayout initialLayoutAttributesForAppearingItemAtIndexPath:key.indexPath];
                } else if (!attributes._isDecorationView) {
                    initialAttributes = [newLayout initialLayoutAttributesForAppearingSupplementaryElementOfKind:key.identifier atIndexPath:key.indexPath];
                }
                if (!initialAttributes) {
                    initialAttributes = [attributes copy];
                    initialAttributes.alpha = 0.0;
                }
                if (!initialAttributes.isHidden || !attributes.isHidden) {
                    if (attributes._isCell) {
                        createdView = [self _createPreparedCellForItemAtIndexPath:key.indexPath withLayoutAttributes:initialAttributes applyAttributes:YES];
                    } else {
                        createdView = [self _createPreparedSupplementaryViewForElementOfKind:key.identifier atIndexPath:key.indexPath withLayoutAttributes:initialAttributes applyAttributes:YES];
                    }
                    self->_layoutTransitionAnimationCount += 1;
                    [newLayout _animateView:createdView withAction:0 fromLayoutAttributes:initialAttributes toLayoutAttributes:attributes fromLayout:oldLayout withCompletionHandler:^(BOOL finished) {
                        [createdView _setLayoutAttributes:attributes];
                        finalizeTransition();
                    }];
                }
            } else if (!attributes.isHidden) {
                [self performWithoutAnimation:^{
                    if (attributes._isCell) {
                        createdView = [self _createPreparedCellForItemAtIndexPath:key.indexPath withLayoutAttributes:nil applyAttributes:YES];
                    } else {
                        createdView = [self _createPreparedSupplementaryViewForElementOfKind:key.identifier atIndexPath:key.indexPath withLayoutAttributes:nil applyAttributes:NO];
                    }
                }];
            }
            if (createdView) {
                [self->_allVisibleViewsDict setObject:createdView forKey:key];
            }
        }

        // Views the new layout keeps onscreen.
        for (UXCollectionReusableView *view in persistingViews) {
            _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:[view _layoutAttributes]];
            UXCollectionViewLayoutAttributes *targetAttributes = nil;
            if (key.type == UXCollectionViewItemTypeCell) {
                targetAttributes = [newLayout layoutAttributesForItemAtIndexPath:key.indexPath];
            } else if (key.type == UXCollectionViewItemTypeSupplementaryView) {
                targetAttributes = [newLayout layoutAttributesForSupplementaryViewOfKind:key.identifier atIndexPath:key.indexPath];
            }
            if (!targetAttributes) {
                targetAttributes = [[view _layoutAttributes] copy];
            }
            if (targetAttributes.zIndex != [view _layoutAttributes].zIndex) {
                [self performWithoutAnimation:^{
                    [self _addControlled:YES subview:view atZIndex:targetAttributes.zIndex];
                }];
            }
            if (runAnimated) {
                self->_layoutTransitionAnimationCount += 1;
                [newLayout _animateView:view withAction:3 fromLayoutAttributes:[view _layoutAttributes] toLayoutAttributes:targetAttributes fromLayout:oldLayout withCompletionHandler:^(BOOL finished) {
                    [view _setLayoutAttributes:targetAttributes];
                    finalizeTransition();
                }];
            } else if (targetAttributes.isHidden) {
                [self performWithoutAnimation:^{
                    [self->_allVisibleViewsDict removeObjectForKey:key];
                    if (targetAttributes._isCell) {
                        [self _reuseCell:(UXCollectionViewCell *)view];
                    } else {
                        [self _reuseSupplementaryView:view];
                    }
                }];
            } else {
                [self performWithoutAnimation:^{
                    [view _setLayoutAttributes:targetAttributes];
                }];
            }
        }
    };

    _layoutTransitionAnimationCount += 1;
    if (animated) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.allowsImplicitAnimation = YES;
            context.duration = 0.25;
            context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            if (([NSEvent modifierFlags] & NSEventModifierFlagShift) != 0) {
                context.duration *= 10.0;
            }
            animationBody(YES);
        } completionHandler:^{
            finalizeTransition();
            self->_collectionViewFlags.updatingLayout = NO;
        }];
    } else {
        animationBody(NO);
        finalizeTransition();
        _collectionViewFlags.updatingLayout = NO;
    }
}

- (void)updateLayout {
    @autoreleasepool {
        [self _updateVisibleCellsNow:YES];
    }
}

- (void)_invalidateLayoutWithContext:(UXCollectionViewLayoutInvalidationContext *)context {
    _minReusedViewSize = CGSizeMake(1024.0, 1024.0);
    if ([NSAnimationContext respondsToSelector:@selector(_hasActiveGrouping)]) {
        _collectionViewFlags.fadeCellsForBoundsChange = [NSAnimationContext _hasActiveGrouping];
    }
    NSDictionary *invalidatedSupplementaryViews = [context _invalidatedSupplementaryViews];
    if (invalidatedSupplementaryViews && !context.invalidateContentSize) {
        [_collectionViewData invalidateSupplementaryViews:invalidatedSupplementaryViews];
    } else {
        [_collectionViewData invalidate:!context.invalidateEverything];
    }
    _collectionViewFlags.layoutInvalidatedSinceLastCellUpdate = YES;
    [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:YES];
}

- (void)_invalidateLayoutIfNecessary {
    if ([_collectionViewData layoutIsPrepared]) {
        UXCollectionViewLayoutInvalidationContext *context = [[[[_layout class] invalidationContextClass] alloc] init];
        [context _setInvalidateDataSourceCounts:YES];
        [context _setInvalidateEverything:YES];
        [_layout _invalidateLayoutUsingContext:context];
    }
}

- (void)_setNeedsVisibleCellsUpdate:(BOOL)needsUpdate withLayoutAttributes:(BOOL)withAttributes {
    if (needsUpdate) {
        _collectionViewFlags.scheduledUpdateVisibleCells = YES;
    }
    if (withAttributes) {
        _collectionViewFlags.scheduledUpdateVisibleCellLayoutAttributes = YES;
    }
    if (_collectionViewFlags.scheduledUpdateVisibleCells || _collectionViewFlags.scheduledUpdateVisibleCellLayoutAttributes) {
        [self setNeedsLayout];
    }
}

#pragma mark - Layout

- (void)layoutSubviews {
    if (_collectionViewFlags.updatingLayout || _collectionViewFlags.skipLayoutDuringSnapshotting) {
        return;
    }
    [self _reloadDataIfNeeded];
    [_collectionViewData validateLayoutInRect:[self _visibleBounds]];
    if (_collectionViewFlags.scheduledUpdateVisibleCells && _reloadingSuspendedCount == 0) {
        @autoreleasepool {
            [self _updateVisibleCellsNow:YES];
        }
    }
    _collectionViewFlags.doneFirstLayout = YES;
    _doneFirstLayout = YES;
}

- (void)setNeedsLayout {
    if (self.layoutSubviewsOnSetNeedsLayout) {
        [self layoutSubviews];
    } else {
        [self setNeedsLayout:YES];
    }
}

- (void)layout {
    [super layout];
    // AppKit drives -layout; UXKit routes the work through -layoutSubviews so
    // the scheduled-update flags decide whether visible cells refresh.
    [self layoutSubviews];
}

@end
