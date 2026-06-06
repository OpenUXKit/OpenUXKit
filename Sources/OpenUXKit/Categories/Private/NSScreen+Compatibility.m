#import "NSScreen+Compatibility.h"

@implementation NSScreen (Compatibility)

- (CGFloat)scale {
    return self.backingScaleFactor;
}

@end
