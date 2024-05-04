#import "NSResponder-UXKit.h"


@implementation NSResponder (UXKit)

- (BOOL)isInResponderChainOf:(NSResponder *)responder {
    NSInteger i = 0;
    for (i = responder == nil; responder; i = responder == nil) {
        if (responder == self) {
            break;
        }
        responder = responder.nextResponder;
    }
    return !i;
}

@end
