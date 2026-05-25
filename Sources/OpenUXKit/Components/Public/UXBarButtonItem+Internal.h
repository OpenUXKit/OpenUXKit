#import <OpenUXKit/UXBarButtonItem.h>

NS_ASSUME_NONNULL_BEGIN

@interface UXBarButtonItem ()
{
    NSView *__view;    // 8 = 0x8
    BOOL _wantsToUseCustomWidth;
    BOOL _ignoresMultiClick;    // 16 = 0x10
    BOOL _isSystemItem;
    SEL _action;    // 40 = 0x28
    __weak id _target;    // 48 = 0x30
    NSString *_toolTip;    // 56 = 0x38
    NSString *_identifier;
    NSString *_keyEquivalent;    // 64 = 0x40
    NSEventModifierFlags _keyEquivalentModifierMask;    // 72 = 0x48
    NSControlStateValue _buttonState;    // 80 = 0x50
}

@property (nonatomic, weak, setter = _setWidthConstrainingItem:) UXBarButtonItem *_widthConstrainingItem;
@property (nonatomic) NSLayoutPriority visibilityPriority;
@property (nonatomic, getter = isCondensed) BOOL condensed;
@property (nonatomic, readonly) BOOL isSystemItem;
@property (nonatomic, readonly) UXBarButtonSystemItem systemItem;
@property (nonatomic, readonly) UXViewController *contentViewController;
@property (nonatomic, strong) NSLayoutAnchor *baselineAnchor;
@property (nonatomic, readonly) NSView *_view;
@property (nonatomic, copy, nullable) NSColor *backgroundColor;
@property (nonatomic, weak, nullable) NSToolbarItem *toolbarItem;
@property (nonatomic, getter=isNavigational) BOOL navigational;
@property (nonatomic, strong, nullable) NSMenu *menu;
@property (nonatomic, getter=isHidden) BOOL hidden;

- (nullable id)_viewOfClass:(Class)cls;
- (CGFloat)preferredSpacingToItem:(UXBarItem *)item proposedSpacing:(CGFloat)spacing;

@end

NS_ASSUME_NONNULL_END
