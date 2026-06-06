#import "NSMenuItem+Compatibility.h"

@implementation NSMenuItem (Compatibility)

- (instancetype)initWithTitle:(NSString *)title action:(SEL)action {
    return [self initWithTitle:title action:action keyEquivalent:@""];
}

@end
