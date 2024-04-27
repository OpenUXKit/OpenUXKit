#import <AppKit/AppKit.h>
#import "UXNavigationController.h"

@class UXNavigationController, UXViewController;
@protocol UXViewControllerInteractiveTransitioning, UXViewControllerAnimatedTransitioning;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)
@protocol UXNavigationControllerDelegate <NSObject>
@optional
- (nullable id<UXViewControllerAnimatedTransitioning>)navigationController:(UXNavigationController *)navigationController animationControllerForOperation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController;
- (nullable id<UXViewControllerInteractiveTransitioning>)navigationController:(UXNavigationController *)navigationController interactionControllerForAnimationController:(id<UXViewControllerAnimatedTransitioning>)animationController;
- (void)navigationController:(UXNavigationController *)navigationController didShowViewController:(UXViewController *)viewController;
- (BOOL)navigationController:(UXNavigationController *)navigationController shouldBeginInteractivePopFromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController;
- (BOOL)navigationController:(UXNavigationController *)navigationController shouldPopFromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController;
- (void)navigationController:(UXNavigationController *)navigationController willShowViewController:(UXViewController *)viewController;

@end
NS_HEADER_AUDIT_END(nullability, sendability)
