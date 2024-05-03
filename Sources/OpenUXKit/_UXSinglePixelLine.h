#import <AppKit/AppKit.h>

@class NSColor;

@interface _UXSinglePixelLine : NSView

@property (nonatomic, strong) NSColor *color; // @synthesize color=_color;

- (void)updateHeight;

@end
