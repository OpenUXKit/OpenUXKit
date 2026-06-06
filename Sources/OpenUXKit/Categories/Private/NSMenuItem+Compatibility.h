#import <AppKit/NSMenuItem.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSMenuItem (Compatibility)

- (instancetype)initWithTitle:(NSString *)title action:(nullable SEL)action;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
