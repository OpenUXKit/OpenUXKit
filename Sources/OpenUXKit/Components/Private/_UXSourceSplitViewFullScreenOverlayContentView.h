#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@protocol _UXSourceSplitViewCursorProvider;

@interface _UXSourceSplitViewFullScreenOverlayContentView : NSView

@property(nonatomic, weak, nullable) id <_UXSourceSplitViewCursorProvider> cursorProvider;
@property(nonatomic, weak, nullable) NSView *dividerView;

@end


NS_HEADER_AUDIT_END(nullability, sendability)
