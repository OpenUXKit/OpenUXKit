#import "UXCollectionView+Private.h"

@implementation UXCollectionView (Scrolling)

#pragma mark - Scrolling

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UXCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated {
    [self scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated userInteractivelyScrolling:NO];
}

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UXCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated userInteractivelyScrolling:(BOOL)userInteractivelyScrolling {
    UXCollectionViewLayoutAttributes *attributes = [_collectionViewData layoutAttributesForItemAtIndexPath:indexPath];
    if (!attributes) {
        return;
    }
    NSEdgeInsets insets = [_layout insetsForScrollingItemAtIndexPath:indexPath toScrollPosition:scrollPosition];
    [self _scrollRect:attributes.frame toScrollPosition:scrollPosition withInsets:insets animated:animated userInteractivelyScrolling:userInteractivelyScrolling];
}

- (void)scrollRect:(CGRect)rect toScrollPosition:(UXCollectionViewScrollPosition)scrollPosition withInsets:(NSEdgeInsets)insets animated:(BOOL)animated {
    [self _scrollRect:rect toScrollPosition:scrollPosition withInsets:insets animated:animated userInteractivelyScrolling:NO];
}

- (void)_scrollRect:(CGRect)rect toScrollPosition:(UXCollectionViewScrollPosition)scrollPosition withInsets:(NSEdgeInsets)insets animated:(BOOL)animated userInteractivelyScrolling:(BOOL)userInteractivelyScrolling {
    NSClipView *clipView = self.contentView;
    NSRect destination = clipView.bounds;
    destination.origin.x += insets.left;
    destination.origin.y += insets.top;
    destination.size.width -= (insets.left + insets.right);
    destination.size.height -= (insets.top + insets.bottom);

    CGPoint amount = [self _scrollAmountForMovingRect:rect toScrollPosition:scrollPosition inDestinationRect:destination];
    NSPoint target = NSMakePoint(clipView.bounds.origin.x + amount.x, clipView.bounds.origin.y + amount.y);
    if (animated) {
        [clipView.animator setBoundsOrigin:target];
    } else {
        [clipView setBoundsOrigin:target];
    }
    [self reflectScrolledClipView:clipView];
}

- (CGPoint)_scrollAmountForMovingRect:(CGRect)movingRect toScrollPosition:(UXCollectionViewScrollPosition)position inDestinationRect:(CGRect)destinationRect {
    CGFloat dx = 0.0;
    CGFloat dy = 0.0;

    if (position & UXCollectionViewScrollPositionCenteredVertically) {
        dy = CGRectGetMidY(movingRect) - CGRectGetMidY(destinationRect);
    } else if (position & UXCollectionViewScrollPositionTop) {
        dy = CGRectGetMinY(movingRect) - CGRectGetMinY(destinationRect);
    } else if (position & UXCollectionViewScrollPositionBottom) {
        dy = CGRectGetMaxY(movingRect) - CGRectGetMaxY(destinationRect);
    }

    if (position & UXCollectionViewScrollPositionCenteredHorizontally) {
        dx = CGRectGetMidX(movingRect) - CGRectGetMidX(destinationRect);
    } else if (position & UXCollectionViewScrollPositionLeft) {
        dx = CGRectGetMinX(movingRect) - CGRectGetMinX(destinationRect);
    } else if (position & UXCollectionViewScrollPositionRight) {
        dx = CGRectGetMaxX(movingRect) - CGRectGetMaxX(destinationRect);
    }

    return CGPointMake(dx, dy);
}

- (void)_scrollToEnd:(BOOL)end {
    NSIndexPath *target = end ? [self _lastSelectableItemIndexPath] : [self _firstSelectableItemIndexPath];
    if (target) {
        [self scrollToItemAtIndexPath:target
                     atScrollPosition:end ? UXCollectionViewScrollPositionBottom : UXCollectionViewScrollPositionTop
                             animated:NO];
    }
}

- (void)_scrollPage:(BOOL)pageDown {
    NSClipView *clipView = self.contentView;
    CGRect bounds = clipView.bounds;
    CGFloat delta = pageDown ? bounds.size.height : -bounds.size.height;
    NSPoint target = NSMakePoint(bounds.origin.x, bounds.origin.y + delta);
    [clipView setBoundsOrigin:target];
    [self reflectScrolledClipView:clipView];
}

- (BOOL)_performScrollingForKey:(uint16_t)key {
    switch (key) {
        case NSPageUpFunctionKey:
            [self _scrollPage:NO];
            return YES;
        case NSPageDownFunctionKey:
            [self _scrollPage:YES];
            return YES;
        case NSHomeFunctionKey:
            [self _scrollToEnd:NO];
            return YES;
        case NSEndFunctionKey:
            [self _scrollToEnd:YES];
            return YES;
    }
    return NO;
}

- (void)_submitScrollingRequest:(void (^)(void))request {
    if (request) {
        request();
    }
}

- (void)resetScrollingOverdraw {
    _lastPreparedOverdrawContentRect = CGRectNull;
}

#pragma mark - Scrolling lifecycle

