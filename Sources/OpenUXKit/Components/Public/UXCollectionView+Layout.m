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
        if (completion) {
            completion(YES);
        }
        return;
    }

    // Invalidate the incoming layout before it goes live so its first prepare
    // pass rebuilds from the data source.
    UXCollectionViewLayoutInvalidationContext *invalidationContext = [[[[layout class] invalidationContextClass] alloc] init];
    [invalidationContext _setInvalidateEverything:YES];
    [invalidationContext _setInvalidateDataSourceCounts:YES];
    [layout _invalidateLayoutUsingContext:invalidationContext];

    // The animated cross-layout transition (UXKit's _prepareForTransitionToLayout:
    // / _animateView: anchor-tracking path) is not yet ported; until then every
    // request takes the non-animated swap, which UXKit itself uses whenever the
    // view is offscreen or has not completed its first layout.
    [layout _setCollectionView:self];
    [(id)_layout _setCollectionView:nil];
    _layout = layout;
    _collectionViewData = [[UXCollectionViewData alloc] initWithCollectionView:self layout:layout];
    [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:YES];
    if (completion) {
        completion(YES);
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
