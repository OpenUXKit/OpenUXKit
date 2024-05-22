#import <AppKit/AppKit.h>
#import <OpenUXKit/UXBarCommon.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXView.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXBar : UXView <NSAccessibilityGroup, UXBarPositioning>
@end

NS_HEADER_AUDIT_END(nullability, sendability)
