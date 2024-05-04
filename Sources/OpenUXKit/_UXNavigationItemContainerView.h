#import <AppKit/AppKit.h>
#import "_UXBarItemsContainer-Protocol.h"
#import "UXView.h"
#import "UXKitDefines.h"

@class UXImageView, UXNavigationBar, UXNavigationItem;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_PRIVATE
@interface _UXNavigationItemContainerView : UXView <_UXBarItemsContainer>

@property (nonatomic, weak, nullable) NSView *titleCenteringConstraintOwnerView;
@property (nonatomic, weak, nullable) NSView *titleCenteringTrackedView;
@property (nonatomic, weak, nullable) NSView *titleCenteringConstrainedTitleView;
@property (nonatomic, strong, nullable) NSLayoutConstraint *titleCenteringConstraint;
@property (nonatomic, strong) NSMutableArray *addedConstraints;
@property (nonatomic, strong) NSMutableDictionary *overflowItemsByMinimumWidth;
@property (nonatomic, strong) NSMutableArray *itemsSortedByPriority;
@property (nonatomic, strong) NSView *rightView;
@property (nonatomic, strong) NSMutableArray *rightItemViews;
@property (nonatomic, strong) NSView *titleView;
@property (nonatomic, strong) NSMutableArray *leftItemViews;
@property (nonatomic, strong) NSView *leftView;
@property (nonatomic) CGFloat minimumWidthForExpandedItems;
@property (nonatomic) CGFloat minimumWidthForExpandedTitle;
@property (nonatomic) NSUInteger state;
@property (nonatomic, weak, readonly, nullable) UXNavigationBar *navigationBar;
@property (nonatomic, readonly) UXNavigationItem *item;
@property (nonatomic, readonly) BOOL hidesGlobalTrailingView;
+ (instancetype)layoutContainerForItem:(UXNavigationItem *)item navigationBar:(UXNavigationBar *)navigationBar;
- (void)_updateItemsViews:(NSArray<NSView *> *)itemsView withNewViews:(NSArray<NSView *> *)newViews;
- (void)setTitleCenteringTrackedView:(NSView *)trackedView updateConstraints:(BOOL)updateConstraints;
- (NSArray<NSView *> *)subviewsIntersectedWithViews:(NSArray<NSView *> *)views excludingHidden:(BOOL)excludingHidden;
- (void)updateRightItemViewsAnimated:(BOOL)animated;
- (void)updateLeftItemViewsAnimated:(BOOL)animated;
- (void)_updateItemViews;
- (void)_updateItemsSortedByPriority;
- (void)_updateTitleView;
- (void)cancelTransistion;
- (void)prepareForTransition;
- (void)_updateStateForWindow:(NSWindow *)window;
@end


NS_HEADER_AUDIT_END(nullability, sendability)
