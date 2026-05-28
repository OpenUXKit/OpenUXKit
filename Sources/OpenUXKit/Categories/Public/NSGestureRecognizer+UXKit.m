#import <OpenUXKit/NSGestureRecognizer+UXKit.h>
#import <objc/runtime.h>

@interface NSGestureRecognizer (UXKitSPI)
- (void)addTarget:(id)target action:(SEL)action;
@end

static const char kBeginHandlerKey;
static const char kChangeHandlerKey;
static const char kEndHandlerKey;

@implementation NSGestureRecognizer (UXKit)

- (void)__stateChange:(NSGestureRecognizer *)gestureRecognizer {
    NSGestureRecognizerState state = gestureRecognizer.state;
    const void *handlerKey = NULL;
    switch (state) {
        case NSGestureRecognizerStateBegan:
            handlerKey = &kBeginHandlerKey;
            break;
        case NSGestureRecognizerStateChanged:
            handlerKey = &kChangeHandlerKey;
            break;
        case NSGestureRecognizerStateEnded:
        case NSGestureRecognizerStateCancelled:
        case NSGestureRecognizerStateFailed:
            handlerKey = &kEndHandlerKey;
            break;
        default:
            return;
    }
    void (^handler)(NSGestureRecognizer *) = objc_getAssociatedObject(self, handlerKey);
    if (handler) {
        handler(gestureRecognizer);
    }
}

- (void)setGestureDidBeginHandler:(void (^)(NSGestureRecognizer *))gestureDidBeginHandler {
    if (!gestureDidBeginHandler) {
        return;
    }
    objc_setAssociatedObject(self, &kBeginHandlerKey, gestureDidBeginHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(__stateChange:)];
}

- (void)setGestureDidChangeHandler:(void (^)(NSGestureRecognizer *))gestureDidChangeHandler {
    if (!gestureDidChangeHandler) {
        return;
    }
    objc_setAssociatedObject(self, &kChangeHandlerKey, gestureDidChangeHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(__stateChange:)];
}

- (void)setGestureDidEndHandler:(void (^)(NSGestureRecognizer *))gestureDidEndHandler {
    if (!gestureDidEndHandler) {
        return;
    }
    objc_setAssociatedObject(self, &kEndHandlerKey, gestureDidEndHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(__stateChange:)];
}

@end
