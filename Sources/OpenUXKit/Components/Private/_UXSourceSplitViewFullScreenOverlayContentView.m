#import <OpenUXKit/_UXSourceSplitViewFullScreenOverlayContentView.h>
#import <OpenUXKit/_UXSourceSplitView.h>

@interface _UXSourceSplitViewFullScreenOverlayContentView ()

@end

@implementation _UXSourceSplitViewFullScreenOverlayContentView

- (NSView *)hitTest:(NSPoint)point {
    BOOL mouseInRect = [self mouse:point inRect:self.dividerView.frame];
    if (mouseInRect) {
        return self;
    } else {
        return [super hitTest:point];
    }
}

- (void)resetCursorRects {
    [super resetCursorRects];
    if (self.cursorProvider.dividerCursor) {
        [self addCursorRect:self.dividerView.frame cursor:self.cursorProvider.dividerCursor];
    }
}

@end
