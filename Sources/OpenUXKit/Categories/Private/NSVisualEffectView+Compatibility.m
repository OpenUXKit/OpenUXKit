#import "NSVisualEffectView+Compatibility.h"

@implementation NSVisualEffectView (Compatibility)

- (NSView *)contentView {
    return self;
}

@end
