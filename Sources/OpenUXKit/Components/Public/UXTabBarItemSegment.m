#import <OpenUXKit/UXTabBarItemSegment.h>

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

- (BOOL)isEqualToTabBarItemSegment:(UXTabBarItemSegment *)tabBarItemSegment {
    return tabBarItemSegment
        && [_title isEqualToString:tabBarItemSegment->_title]
        && _enabled == tabBarItemSegment->_enabled
        && _symbol == tabBarItemSegment->_symbol;
}

@end
