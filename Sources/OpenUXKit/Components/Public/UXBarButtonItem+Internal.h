#import <OpenUXKit/UXBarButtonItem.h>

NS_ASSUME_NONNULL_BEGIN

@interface UXBarButtonItem ()
{
    NSView *__view;    // 8 = 0x8
    BOOL _wantsToUseCustomWidth;
    BOOL _ignoresMultiClick;    // 16 = 0x10
    BOOL _isSystemItem;
    BOOL _condensed;    // 17 = 0x11
    float _visibilityPriority;    // 20 = 0x14
    NSColor *_tintColor;    // 24 = 0x18
    UXTintAdjustmentMode _tintAdjustmentMode;    // 32 = 0x20
    SEL _action;    // 40 = 0x28
    __weak id _target;    // 48 = 0x30
    NSString *_toolTip;    // 56 = 0x38
    NSString *_identifier;
    NSString *_keyEquivalent;    // 64 = 0x40
    NSEventModifierFlags _keyEquivalentModifierMask;    // 72 = 0x48
    NSControlStateValue _buttonState;    // 80 = 0x50
    UXBarButtonItemStyle _style;    // 88 = 0x58
    CGFloat _width;    // 96 = 0x60
    NSView *_customView;    // 104 = 0x68
    NSLayoutAnchor *_baselineAnchor;    // 112 = 0x70
    UXViewController *_contentViewController;    // 120 = 0x78
    UXBarButtonSystemItem _systemItem;    // 128 = 0x80
    __weak UXBarButtonItem *__widthConstrainingItem;    // 136 = 0x88
}

@property (nonatomic, weak, setter = _setWidthConstrainingItem:) UXBarButtonItem *_widthConstrainingItem;
@property (nonatomic) NSLayoutPriority visibilityPriority;
@property (nonatomic, getter = isCondensed) BOOL condensed;
@property (nonatomic, readonly) UXBarButtonSystemItem systemItem;
@property (nonatomic, readonly) UXViewController *contentViewController;
@property (nonatomic, strong) NSLayoutAnchor *baselineAnchor;
@property (nonatomic, readonly) NSView *_view;

- (nullable id)_viewOfClass:(Class)cls;
- (CGFloat)preferredSpacingToItem:(UXBarItem *)item proposedSpacing:(CGFloat)spacing;

@end

NS_ASSUME_NONNULL_END
