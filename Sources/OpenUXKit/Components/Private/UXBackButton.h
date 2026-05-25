#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXBackButtonProtocol.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

/// Default `NSSegmentedControl`-based back button that matches the original
/// Apple UXKit appearance. On macOS 26+ `NSSegmentedControl` is internally
/// reimplemented on top of SwiftUI / DesignLibrary, which makes every push
/// trigger a `ViewGraph.sizeThatFits` pass; clients that observe push-time
/// flashing on macOS 26 should override `UXKitBehavior.backButtonClass` with
/// an `NSButton`-based subclass conforming to `UXBackButtonProtocol`.
UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface UXBackButton : NSSegmentedControl <UXBackButtonProtocol>

@property (nonatomic, strong, nullable) NSImage *image;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic) BOOL hidesTitle;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
