#import <Foundation/Foundation.h>
#import "UXBarItem.h"
#import "UXBarItem+Internal.h"

@implementation UXBarItem

- (instancetype)init {
    if (self = [super init]) {
        self.enabled = YES;
    }
    return self;
}

@end
