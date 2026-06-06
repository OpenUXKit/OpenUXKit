#import <OpenUXKit/NSBezierPath+Compatibility.h>

@implementation NSBezierPath (Compatibility)

+ (instancetype)bezierPathWithRoundedRect:(CGRect)roundedRect cornerRadius:(CGFloat)cornerRadius {
    return [self bezierPathWithRoundedRect:roundedRect xRadius:cornerRadius yRadius:cornerRadius];
}

- (void)appendPath:(NSBezierPath *)appendPath {
    if (appendPath) {
        [self appendBezierPath:appendPath];
    }
}

@end
