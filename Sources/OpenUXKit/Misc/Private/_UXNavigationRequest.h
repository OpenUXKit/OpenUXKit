#import <AppKit/AppKit.h>
#import <OpenUXKit/UXNavigationController.h>

@class UXViewController;

@interface _UXNavigationRequest : NSObject

@property (nonatomic, readonly) NSArray<UXViewController *> *viewControllers;
@property (nonatomic, readonly) UXViewController *viewController;
@property (nonatomic, readonly) UXNavigationControllerOperation operation;
@property (nonatomic, readonly) BOOL animated;

+ (_UXNavigationRequest *)setRequestWithViewControllers:(NSArray<UXViewController *> *)viewControllers animated:(BOOL)animated;
+ (_UXNavigationRequest *)popRequestWithViewController:(UXViewController *)viewController animated:(BOOL)animated;
+ (_UXNavigationRequest *)pushRequestWithViewController:(UXViewController *)viewController animated:(BOOL)animated;
+ (_UXNavigationRequest *)_requestWithOperation:(UXNavigationControllerOperation)operation viewControllers:(NSArray<UXViewController *> *)viewControllers animated:(BOOL)animated;
- (BOOL)isEqualToNavigationRequest:(_UXNavigationRequest *)request;
- (void)tearDownContainmentIfNeeded;
- (void)setupContainmentIfNeededInParentViewController:(UXViewController *)parentViewController;

@end
