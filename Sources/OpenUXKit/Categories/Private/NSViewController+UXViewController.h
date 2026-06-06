#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSViewController (UXViewController)

- (void)didMoveToParentViewController:(nullable NSViewController *)parent;
- (void)willMoveToParentViewController:(nullable NSViewController *)parent;

@end

NS_HEADER_AUDIT_END(nullability, sendability)

