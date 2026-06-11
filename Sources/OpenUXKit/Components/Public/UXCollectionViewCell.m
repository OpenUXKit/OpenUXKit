#import "UXCollectionViewCell.h"
#import "UXCollectionViewCell+Internal.h"
#import "UXCollectionReusableView+Internal.h"
#import "UXCollectionView.h"
#import "UXCollectionViewLayout.h"
#import "UXCollectionViewLayout+Internal.h"
#import "UXCollectionViewLayoutAccessibility.h"
#import <QuartzCore/QuartzCore.h>

@implementation UXCollectionViewCell

// UXKit 26.4 uses a static C function shared by -initWithFrame: and
// -initWithCoder: instead of an Objective-C "_commonInit" selector.
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

#pragma mark - Accessibility

- (NSIndexPath *)_accessibilityIndexPath {
    return [[self _collectionView] indexPathForCell:self];
}

- (NSString *)_accessibilityDefaultRole {
    return NSAccessibilityCellRole;
}

- (id)_dynamicAccessibilityParent {
    return [[[self _collectionView].collectionViewLayout layoutAccessibility] accessibilityParentForCell:self];
}

- (BOOL)isAccessibilitySelected {
    UXCollectionView *collectionView = [self _collectionView];
    return [collectionView selectedItemAtIndexPath:[collectionView indexPathForCell:self]];
}

- (void)setAccessibilitySelected:(BOOL)accessibilitySelected {
    UXCollectionView *collectionView = [self _collectionView];
    NSIndexPath *indexPath = [collectionView indexPathForCell:self];
    if (indexPath) {
        if (accessibilitySelected) {
            [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UXCollectionViewScrollPositionNone];
        } else {
            [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        }
    }
}

- (BOOL)isAccessibilitySelectorAllowed:(SEL)selector {
    if (selector == @selector(setAccessibilitySelected:)) {
        UXCollectionView *collectionView = [self _collectionView];
        return [collectionView selectableItemAtIndexPath:[collectionView indexPathForCell:self]];
    }
    return [super isAccessibilitySelectorAllowed:selector];
}

- (BOOL)accessibilityPerformPress {
    [self mouseDown:[self _axSimulateClick:NSEventTypeLeftMouseDown withNumberOfClicks:1]];
    [self mouseUp:[self _axSimulateClick:NSEventTypeLeftMouseUp withNumberOfClicks:1]];
    return YES;
}

- (void)_axPerformDoubleClick {
    UXCollectionView *collectionView = [self _collectionView];
    [collectionView accessibilityPerformPressWithItemAtIndexPath:[collectionView indexPathForCell:self]];
}

- (id)_axSimulateClick:(NSUInteger)clickType withNumberOfClicks:(NSUInteger)clicks {
    CGPoint locationInWindow = [self convertPoint:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)) toView:nil];
    // UXKit ignores the clicks argument and always emits clickCount 1.
    return [NSEvent mouseEventWithType:(NSEventType)clickType
                              location:locationInWindow
                         modifierFlags:0
                             timestamp:[NSDate timeIntervalSinceReferenceDate]
                          windowNumber:self.window.windowNumber
                               context:nil
                           eventNumber:0
                            clickCount:1
                              pressure:1.0];
}

@end
