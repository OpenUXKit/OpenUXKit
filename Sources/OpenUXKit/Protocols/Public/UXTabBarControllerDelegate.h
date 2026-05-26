#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXTabBarController, UXViewController;

@protocol UXTabBarControllerDelegate <NSObject>

@optional
- (void)tabBarController:(UXTabBarController *)tabBarController didSelectViewController:(UXViewController *)viewController;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
