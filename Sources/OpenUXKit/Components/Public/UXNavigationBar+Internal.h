#import <OpenUXKit/UXNavigationBar.h>

NS_ASSUME_NONNULL_BEGIN

@interface UXNavigationBar ()
{
    BOOL _needsRecalculateWindowKeyViewLoop;    // 108 = 0x6c
    BOOL _recalculatingKeyViewLoop;    // 109 = 0x6d
    BOOL _translucent;    // 110 = 0x6e
    BOOL _recalculatingWindowKeyViewLoop;    // 111 = 0x6f
    BOOL _alternateTitleEnabled;    // 112 = 0x70
    BOOL _detached;    // 113 = 0x71
    __weak id <UXNavigationBarDelegate> _delegate;    // 120 = 0x78
    __weak NSView *_titleCenteringTrackedView;    // 128 = 0x80
    NSArray *_items;    // 136 = 0x88
    NSImage *_backIndicatorImage;    // 144 = 0x90
    NSView *_globalTrailingView;    // 152 = 0x98
    CGFloat _globalTrailingViewWidthMultiplier;    // 160 = 0xa0
    NSMutableArray *_internalItems;    // 168 = 0xa8
    _UXNavigationItemContainerView *_topItemContainer;    // 176 = 0xb0
    UXNavigationControllerOperation _currentOperation;    // 184 = 0xb8
    UXNavigationItem *_transitioningItem;    // 192 = 0xc0
    NSView *_alternateTitleView;    // 200 = 0xc8
    NSView *_alternateCondensedTitleView;    // 208 = 0xd0
    CGFloat _leftInteritemSpacing;    // 216 = 0xd8
    CGFloat _rightInteritemSpacing;    // 224 = 0xe0
    CGFloat _centerYOffset;    // 232 = 0xe8
    NSEdgeInsets _edgeInsets;    // 240 = 0xf0
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
