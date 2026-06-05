#import "UXTableViewCell+Internal.h"
#import <OpenUXKit/UXLabel.h>
#import <OpenUXKit/UXImageView.h>
#import <OpenUXKit/UXView.h>
#import "_UXButton.h"

@interface UXTableViewCell () {
    NSString *_text;
    NSString *_detailText;
    NSImage *_image;
    UXLabel *_textLabel;
    UXLabel *_detailTextLabel;
    UXImageView *_imageView;
    UXView *_backgroundView;
    UXView *_selectedBackgroundView;
    UXView *_defaultSelectedBackgroundView;
    UXView *_internalHighlightedBackgroundView;
    UXView *_upperSpace;
    UXView *_lowerSpace;
    UXView *_accessoryView;
    _UXButton *_internalAccessoryView;
    NSColor *_highlightColor;
    NSColor *__separatorColor;
    NSEdgeInsets _separatorInset;
    NSInteger _indentationLevel;
    CGFloat _indentationWidth;
    UXTableViewCellStyle _style;
    UXTableViewCellAccessoryType _accessoryType;
    UXTableViewCellSelectionStyle _selectionStyle;
    BOOL __highlightingForContext;
    NSInteger __separatorStyle;
    CGFloat __separatorHeight;
    NSMutableArray *__addedConstraints;
}
@end

@implementation UXTableViewCell

@synthesize text = _text;
@synthesize detailText = _detailText;
@synthesize image = _image;
@synthesize textLabel = _textLabel;
@synthesize detailTextLabel = _detailTextLabel;
@synthesize backgroundView = _backgroundView;
@synthesize selectedBackgroundView = _selectedBackgroundView;
@synthesize defaultSelectedBackgroundView = _defaultSelectedBackgroundView;
@synthesize internalHighlightedBackgroundView = _internalHighlightedBackgroundView;
@synthesize upperSpace = _upperSpace;
@synthesize lowerSpace = _lowerSpace;
@synthesize accessoryView = _accessoryView;
@synthesize internalAccessoryView = _internalAccessoryView;
@synthesize highlightColor = _highlightColor;
@synthesize _separatorColor = __separatorColor;
@synthesize separatorInset = _separatorInset;
@synthesize indentationLevel = _indentationLevel;
@synthesize indentationWidth = _indentationWidth;
@synthesize style = _style;
@synthesize accessoryType = _accessoryType;
@synthesize selectionStyle = _selectionStyle;
@synthesize _highlightingForContext = __highlightingForContext;
@synthesize _separatorStyle = __separatorStyle;
@synthesize _separatorHeight = __separatorHeight;
@synthesize _addedConstraints = __addedConstraints;

- (instancetype)initWithStyle:(UXTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _style = style;
        _selectionStyle = UXTableViewCellSelectionStyleDefault;
        _indentationWidth = 10.0;
        __addedConstraints = [[NSMutableArray alloc] init];
        __separatorStyle = 1;
        __separatorHeight = 1.0;
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frame {
    return [self initWithStyle:UXTableViewCellStyleDefault reuseIdentifier:nil];
}

- (UXLabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UXLabel alloc] init];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_textLabel];
        [self.contentView setNeedsUpdateConstraints:YES];
    }
    return _textLabel;
}

- (UXLabel *)detailTextLabel {
    if (!_detailTextLabel && _style != UXTableViewCellStyleDefault) {
        _detailTextLabel = [[UXLabel alloc] init];
        _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_detailTextLabel];
        [self.contentView setNeedsUpdateConstraints:YES];
    }
    return _detailTextLabel;
}

- (UXImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UXImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_imageView];
        [self.contentView setNeedsUpdateConstraints:YES];
    }
    return _imageView;
}

- (UXView *)defaultSelectedBackgroundView {
    if (!_defaultSelectedBackgroundView) {
        _defaultSelectedBackgroundView = [[UXView alloc] init];
        _defaultSelectedBackgroundView.backgroundColor = [NSColor selectedContentBackgroundColor];
    }
    return _defaultSelectedBackgroundView;
}

- (UXView *)internalHighlightedBackgroundView {
    if (!_internalHighlightedBackgroundView) {
        _internalHighlightedBackgroundView = [[UXView alloc] init];
        _internalHighlightedBackgroundView.backgroundColor = self.highlightColor;
    }
    return _internalHighlightedBackgroundView;
}

