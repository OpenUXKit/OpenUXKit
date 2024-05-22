#import <AppKit/NSPopover.h>
#import <OpenUXKit/UXKitDefines.h>

@class UXPopoverController;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXPopover : NSPopover

@property (nonatomic, weak, nullable) UXPopoverController *popoverController;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
