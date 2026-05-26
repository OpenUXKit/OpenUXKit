#import <OpenUXKit/UXCollectionViewCell.h>
#import <QuartzCore/QuartzCore.h>

static void UXCollectionViewCellCommonInit(UXCollectionViewCell *cell);

@interface UXCollectionViewCell () {
    NSView *_contentView;
    BOOL _selected;
    BOOL _highlighted;
    BOOL _selectionBorderShouldUsePrimaryColor;
}
@end

@implementation UXCollectionViewCell

- (instancetype)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        UXCollectionViewCellCommonInit(self);
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        UXCollectionViewCellCommonInit(self);
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

@end

static void UXCollectionViewCellCommonInit(UXCollectionViewCell *cell) {
    cell.autoresizingMask = NSViewNotSizable;
    cell.translatesAutoresizingMaskIntoConstraints = YES;
    NSView *contentView = [[NSView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.bounds))];
    cell->_contentView = contentView;
    contentView.accessibilityRole = NSAccessibilityGroupRole;
    contentView.accessibilityElement = NO;
    contentView.autoresizingMask = NSViewNotSizable;
    contentView.translatesAutoresizingMaskIntoConstraints = YES;
    contentView.wantsLayer = YES;
    contentView.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    [cell addSubview:contentView];
}
