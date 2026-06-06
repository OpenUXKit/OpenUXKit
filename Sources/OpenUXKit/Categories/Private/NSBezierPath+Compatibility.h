#import <AppKit/NSBezierPath.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSBezierPath (Compatibility)

+ (instancetype)bezierPathWithRoundedRect:(CGRect)roundedRect cornerRadius:(CGFloat)cornerRadius;

- (void)appendPath:(nullable NSBezierPath *)appendPath;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
