#import <OpenUXKit/UXCollectionViewCell.h>
#import <QuartzCore/QuartzCore.h>

@interface UXCollectionViewCell () {
    NSView *_contentView;
    BOOL _selected;
    BOOL _highlighted;
    BOOL _selectionBorderShouldUsePrimaryColor;
}
@end

@implementation UXCollectionViewCell

- (void)_commonInit {
    self.autoresizingMask = NSViewNotSizable;
    self.translatesAutoresizingMaskIntoConstraints = YES;
    NSView *contentView = [[NSView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    _contentView = contentView;
    contentView.accessibilityRole = NSAccessibilityGroupRole;
    contentView.accessibilityElement = NO;
    contentView.autoresizingMask = NSViewNotSizable;
    contentView.translatesAutoresizingMaskIntoConstraints = YES;
    contentView.wantsLayer = YES;
    contentView.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    [self addSubview:contentView];
}

- (instancetype)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _commonInit];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self _commonInit];
    }

    return self;
}

- (void)dealloc {
    [_contentView.layer removeAllAnimations];
}

- (BOOL)wantsUpdateLayer {
    return YES;
}

- (NSView *)contentView {
    return _contentView;
}

- (BOOL)isSelected {
    return _selected;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
}

- (BOOL)isHighlighted {
    return _highlighted;
}

- (void)setHighlighted:(BOOL)highlighted {
    _highlighted = highlighted;
}

- (BOOL)selectionBorderShouldUsePrimaryColor {
    return _selectionBorderShouldUsePrimaryColor;
}

- (void)setSelectionBorderShouldUsePrimaryColor:(BOOL)selectionBorderShouldUsePrimaryColor {
    _selectionBorderShouldUsePrimaryColor = selectionBorderShouldUsePrimaryColor;
}

- (void)_setSelected:(BOOL)selected animated:(BOOL)animated {
    if (animated) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.25];
        [CATransaction setCompletionBlock:^{
        }];
        [self setSelected:selected];
        [CATransaction commit];
    } else {
        [self setSelected:selected];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self setSelected:NO];
    [_contentView.layer removeAllAnimations];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
    _contentView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
}

#pragma mark - Accessibility helpers

- (void)_axPerformDoubleClick {
    [self _axSimulateClick:0 withNumberOfClicks:2];
}

- (id)_axSimulateClick:(NSUInteger)clickType withNumberOfClicks:(NSUInteger)clicks {
    return nil;
}

@end
