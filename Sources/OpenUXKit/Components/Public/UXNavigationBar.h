#import <AppKit/AppKit.h>
#import <OpenUXKit/UXBar.h>
#import <OpenUXKit/UXNavigationController.h>

@class UXNavigationItem, _UXNavigationItemContainerView;

@protocol UXNavigationBarDelegate <NSObject>
@end

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXNavigationBar : UXBar

@property (nonatomic, copy) NSArray<UXNavigationItem *> *items;
@property (nonatomic, getter = isTranslucent) BOOL translucent;
@property (nonatomic, weak, nullable) id <UXNavigationBarDelegate> delegate;
@property (nonatomic, readonly, nullable) UXNavigationItem *backItem;
@property (nonatomic, readonly, nullable) UXNavigationItem *topItem;


- (nullable UXNavigationItem *)popNavigationItemAnimated:(BOOL)animated;
- (void)pushNavigationItem:(UXNavigationItem *)navigationItem animated:(BOOL)animated;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