- (UXView *)upperSpace {
    if (!_upperSpace) {
        _upperSpace = [[UXView alloc] init];
        _upperSpace.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _upperSpace;
}

- (UXView *)lowerSpace {
    if (!_lowerSpace) {
        _lowerSpace = [[UXView alloc] init];
        _lowerSpace.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _lowerSpace;
}

- (_UXButton *)internalAccessoryView {
    if (!_internalAccessoryView) {
        _internalAccessoryView = [[_UXButton alloc] initWithFrame:CGRectZero];
        _internalAccessoryView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _internalAccessoryView;
}

#pragma mark - Setters

- (void)setText:(NSString *)text {
    _text = [text copy];
    self.textLabel.text = text;
}

- (void)setDetailText:(NSString *)detailText {
    _detailText = [detailText copy];
    self.detailTextLabel.text = detailText;
}

- (void)setImage:(NSImage *)image {
    _image = image;
    self.imageView.image = image;
}

- (void)setTextLabel:(UXLabel *)textLabel {
    if (_textLabel != textLabel) {
        [_textLabel removeFromSuperview];
        _textLabel = textLabel;
        if (textLabel) {
            textLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:textLabel];
        }
    }
}

- (void)setDetailTextLabel:(UXLabel *)detailTextLabel {
    if (_detailTextLabel != detailTextLabel) {
        [_detailTextLabel removeFromSuperview];
        _detailTextLabel = detailTextLabel;
        if (detailTextLabel) {
            detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:detailTextLabel];
        }
    }
}

- (void)setBackgroundView:(UXView *)backgroundView {
    [_backgroundView removeFromSuperview];
    _backgroundView = backgroundView;
    if (backgroundView) {
        backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:backgroundView positioned:NSWindowBelow relativeTo:nil];
    }
    [self setNeedsUpdateConstraints:YES];
}

- (void)setSelectedBackgroundView:(UXView *)selectedBackgroundView {
    [_selectedBackgroundView removeFromSuperview];
    _selectedBackgroundView = selectedBackgroundView;
    if (selectedBackgroundView) {
        selectedBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    [self setNeedsUpdateConstraints:YES];
}

- (void)setAccessoryView:(UXView *)accessoryView {
    [_accessoryView removeFromSuperview];
    _accessoryView = accessoryView;
    if (accessoryView) {
        accessoryView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:accessoryView];
    }
    [self setNeedsUpdateConstraints:YES];
}

- (void)setAccessoryType:(UXTableViewCellAccessoryType)accessoryType {
    _accessoryType = accessoryType;
    [self _configureInternalAccessoryViewForType:accessoryType];
    [self setNeedsUpdateConstraints:YES];
}

- (void)setSelectionStyle:(UXTableViewCellSelectionStyle)selectionStyle {
    _selectionStyle = selectionStyle;
}

- (void)setStyle:(UXTableViewCellStyle)style {
    if (_style != style) {
        _style = style;
        [self setNeedsUpdateConstraints:YES];
    }
}

- (void)setSeparatorInset:(NSEdgeInsets)separatorInset {
    _separatorInset = separatorInset;
    [self setNeedsUpdateConstraints:YES];
}

- (void)setHighlightColor:(NSColor *)highlightColor {
    _highlightColor = highlightColor;
    _internalHighlightedBackgroundView.backgroundColor = highlightColor;
}

- (void)setIndentationLevel:(NSInteger)indentationLevel {
    _indentationLevel = indentationLevel;
    [self setNeedsUpdateConstraints:YES];
}

- (void)setIndentationWidth:(CGFloat)indentationWidth {
    _indentationWidth = indentationWidth;
    [self setNeedsUpdateConstraints:YES];
}

#pragma mark - Selection / highlight

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    self.selected = selected;
    [self _updateTextColor];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self _updateTextColor];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self _updateTextColor];
}

#pragma mark - Internal helpers

- (void)_updateTextColor {
    NSColor *color = (self.isSelected || self.isHighlighted) ? [NSColor alternateSelectedControlTextColor] : [NSColor labelColor];
    _textLabel.textColor = color;
    _detailTextLabel.textColor = color;
}

- (NSInteger)_detailTextAlignment {
    switch (_style) {
        case UXTableViewCellStyleValue1:
            return NSTextAlignmentRight;
        case UXTableViewCellStyleValue2:
            return NSTextAlignmentLeft;
        case UXTableViewCellStyleSubtitle:
            return NSTextAlignmentLeft;
        default:
            return NSTextAlignmentLeft;
    }
}

- (void)_configureInternalAccessoryViewForType:(UXTableViewCellAccessoryType)type {
    _UXButton *button = self.internalAccessoryView;
    switch (type) {
        case UXTableViewCellAccessoryDisclosureIndicator:
            button.image = [NSImage imageWithSystemSymbolName:@"chevron.forward" accessibilityDescription:nil];
            button.hidden = NO;
            break;
        case UXTableViewCellAccessoryDetailDisclosureButton:
        case UXTableViewCellAccessoryDetailButton:
            button.image = [NSImage imageWithSystemSymbolName:@"info.circle" accessibilityDescription:nil];
            button.hidden = NO;
            break;
        case UXTableViewCellAccessoryCheckmark:
            button.image = [NSImage imageWithSystemSymbolName:@"checkmark" accessibilityDescription:nil];
            button.hidden = NO;
            break;
        case UXTableViewCellAccessoryNone:
        default:
            button.image = nil;
            button.hidden = YES;
            break;
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _textLabel.text = nil;
    _detailTextLabel.text = nil;
    _imageView.image = nil;
    self.accessoryType = UXTableViewCellAccessoryNone;
    self.accessoryView = nil;
}

@end
