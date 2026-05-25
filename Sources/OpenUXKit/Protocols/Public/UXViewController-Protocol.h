#import <AppKit/AppKit.h>

@protocol UXLayoutSupport, UXViewControllerTransitionCoordinator;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

NS_SWIFT_UI_ACTOR
@protocol UXViewController <NSObject>

@required

@property (nonatomic, readonly, nullable) NSResponder *preferredFirstResponder;
@property (nonatomic, readonly) id<UXLayoutSupport> topLayoutGuide;
@property (nonatomic, readonly) id<UXLayoutSupport> bottomLayoutGuide;
@property (nonatomic, getter=isWindowInFullScreen, readonly) BOOL windowInFullScreen;
@property (nonatomic, getter=isWindowConsideredInFullScreen, readonly) BOOL windowConsideredInFullScreen;
@property (nonatomic, readonly, nullable) NSViewController *contentRepresentingViewController;
@property (nonatomic, readonly, nullable) id<UXViewControllerTransitionCoordinator> transitionCoordinator;

- (void)willMoveToParentViewController:(nullable id)parent NS_SWIFT_NAME(willMove(toParent:));
- (void)didMoveToParentViewController:(nullable id)parent NS_SWIFT_NAME(didMove(toParent:));
- (void)windowDidRecalculateKeyViewLoop;
- (void)invalidateIntrinsicLayoutInsets;
- (void)contentRepresentingViewControllerDidChange;
- (void)windowWillRecalculateKeyViewLoop;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
