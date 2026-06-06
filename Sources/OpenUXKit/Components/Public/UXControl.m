#import <OpenUXKit/UXControl.h>
#import "UXControl+Internal.h"

@implementation UXControl

@synthesize highlighted = _highlighted;
@synthesize selected = _selected;
@synthesize enabled = _enabled;
@synthesize ignoresMultiClick = _ignoresMultiClick;
@synthesize sendsActionOnMouseDown = _sendsActionOnMouseDown;
@synthesize action = _action;
@synthesize target = _target;

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _enabled = YES;
    }
    return self;
}

- (BOOL)isFlipped {
    return YES;
}

- (void)setTarget:(id)target action:(SEL)action {
    _target = target;
    _action = action;
}

- (BOOL)sendAction:(SEL)action to:(id)target {
    return [NSApp sendAction:action to:target from:self];
}

- (BOOL)_locationInsideForEvent:(NSEvent *)event {
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    return NSPointInRect(location, self.bounds);
}

- (void)mouseDown:(NSEvent *)event {
    if ((_ignoresMultiClick && event.clickCount > 1) || !_enabled) {
        [super mouseDown:event];
        return;
    }

    self.highlighted = YES;
    id target = self.target;

    if (_sendsActionOnMouseDown) {
        [self sendAction:_action to:target];
        self.highlighted = NO;
        return;
    }

    NSEvent *currentEvent = nil;
    while (YES) {
        currentEvent = [NSApp nextEventMatchingMask:(NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged)
                                          untilDate:[NSDate distantFuture]
                                             inMode:NSEventTrackingRunLoopMode
                                            dequeue:YES];
        NSEventType type = currentEvent.type;
        if (type == NSEventTypeLeftMouseDragged) {
            BOOL inside = [self _locationInsideForEvent:currentEvent];
            if (self.isHighlighted != inside) {
                self.highlighted = !self.isHighlighted;
            }
            continue;
        }
        if (type == NSEventTypeLeftMouseUp) {
            break;
        }
    }

    if ([self _locationInsideForEvent:currentEvent]) {
        [self sendAction:_action to:target];
    }
    self.highlighted = NO;
}

@end
