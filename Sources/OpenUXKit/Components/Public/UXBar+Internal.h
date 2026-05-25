#import <OpenUXKit/UXBar.h>
#import <OpenUXKit/UXBase.h>
#import <QuartzCore/QuartzCore.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXView, _UXSinglePixelLine;

@protocol _UXBarItemsContainer;

@interface UXBar ()
{
    _UXSinglePixelLine *_decorationLine;
    NSMutableSet *_previousBarItemContainers;
    NSInteger _containerTransitionAnimationCount;
    NSView *_placeholderTrailingView;
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
