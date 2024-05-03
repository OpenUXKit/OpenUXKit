//
//  UXParallaxTransitionController.m
//  
//
//  Created by JH on 2024/4/21.
//

#import <Foundation/Foundation.h>
#import "UXParallaxTransitionController.h"
#import "UXNavigationController.h"
#import "UXNavigationController+Internal.h"
#import "UXView.h"
#import "NSView-UXKit.h"
#import "UXViewControllerTransitioning.h"
#import "_UXViewControllerOneToOneTransitionContext.h"
#import <QuartzCore/QuartzCore.h>

@interface UXParallaxTransitionController ()
{
    UXView *_dimmingView;    // 24 = 0x18
}
@end

@implementation UXParallaxTransitionController

- (BOOL)navigationController:(UXNavigationController *)navigationController shouldBeginInteractivePopFromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController {
    return YES;
}

- (id<UXViewControllerAnimatedTransitioning>)navigationController:(UXNavigationController *)navigationController animationControllerForOperation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController {
    return self;
}

- (id<UXViewControllerInteractiveTransitioning>)navigationController:(UXNavigationController *)navigationController interactionControllerForAnimationController:(id<UXViewControllerAnimatedTransitioning>)animationController {
    if (navigationController.isInteractive) {
        return self;
    } else {
        return nil;
    }
}

- (void)_setupDimmingViewInContext:(_UXViewControllerOneToOneTransitionContext *)context withAlpha:(CGFloat)alpha {
    [_dimmingView removeFromSuperview];
    _dimmingView = [UXView new];
    _dimmingView.backgroundColor = [NSColor colorWithWhite:0.0 alpha:1.0];
    _dimmingView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    _dimmingView.frame = context.containerView.bounds;
    _dimmingView.alphaValue = alpha;
}

- (void)updateInteractiveTransition:(CGFloat)transition inContext:(_UXViewControllerOneToOneTransitionContext *)context {
    [super updateInteractiveTransition:transition inContext:context];
    CGFloat percentComplete = self.percentComplete;
    UXView *fromView = context.fromView;
    UXView *toView = context.toView;
    CGRect fromStartFrame = context.fromStartFrame;
    CGRect toEndFrame = context.toEndFrame;
    UXView *containerView = context.containerView;
    CGFloat width = CGRectGetWidth(containerView.bounds);
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        width = -width;
    }
    CGFloat minX = CGRectGetMinX(toEndFrame);
    CGFloat _width = width * -0.33;
    CGFloat alpha = 0.0;
    if (self.operation == 1) {
        CGFloat x = width + (minX - width) * percentComplete;
        [toView setFrameOrigin:NSMakePoint(floorf(x), 0.0)];
        minX = CGRectGetMinX(fromStartFrame);
        x = minX + (_width - minX) * percentComplete;
        [fromView setFrameOrigin:NSMakePoint(x, 0.0)];
        [[self class] _addShadowToView:toView withAlpha:percentComplete * -0.6 + 0.6];
        alpha = percentComplete * 0.08 + 0.0;
    } else {
        CGFloat x = _width + (minX - _width) * percentComplete;
        [toView setFrameOrigin:NSMakePoint(floorf(x), 0.0)];
        minX = CGRectGetMinX(fromStartFrame);
        x = minX + (width - minX) * percentComplete;
        [fromView setFrameOrigin:NSMakePoint(floorf(minX), 0.0)];
        [[self class] _addShadowToView:fromView withAlpha:percentComplete * -0.6 + 0.6];
        alpha = percentComplete * -0.08 + 0.08;
    }
    
    _dimmingView.alphaValue = alpha;
}

- (void)startInteractiveTransition:(_UXViewControllerOneToOneTransitionContext *)transitionContext {
    UXView *fromView = transitionContext.fromView;
    UXView *toView = transitionContext.toView;
    UXView *containerView = transitionContext.containerView;
    CGRect toEndFrame = transitionContext.toEndFrame;
    CGFloat width = CGRectGetWidth(containerView.bounds);
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        width = -width;
    }
    if (self.operation == 1) {
        toView.frame = CGRectMake(width, 0.0, CGRectGetWidth(toEndFrame), CGRectGetHeight(toEndFrame));
        [containerView addSubview:toView];
        [self _setupDimmingViewInContext:transitionContext withAlpha:0.0];
        [containerView addSubview:_dimmingView positioned:NSWindowBelow relativeTo:toView];
    } else {
        CGFloat x = floorf(width * -0.33);
        toView.frame = CGRectMake(x, 0.0, CGRectGetWidth(toEndFrame), CGRectGetHeight(toEndFrame));
        [containerView addSubview:toView positioned:NSWindowBelow relativeTo:fromView];
        [self _setupDimmingViewInContext:transitionContext withAlpha:0.6];
        [containerView addSubview:_dimmingView positioned:NSWindowBelow relativeTo:fromView];
        [[self class] _addShadowToView:fromView withAlpha:0.6];
    }
    fromView.autoresizingMask = NSViewNotSizable;
    toView.autoresizingMask = NSViewNotSizable;
}


- (void)animateTransition:(_UXViewControllerOneToOneTransitionContext *)transitionContext {
    UXView *fromView = transitionContext.fromView;
    UXView *toView = transitionContext.toView;
    CGRect fromStartFrame = transitionContext.fromStartFrame;
    UXView *containerView = transitionContext.containerView;
    CGFloat transitionWidth = CGRectGetWidth(containerView.bounds);
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        transitionWidth = -transitionWidth;
    }
    CGFloat parallaxOffsetFactor = floorf(transitionWidth * -0.33);
    
    if (self.operation == 1) {
        if (!transitionContext.initiallyInteractive) {
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [UXView animateWithDuration:0.33 delay:0.0 options:0x20000 animations:^{
                    if (transitionContext.transitionWasCancelled) {
                        
                        self->_dimmingView.alphaValue = 0.0;
                    } else {
                        self->_dimmingView.alphaValue = 0.08;
                    }
                } completion:^(BOOL finished) {
                    
                }];
            }];
        }
    } else {
        
    }
}

@end
