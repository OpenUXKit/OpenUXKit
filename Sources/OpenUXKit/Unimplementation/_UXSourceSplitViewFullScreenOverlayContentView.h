

#import <AppKit/NSView.h>

@protocol _UXSourceSplitViewCursorProvider;

@interface _UXSourceSplitViewFullScreenOverlayContentView : NSView
{
    NSView *_separatorView;	// 112 = 0x70
    id <_UXSourceSplitViewCursorProvider> _cursorProvider;	// 120 = 0x78
}


@property(nonatomic) __weak id <_UXSourceSplitViewCursorProvider> cursorProvider; // @synthesize cursorProvider=_cursorProvider;
@property(nonatomic) __weak NSView *separatorView; // @synthesize separatorView=_separatorView;
- (id)description;
- (id)hitTest:(CGPoint)arg1;
- (void)resetCursorRects;

@end

