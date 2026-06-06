#import <AppKit/AppKit.h>
#import "_UXViewControllerTransitionContext.h"
#import "UXKitDefines.h"

@class UXView, UXViewController;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface _UXViewControllerOneToOneTransitionContext : _UXViewControllerTransitionContext

@property (nonatomic) CGRect toStartFrame;
@property (nonatomic) CGRect toEndFrame;
@property (nonatomic) CGRect fromEndFrame;
@property (nonatomic) CGRect fromStartFrame;
@property (nonatomic, strong) UXViewController *toViewController;
@property (nonatomic, strong) UXViewController *fromViewController;
@property (nonatomic, readonly) UXView *fromView;
@property (nonatomic, readonly) UXView *toView;
@property (nonatomic, copy, nullable) UXCompletionHandler arbitraryTransitionCompletionHandler;

- (CGRect)finalFrameForViewController:(UXViewController *)viewController;
- (CGRect)initialFrameForViewController:(UXViewController *)viewController;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
