#import <OpenUXKit/UXToolbar.h>

NS_ASSUME_NONNULL_BEGIN

@interface UXToolbar () {
    __weak id <UXToolbarDelegate> _delegate;    // 112 = 0x70
    NSArray *_items;    // 120 = 0x78
}
- (void)_setItems:(nullable NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)_beginInteractiveTransitionForItems:(NSArray<UXBarButtonItem *> *)items;

@end

NS_ASSUME_NONNULL_END
