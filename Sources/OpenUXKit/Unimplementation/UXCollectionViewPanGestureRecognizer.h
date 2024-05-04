

#import <AppKit/NSPanGestureRecognizer.h>

@class NSEvent;

@interface UXCollectionViewPanGestureRecognizer : NSPanGestureRecognizer
{
    NSEvent *_mouseDownEvent;	// 8 = 0x8
}

@property(strong, nonatomic) NSEvent *mouseDownEvent; // @synthesize mouseDownEvent=_mouseDownEvent;
- (void)dealloc;
- (void)uxCancel;
- (void)mouseDown:(id)arg1;

@end

