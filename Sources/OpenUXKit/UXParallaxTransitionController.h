#import <AppKit/AppKit.h>
#import "UXNavigationControllerOperation.h"
#import "UXTransitionController.h"

@class UXView, UXNavigationController, UXViewController, _UXViewControllerOneToOneTransitionContext;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)


@interface UXParallaxTransitionController : UXTransitionController

+ (void)_addShadowToView:(UXView *)view withAlpha:(CGFloat)alpha;
- (BOOL)navigationController:(UXNavigationController *)navigationController shouldBeginInteractivePopFromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController;
- (nullable id<UXViewControllerAnimatedTransitioning>)navigationController:(UXNavigationController *)navigationController animationControllerForOperation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController;
- (nullable id<UXViewControllerInteractiveTransitioning>)navigationController:(UXNavigationController *)navigationController interactionControllerForAnimationController:(id<UXViewControllerAnimatedTransitioning>)animationController;
- (void)_setupDimmingViewInContext:(_UXViewControllerOneToOneTransitionContext *)context withAlpha:(CGFloat)alpha;
- (void)updateInteractiveTransition:(CGFloat)transition inContext:(_UXViewControllerOneToOneTransitionContext *)context;

@end



NS_HEADER_AUDIT_END(nullability, sendability)
