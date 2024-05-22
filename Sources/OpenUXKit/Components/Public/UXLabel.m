#import <OpenUXKit/UXLabel.h>

@interface UXLabel () {
    NSTextField *_concreteTextField;    // 112 = 0x70
    NSArray<NSLayoutConstraint *> *_verticalDefaultConstraints;       // 120 = 0x78
    NSArray<NSLayoutConstraint *> *_verticalCenteringConstraints;     // 128 = 0x80
    NSColor *_textColor;        // 136 = 0x88
    NSColor *_shadowColor;      // 144 = 0x90
    NSColor *_highlightedTextColor;     // 152 = 0x98
    NSInteger _numberOfLines;   // 160 = 0xa0
    CGSize _shadowOffset;       // 168 = 0xa8
}

@end

@implementation UXLabel

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.accessibilityElement = nil;
        _concreteTextField = [[NSTextField alloc] initWithFrame:self.bounds];
        _concreteTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _concreteTextField.backgroundColor = [NSColor clearColor];
        _concreteTextField.bezeled = NO;
        _concreteTextField.bordered = NO;
        _concreteTextField.editable = NO;
        _concreteTextField.selectable = NO;
        _concreteTextField.font = [NSFont labelFontOfSize:[NSFont systemFontSize]];
        _concreteTextField.textColor = [NSColor labelColor];
        [self bind:NSStringFromSelector(@selector(clipsToBounds)) toObject:_concreteTextField withKeyPath:NSStringFromSelector(@selector(clipsToBounds)) options:nil];
        [self addSubview:_concreteTextField];
        [self.leadingAnchor constraintEqualToAnchor:_concreteTextField.leadingAnchor].active = YES;
        [self.trailingAnchor constraintEqualToAnchor:_concreteTextField.trailingAnchor].active = YES;
        _verticalDefaultConstraints = @[
            [self.topAnchor constraintEqualToAnchor:_concreteTextField.topAnchor],
            [self.bottomAnchor constraintEqualToAnchor:_concreteTextField.bottomAnchor],
        ];
        _verticalCenteringConstraints = @[
            [self.centerYAnchor constraintEqualToAnchor:_concreteTextField.centerYAnchor],
            [self.heightAnchor constraintGreaterThanOrEqualToAnchor:_concreteTextField.heightAnchor],
        ];
        self.centerVertically = NO;
        
    }
    return self;
}

- (void)setContentCompressionResistancePriority:(NSLayoutPriority)priority forOrientation:(NSLayoutConstraintOrientation)orientation {
    [super setContentCompressionResistancePriority:priority forOrientation:orientation];
    
    [_concreteTextField setContentCompressionResistancePriority:priority forOrientation:orientation];
}

- (void)setCenterVertically:(BOOL)centerVertically {
    NSArray *deactivateConstraints = nil;
    NSArray *activateConstraints = nil;
    if (centerVertically) {
        deactivateConstraints = _verticalDefaultConstraints;
        activateConstraints = _verticalCenteringConstraints;
    } else {
        deactivateConstraints = _verticalCenteringConstraints;
        activateConstraints = _verticalDefaultConstraints;
    }
    [NSLayoutConstraint deactivateConstraints:deactivateConstraints];
    [NSLayoutConstraint activateConstraints:activateConstraints];
}

- (void)setLineBreakMode:(NSUInteger)lineBreakMode {
    _concreteTextField.lineBreakMode = lineBreakMode;
}

- (void)setTextAlignment:(NSInteger)textAlignment {
    _concreteTextField.alignment = textAlignment;
}

- (void)setFont:(NSFont *)font {
    _concreteTextField.font = font;
}

- (void)setText:(NSString *)text {
    if (!text) {
        text = @"";
    }
    _concreteTextField.stringValue = text;
}

- (NSSize)intrinsicContentSize {
    return _concreteTextField.intrinsicContentSize;
}

- (void)setTextColor:(NSColor *)textColor {
    _textColor = textColor;
    _concreteTextField.textColor = textColor;
}

