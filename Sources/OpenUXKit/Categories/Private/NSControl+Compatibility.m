#import <OpenUXKit/NSControl+Compatibility.h>

@implementation NSControl (Compatibility)

- (void)setTarget:(id)target action:(SEL)action {
    [self setTarget:target];
    [self setAction:action];
}

@end
