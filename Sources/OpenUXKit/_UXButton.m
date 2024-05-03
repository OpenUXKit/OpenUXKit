#import "_UXButton.h"
#import "NSView-UXKit.h"
#import "_UXButtonCell.h"


@interface _UXButton ()
{
    NSMutableDictionary *_titlesByState;    // 112 = 0x70
    NSMutableDictionary *_titleAttributesByState;    // 120 = 0x78
}
@end

@implementation _UXButton

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.wantsLayer = YES;
        _titlesByState = [NSMutableDictionary dictionary];
        _titleAttributesByState = [NSMutableDictionary dictionary];
        self.ignoresMultiClick = YES;
        self.bordered = NO;
        [self setButtonType:(NSButtonTypeMomentaryChange)];
    }
    return self;
}

- (BOOL)accessibilityPerformPress {
    if ([self.cell respondsToSelector:_cmd]) {
        return self.cell.accessibilityPerformPress;
    } else {
        return [super accessibilityPerformPress];
    }
}

- (NSString *)accessibilityLabel {
    return [super accessibilityLabel];
}

- (NSColor *)_textColorForState:(UXControlState)state {
    return _titleAttributesByState[@(state)][NSForegroundColorAttributeName];
}

- (NSAttributedString *)_attributedStringForState:(UXControlState)state {
    NSDictionary<NSAttributedStringKey, id> *titleAttributes = _titleAttributesByState[@(state)];
    NSString *title = _titlesByState[@(state)];
    BOOL v11 = NO;
    if (titleAttributes) {
        v11 = title == nil;
    } else {
        v11 = YES;
    }
    if (!v11) {
        return [[NSAttributedString alloc] initWithString:title attributes:titleAttributes];
    }
    if (title) {
        return [[NSAttributedString alloc] initWithString:title attributes:nil];
    }
    return nil;
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    [self setTitle:title forState:(UXControlStateNormal)];
    [self setTitle:title forState:(UXControlStateHighlighted)];
    [self setTitle:title forState:(UXControlStateDisabled)];
    [self setTitle:title forState:(UXControlStateSelected)];
}

- (void)mouseUp:(NSEvent *)event {
    if (event.clickCount <= 1) {
        [super mouseUp:event];
    }
}

- (void)viewWillMoveToSuperview:(NSView *)newSuperview {
    [super viewWillMoveToSuperview:newSuperview];
    if ([newSuperview respondsToSelector:@selector(setTintColor:)]) {
        self.tintColor = newSuperview.tintColor;
    }
}

- (void)tintColorDidChange {
    [self setTitleAttributes:@{
        NSFontAttributeName: [NSFont labelFontOfSize:[NSFont systemFontSize]],
        NSForegroundColorAttributeName: self.tintColor,
    } forState:(UXControlStateNormal)];
    [self setTitleAttributes:@{
        NSFontAttributeName: [NSFont labelFontOfSize:[NSFont systemFontSize]],
        NSForegroundColorAttributeName: [NSColor lightGrayColor],
    } forState:(UXControlStateDisabled)];
    [self setTitleAttributes:@{
        NSFontAttributeName: [NSFont labelFontOfSize:[NSFont systemFontSize]],
        NSForegroundColorAttributeName: [self.tintColor colorWithAlphaComponent:0.7],
    } forState:(UXControlStateHighlighted)];
    [self setNeedsDisplay:YES];
}

- (void)setTitleAttributes:(NSDictionary<NSAttributedStringKey,id> *)titleAttributes forState:(UXControlState)state {
    _titleAttributesByState[@(state)] = titleAttributes;
}

- (void)setTitle:(NSString *)title forState:(UXControlState)state {
    if (title) {
        _titlesByState[@(state)] = title;
    } else {
        [_titlesByState removeObjectForKey:@(state)];
    }
}

+ (Class)cellClass {
    return [_UXButtonCell class];
}

@end
