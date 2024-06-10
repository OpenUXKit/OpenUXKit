#import <OpenUXKit/UXNavigationBar.h>

NS_ASSUME_NONNULL_BEGIN

@interface UXNavigationBar () {
    BOOL _needsRecalculateWindowKeyViewLoop;
    BOOL _recalculatingKeyViewLoop;
    NSView *_globalTrailingView;
    CGFloat _globalTrailingViewWidthMultiplier;
}

@property (nonatomic) CGFloat centerYOffset;
@property (nonatomic) CGFloat rightInteritemSpacing;
@property (nonatomic) CGFloat leftInteritemSpacing;
@property (nonatomic) UXNavigationControllerOperation currentOperation;
@property (nonatomic, getter = isDetached) BOOL detached;
@property (nonatomic) BOOL alternateTitleEnabled;
@property (nonatomic) BOOL recalculatingWindowKeyViewLoop;
@property (nonatomic) NSEdgeInsets edgeInsets;
@property (nonatomic, strong) NSView *alternateCondensedTitleView;
@property (nonatomic, strong) NSView *alternateTitleView;
@property (nonatomic, strong, nullable) UXNavigationItem *transitioningItem;
@property (nonatomic, strong) _UXNavigationItemContainerView *topItemContainer;
@property (nonatomic, strong) NSMutableArray<UXNavigationItem *> *internalItems;
@property (nonatomic, strong) NSImage *backIndicatorImage;
@property (nonatomic, weak, nullable) NSView *titleCenteringTrackedView;

- (void)setNeedsRecalcuateWindowKeyViewLoop;
- (void)recalculateKeyViewLoop;
- (void)beginInteractivePop;
- (void)beginInteractivePushToItem:(UXNavigationItem *)item;
- (void)_updateItemContainer;
- (void)_snapshot;
- (nullable UXNavigationItem *)_popNavigationItemAnimated:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)_pushNavigationItem:(UXNavigationItem *)item animated:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)_prepareForNavigationItemTransition;
- (void)_updateTitleView;
- (nullable UXNavigationItem *)_popNavigationItem;
- (void)_removeItem:(UXNavigationItem *)item;
- (void)_pushItem:(UXNavigationItem *)item;
- (void)_removeObserversForItem:(UXNavigationItem *)item;
- (void)_addObserversForItem:(UXNavigationItem *)item;

@end

NS_ASSUME_NONNULL_END
