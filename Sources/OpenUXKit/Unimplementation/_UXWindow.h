

#import <AppKit/NSWindow.h>

@protocol _UXWindowDelegate;

@interface _UXWindow : NSWindow
{
}

- (void)cancelOperation:(id)arg1;
- (BOOL)makeFirstResponder:(id)arg1;
- (void)recalculateKeyViewLoop;
- (void)tintColorDidChange;
- (void)beginCriticalSheet:(id)arg1 completionHandler:(id)arg2;
- (void)beginSheet:(id)arg1 completionHandler:(id)arg2;
- (void)dealloc;
- (id)initWithContentRect:(CGRect)arg1;

// Remaining properties
@property __weak id <_UXWindowDelegate> delegate; // @dynamic delegate;

@end

