#import <AppKit/AppKit.h>

@protocol _UXAccessoryBarContainer <NSObject>

@property (nonatomic, readonly) CGFloat _accessoryBarHeight;

- (void)_setAccessoryBarHidden:(BOOL)hidden;

@end
