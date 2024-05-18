#import <OpenUXKit/UXBar.h>
#import <OpenUXKit/UXBase.h>
#import <QuartzCore/QuartzCore.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXView, _UXSinglePixelLine;

@protocol _UXBarItemsContainer;

@interface UXBar ()
{
    _UXSinglePixelLine *_decorationLine;    // 112 = 0x70
    NSMutableSet *_previousBarItemContainers;    // 120 = 0x78
    NSInteger _containerTransitionAnimationCount;    // 128 = 0x80
    NSView *_placeholderTrailingView;    // 136 = 0x88
    BOOL _isInteractiveTransitioning;    // 144 = 0x90
    BOOL _trailingViewNeedsRemoval;    // 145 = 0x91
    NSColor *_barTintColor;    // 152 = 0x98
    CGFloat _interitemSpacing;    // 160 = 0xa0
    CGFloat _height;    // 168 = 0xa8
    CGFloat _baselineOffsetFromBottom;    // 176 = 0xb0
    CGFloat _percent;    // 184 = 0xb8
    UXView<_UXBarItemsContainer> *_nextItemContainer;    // 192 = 0xc0
    NSView *_globalTrailingView;    // 200 = 0xc8
    CGFloat _globalTrailingViewWidthMultiplier;    // 208 = 0xd0
    UXView<_UXBarItemsContainer> *_barItemsContainer;    // 216 = 0xd8
    NSEdgeInsets _decorationInsets;    // 224 = 0xe0
}

@property (nonatomic) NSEdgeInsets decorationInsets;
@property (nonatomic, strong) UXView<_UXBarItemsContainer> *barItemsContainer;
@property (nonatomic) CGFloat globalTrailingViewWidthMultiplier;
@property (nonatomic, strong) NSView *globalTrailingView;
@property (nonatomic, strong) UXView<_UXBarItemsContainer> *nextItemContainer;
@property (nonatomic) CGFloat percent;
@property (nonatomic) BOOL trailingViewNeedsRemoval;
@property (nonatomic) BOOL isInteractiveTransitioning;
@property (nonatomic) CGFloat baselineOffsetFromBottom;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat interitemSpacing;
@property (nonatomic, strong) NSColor *barTintColor;
@property (nonatomic) NSEdgeInsets layoutMargins;
@property (nonatomic) BOOL bordered;

- (void)_updateDecorationLine;
- (void)_completeInteractiveTransition:(BOOL)completeInteractiveTransition duration:(NSTimeInterval)duration;
- (void)_finishInteractiveTransition:(BOOL)finishInteractiveTransition duration:(NSTimeInterval)duration completion:(UXCompletionHandler)completion;
- (void)_updateInteractiveTransition:(CGFloat)transition;
- (void)_beginInteractiveTransitionToItemContainer:(UXView<_UXBarItemsContainer> *)itemContainer;
- (void)_animateTransitionFromContainer:(UXView<_UXBarItemsContainer> *)fromContainer toContainer:(UXView<_UXBarItemsContainer> *)toContainer transition:(NSUInteger)transition duration:(NSTimeInterval)duration fromValue:(CGFloat)fromValue toValue:(CGFloat)toValue completion:(UXCompletionHandler)completion;
- (void)_didCompleteContainerTransitionAnimation;
- (void)_transitionToContainer:(UXView<_UXBarItemsContainer> *)container transition:(NSUInteger)transition duration:(NSTimeInterval)duration;
- (void)_updateTrailingViewWithItemContainer:(UXView<_UXBarItemsContainer> *)itemContainer;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
