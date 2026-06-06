#import "NSScrollView+UXKit.h"

@interface NSScrollView (UXKitSPI)
- (nullable id)delegate;
- (void)setDelegate:(nullable id)delegate;
- (NSInteger)_scrollingModeForAxis:(NSInteger)axis;
- (void)_setScrollingMode:(NSInteger)mode forAxis:(NSInteger)axis;
@end

@implementation NSScrollView (UXKit)

- (id)scrollViewDelegate {
    return [self delegate];
}

- (void)setScrollViewDelegate:(id)scrollViewDelegate {
    [self setDelegate:scrollViewDelegate];
}

- (BOOL)isScrollEnabled {
    return [self _scrollingModeForAxis:1] != 3;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    NSInteger mode = scrollEnabled ? 0 : 3;
    [self _setScrollingMode:mode forAxis:1];
    [self _setScrollingMode:mode forAxis:2];
}

- (BOOL)pagingEnabled {
    return [self _scrollingModeForAxis:1] == 2;
}

- (void)setPagingEnabled:(BOOL)pagingEnabled {
    NSInteger mode = pagingEnabled ? 2 : 0;
    [self _setScrollingMode:3 forAxis:2];
    [self _setScrollingMode:mode forAxis:1];
}

@end
