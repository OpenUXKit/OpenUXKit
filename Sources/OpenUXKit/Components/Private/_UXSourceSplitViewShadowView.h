#import <AppKit/AppKit.h>

@interface _UXSourceSplitViewShadowView : NSView

@property (nonatomic) NSRectEdge shadowEdge;
@property (nonatomic) CGFloat shadowRevealAmount;

- (NSImage *)makeShadowImage;

@end
