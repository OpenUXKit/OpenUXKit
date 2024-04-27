#import <AppKit/AppKit.h>
#import "UXBar.h"
#import "UXNavigationControllerOperation.h"

@class UXNavigationItem, _UXNavigationItemContainerView;
@protocol UXNavigationBarDelegate;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXNavigationBar : UXBar

@property (nonatomic) CGFloat centerYOffset; // @synthesize centerYOffset=_centerYOffset;
@property (nonatomic) CGFloat rightInteritemSpacing; // @synthesize rightInteritemSpacing=_rightInteritemSpacing;
@property (nonatomic) CGFloat leftInteritemSpacing; // @synthesize leftInteritemSpacing=_leftInteritemSpacing;
@property (nonatomic, getter = isDetached) BOOL detached; // @synthesize detached=_detached;
@property (nonatomic) BOOL alternateTitleEnabled; // @synthesize alternateTitleEnabled=_alternateTitleEnabled;
@property (nonatomic, strong) NSView *alternateCondensedTitleView; // @synthesize alternateCondensedTitleView=_alternateCondensedTitleView;
@property (nonatomic, strong) NSView *alternateTitleView; // @synthesize alternateTitleView=_alternateTitleView;
@property (nonatomic) BOOL recalculatingWindowKeyViewLoop; // @synthesize recalculatingWindowKeyViewLoop=_recalculatingWindowKeyViewLoop;
@property (nonatomic, strong, nullable) UXNavigationItem *transitioningItem; // @synthesize transitioningItem=_transitioningItem;
@property (nonatomic) UXNavigationControllerOperation currentOperation; // @synthesize currentOperation=_currentOperation;
@property (nonatomic, strong) _UXNavigationItemContainerView *topItemContainer; // @synthesize topItemContainer=_topItemContainer;
@property (nonatomic, strong) NSMutableArray<UXNavigationItem *> *internalItems; // @synthesize internalItems=_internalItems;
@property (nonatomic, strong) NSImage *backIndicatorImage; // @synthesize backIndicatorImage=_backIndicatorImage;
@property (nonatomic, copy) NSArray *items; // @synthesize items=_items;
@property (nonatomic, weak, nullable) NSView *titleCenteringTrackedView; // @synthesize titleCenteringTrackedView=_titleCenteringTrackedView;
@property (nonatomic) NSEdgeInsets edgeInsets; // @synthesize edgeInsets=_edgeInsets;
@property (nonatomic, getter = isTranslucent) BOOL translucent; // @synthesize translucent=_translucent;
@property (nonatomic, weak, nullable) id <UXNavigationBarDelegate> delegate; // @synthesize delegate=_delegate;
@property (nonatomic, readonly) UXNavigationItem *backItem;
@property (nonatomic, readonly) UXNavigationItem *topItem;

- (void)setNeedsRecalcuateWindowKeyViewLoop;
- (void)recalculateKeyViewLoop;
- (void)beginInteractivePop;
- (void)beginInteractivePushToItem:(UXNavigationItem *)item;
- (void)_updateItemContainer;
- (void)_snapshot;
- (UXNavigationItem *)_popNavigationItemAnimated:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)_pushNavigationItem:(UXNavigationItem *)item animated:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)_prepareForNavigationItemTransition;
- (void)_updateTitleView;
- (UXNavigationItem *)_popNavigationItem;
- (void)_removeItem:(UXNavigationItem *)item;
- (void)_pushItem:(UXNavigationItem *)item;
- (void)_removeObserversForItem:(UXNavigationItem *)item;
- (void)_addObserversForItem:(UXNavigationItem *)item;
- (UXNavigationItem *)popNavigationItemAnimated:(BOOL)animated;
- (void)pushNavigationItem:(UXNavigationItem *)navigationItem animated:(BOOL)animated;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
