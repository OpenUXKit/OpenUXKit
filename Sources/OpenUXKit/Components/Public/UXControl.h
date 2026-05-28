#import <OpenUXKit/UXView.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

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
