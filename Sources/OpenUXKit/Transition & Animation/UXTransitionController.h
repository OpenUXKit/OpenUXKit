#import <AppKit/AppKit.h>
#import <OpenUXKit/UXViewControllerTransitioning.h>
#import <OpenUXKit/UXNavigationController.h>

@class _UXViewControllerTransitionContext, UXNavigationController, UXViewController;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXTransitionController : NSObject <UXViewControllerAnimatedTransitioning, UXViewControllerInteractiveTransitioning>

@property (nonatomic, readonly) CGFloat percentComplete;
@property (nonatomic) NSInteger operation;
- (BOOL)navigationController:(UXNavigationController *)navigationController shouldBeginInteractivePopFromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController;
- (nullable id<UXViewControllerAnimatedTransitioning>)navigationController:(UXNavigationController *)navigationController animationControllerForOperation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController;
- (nullable id<UXViewControllerInteractiveTransitioning>)navigationController:(UXNavigationController *)navigationController interactionControllerForAnimationController:(id<UXViewControllerAnimatedTransitioning>)animationController;
- (void)updateInteractiveTransition:(CGFloat)transition inContext:(_UXViewControllerTransitionContext *)context;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
