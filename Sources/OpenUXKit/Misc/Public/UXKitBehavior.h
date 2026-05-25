#import <Foundation/Foundation.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

/// Process-wide hook for overriding UXKit construction choices that would
/// otherwise be hard-coded inside the framework.
///
/// At the moment this exposes a single knob — `backButtonClass` — which lets
/// host applications replace the default `NSSegmentedControl`-backed back
/// button with a lighter `NSButton`-based implementation. The use case is
/// macOS 26+, where `NSSegmentedControl` is reimplemented internally on top
/// of SwiftUI / DesignLibrary; every push there triggers a
/// `ViewGraph.sizeThatFits` pass through the navbar's auto-inserted back
/// button, which is enough to cause a visible flash on the push critical
/// path. Substituting an `NSButton` subclass keeps rendering on the
/// pure-AppKit cell path and removes the SwiftUI sizing pass entirely.
///
/// Mutate properties on the main thread before the first
/// `UXNavigationController` is created. UXKit reads the configured class
/// lazily during `pushViewController:` / `setViewControllers:`, so late
/// updates affect subsequent pushes but won't retroactively replace already
/// constructed back buttons.
NS_SWIFT_UI_ACTOR
@interface UXKitBehavior : NSObject

@property (class, readonly) UXKitBehavior *sharedBehavior;

/// Subclass of `NSControl` that conforms to `UXBackButtonProtocol`. The
/// default is the framework-provided `UXBackButton` (`NSSegmentedControl`
/// subclass) which matches the original UXKit appearance. Set to `nil` to
/// restore the default; UXKit treats an unset value identically to the
/// default class.
@property (nonatomic, null_resettable) Class backButtonClass;

/// Controls whether `UXNavigationController` calls
/// `-[NSWindow recalculateKeyViewLoop]` synchronously at the end of every
/// `pushViewController:` / `setViewControllers:` / `popViewController:`
/// completion handler. Default is `YES`, matching Apple UXKit.
///
/// Apple's implementation forces a global key-view recalculation after each
/// navigation transition so the keyboard tab order picks up the newly
/// promoted top view controller. Internally `-recalculateKeyViewLoop` walks
/// the entire window's view tree and calls `-_setDefaultKeyViewLoop` on each
/// view, which in turn calls `-layoutSubtreeIfNeeded` to know each view's
/// frame. On macOS 26+, that synchronous layout pass is where any
/// SwiftUI-backed AppKit controls (`NSSegmentedControl`, `NSPopUpButton`,
/// some `NSButton` styles) inside the new top view trigger
/// `ViewGraph.sizeThatFits` work — easily 60–80 ms per push.
///
/// Setting this to `NO` skips the synchronous call. AppKit will still pick
/// up the new key view loop lazily on the next user keyboard event
/// (`NSWindow` validates it on demand), so the only observable difference is
/// that programmatically focused tab traversal immediately after a
/// programmatic push may be one runloop late. For apps where the navigation
/// stack is mouse-driven and Inspector-like, this trade-off is essentially
/// invisible while removing the largest hitch on the push critical path.
@property (nonatomic) BOOL recalculatesKeyViewLoopAfterTransition;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
