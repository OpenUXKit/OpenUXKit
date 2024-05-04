#import <AppKit/AppKit.h>
#import "UXKitDefines.h"
#import "UXLayoutSupport-Protocol.h"

UXKIT_PRIVATE
@interface _UXLayoutSpacer : NSLayoutGuide <UXLayoutSupport>

@property (nonatomic, copy) void(^lengthUpdateBlock)(void);
@property (nonatomic) BOOL horizontal;

+ (instancetype)_horizontalLayoutSpacer;
+ (instancetype)_verticalLayoutSpacer;
- (void)_activate;
- (void)_setUpDimensionConstraintWithLength:(CGFloat)length;
- (void)_setUpCounterDimensionConstraint;

@end
