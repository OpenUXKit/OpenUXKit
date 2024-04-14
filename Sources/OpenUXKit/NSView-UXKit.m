//
//  NSView-UXKit.m
//  
//
//  Created by JH on 2024/4/7.
//

#import "NSView-UXKit.h"
#import <objc/runtime.h>
@implementation NSView (UXKit)

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

@end
