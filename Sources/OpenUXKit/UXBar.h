#import <AppKit/AppKit.h>
#import "UXBarCommon.h"
#import "UXView.h"
#import "UXBase.h"

@class UXView, _UXSinglePixelLine;
@protocol _UXBarItemsContainer;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXBar : UXView <NSAccessibilityGroup, UXBarPositioning>

@property (nonatomic) NSEdgeInsets decorationInsets; // @synthesize decorationInsets=_decorationInsets;
@property (nonatomic, strong) UXView<_UXBarItemsContainer> *barItemsContainer; // @synthesize barItemsContainer=_barItemsContainer;
@property (nonatomic) CGFloat globalTrailingViewWidthMultiplier; // @synthesize globalTrailingViewWidthMultiplier=_globalTrailingViewWidthMultiplier;
@property (nonatomic, strong) NSView *globalTrailingView; // @synthesize globalTrailingView=_globalTrailingView;
@property (nonatomic, strong) UXView<_UXBarItemsContainer> *nextItemContainer; // @synthesize nextItemContainer=_nextItemContainer;
@property (nonatomic) CGFloat percent; // @synthesize percent=_percent;
@property (nonatomic) BOOL trailingViewNeedsRemoval; // @synthesize trailingViewNeedsRemoval=_trailingViewNeedsRemoval;
@property (nonatomic) BOOL isInteractiveTransitioning; // @synthesize isInteractiveTransitioning=_isInteractiveTransitioning;
@property (nonatomic) CGFloat baselineOffsetFromBottom; // @synthesize baselineOffsetFromBottom=_baselineOffsetFromBottom;
@property (nonatomic) NSEdgeInsets layoutMargins;
@property (nonatomic) CGFloat height; // @synthesize height=_height;
@property (nonatomic) CGFloat interitemSpacing; // @synthesize interitemSpacing=_interitemSpacing;
@property (nonatomic, strong) NSColor *barTintColor; // @synthesize barTintColor=_barTintColor;
@property (nonatomic, readonly) UXBarPosition barPosition;
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
