#import <AppKit/AppKit.h>
#import <OpenUXKit/UXBarCommon.h>
#import <OpenUXKit/UXView.h>


NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXBar : UXView <NSAccessibilityGroup, UXBarPositioning>
@end

NS_HEADER_AUDIT_END(nullability, sendability)
