#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXSourceSplitViewShadowView : NSView

@property (nonatomic) NSRectEdge shadowEdge;
@property (nonatomic) CGFloat shadowRevealAmount;

- (NSImage *)makeShadowImage;

@end
