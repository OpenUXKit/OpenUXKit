#import <OpenUXKit/NSColor+Compatibility.h>

@implementation NSColor (Compatibility)

+ (NSColor *)lightTextColor {
    return [NSColor whiteColor];
}

+ (NSColor *)systemBackgroundColor {
    return [NSColor clearColor];
}

+ (NSColor *)secondarySystemBackgroundColor {
    return [NSColor clearColor];
}

@end
