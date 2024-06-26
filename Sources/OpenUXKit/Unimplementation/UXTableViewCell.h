

@class NSColor, NSLayoutConstraint, NSMutableArray, UXLabel, UXView, _UXButton;

@interface UXTableViewCell
{
    NSInteger _style;	// 112 = 0x70
    _UXButton *_internalAccessoryView;	// 120 = 0x78
    UXView *_internalHighlightedBackgroundView;	// 128 = 0x80
    UXView *_defaultSelectedBackgroundView;	// 136 = 0x88
    UXView *__lineView;	// 144 = 0x90
    UXView *_upperSpace;	// 152 = 0x98
    UXView *_lowerSpace;	// 160 = 0xa0
    NSLayoutConstraint *_leadingInsetConstraint;	// 168 = 0xa8
    NSLayoutConstraint *_trailingInsetConstraint;	// 176 = 0xb0
    NSLayoutConstraint *_lineHeightConstraint;	// 184 = 0xb8
    BOOL __highlightingForContext;	// 192 = 0xc0
    UXView *_backgroundView;	// 200 = 0xc8
    UXView *_selectedBackgroundView;	// 208 = 0xd0
    NSInteger _accessoryType;	// 216 = 0xd8
    UXView *_accessoryView;	// 224 = 0xe0
    NSColor *_highlightColor;	// 232 = 0xe8
    NSInteger _selectionStyle;	// 240 = 0xf0
    NSInteger _indentationLevel;	// 248 = 0xf8
    CGFloat _indentationWidth;	// 256 = 0x100
    NSMutableArray *__addedConstraints;	// 264 = 0x108
    UXLabel *_textLabel;	// 272 = 0x110
    UXLabel *_detailTextLabel;	// 280 = 0x118
    NSInteger __separatorStyle;	// 288 = 0x120
    CGFloat __separatorHeight;	// 296 = 0x128
    NSColor *__separatorColor;	// 304 = 0x130
    NSEdgeInsets _separatorInset;	// 312 = 0x138
}


@property(strong, nonatomic, setter=_setSeparatorColor:) NSColor *_separatorColor; // @synthesize _separatorColor=__separatorColor;
@property(nonatomic, setter=_setSeparatorHeight:) CGFloat _separatorHeight; // @synthesize _separatorHeight=__separatorHeight;
@property(nonatomic, setter=_setSeparatorStyle:) NSInteger _separatorStyle; // @synthesize _separatorStyle=__separatorStyle;
@property(nonatomic, setter=_setHighlightingForContext:) BOOL _highlightingForContext; // @synthesize _highlightingForContext=__highlightingForContext;
@property(strong, nonatomic) UXLabel *detailTextLabel; // @synthesize detailTextLabel=_detailTextLabel;
@property(strong, nonatomic) UXLabel *textLabel; // @synthesize textLabel=_textLabel;
@property(strong, nonatomic) NSMutableArray *_addedConstraints; // @synthesize _addedConstraints=__addedConstraints;
@property(readonly, nonatomic) UXView *internalHighlightedBackgroundView; // @synthesize internalHighlightedBackgroundView=_internalHighlightedBackgroundView;
@property(nonatomic) NSEdgeInsets separatorInset; // @synthesize separatorInset=_separatorInset;
@property(nonatomic) CGFloat indentationWidth; // @synthesize indentationWidth=_indentationWidth;
@property(nonatomic) NSInteger indentationLevel; // @synthesize indentationLevel=_indentationLevel;
@property(nonatomic) NSInteger selectionStyle; // @synthesize selectionStyle=_selectionStyle;
@property(strong, nonatomic) NSColor *highlightColor; // @synthesize highlightColor=_highlightColor;
@property(strong, nonatomic) UXView *accessoryView; // @synthesize accessoryView=_accessoryView;
@property(nonatomic) NSInteger accessoryType; // @synthesize accessoryType=_accessoryType;
@property(strong, nonatomic) UXView *selectedBackgroundView; // @synthesize selectedBackgroundView=_selectedBackgroundView;
@property(strong, nonatomic) UXView *backgroundView; // @synthesize backgroundView=_backgroundView;
@property(nonatomic) NSInteger style; // @synthesize style=_style;
- (id)accessibilityLabel;
- (NSInteger)_detailTextAlignment;
- (void)_configureInternalAccessoryViewForType:(NSInteger)arg1;
- (void)_updateTextColor;
@property(readonly, nonatomic) UXView *lowerSpace;
@property(readonly, nonatomic) UXView *upperSpace;
@property(readonly, nonatomic) UXView *defaultSelectedBackgroundView;
@property(readonly, nonatomic) _UXButton *internalAccessoryView;
- (void)setHighlighted:(BOOL)arg1;
- (void)prepareForReuse;
- (void)setSelected:(BOOL)arg1;
- (void)setSelected:(BOOL)arg1 animated:(BOOL)arg2;
- (void)updateConstraints;
- (void)viewDidMoveToWindow;
- (id)initWithFrame:(CGRect)arg1;
- (id)initWithStyle:(NSInteger)arg1 reuseIdentifier:(id)arg2;

@end

