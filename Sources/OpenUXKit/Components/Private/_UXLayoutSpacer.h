#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXLayoutSupport.h>

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXLayoutSpacer : NSLayoutGuide <UXLayoutSupport>

@property (nonatomic, copy) void(^lengthUpdateBlock)(void);
@property (nonatomic) BOOL horizontal;

+ (instancetype)_horizontalLayoutSpacer;
+ (instancetype)_verticalLayoutSpacer;
- (void)_activate;
- (void)_setUpDimensionConstraintWithLength:(CGFloat)length;
- (void)_setUpCounterDimensionConstraint;

@end
