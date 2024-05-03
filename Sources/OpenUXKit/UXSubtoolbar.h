#import <AppKit/AppKit.h>
#import "UXToolbar.h"

@class NSLayoutConstraint;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXSubtoolbar : UXToolbar

@property (nonatomic, class, readonly) CGFloat defaultHeight;
@property (nonatomic, readonly) NSLayoutConstraint *heightConstraint;

@end


NS_HEADER_AUDIT_END(nullability, sendability)
