#import <AppKit/NSControl.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSControl (Compatibility)

- (void)setTarget:(nullable id)target action:(nullable SEL)action;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
