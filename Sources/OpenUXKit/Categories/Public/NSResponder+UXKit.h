#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSResponder (UXKit)

- (BOOL)isInResponderChainOf:(nullable NSResponder *)responder;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
