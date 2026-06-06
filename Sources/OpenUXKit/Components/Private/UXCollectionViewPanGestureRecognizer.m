#import <OpenUXKit/UXCollectionViewPanGestureRecognizer.h>

@interface NSGestureRecognizer (UXCollectionViewPanGestureRecognizerPrivateSPI)
- (void)setState:(NSGestureRecognizerState)state;
@end

@implementation UXCollectionViewPanGestureRecognizer

@synthesize mouseDownEvent = _mouseDownEvent;

- (void)dealloc {
    [self setMouseDownEvent:nil];
}

- (void)uxCancel {
    [self setState:NSGestureRecognizerStateCancelled];
    [self setMouseDownEvent:nil];
}

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];

    if (event.clickCount == 1) {
        [self setMouseDownEvent:event];
    } else {
        [self uxCancel];
    }
}

@end
