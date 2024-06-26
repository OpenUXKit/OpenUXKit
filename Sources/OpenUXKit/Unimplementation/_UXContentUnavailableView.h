

@class NSButton, NSMutableArray, NSProgressIndicator, NSString, NSTextField, UXView;

@interface _UXContentUnavailableView{
    BOOL _showProgress; // 108 = 0x6c
    NSString *_title;   // 112 = 0x70
    NSString *_message; // 120 = 0x78
    NSString *_buttonTitle;     // 128 = 0x80
    NSButton *_actionButton;    // 136 = 0x88
    id _buttonAction;   // 144 = 0x90
    NSProgressIndicator *_progressIndicator;    // 152 = 0x98
    NSUInteger _progressIndicatorStyle; // 160 = 0xa0
    NSUInteger _vibrantOptions; // 168 = 0xa8
    UXView *_containerView;     // 176 = 0xb0
    NSTextField *_titleLabel;   // 184 = 0xb8
    NSTextField *_messageLabel; // 192 = 0xc0
    NSMutableArray *_containerViewContraints;   // 200 = 0xc8
}


@property (nonatomic, strong) NSMutableArray *containerViewContraints; // @synthesize containerViewContraints=_containerViewContraints;
@property (nonatomic, strong) NSTextField *messageLabel; // @synthesize messageLabel=_messageLabel;
@property (nonatomic, strong) NSTextField *titleLabel; // @synthesize titleLabel=_titleLabel;
@property (nonatomic, strong) UXView *containerView; // @synthesize containerView=_containerView;
@property (nonatomic) NSUInteger vibrantOptions; // @synthesize vibrantOptions=_vibrantOptions;
@property (nonatomic) NSUInteger progressIndicatorStyle; // @synthesize progressIndicatorStyle=_progressIndicatorStyle;
@property (nonatomic, strong) NSProgressIndicator *progressIndicator; // @synthesize progressIndicator=_progressIndicator;
@property (nonatomic) BOOL showProgress; // @synthesize showProgress=_showProgress;
@property (nonatomic, copy) id buttonAction; // @synthesize buttonAction=_buttonAction;
@property (nonatomic, strong) NSButton *actionButton; // @synthesize actionButton=_actionButton;
@property (nonatomic, strong) NSString *buttonTitle; // @synthesize buttonTitle=_buttonTitle;
@property (nonatomic, strong) NSString *message; // @synthesize message=_message;
@property (nonatomic, strong) NSString *title; // @synthesize title=_title;
- (void)layout;
- (void)_updateProgressLayout;
- (void)updateConstraints;
- (void)commonInit;
- (id)initWithCoder:(id)arg1;
- (id)initWithFrame:(CGRect)arg1;
- (void)_updateTextField:(id)arg1 withAttributedText:(id)arg2;
- (id)_textFieldWithFontSize:(CGFloat)arg1;
- (void)_actionButtonPressed:(id)arg1;
- (id)placeholderMessageTextAttributes;
- (id)placeholderTitleTextAttributes;
- (id)_buttonTitleAttributes;
- (CGFloat)_buttonAlpha;
- (CGFloat)_labelAlpha;
- (id)_tintColor;
- (id)_textColor;
- (id)_vibrantBaseColor;
- (BOOL)_hasVibrantButton;
- (BOOL)_hasVibrantText;

@end
