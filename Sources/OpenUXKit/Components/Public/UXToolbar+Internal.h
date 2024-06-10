#import <OpenUXKit/UXToolbar.h>

NS_ASSUME_NONNULL_BEGIN

@interface UXToolbar ()
- (void)_setItems:(nullable NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)_beginInteractiveTransitionForItems:(NSArray<UXBarButtonItem *> *)items;

@end

NS_ASSUME_NONNULL_END
