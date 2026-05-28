#import <OpenUXKit/UXSlideTransitionController.h>
#import <OpenUXKit/UXNavigationController.h>
#import <OpenUXKit/UXView.h>
#import <OpenUXKit/UXViewControllerTransitioning.h>
#import <OpenUXKit/_UXViewControllerOneToOneTransitionContext.h>
#import <OpenUXKit/UXKitPrivateUtilites.h>
#import <QuartzCore/QuartzCore.h>

@implementation UXSlideTransitionController

- (id<UXViewControllerAnimatedTransitioning>)navigationController:(UXNavigationController *)navigationController animationControllerForOperation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController {
    return self;
}

- (id<UXViewControllerInteractiveTransitioning>)navigationController:(UXNavigationController *)navigationController interactionControllerForAnimationController:(id<UXViewControllerAnimatedTransitioning>)animationController {
    return nil;
}

- (void)updateInteractiveTransition:(CGFloat)transition inContext:(_UXViewControllerOneToOneTransitionContext *)context {
    [super updateInteractiveTransition:transition inContext:context];
    CGFloat percentComplete = self.percentComplete;
    UXView *fromView = context.fromView;
    UXView *toView = context.toView;
    CGFloat width = CGRectGetWidth(context.containerView.bounds);

    if (self.operation == 1) {
        [toView setFrameOrigin:NSMakePoint(floorf(width + (0.0 - width) * percentComplete), 0.0)];
        width = -width;
    } else {
        [toView setFrameOrigin:NSMakePoint(floorf(-(width - (width + 0.0) * percentComplete)), 0.0)];
    }

    [fromView setFrameOrigin:NSMakePoint(floorf(width * percentComplete + 0.0), 0.0)];
}

- (void)startInteractiveTransition:(_UXViewControllerOneToOneTransitionContext *)transitionContext {
    UXView *fromView = transitionContext.fromView;
    UXView *toView = transitionContext.toView;
    CGFloat width = CGRectGetWidth(transitionContext.containerView.bounds);
    CGFloat height = CGRectGetHeight(transitionContext.containerView.bounds);

    if (self.operation == 1) {
        toView.frame = CGRectMake(width, 0.0, width, height);
        [transitionContext.containerView addSubview:toView];
    } else {
        toView.frame = CGRectMake(floorf(-width), 0.0, width, height);
        [transitionContext.containerView addSubview:toView positioned:NSWindowBelow relativeTo:fromView];
    }

    fromView.autoresizingMask = NSViewNotSizable;
    toView.autoresizingMask = NSViewNotSizable;
}

- (void)animateTransition:(_UXViewControllerOneToOneTransitionContext *)transitionContext {
    UXView *fromView = transitionContext.fromView;
    UXView *toView = transitionContext.toView;
    UXView *containerView = transitionContext.containerView;
    CGFloat width = CGRectGetWidth(containerView.bounds);
    CGFloat height = CGRectGetHeight(containerView.bounds);

    auto setFrameOrigin = ^(NSView *view, CGFloat x, CGFloat y) {
        [view setFrameOrigin:CGPointMake(x, y)];
    };

    auto completion = ^(BOOL isCompletion) {
        toView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        if (transitionContext.transitionWasCancelled) {
            fromView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        }
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    };

    auto pushAnimation = ^{
        if (transitionContext.transitionWasCancelled) {
            setFrameOrigin(toView, width, 0.0);
            setFrameOrigin(fromView, 0.0, 0.0);
        } else {
            setFrameOrigin(toView, 0.0, 0.0);
            setFrameOrigin(fromView, floorf(-width), 0.0);
        }
    };

    auto popAnimation = ^{
        if (transitionContext.transitionWasCancelled) {
            setFrameOrigin(toView, floorf(-width), 0.0);
            setFrameOrigin(fromView, 0.0, 0.0);
        } else {
            setFrameOrigin(toView, 0.0, 0.0);
            setFrameOrigin(fromView, width, 0.0);
        }
    };

    if (self.operation == 1) {
        if (transitionContext.initiallyInteractive) {
            [UXView animateWithDuration:0.33 delay:0.0 options:0x20000 animations:pushAnimation completion:completion];
        } else {
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [UXView animateWithDuration:0.33 delay:0.0 options:0x20000 animations:pushAnimation completion:completion];
            }];
            fromView.autoresizingMask = NSViewNotSizable;
            toView.autoresizingMask = NSViewNotSizable;
            toView.frame = CGRectMake(width, 0.0, width, height);
            [containerView addSubview:toView];
            [CATransaction commit];
        }
    } else {
        if (transitionContext.initiallyInteractive) {
            [UXView animateWithDuration:0.33 delay:0.0 options:0x20000 animations:popAnimation completion:completion];
        } else {
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [UXView animateWithDuration:0.33 delay:0.0 options:0x20000 animations:popAnimation completion:completion];
            }];
            fromView.autoresizingMask = NSViewNotSizable;
            toView.autoresizingMask = NSViewNotSizable;
            toView.frame = CGRectMake(floorf(-width), 0.0, width, height);
            [containerView addSubview:toView positioned:NSWindowBelow relativeTo:fromView];
            [CATransaction commit];
        }
    }
}

@end
