#import "UXViewController.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXView;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXProxyViewController : UXViewController

- (instancetype)initWithView:(UXView *)view;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
