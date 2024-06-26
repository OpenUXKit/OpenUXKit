#import <OpenUXKit/UXTransitionController.h>
#import <OpenUXKit/_UXViewControllerTransitionContext.h>

@interface UXTransitionController ()
@end

@implementation UXTransitionController

- (void)startInteractiveTransition:(id)transition {}

- (void)updateInteractiveTransition:(CGFloat)transition inContext:(_UXViewControllerTransitionContext *)context {
    _percentComplete = fmax(fmin(transition, 1.0), 0.0);
    [context updateInteractiveTransition:transition];
}

- (CGFloat)transitionDuration:(id)transition {
    return 0.33;
}

- (void)animateTransition:(id<UXViewControllerContextTransitioning>)transition {
    [transition completeTransition:YES];
}

- (BOOL)navigationController:(UXNavigationController *)navigationController shouldBeginInteractivePopFromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController {
    return NO;
}

- (id<UXViewControllerAnimatedTransitioning>)navigationController:(UXNavigationController *)navigationController animationControllerForOperation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController {
    return self;
}

- (id<UXViewControllerInteractiveTransitioning>)navigationController:(UXNavigationController *)navigationController interactionControllerForAnimationController:(id<UXViewControllerAnimatedTransitioning>)animationController {
    return nil;
}

@end
