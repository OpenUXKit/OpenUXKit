#import "UXKitDefines.h"
#import "UXTabBarControllerDelegate.h"
#import "UXViewController.h"

@class UXTransitionController, UXViewController;
@protocol UXTabBarControllerDelegate;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXTabBarController : UXViewController

@property (nonatomic, copy) NSArray<UXViewController *> *viewControllers;
@property (nonatomic, weak, nullable) UXViewController *selectedViewController;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic) BOOL tabBarHidden;
@property (nonatomic, weak, nullable) id <UXTabBarControllerDelegate> delegate;
@property (nonatomic, strong, nullable) UXViewController *transientViewController;
@property (nonatomic, copy, nullable) NSArray<NSString *> *centerToolbarItemGroupTitles;
@property (nonatomic, copy, nullable) NSArray<NSMenuItem *> *shortcutMenuItems;

- (void)setTransientViewController:(nullable UXViewController *)transientViewController animated:(BOOL)animated;
- (void)setSelectedIndex:(NSUInteger)selectedIndex allowsCurrentTabReselectionCallback:(BOOL)allowsCurrentTabReselectionCallback;

- (void)registerTransitionControllerClass:(Class)transitionControllerClass forViewControllerClass:(Class)viewControllerClass;
- (void)unregisterTransitionControllerForTransitionToViewControllerClass:(Class)viewControllerClass;

- (void)populateShortcutMenuItemsStartingAtIndex:(NSUInteger)index ofMenu:(NSMenu *)menu useSeparators:(BOOL)useSeparators;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
