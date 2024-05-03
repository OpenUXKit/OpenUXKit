#import <AppKit/NSPopover.h>

@class UXPopoverController;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXPopover : NSPopover

@property (nonatomic, weak, nullable) UXPopoverController *popoverController;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
