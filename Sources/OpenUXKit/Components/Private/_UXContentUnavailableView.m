#import <OpenUXKit/_UXContentUnavailableView.h>

@interface _UXContentUnavailableView () {
    BOOL _showProgress;
    NSString *_title;
    NSString *_message;
    NSAttributedString *_attributedMessage;
    NSString *_buttonTitle;
    NSString *_symbolName;
    NSImageView *_imageView;
    NSButton *_actionButton;
    void (^_buttonAction)(void);
    NSProgressIndicator *_progressIndicator;
    NSProgressIndicatorStyle _progressIndicatorStyle;
    _UXContentUnavailableVibrantOptions _vibrantOptions;
    NSView *_containerView;
    NSTextField *_titleLabel;
    NSTextField *_messageLabel;
    NSMutableArray<NSLayoutConstraint *> *_containerViewContraints;
}
@end

@implementation _UXContentUnavailableView

@synthesize showProgress = _showProgress;
@synthesize title = _title;
@synthesize message = _message;
@synthesize attributedMessage = _attributedMessage;
@synthesize buttonTitle = _buttonTitle;
@synthesize symbolName = _symbolName;
@synthesize imageView = _imageView;
@synthesize actionButton = _actionButton;
@synthesize buttonAction = _buttonAction;
@synthesize progressIndicator = _progressIndicator;
@synthesize progressIndicatorStyle = _progressIndicatorStyle;
@synthesize vibrantOptions = _vibrantOptions;
@synthesize containerView = _containerView;
@synthesize titleLabel = _titleLabel;
@synthesize messageLabel = _messageLabel;
@synthesize containerViewContraints = _containerViewContraints;

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit {
    _containerView = [[NSView alloc] initWithFrame:NSZeroRect];
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_containerView];
}

#pragma mark - Property setters that trigger layout

- (void)setTitle:(NSString *)title {
    if (![_title isEqualToString:title]) {
        _title = [title copy];
        self.needsLayout = YES;
    }
}

- (void)setMessage:(NSString *)message {
    if (![_message isEqualToString:message]) {
        _message = [message copy];
        self.needsLayout = YES;
    }
}

- (void)setAttributedMessage:(NSAttributedString *)attributedMessage {
    if (_attributedMessage != attributedMessage) {
        _attributedMessage = [attributedMessage copy];
        self.needsLayout = YES;
    }
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    if (![_buttonTitle isEqualToString:buttonTitle]) {
        _buttonTitle = [buttonTitle copy];
        self.needsLayout = YES;
    }
}

- (void)setSymbolName:(NSString *)symbolName {
    if (![_symbolName isEqualToString:symbolName]) {
        _symbolName = [symbolName copy];
        self.needsLayout = YES;
    }
}

- (void)setShowProgress:(BOOL)showProgress {
    if (_showProgress != showProgress) {
        _showProgress = showProgress;
        self.needsLayout = YES;
    }
}

- (void)setProgressIndicatorStyle:(NSProgressIndicatorStyle)style {
    if (_progressIndicatorStyle != style) {
        _progressIndicatorStyle = style;
        self.needsLayout = YES;
    }
}

- (void)setVibrantOptions:(_UXContentUnavailableVibrantOptions)options {
    if (_vibrantOptions != options) {
        _vibrantOptions = options;
        self.needsLayout = YES;
    }
}

#pragma mark - Layout

- (void)layout {
    if (_symbolName.length > 0) {
        NSImage *image = [NSImage imageWithSystemSymbolName:_symbolName accessibilityDescription:nil];
        if (!_imageView) {
            _imageView = [NSImageView imageViewWithImage:image];
            _imageView.symbolConfiguration = [NSImageSymbolConfiguration configurationWithPointSize:36.0 weight:NSFontWeightRegular];
            _imageView.contentTintColor = [NSColor tertiaryLabelColor];
            _imageView.translatesAutoresizingMaskIntoConstraints = NO;
            [_containerView addSubview:_imageView];
        } else {
            _imageView.image = image;
        }
    } else if (_imageView) {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }

    if (!_titleLabel) {
        _titleLabel = [self _textFieldWithTextStyle:NSFontTextStyleBody addingSymbolicTraits:NSFontDescriptorTraitBold];
        [_titleLabel setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];
        [_containerView addSubview:_titleLabel];
    }
    [self _updateTextField:_titleLabel withText:_title attributedText:nil];

    if (_message.length > 0 || _attributedMessage.length > 0) {
        if (!_messageLabel) {
            _messageLabel = [self _textFieldWithTextStyle:NSFontTextStyleBody addingSymbolicTraits:0];
            [_messageLabel setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];
            [_containerView addSubview:_messageLabel];
        }
        [self _updateTextField:_messageLabel withText:_message attributedText:_attributedMessage];
    } else if (_messageLabel) {
        [_messageLabel removeFromSuperview];
        _messageLabel = nil;
    }

    if (_buttonTitle.length > 0) {
        if (!_actionButton) {
            _actionButton = [NSButton buttonWithTitle:@"" target:self action:@selector(_actionButtonPressed:)];
            _actionButton.translatesAutoresizingMaskIntoConstraints = NO;
            [_containerView addSubview:_actionButton];
        }
        _actionButton.title = _buttonTitle;
        _actionButton.alphaValue = [self _buttonAlpha];
    } else if (_actionButton) {
        [_actionButton removeFromSuperview];
        _actionButton = nil;
    }

    [self _updateProgressLayout];
    [self updateConstraints];
    [super layout];
}

