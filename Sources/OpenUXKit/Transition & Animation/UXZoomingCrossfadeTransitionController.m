#import <OpenUXKit/UXZoomingCrossfadeTransitionController.h>
#import <OpenUXKit/UXView.h>
#import <OpenUXKit/UXViewControllerTransitioning.h>
#import <OpenUXKit/_UXViewControllerOneToOneTransitionContext.h>
#import <OpenUXKit/UXKitPrivateUtilites.h>
#import <QuartzCore/QuartzCore.h>

@implementation UXZoomingCrossfadeTransitionController

- (void)animateTransition:(_UXViewControllerOneToOneTransitionContext *)transitionContext {
    UXView *containerView = transitionContext.containerView;
    UXView *fromView = transitionContext.fromView;
    UXView *toView = transitionContext.toView;
    CGRect toEndFrame = transitionContext.toEndFrame;

    auto completion = ^(BOOL isCompletion) {
        toView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        if (transitionContext.transitionWasCancelled) {
            fromView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        }
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        fromView.layer.opacity = 1.0;
        fromView.layer.transform = CATransform3DIdentity;
    };

    auto animation = ^{
        if (!transitionContext.transitionWasCancelled) {
            toView.layer.transform = CATransform3DIdentity;
            toView.layer.opacity = 1.0;
            fromView.layer.opacity = 0.0;
            CATransform3D transform = CATransform3DMakeScale(1.02, 1.02, 1.0);
            transform = CATransform3DTranslate(transform, CGRectGetWidth(toEndFrame) * -0.02 * 0.5, CGRectGetHeight(toEndFrame) * -0.02, 0.0);
            fromView.layer.transform = transform;
        }
    };

    if (self.operation == 1) {
        if (transitionContext.initiallyInteractive) {
            [UXView animateWithDuration:0.33 delay:0.0 options:0 animations:animation completion:completion];
        } else {
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [UXView animateWithDuration:0.33 delay:0.0 options:0 animations:animation completion:completion];
            }];
            fromView.autoresizingMask = NSViewNotSizable;
            toView.autoresizingMask = NSViewNotSizable;
            toView.frame = toEndFrame;
            [containerView addSubview:toView];
            toView.layer.opacity = 0.0;
            CATransform3D transform = CATransform3DMakeScale(0.98, 0.98, 1.0);
            transform = CATransform3DTranslate(transform, CGRectGetWidth(toEndFrame) * 0.02 * 0.5, CGRectGetHeight(toEndFrame) * 0.02, 0.0);
            toView.layer.transform = transform;
            [CATransaction commit];
        }
    } else {
        if (transitionContext.initiallyInteractive) {
            [UXView animateWithDuration:0.33 delay:0.0 options:0 animations:animation completion:completion];
        } else {
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [UXView animateWithDuration:0.33 delay:0.0 options:0 animations:animation completion:completion];
            }];
            fromView.autoresizingMask = NSViewNotSizable;
            toView.autoresizingMask = NSViewNotSizable;
            toView.frame = toEndFrame;
            [containerView addSubview:toView positioned:NSWindowBelow relativeTo:fromView];
            toView.layer.opacity = 0.0;
            CATransform3D transform = CATransform3DMakeScale(1.02, 1.02, 1.0);
            transform = CATransform3DTranslate(transform, CGRectGetWidth(toEndFrame) * -0.02 * 0.5, CGRectGetHeight(toEndFrame) * -0.02, 0.0);
            toView.layer.transform = transform;
            [CATransaction commit];
        }
    }
}

@end
