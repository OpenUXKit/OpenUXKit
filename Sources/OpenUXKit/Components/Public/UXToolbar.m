#import <OpenUXKit/UXToolbar.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/_UXBarItemsContainer-Protocol.h>
#import <OpenUXKit/_UXToolbarItemsContainer.h>
#import <OpenUXKit/UXBar+Internal.h>

@interface UXToolbar ()
{
    __weak id <UXToolbarDelegate> _delegate;    // 112 = 0x70
    NSArray *_items;    // 120 = 0x78
}

@end

@implementation UXToolbar

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.blurEnabled = YES;
        self.wantsLayer = YES;
        self.layer.masksToBounds = NO;
    }
    return self;
}

- (UXBarPosition)barPosition {
    if ([self.delegate respondsToSelector:@selector(positionForBar:)]) {
        return [self.delegate positionForBar:self];
    } else {
        return UXBarPositionBottom;
    }
}

- (void)_setItems:(NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated duration:(NSTimeInterval)duration {
    if (_items != items && ![_items isEqual:items]) {
        _items = [items copy];
        NSUInteger transition = 0;
        if (animated) {
            [self.barItemsContainer prepareForTransition];
            transition = 6;
        }
        _UXToolbarItemsContainer *container = [_UXToolbarItemsContainer toolbarItemsContainerForToolbar:self items:items];
        [self _transitionToContainer:container transition:transition duration:duration];
    }
}

- (void)setItems:(NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated {
    [self _setItems:items animated:animated duration:0.33];
}

- (void)_beginInteractiveTransitionForItems:(NSArray<UXBarButtonItem *> *)items {
    _UXToolbarItemsContainer *container = [_UXToolbarItemsContainer toolbarItemsContainerForToolbar:self items:items];
    [self _beginInteractiveTransitionToItemContainer:container];
}

- (void)setItems:(NSArray<UXBarButtonItem *> *)items {
    [self setItems:items animated:NO];
}

- (NSResponder *)nextResponder {
    NSResponder *result = nil;
    if ([self.delegate respondsToSelector:@selector(nextResponderForToolbar:)]) {
        result = [self.delegate nextResponderForToolbar:self];
    }
    
    if (!result) {
        result = [super nextResponder];
    }
    
    return result;
}

- (void)otherMouseDragged:(NSEvent *)event {}

- (void)rightMouseDragged:(NSEvent *)event {}

- (void)mouseDragged:(NSEvent *)event {}

- (void)mouseMoved:(NSEvent *)event {}

- (void)otherMouseUp:(NSEvent *)event {}

- (void)rightMouseUp:(NSEvent *)event {}

- (void)mouseUp:(NSEvent *)event {}

- (void)otherMouseDown:(NSEvent *)event {}

- (void)rightMouseDown:(NSEvent *)event {}

- (void)mouseDown:(NSEvent *)event {}

@end
