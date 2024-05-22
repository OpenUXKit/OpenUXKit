#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

@class NSColor;

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXSinglePixelLine : NSView

@property (nonatomic, strong) NSColor *color; // @synthesize color=_color;

- (void)updateHeight;

@end
