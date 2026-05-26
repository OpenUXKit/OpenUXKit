#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@protocol UXLayoutSupport, UXViewControllerTransitionCoordinator;

// Mirrors the private UXKit `UXViewController` protocol. Container view controllers
// that cannot subclass the `UXViewController` class (e.g. `UXSourceController`, which
// must subclass `NSSplitViewController`) adopt this protocol to expose the same
// UXViewController-style contract.
@protocol UXViewController <NSObject>

@required

@property (nonatomic, readonly, nullable) NSResponder *preferredFirstResponder;
@property (nonatomic, readonly) id<UXLayoutSupport> topLayoutGuide;
@property (nonatomic, readonly) id<UXLayoutSupport> bottomLayoutGuide;
@property (nonatomic, getter=isWindowInFullScreen, readonly) BOOL windowInFullScreen;
@property (nonatomic, getter=isWindowConsideredInFullScreen, readonly) BOOL windowConsideredInFullScreen;
@property (nonatomic, readonly, nullable) NSViewController *contentRepresentingViewController;
@property (nonatomic, readonly, nullable) id<UXViewControllerTransitionCoordinator> transitionCoordinator;

- (void)willMoveToParentViewController:(nullable id)parentViewController;
- (void)didMoveToParentViewController:(nullable id)parentViewController;
- (void)windowDidRecalculateKeyViewLoop;
- (void)invalidateIntrinsicLayoutInsets;
- (void)contentRepresentingViewControllerDidChange;
- (void)windowWillRecalculateKeyViewLoop;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
