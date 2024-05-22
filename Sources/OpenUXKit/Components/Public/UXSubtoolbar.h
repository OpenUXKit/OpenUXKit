#import <AppKit/AppKit.h>
#import <OpenUXKit/UXToolbar.h>
#import <OpenUXKit/UXKitDefines.h>

@class NSLayoutConstraint;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXSubtoolbar : UXToolbar

@property (nonatomic, class, readonly) CGFloat defaultHeight;
@property (nonatomic, readonly) NSLayoutConstraint *heightConstraint;

@end


NS_HEADER_AUDIT_END(nullability, sendability)
