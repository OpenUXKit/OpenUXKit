#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@protocol _UXAccessoryBarContainer <NSObject>

@required
@property (nonatomic, readonly) CGFloat _accessoryBarHeight;
- (void)_setAccessoryBarHidden:(BOOL)accessoryBarHidden;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
