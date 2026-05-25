#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

/// Contract that any class registered via
/// `UXKitBehavior.backButtonClass` must satisfy. Instances are placed inside
/// a `UXBarButtonItem` as a custom view, so the concrete class must also be
/// an `NSControl` subclass — that's where the inherited `target` / `action` /
/// `controlSize` / `menu` properties used by the navigation controller come
/// from. This protocol only adds the extra knobs UXKit needs on top.
NS_SWIFT_UI_ACTOR
@protocol UXBackButtonProtocol <NSObject>

/// Chevron + optional title image. Setting `nil` removes the image.
@property (nonatomic, strong, nullable) NSImage *image;

/// The string the previous view controller exposed as its title; shown next
/// to the chevron unless `hidesTitle` is `YES`.
@property (nonatomic, copy) NSString *title;

/// When `YES`, the implementation should collapse the visible title and only
/// display the chevron (typically promoting `title` into a tooltip instead).
@property (nonatomic) BOOL hidesTitle;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
