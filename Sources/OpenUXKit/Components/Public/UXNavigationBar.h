#import <AppKit/AppKit.h>
#import <OpenUXKit/UXBar.h>
#import <OpenUXKit/UXNavigationController.h>

@class UXNavigationItem, _UXNavigationItemContainerView;

@protocol UXNavigationBarDelegate <NSObject>
@end

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXNavigationBar : UXBar

@property (nonatomic, getter = isTranslucent) BOOL translucent;
@property (nonatomic, copy, nullable) NSArray<UXNavigationItem *> *items;
@property (nonatomic, weak, nullable) id <UXNavigationBarDelegate> delegate;
@property (nonatomic, readonly, nullable) UXNavigationItem *backItem;
@property (nonatomic, readonly, nullable) UXNavigationItem *topItem;

- (void)pushNavigationItem:(UXNavigationItem *)navigationItem animated:(BOOL)animated NS_SWIFT_NAME(pushItem(_:animated:));
- (nullable UXNavigationItem *)popNavigationItemAnimated:(BOOL)animated NS_SWIFT_NAME(popItem(animated:));

@end

NS_HEADER_AUDIT_END(nullability, sendability)