- (void)_updateProgressLayout {
    if (_showProgress) {
        if (!_progressIndicator) {
            _progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSZeroRect];
            _progressIndicator.style = _progressIndicatorStyle;
            _progressIndicator.translatesAutoresizingMaskIntoConstraints = NO;
            [_containerView addSubview:_progressIndicator];
        } else {
            _progressIndicator.style = _progressIndicatorStyle;
        }
        [_progressIndicator startAnimation:nil];
    } else if (_progressIndicator) {
        [_progressIndicator stopAnimation:nil];
        [_progressIndicator removeFromSuperview];
        _progressIndicator = nil;
    }
}

- (void)updateConstraints {
    [NSLayoutConstraint deactivateConstraints:_containerViewContraints];
    _containerViewContraints = [[NSMutableArray alloc] init];

    [_containerViewContraints addObject:[_containerView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor]];
    [_containerViewContraints addObject:[_containerView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]];
    [_containerViewContraints addObject:[_containerView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:20.0]];
    [_containerViewContraints addObject:[_containerView.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-20.0]];

    NSView *previousView = nil;
    NSArray<NSView *> *stack = @[_imageView, _titleLabel, _messageLabel, _progressIndicator, _actionButton];
    for (NSView *view in stack) {
        if (!view) {
            continue;
        }
        [_containerViewContraints addObject:[view.centerXAnchor constraintEqualToAnchor:_containerView.centerXAnchor]];
        if (previousView == nil) {
            [_containerViewContraints addObject:[view.topAnchor constraintEqualToAnchor:_containerView.topAnchor]];
        } else {
            [_containerViewContraints addObject:[view.topAnchor constraintEqualToAnchor:previousView.bottomAnchor constant:8.0]];
        }
        if (view == _titleLabel || view == _messageLabel) {
            [_containerViewContraints addObject:[view.leadingAnchor constraintEqualToAnchor:_containerView.leadingAnchor]];
            [_containerViewContraints addObject:[view.trailingAnchor constraintEqualToAnchor:_containerView.trailingAnchor]];
        }
        previousView = view;
    }
    if (previousView) {
        [_containerViewContraints addObject:[previousView.bottomAnchor constraintEqualToAnchor:_containerView.bottomAnchor]];
    }

    [NSLayoutConstraint activateConstraints:_containerViewContraints];
    [super updateConstraints];
}

#pragma mark - Helpers

- (void)_updateTextField:(NSTextField *)textField withText:(NSString *)text attributedText:(NSAttributedString *)attributedText {
    if (attributedText) {
        textField.attributedStringValue = attributedText;
    } else if (text) {
        NSDictionary *attributes = (textField == _titleLabel) ? [self titleTextAttributes] : [self messageTextAttributes];
        textField.attributedStringValue = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    } else {
        textField.stringValue = @"";
    }
}

- (NSTextField *)_textFieldWithTextStyle:(NSFontTextStyle)textStyle addingSymbolicTraits:(NSFontDescriptorSymbolicTraits)traits {
    NSTextField *field = [NSTextField labelWithString:@""];
    field.translatesAutoresizingMaskIntoConstraints = NO;
    field.alignment = NSTextAlignmentCenter;
    field.lineBreakMode = NSLineBreakByWordWrapping;
    field.maximumNumberOfLines = 0;
    NSFontDescriptor *descriptor = [NSFontDescriptor preferredFontDescriptorForTextStyle:textStyle options:@{}];
    if (traits) {
        descriptor = [descriptor fontDescriptorWithSymbolicTraits:descriptor.symbolicTraits | traits];
    }
    field.font = [NSFont fontWithDescriptor:descriptor size:0.0];
    return field;
}

- (void)_actionButtonPressed:(id)sender {
    if (_buttonAction) {
        _buttonAction();
    }
}

- (NSDictionary *)titleTextAttributes {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    return @{
        NSForegroundColorAttributeName: [self _textColor],
        NSParagraphStyleAttributeName: style,
    };
}

- (NSDictionary *)messageTextAttributes {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    return @{
        NSForegroundColorAttributeName: [NSColor secondaryLabelColor],
        NSParagraphStyleAttributeName: style,
    };
}

- (CGFloat)_buttonAlpha {
    return [self _hasVibrantButton] ? 0.85 : 1.0;
}

- (CGFloat)_labelAlpha {
    return [self _hasVibrantText] ? 0.85 : 1.0;
}

- (NSColor *)_tintColor {
    return [self _hasVibrantText] ? [self _vibrantBaseColor] : [NSColor controlAccentColor];
}

- (NSColor *)_textColor {
    if ([self _hasVibrantText]) {
        return [self _vibrantBaseColor];
    }
    return [NSColor labelColor];
}

- (NSColor *)_vibrantBaseColor {
    return [NSColor secondaryLabelColor];
}

- (BOOL)_hasVibrantButton {
    return (_vibrantOptions & _UXContentUnavailableVibrantButton) != 0;
}

- (BOOL)_hasVibrantText {
    return (_vibrantOptions & _UXContentUnavailableVibrantText) != 0;
}

@end
