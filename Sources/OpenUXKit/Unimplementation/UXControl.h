

@interface UXControl
{
    BOOL _highlighted;	// 108 = 0x6c
    BOOL _selected;	// 109 = 0x6d
    BOOL _enabled;	// 110 = 0x6e
    BOOL _ignoresMultiClick;	// 111 = 0x6f
    BOOL _sendsActionOnMouseDown;	// 112 = 0x70
    id _target;	// 120 = 0x78
    SEL _action;	// 128 = 0x80
}


@property(nonatomic) BOOL sendsActionOnMouseDown; // @synthesize sendsActionOnMouseDown=_sendsActionOnMouseDown;
@property(nonatomic) BOOL ignoresMultiClick; // @synthesize ignoresMultiClick=_ignoresMultiClick;
@property(nonatomic, getter=isEnabled) BOOL enabled; // @synthesize enabled=_enabled;
@property(nonatomic, getter=isSelected) BOOL selected; // @synthesize selected=_selected;
@property(nonatomic, getter=isHighlighted) BOOL highlighted; // @synthesize highlighted=_highlighted;
@property(nonatomic) SEL action; // @synthesize action=_action;
@property(nonatomic) __weak id target; // @synthesize target=_target;
- (void)setTarget:(id)arg1 action:(SEL)arg2;
- (void)mouseDown:(id)arg1;
- (BOOL)sendAction:(SEL)arg1 to:(id)arg2;
- (BOOL)isFlipped;
- (BOOL)_locationInsideForEvent:(id)arg1;
- (id)initWithFrame:(CGRect)arg1;

@end