- (void)setHighlightedTextColor:(NSColor *)highlightedTextColor {
    _highlightedTextColor = highlightedTextColor;
    if (highlightedTextColor && _concreteTextField.isHighlighted) {
        _concreteTextField.textColor = highlightedTextColor;
    } else {
        if (!_concreteTextField.isHighlighted) {
            return;
        }
        _concreteTextField.textColor = _textColor;
    }
}

- (NSString *)accessibilityRoleDescription {
    return _concreteTextField.accessibilityRoleDescription;
}

- (void)setAccessibilityRoleDescription:(NSString *)accessibilityRoleDescription {
    _concreteTextField.accessibilityRoleDescription = accessibilityRoleDescription;
}

- (NSAccessibilityRole)accessibilityRole {
    return NSAccessibilityStaticTextRole;
}

- (NSString *)accessibilityLabel {
    return _concreteTextField.accessibilityLabel;
}


- (void)setAccessibilityLabel:(NSString *)accessibilityLabel {
    _concreteTextField.accessibilityLabel = accessibilityLabel;
}

- (id)accessibilityValue {
    return _concreteTextField.accessibilityValue;
}


- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    if (self.text.length) {
        if (self.attributedText) {
            bounds = [self.attributedText boundingRectWithSize:bounds.size options:0];
            
        } else {
            bounds = [self.text boundingRectWithSize:bounds.size options:0 attributes:nil];
        }
    } else {
        bounds.size.width = 0;
        bounds.size.height = 0;
    }
    return bounds;
}

- (id)textFieldCell {
    return _concreteTextField.cell;
}

- (BOOL)selectable {
    return _concreteTextField.isSelectable;
}

- (void)setSelectable:(BOOL)selectable {
    _concreteTextField.selectable = selectable;
}

- (BOOL)centerVertically {
    return _verticalCenteringConstraints.firstObject.isActive;
}

- (CGFloat)preferredMaxLayoutWidth {
    return _concreteTextField.preferredMaxLayoutWidth;
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    _concreteTextField.preferredMaxLayoutWidth = preferredMaxLayoutWidth;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    _numberOfLines = numberOfLines;
    _concreteTextField.usesSingleLineMode = numberOfLines == 1;
}

- (NSInteger)textAlignment {
    return _concreteTextField.alignment;
}

- (NSUInteger)lineBreakMode {
    return _concreteTextField.lineBreakMode;
}

- (void)setHighlighted:(BOOL)highlighted {
    NSColor *textColor = nil;
    if (!highlighted || !(textColor = _highlightedTextColor)) {
        if (_concreteTextField.isHighlighted == highlighted) {
            _concreteTextField.highlighted = highlighted;
            return;
        }
        textColor = _textColor;
    }
    _concreteTextField.textColor = textColor;
    _concreteTextField.highlighted = highlighted;
}

- (BOOL)isHighlighted {
    return _concreteTextField.isHighlighted;
}

- (NSAttributedString *)attributedText {
    return _concreteTextField.attributedStringValue;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _concreteTextField.attributedStringValue = attributedText;
}

- (void)setShadowOffset:(CGSize)shadowOffset {}

- (void)setShadowColor:(NSColor *)shadowColor {}

- (NSString *)text {
    return _concreteTextField.stringValue;
}

- (NSFont *)font {
    return _concreteTextField.font;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [_concreteTextField sizeThatFits:size];
}

- (void)sizeToFit {
    [_concreteTextField sizeToFit];
    CGSize cellSize = _concreteTextField.cell.cellSize;
    [self setFrameSize:NSMakeSize(ceil(cellSize.width), ceil(cellSize.height))];
}

- (CGFloat)lastBaselineOffsetFromBottom {
    return _concreteTextField.lastBaselineOffsetFromBottom;
}

- (CGFloat)firstBaselineOffsetFromTop {
    return _concreteTextField.firstBaselineOffsetFromTop;
}

- (NSEdgeInsets)alignmentRectInsets {
    return _concreteTextField.alignmentRectInsets;
}

@end
