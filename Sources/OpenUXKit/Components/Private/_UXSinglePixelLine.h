#import <AppKit/AppKit.h>
#import "UXKitDefines.h"

@class NSColor;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXSinglePixelLine : NSView

@property (nonatomic, strong, nullable) NSColor *color;

- (void)updateHeight;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
