#import <OpenUXKit/_UXWindowState.h>

@interface _UXWindowState ()
@end

@implementation _UXWindowState

+ (instancetype)windowStateWithStyleMask:(NSWindowStyleMask)styleMask collectionBehavior:(NSWindowCollectionBehavior)collectionBehavior {
    _UXWindowState *windowState = [[self alloc] init];

    windowState->_styleMask = styleMask;
    windowState->_collectionBehavior = collectionBehavior;
    return windowState;
}

- (void)applyToWindow:(NSWindow *)window {
    window.styleMask = _styleMask;
    window.collectionBehavior = _collectionBehavior;
}

@end
