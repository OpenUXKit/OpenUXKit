#import <OpenUXKit/UXToolbar.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXToolbar ()
- (void)_setItems:(nullable NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)_beginInteractiveTransitionForItems:(NSArray<UXBarButtonItem *> *)items;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
