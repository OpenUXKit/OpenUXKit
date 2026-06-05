#import <OpenUXKit/UXView.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_OPTIONS(NSUInteger, UXControlState) {
    UXControlStateNormal       = 0,
    UXControlStateHighlighted  = 1 << 0,
    UXControlStateDisabled     = 1 << 1,
    UXControlStateSelected     = 1 << 2,
    UXControlStateFocused      = 1 << 3,
    UXControlStateApplication  = 0x00FF0000,
    UXControlStateReserved     = 0xFF000000
} NS_SWIFT_NAME(UXControl.State);

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXControl : UXView

@property (nonatomic, weak, nullable) id target;
@property (nonatomic, nullable) SEL action;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic) BOOL ignoresMultiClick;
@property (nonatomic) BOOL sendsActionOnMouseDown;

- (void)setTarget:(nullable id)target action:(nullable SEL)action;
- (BOOL)sendAction:(SEL)action to:(nullable id)target;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
