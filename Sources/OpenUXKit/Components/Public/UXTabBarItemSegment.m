#import <OpenUXKit/UXTabBarItemSegment.h>
#import "UXTabBarItemSegment+Internal.h"

@implementation UXTabBarItemSegment

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        _title = title.copy;
        _enabled = YES;
    }

    return self;
}

- (instancetype)initWithTitle:(NSString *)title symbol:(NSImage *)symbol {
    if (self = [super init]) {
        _title = title.copy;
        _enabled = YES;
        _symbol = symbol;
    }

    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)isEqualToTabBarItemSegment:(UXTabBarItemSegment *)tabBarItemSegment {
    return tabBarItemSegment
        && [_title isEqualToString:tabBarItemSegment->_title]
        && _enabled == tabBarItemSegment->_enabled
        && _symbol == tabBarItemSegment->_symbol;
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    return [self isEqualToTabBarItemSegment:(UXTabBarItemSegment *)object];
}

- (NSUInteger)hash {
    return _title.hash ^ (NSUInteger)_enabled ^ _symbol.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; title = %@>",
            NSStringFromClass(self.class), self, _title];
}

@end
