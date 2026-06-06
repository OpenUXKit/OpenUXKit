#import <AppKit/AppKit.h>
#import "_UXButton.h"
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXButtonCell : NSButtonCell

@property (nonatomic, readonly) UXControlState _controlState;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
