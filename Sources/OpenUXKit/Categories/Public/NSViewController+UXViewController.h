#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSViewController (UXViewController)

- (void)didMoveToParentViewController:(nullable NSViewController *)parent;
- (void)willMoveToParentViewController:(nullable NSViewController *)parent;
- (nullable id)ux_ancestorViewControllerOfClass:(Class)cls;

@end

NS_HEADER_AUDIT_END(nullability, sendability)