- (void)scrollViewWillStartLiveScrollNotification:(NSNotification *)notification {
    _liveScrolling = YES;
    [self _willStartScrolling:notification];
}

- (void)scrollViewDidEndLiveScrollNotification:(NSNotification *)notification {
    _liveScrolling = NO;
    [self _didEndScrolling:notification];
}

- (void)_willStartScrolling:(id)sender {
    // The pending _didEndScrolling: dispatched by clipViewBoundsDidChange: is
    // cancelled here so a fresh scroll restarts the idle timer cleanly.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_didEndScrolling:) object:self];
    if (_scrolling) {
        return;
    }
    _decelerating = NO;
    _lastScrollingDistance = CGPointZero;
    _lastScrollingTime = 0.0;
    if (_collectionViewFlags.delegateWillBeginScrolling) {
        [self.delegate collectionViewWillBeginScrolling:self];
    }
    _scrolling = YES;
}

- (void)scrollWheel:(NSEvent *)event {
    _involvesScrollWheel = YES;
    [super scrollWheel:event];
}

- (void)_didEndScrolling:(id)sender {
    if (!_scrolling) {
        return;
    }
    _scrolling = NO;
    id<UXCollectionViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(collectionViewDidEndScrolling:)]) {
        [delegate collectionViewDidEndScrolling:self];
    }
}

- (void)_didEndScrollingAnimation {
    id<UXCollectionViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(collectionViewDidEndScrollingAnimation:)]) {
        [delegate collectionViewDidEndScrollingAnimation:self];
    }
}

- (void)willStartScrollingFromExternalControl {
    _scrollingFromExternalControl = YES;
    [self _willStartScrolling:nil];
}

- (void)willEndScrollingFromExternalControl {
    // No-op: matches Apple's symbol signature; clients hook in scrolling notification flow.
}

- (void)didEndScrollingFromExternalControl {
    _scrollingFromExternalControl = NO;
    [self _didEndScrolling:nil];
}

- (void)clipViewBoundsDidChange:(NSNotification *)notification {
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    CGRect newBounds;
    if (_currentUpdate) {
        newBounds = [_currentUpdate _newVisibleBounds];
    } else {
        newBounds = self.contentView.bounds;
    }
    if (CGPointEqualToPoint(newBounds.origin, _lastContentOffset)) {
        return;
    }

    if (!_scrolling && !_liveScrolling && _involvesScrollWheel && _suspendClipViewBoundsDidChange == 0) {
        [self _willStartScrolling:self];
    }

    id<UXCollectionViewDelegate> delegate = self.delegate;
    CGPoint scrollingDistance = CGPointMake(newBounds.origin.x - _lastContentOffset.x,
                                            newBounds.origin.y - _lastContentOffset.y);
    if (!CGPointEqualToPoint(_lastScrollingDistance, CGPointZero) && _lastScrollingTime != 0.0) {
        double distance = sqrt(scrollingDistance.x * scrollingDistance.x + scrollingDistance.y * scrollingDistance.y);
        _scrollingVelocity = (float)(distance * 0.001 / (currentTime - _lastScrollingTime));
    }

    if (_scrolling && _canDetectDeceleration && _involvesScrollWheel) {
        if (!_decelerating) {
            _decelerating = YES;
            if (_collectionViewFlags.delegateWillBeginDeceleratingTargetContentOffset && _suspendClipViewBoundsDidChange == 0) {
                [delegate collectionViewWillBeginDecelerating:self targetContentOffset:newBounds.origin];
            }
        }
    } else if (!_scrollingFromExternalControl && _decelerating) {
        _decelerating = NO;
        if (_collectionViewFlags.delegateDidEndDecelerating && _suspendClipViewBoundsDidChange == 0) {
            [delegate collectionViewDidEndDecelerating:self];
        }
    }

    _lastScrollingDistance = scrollingDistance;
    _lastContentOffset = newBounds.origin;
    _lastScrollingTime = currentTime;

    if ([_layout shouldUpdateVisibleCellLayoutAttributes]) {
        _collectionViewFlags.scheduledUpdateVisibleCellLayoutAttributes = YES;
    }
    if ([_layout shouldInvalidateLayoutForBoundsChange:newBounds]) {
        [_layout _invalidateLayoutUsingContext:[_layout invalidationContextForBoundsChange:newBounds]];
    } else {
        [self updateLayout];
    }

    if (_collectionViewFlags.delegateDidScroll && _suspendClipViewBoundsDidChange == 0) {
        [delegate collectionViewDidScroll:self];
    }

    if (_scrolling && !_liveScrolling && _involvesScrollWheel) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_didEndScrolling:) object:self];
        [self performSelector:@selector(_didEndScrolling:)
                   withObject:self
                   afterDelay:0.25
                      inModes:@[(__bridge NSRunLoopMode)kCFRunLoopCommonModes, NSModalPanelRunLoopMode]];
    }
}

- (void)reflectScrolledClipView:(NSClipView *)clipView {
    [super reflectScrolledClipView:clipView];
    [self clipViewBoundsDidChange:nil];
}

@end
