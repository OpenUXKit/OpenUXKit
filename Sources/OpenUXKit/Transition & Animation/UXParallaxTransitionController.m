#import <OpenUXKit/UXParallaxTransitionController.h>
#import <OpenUXKit/UXNavigationController.h>
#import <OpenUXKit/UXNavigationController+Internal.h>
#import <OpenUXKit/UXView.h>
#import <OpenUXKit/NSView+UXKit.h>
#import <OpenUXKit/UXViewControllerTransitioning.h>
#import <OpenUXKit/_UXViewControllerOneToOneTransitionContext.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXKitPrivateUtilites.h>

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
    CGRect toEndFrame = transitionContext.toEndFrame;
    UXView *containerView = transitionContext.containerView;
    CGFloat containerViewWidth = CGRectGetWidth(containerView.bounds);
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        containerViewWidth = -containerViewWidth;
    }
    CGFloat parallaxOffsetFactor = floorf(containerViewWidth * -0.33);
    auto setFrameOrigin = ^(NSView *view, CGFloat x, CGFloat y){
        [view.animator setFrameOrigin:CGPointMake(x, y)];
    };
    auto setShadowOpacityUsingAnimation = ^(NSView *view, CGFloat shadowOpacity){
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(shadowOpacity))];
        CALayer *layer = view.layer;
        animation.fromValue = @(layer.shadowOpacity);
        animation.toValue = @(shadowOpacity);
        animation.removedOnCompletion = YES;
        [layer addAnimation:animation forKey:NSStringFromSelector(@selector(shadowOpacity))];
        layer.shadowOpacity = shadowOpacity;
        
    };
    auto completion = ^(BOOL isCompletion){
        toView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        if (transitionContext.transitionWasCancelled) {
            fromView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        }
        toView.shadow = nil;
        fromView.shadow = nil;
        [self->_dimmingView removeFromSuperview];
        self->_dimmingView = nil;
        BOOL isComplete = !transitionContext.transitionWasCancelled;
        [transitionContext completeTransition:isComplete];
    };
    if (self.operation == 1) {
        if (!transitionContext.initiallyInteractive) {
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [UXView animateWithDuration:0.33 delay:0.0 options:0x20000 animations:^{
                    CGFloat alpha = 0.0;
                    if (transitionContext.transitionWasCancelled) {
                        alpha = 0.0;
                        setFrameOrigin(toView, containerViewWidth, 0.0);
                        setFrameOrigin(fromView, fromStartFrame.origin.x, fromStartFrame.origin.y);
                        setShadowOpacityUsingAnimation(toView, 0.6);
                    } else {
                        setFrameOrigin(toView, 0.0, 0.0);
                        setFrameOrigin(fromView, parallaxOffsetFactor, 0.0);
                        setShadowOpacityUsingAnimation(toView, 0.0);
                        alpha = 0.08;
                    }
                    self->_dimmingView.alphaValue = alpha;
                } completion:completion];
            }];
            fromView.autoresizingMask = NSViewNotSizable;
            toView.autoresizingMask = NSViewNotSizable;
            toView.frame = CGRectMake(containerViewWidth, 0.0, CGRectGetWidth(toEndFrame), CGRectGetHeight(toEndFrame));
            [transitionContext.containerView addSubview:toView];
            [[self class] _addShadowToView:toView withAlpha:0.6];
            [self _setupDimmingViewInContext:transitionContext withAlpha:0.0];
            [transitionContext.containerView addSubview:_dimmingView positioned:NSWindowBelow relativeTo:toView];
            [CATransaction commit];
        }
    } else {
        if (!transitionContext.initiallyInteractive) {
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [UXView animateWithDuration:0.33 delay:0 options:0x20000 animations:^{
                    CGFloat alpha = 0.0;
                    if (transitionContext.transitionWasCancelled) {
                        alpha = 0.08;
                        setFrameOrigin(toView, parallaxOffsetFactor, 0.0);
                        setFrameOrigin(fromView, fromStartFrame.origin.x, fromStartFrame.origin.y);
                        setShadowOpacityUsingAnimation(toView, 0.6);
                    } else {
                        setFrameOrigin(toView, toEndFrame.origin.x, toEndFrame.origin.y);
                        setFrameOrigin(fromView, containerViewWidth, 0.0);
                        setShadowOpacityUsingAnimation(toView, 0.0);
                        
                        alpha = 0.0;
                    }
                    self->_dimmingView.alphaValue = alpha;
                } completion:completion];
            }];
            fromView.autoresizingMask = NSViewNotSizable;
            toView.autoresizingMask = NSViewNotSizable;
            toView.frame = CGRectMake(parallaxOffsetFactor, 0.0, CGRectGetWidth(toEndFrame), CGRectGetHeight(toEndFrame));
            [transitionContext.containerView addSubview:toView positioned:NSWindowBelow relativeTo:fromView];
            [self _setupDimmingViewInContext:transitionContext withAlpha:0.08];
            [transitionContext.containerView addSubview:_dimmingView positioned:NSWindowBelow relativeTo:fromView];
            [[self class] _addShadowToView:toView withAlpha:0.6];
            [CATransaction commit];
        }
    }
}

+ (void)_addShadowToView:(UXView *)view withAlpha:(CGFloat)alpha {
    if (!view.shadow) {
        view.shadow = [NSShadow new];
        view.layer.shadowColor = [NSColor blackColor].CGColor;
        view.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        view.layer.shadowRadius = 10.0;
        CGPathRef shadowPath = CGPathCreateWithRect(view.bounds, nil);
        view.layer.shadowPath = shadowPath;
        CGPathRelease(shadowPath);
    }
    view.layer.shadowOpacity = alpha;
}

@end
