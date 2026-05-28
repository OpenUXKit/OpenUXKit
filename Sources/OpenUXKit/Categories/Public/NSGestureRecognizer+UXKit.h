#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSGestureRecognizer (UXKit)

- (void)__stateChange:(NSGestureRecognizer *)gestureRecognizer;
- (void)setGestureDidBeginHandler:(void (^_Nullable)(NSGestureRecognizer *gestureRecognizer))gestureDidBeginHandler;
- (void)setGestureDidChangeHandler:(void (^_Nullable)(NSGestureRecognizer *gestureRecognizer))gestureDidChangeHandler;
- (void)setGestureDidEndHandler:(void (^_Nullable)(NSGestureRecognizer *gestureRecognizer))gestureDidEndHandler;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
