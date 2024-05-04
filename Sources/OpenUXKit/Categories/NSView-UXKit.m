//
//  NSView-UXKit.m
//  
//
//  Created by JH on 2024/4/7.
//

#import <OpenUXKit/NSView-UXKit.h>
#import <objc/runtime.h>

@implementation NSView (UXKit)

@dynamic backgroundColor;

- (NSColor *)tintColor {
    NSColor *tintColor = objc_getAssociatedObject(self, @selector(tintColor));
    if (!tintColor) {
        self.tintColor = [NSColor controlTextColor];
        tintColor = [NSColor controlTextColor];
    }
    return tintColor;
}

- (void)setTintColor:(NSColor *)tintColor {
    if (tintColor == nil) {
        tintColor = [NSColor controlTextColor];
    }
    
    NSColor *existTintColor = objc_getAssociatedObject(self, @selector(tintColor));
    BOOL isEqualExistTintColor = [tintColor isEqual:existTintColor];
    objc_setAssociatedObject(self, @selector(tintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (!isEqualExistTintColor) {
        [self tintColorDidChange];
        
        for (NSView *subview in self.subviews) {
            subview.tintColor = tintColor;
        }
    }
}

- (void)tintColorDidChange {}

- (void)setTintAdjustmentMode:(NSInteger)tintAdjustmentMode {}

- (NSInteger)tintAdjustmentMode {
    return 1;
}

- (void)setAlpha:(CGFloat)alpha {
    self.alphaValue = alpha;
}

- (CGFloat)alpha {
    return self.alphaValue;
}

- (CGFloat)ux_backingScaleFactor {
    CGFloat backingScaleFactor = self.window.backingScaleFactor;
    if (backingScaleFactor == 0.0) {
        backingScaleFactor = NSApp.mainWindow.backingScaleFactor;
    }
    
    if (backingScaleFactor == 0.0) {
        backingScaleFactor = NSScreen.mainScreen.backingScaleFactor;
    }
    
    if (backingScaleFactor == 0.0) {
        backingScaleFactor = 1.0;
    }
    return backingScaleFactor;
}

- (id)enclosingViewOfClass:(Class)cls {
    NSView *superview = self.superview;
    if (superview) {
        do {
            if ([superview isKindOfClass:cls]) {
                break;
            }
            superview = superview.superview;
        } while (superview);
    }
    return superview;
}

- (void)layoutIfNeeded {
    [self layoutSubtreeIfNeeded];
}

- (void)layoutSubviews {
    
}

- (void)setNeedsUpdateConstraints {
    [self setNeedsUpdateConstraints:YES];
}

- (void)updateConstraintsIfNeeded {
    [self updateConstraintsForSubtreeIfNeeded];
}

- (void)setNeedsDisplay {
    [self setNeedsDisplay:YES];
}


- (void)setNeedsLayout {
    [self setNeedsDisplay:YES];
}

- (void)didMoveToWindow {
    [self viewDidMoveToWindow];
}


- (NSLayoutPriority)contentHuggingPriorityForAxis:(UXLayoutConstraintAxis)axis {
    return [self contentHuggingPriorityForOrientation:(NSLayoutConstraintOrientation)axis];
}

- (void)setContentHuggingPriority:(NSLayoutPriority)priority forAxis:(UXLayoutConstraintAxis)axis {
    [self setContentHuggingPriority:priority forOrientation:(NSLayoutConstraintOrientation)axis];
}

- (NSLayoutPriority)contentCompressionResistancePriorityForAxis:(UXLayoutConstraintAxis)axis {
    return [self contentCompressionResistancePriorityForOrientation:(NSLayoutConstraintOrientation)axis];
}

- (void)setContentCompressionResistancePriority:(NSLayoutPriority)priority forAxis:(UXLayoutConstraintAxis)axis {
    [self setContentCompressionResistancePriority:priority forOrientation:(NSLayoutConstraintOrientation)axis];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(NSEvent *)event {
    return [self.layer containsPoint:point];
}

@end



