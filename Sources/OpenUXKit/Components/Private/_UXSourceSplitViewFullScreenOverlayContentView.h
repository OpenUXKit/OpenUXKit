#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@protocol _UXSourceSplitViewCursorProvider;

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXSourceSplitViewFullScreenOverlayContentView : NSView

@property(nonatomic, weak, nullable) id <_UXSourceSplitViewCursorProvider> cursorProvider;
@property(nonatomic, weak, nullable) NSView *dividerView;

@end


NS_HEADER_AUDIT_END(nullability, sendability)
