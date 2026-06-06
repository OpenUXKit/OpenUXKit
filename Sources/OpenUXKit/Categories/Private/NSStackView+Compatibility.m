#import <OpenUXKit/NSStackView+Compatibility.h>

@implementation NSStackView (Compatibility)

+ (instancetype)stackViewWithArrangedSubviews:(NSArray<NSView *> *)arrangedSubviews {
    return [self stackViewWithViews:arrangedSubviews];
}

- (NSInteger)axis {
    return (NSInteger)self.orientation;
}

- (void)setAxis:(NSInteger)axis {
    self.orientation = (NSUserInterfaceLayoutOrientation)axis;
}

@end
