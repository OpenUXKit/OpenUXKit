#import <AppKit/AppKit.h>
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionClipView : NSClipView

- (void)_invalidateFocus;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
