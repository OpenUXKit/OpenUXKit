//
//  UXBar.m
//  OpenUXKit
//
//  Created by JH on 2024/4/21.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "_UXBarItemsContainer-Protocol.h"
#import "_UXSinglePixelLine.h"
#import "UXBar.h"

@interface UXBar () {
    _UXSinglePixelLine *_decorationLine;    // 112 = 0x70
    NSMutableSet *_previousBarItemContainers;    // 120 = 0x78
    NSInteger _containerTransitionAnimationCount;    // 128 = 0x80
    NSView *_placeholderTrailingView;    // 136 = 0x88
    BOOL _isInteractiveTransitioning;    // 144 = 0x90
    BOOL _trailingViewNeedsRemoval;    // 145 = 0x91
    NSColor *_barTintColor;    // 152 = 0x98
    CGFloat _interitemSpacing;    // 160 = 0xa0
    CGFloat _height;    // 168 = 0xa8
    CGFloat _baselineOffsetFromBottom;    // 176 = 0xb0
    CGFloat _percent;    // 184 = 0xb8
    UXView<_UXBarItemsContainer> *_nextItemContainer;    // 192 = 0xc0
    NSView *_globalTrailingView;    // 200 = 0xc8
    CGFloat _globalTrailingViewWidthMultiplier;    // 208 = 0xd0
    UXView<_UXBarItemsContainer> *_barItemsContainer;    // 216 = 0xd8
    NSEdgeInsets _decorationInsets;    // 224 = 0xe0
}

@end

@implementation UXBar

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _interitemSpacing = 10.0;
        _height = 52.0;

        if (!_decorationLine) {
            _decorationLine = [[_UXSinglePixelLine alloc] initWithFrame:self.bounds];
            [self addSubview:_decorationLine];
        }
    }

    return self;
}

- (void)setBordered:(BOOL)bordered {
    _decorationLine.hidden = !bordered;
}

- (void)viewWillMoveToSuperview:(NSView *)newSuperview {
    [self _updateDecorationLine];
}

- (void)_updateDecorationLine {
    _decorationLine.frame = self.bounds;

    if (self.barPosition == UXBarPositionBottom) {
        _decorationLine.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    } else {
        _decorationLine.autoresizingMask = NSViewWidthSizable | NSViewMaxYMargin;
    }

    [_decorationLine updateHeight];
}

- (NSSize)intrinsicContentSize {
    return NSMakeSize(-1.0, self.height);
}

- (NSColor *)borderColor {
    return _decorationLine.color;
}

- (void)setBorderColor:(NSColor *)borderColor {
    _decorationLine.color = borderColor;
    [_decorationLine setNeedsDisplay:YES];
}

- (void)setHeight:(CGFloat)height {
    height = fmax(height, 25.0);

    if (_height != height) {
        _height = height;
        [self invalidateIntrinsicContentSize];
    }
}

- (void)_transitionToContainer:(UXView<_UXBarItemsContainer> *)container transition:(NSUInteger)transition duration:(NSTimeInterval)duration {
    [self.barItemsContainer setNeedsUpdateConstraints:YES];
    [self.barItemsContainer updateConstraintsForSubtreeIfNeeded];
    [self _updateTrailingViewWithItemContainer:container];
    UXView<_UXBarItemsContainer> *barItemsContainer = self.barItemsContainer;
    self.barItemsContainer = container;

    if (barItemsContainer) {
        if (!_previousBarItemContainers) {
            _previousBarItemContainers = [NSMutableSet set];
            [_previousBarItemContainers addObject:barItemsContainer];
        }
    } else {
        transition = 0;
    }

    ++_containerTransitionAnimationCount;
    [self _animateTransitionFromContainer:barItemsContainer
                              toContainer:container
                               transition:transition
                                 duration:duration
                                fromValue:0.0
                                  toValue:1.0
                               completion:^{
        [self _didCompleteContainerTransitionAnimation];
    }];
}

