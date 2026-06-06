#import "UXTabBarItem.h"
#import "UXTabBarItemSegment.h"

@implementation UXTabBarItem

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        self.title = title;
    }
    return self;
}

- (NSArray<UXTabBarItemSegment *> *)representedSegments {
    if (_representedSegments == nil) {
        UXTabBarItemSegment *segment = [[UXTabBarItemSegment alloc] initWithTitle:self.title];
        _representedSegments = @[segment];
    }
    return _representedSegments;
}

@end
