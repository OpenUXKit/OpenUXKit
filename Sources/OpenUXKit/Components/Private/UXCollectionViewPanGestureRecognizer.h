#import <AppKit/AppKit.h>
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewPanGestureRecognizer : NSPanGestureRecognizer

@property (nonatomic, strong, nullable) NSEvent *mouseDownEvent;

- (void)uxCancel;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