- (void)_updateTrailingViewWithItemContainer:(UXView<_UXBarItemsContainer> *)itemContainer {
    CGFloat globalTrailingViewWidthMultiplier = self.globalTrailingViewWidthMultiplier;
    NSView *globalTrailingView = nil;
    NSMutableArray *constraints = [NSMutableArray array];

    if (!itemContainer.hidesGlobalTrailingView) {
        globalTrailingView = self.globalTrailingView;
    }

    if (globalTrailingView) {
        UXView<_UXBarItemsContainer> *barItemsContainer = self.barItemsContainer;

        if (!barItemsContainer) {
            _placeholderTrailingView = [[NSView alloc] init];
        }

        NSView *globalTrailingViewSuperview = globalTrailingView.superview;

        if (globalTrailingViewSuperview != self) {
            globalTrailingView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:globalTrailingView positioned:NSWindowBelow relativeTo:_decorationLine];
            [constraints addObject:[globalTrailingView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]];
            [constraints addObject:[globalTrailingView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]];

            if (globalTrailingViewWidthMultiplier > 0.0) {
                NSLayoutConstraint *widthConstraint = [globalTrailingView.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:globalTrailingViewWidthMultiplier constant:0.0];
                widthConstraint.priority = NSLayoutPriorityRequired;
                [constraints addObject:widthConstraint];
            }
        }

        if (!barItemsContainer) {
            [constraints addObject:[globalTrailingView.heightAnchor constraintEqualToConstant:self.frame.size.height]];
        }
    } else {
        if (self.globalTrailingView.superview == self) {
            self.trailingViewNeedsRemoval = YES;
        }
    }

    itemContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:itemContainer positioned:NSWindowBelow relativeTo:_decorationLine];
    [constraints addObjectsFromArray:@[
         [itemContainer.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
         [itemContainer.trailingAnchor constraintEqualToAnchor:globalTrailingView ? globalTrailingView.
          leadingAnchor : self.trailingAnchor
                                                      constant:globalTrailingView ? -24.0 : 0.0],
         [itemContainer.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
         [itemContainer.heightAnchor constraintEqualToAnchor:self.heightAnchor],
    ]];

    [NSLayoutConstraint activateConstraints:constraints];
    [itemContainer layoutSubtreeIfNeeded];
}

CABasicAnimation * _animationForViewFromValueToValueKeyPath(UXView *view, NSNumber *fromValue, NSNumber *toValue, NSString *keyPath) {
    if (fromValue) {
        [CATransaction begin];
        [view setValue:fromValue forKeyPath:keyPath];
        [CATransaction commit];
    } else {
        fromValue = [view valueForKeyPath:keyPath];
    }

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.removedOnCompletion = YES;
    view.animations = @{
            keyPath: animation
    };
    [view setValue:toValue forKeyPath:keyPath];
    return animation;
}

- (void)_animateTransitionFromContainer:(UXView<_UXBarItemsContainer> *)fromContainer toContainer:(UXView<_UXBarItemsContainer> *)toContainer transition:(NSUInteger)transition duration:(NSTimeInterval)duration fromValue:(CGFloat)fromValue toValue:(CGFloat)toValue completion:(UXCompletionHandler)completion {
    if (transition == 6) {
        BOOL toContainerAllowsGroupOpacity = toContainer.layer.allowsGroupOpacity;

        [UXView animateWithDuration:duration
                              delay:0.0
                            options:0x4000
                         animations:^{
            _animationForViewFromValueToValueKeyPath(fromContainer, @(1.0 - fromValue), @(1.0 - toValue), @"alphaValue");
            _animationForViewFromValueToValueKeyPath(toContainer, @(fromValue + 0.0), @(toValue + 0.0), @"alphaValue");
        }
                         completion:^(BOOL finished) {
            toContainer.layer.allowsGroupOpacity = toContainerAllowsGroupOpacity;
            completion();
        }];
    } else {
        completion();
    }
}

- (void)_didCompleteContainerTransitionAnimation {
    NSInteger containerTransitionAnimationCount = _containerTransitionAnimationCount - 1;

    _containerTransitionAnimationCount = containerTransitionAnimationCount;

    if (!containerTransitionAnimationCount) {
        for (UXView<_UXBarItemsContainer> *barItemContainer in _previousBarItemContainers) {
            if (barItemContainer != self.barItemsContainer) {
                [barItemContainer removeFromSuperview];
            }
        }

        if (self.trailingViewNeedsRemoval) {
            self.trailingViewNeedsRemoval = NO;
            [self.globalTrailingView removeFromSuperview];
        }

        [_placeholderTrailingView removeFromSuperview];
        _placeholderTrailingView = nil;
        [_previousBarItemContainers removeAllObjects];
    }
}

- (void)setDecorationInsets:(NSEdgeInsets)decorationInsets {
    if (!NSEdgeInsetsEqual(decorationInsets, _decorationInsets)) {
        _decorationInsets = decorationInsets;
        [self _updateDecorationLine];
    }
}

- (NSInteger)barPosition {
    return UXBarPositionAny;
}

- (void)_completeInteractiveTransition:(BOOL)completeInteractiveTransition duration:(NSTimeInterval)duration {
    [self _finishInteractiveTransition:completeInteractiveTransition
                              duration:duration
                            completion:^{
    }];
}

- (void)_finishInteractiveTransition:(BOOL)finishInteractiveTransition duration:(NSTimeInterval)duration completion:(UXCompletionHandler)completion {
    CGFloat percent = self.percent;

    [self _animateTransitionFromContainer:self.barItemsContainer
                              toContainer:self.nextItemContainer
                               transition:6
                                 duration:duration
                                fromValue:self.percent * duration
                                  toValue:self.percent
                               completion:^{
        if (finishInteractiveTransition) {
            [self.barItemsContainer removeFromSuperview];
            self.barItemsContainer = self.nextItemContainer;
        } else {
            [self.nextItemContainer removeFromSuperview];
            [self _updateTrailingViewWithItemContainer:self.barItemsContainer];
        }

        if (self.trailingViewNeedsRemoval) {
            self.trailingViewNeedsRemoval = NO;
            [self.globalTrailingView removeFromSuperview];
        }

        completion();
    }];
}

- (void)_updateInteractiveTransition:(CGFloat)transition {
    self.percent = transition;
    self.barItemsContainer.alphaValue = 1.0 - transition;
    self.nextItemContainer.alphaValue = transition;
}

- (void)_beginInteractiveTransitionToItemContainer:(UXView<_UXBarItemsContainer> *)itemContainer {
    if (!itemContainer) {
        NSAssert(false, @"Invalid parameter not satisfying: %@", itemContainer);
    }

    if (!self.barItemsContainer) {
        NSAssert(false, @"Invalid parameter not satisfying: %@", self.barItemsContainer);
    }

    self.isInteractiveTransitioning = YES;
    [self.barItemsContainer setNeedsUpdateConstraints:YES];
    [self _updateTrailingViewWithItemContainer:itemContainer];
    self.nextItemContainer = itemContainer;
    [self _updateInteractiveTransition:0.0];
}

- (BOOL)bordered {
    return _decorationLine.isHidden;
}

@end
