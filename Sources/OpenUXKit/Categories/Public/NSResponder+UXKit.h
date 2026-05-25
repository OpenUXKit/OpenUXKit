#import <AppKit/AppKit.h>

@interface NSResponder (UXKit)

- (BOOL)ux_isInResponderChainOf:(NSResponder *)responder;

@end

