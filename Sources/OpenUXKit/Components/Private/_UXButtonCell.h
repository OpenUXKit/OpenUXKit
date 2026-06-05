#import <AppKit/AppKit.h>
#import <OpenUXKit/_UXButton.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXButtonCell : NSButtonCell

@property (nonatomic, readonly) UXControlState _controlState;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
