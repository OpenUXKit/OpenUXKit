// Shared private declarations for the UXCollectionView implementation, which is
// split across several category files by subsystem (UXCollectionView.m plus
// UXCollectionView+Selection.m, +BatchUpdates.m, +VisibleCells.m, +Layout.m,
// +Scrolling.m and +Rearranging.m). This header carries the class extension
// with all instance variables plus the runtime SPI used across those files, so
// every subsystem category can reach the ivars directly.

#import "UXCollectionView.h"
#import "UXCollectionView+Internal.h"
#import "UXCollectionReusableView+Internal.h"
#import "UXCollectionViewCell.h"
#import "UXCollectionReusableView.h"
#import "UXCollectionViewLayout.h"
#import "UXCollectionViewLayout+Internal.h"
#import "UXCollectionViewLayoutAttributes.h"
#import "UXCollectionViewLayoutAttributes+Internal.h"
#import "UXCollectionViewData.h"
#import "UXCollectionViewIndexPathsSet.h"
#import "UXCollectionViewIndexPathsSet+Internal.h"
#import "UXCollectionViewMutableIndexPathsSet.h"
#import "UXCollectionDocumentView.h"
#import "_UXCollectionViewItemKey.h"
#import "_UXCollectionViewRearrangingCoordinator.h"
#import "UXCollectionViewLayoutAccessibility.h"
#import "UXCollectionViewFlowLayout.h"
#import "UXCollectionViewUpdate.h"
#import "UXCollectionViewUpdate+Internal.h"
#import "UXCollectionViewUpdateItem.h"
#import "UXCollectionViewUpdateItem+Internal.h"
#import "UXCollectionViewAnimation.h"
#import "UXCollectionViewAnimationContext.h"
#import "UXCollectionViewLayoutInvalidationContext.h"
#import "UXCollectionViewLayoutInvalidationContext+Internal.h"
#import "UXCollectionViewData+Internal.h"
#import "_UXCollectionSnapshotView.h"
#import "NSObject+UXCollectionView.h"
#import <QuartzCore/QuartzCore.h>

// The UXCollectionView implementation is intentionally split across category
// files (see top of file). Implementing primary-interface methods in a category
// and leaving the primary @implementation "incomplete" are exactly what that
// split entails, so silence the two diagnostics that flag the pattern. The
// linker still guarantees every method is defined exactly once.
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
#pragma clang diagnostic ignored "-Wincomplete-implementation"

NS_ASSUME_NONNULL_BEGIN

@interface NSAnimationContext (UXCollectionViewSPI)
+ (BOOL)_hasActiveGrouping;
@end

@interface NSObject (UXCollectionViewLayoutSPI_Internal)
- (void)_setCollectionView:(UXCollectionView *)collectionView;
- (void)_setCollectionViewBoundsSize:(CGSize)boundsSize;
- (UXCollectionView *)_collectionView;
- (void)_setReuseIdentifier:(nullable NSString *)reuseIdentifier;
- (void)_markAsDequeued;
- (UXCollectionViewLayoutAttributes *)_layoutAttributes;
- (void)_setLayoutAttributes:(nullable UXCollectionViewLayoutAttributes *)layoutAttributes;
- (BOOL)_wasDequeued;
- (BOOL)_isInUpdateAnimation;
- (void)_addUpdateAnimation;
- (void)_clearUpdateAnimation;
- (NSArray *)_visibleSupplementaryViewsOfKind:(NSString *)kind;
- (BOOL)isFloatingPinned;
- (void)setIsFloatingPinned:(BOOL)isFloatingPinned;
- (void)_setSelected:(BOOL)selected animated:(BOOL)animated;
- (CGPoint)_collectionView:(UXCollectionView *)collectionView targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset;
- (void)accessibilityPostNotification:(NSAccessibilityNotificationName)notification;
- (nullable NSIndexSet *)sectionsForSelectAllActionInCollectionView:(UXCollectionView *)collectionView;
@end

@interface UXCollectionView () {
    UXCollectionDocumentView *_collectionDocumentView;
    UXCollectionViewLayout *_layout;
    UXCollectionViewMutableIndexPathsSet *_indexPathsForSelectedItems;
    NSHashTable *_notifiedDisplayedCells;
    NSMutableDictionary *_cellReuseQueues;
    NSMutableDictionary *_supplementaryViewReuseQueues;
    NSInteger _reloadingSuspendedCount;
    NSInteger _updateAnimationCount;
    NSMutableDictionary *_allVisibleViewsDict;
    NSMutableDictionary *_clonedViewsDict;
    NSIndexPath *_lastSelectionAnchorIndexPath;
    NSIndexPath *_pendingSelectionIndexPath;
    UXCollectionViewMutableIndexPathsSet *_pendingDeselectionIndexPaths;
    UXCollectionViewData *_collectionViewData;
    UXCollectionViewUpdate *_currentUpdate;
    CGRect _visibleBounds;
    CGRect _previousBounds;
    CGPoint _resizeBoundsOffset;
    NSInteger _resizeAnimationCount;
    NSInteger _updateCount;
    NSMutableArray *_insertItems;
    NSMutableArray *_deleteItems;
    NSMutableArray *_reloadItems;
    NSMutableArray *_moveItems;
    NSArray *_originalInsertItems;
    NSArray *_originalDeleteItems;
    void (^_updateCompletionHandler)(BOOL);
    NSMutableDictionary *_cellClassDict;
    NSMutableDictionary *_cellNibDict;
    NSMutableDictionary *_supplementaryViewClassDict;
    NSMutableDictionary *_supplementaryViewNibDict;
    NSMutableSet *_supplementaryElementKinds;
    BOOL _rightMouseSimulated;
    CGSize _minReusedViewSize;
    CGPoint _lastContentOffset;
    NSInteger _layoutTransitionAnimationCount;
    BOOL _liveScrolling;
    BOOL _scrolling;
    BOOL _decelerating;
    BOOL _involvesScrollWheel;
    BOOL _canDetectDeceleration;
    BOOL _scrollingFromExternalControl;
    CGPoint _lastScrollingDistance;
    float _scrollingVelocity;
    CGFloat _lastScrollingTime;
    CGRect _lastPreparedOverdrawContentRect;
    CGPoint _normalizedSavedScrollViewPosition;
    BOOL _isPaintingSelectionRunning;
    BOOL _paintingSelectionType;
    CALayer *_lassoSelectionLayer;
    CGPoint _lassoSelectionStartPoint;
    UXCollectionViewIndexPathsSet *_lassoInitiallySelectedItems;
    UXCollectionViewIndexPathsSet *_keyboardRangeSelectionPreviouslySelectedItems;
    NSIndexPath *_keyboardRangeSelectionFirstSelectedItem;
    NSIndexPath *_keyboardRangeSelectionLastSelectedItem;
    NSMutableDictionary *_doubleClickContext;
    _UXCollectionViewRearrangingCoordinator *_rearrangingCoordinator;
    NSInteger _suspendClipViewBoundsDidChange;
    struct {
        unsigned int delegateWillBeginScrolling : 1;
        unsigned int delegateDidScroll : 1;
        unsigned int delegateDidEndScrolling : 1;
        unsigned int delegateDidEndScrollingAnimation : 1;
        unsigned int delegateWillBeginDeceleratingTargetContentOffset : 1;
        unsigned int delegateDidEndDecelerating : 1;
        unsigned int delegateShouldSelectItemAtIndexPath : 1;
        unsigned int delegateShouldDeselectItemAtIndexPath : 1;
        unsigned int delegateDidSelectItemAtIndexPath : 1;
        unsigned int delegateDidDeselectItemAtIndexPath : 1;
        unsigned int delegateSelectionWillAddAndRemove : 1;
        unsigned int delegateSelectionDidAddAndRemove : 1;
        unsigned int delegateSectionsForSelectAllAction : 1;
        unsigned int delegateMouseDownWithEvent : 1;
        unsigned int delegateItemWasDoubleClickedAtIndexPathWithEvent : 1;
        unsigned int delegateItemWasRightClickedAtIndexPathWithEvent : 1;
        unsigned int delegateWillDisplayCell : 1;
        unsigned int delegateDidEndDisplayingCellForItemAtIndexPath : 1;
        unsigned int delegateDidEndDisplayingSupplementaryViewForElementOfKindAtIndexPath : 1;
        unsigned int delegateDidPrepareForOverdraw : 1;
        unsigned int delegateTargetContentOffsetForProposedContentOffset : 1;
        unsigned int delegateTargetContentOffsetOnResizeForProposedContentOffset : 1;
        unsigned int delegateAllowedDropPositionsForItemsAtIndexPathsMovedToIndexPath : 1;
        unsigned int delegateDragOperationForItemsAtIndexPathsMovedOntoItemAtIndexPath : 1;
        unsigned int dataSourceNumberOfSections : 1;
        unsigned int dataSourceViewForSupplementaryElement : 1;
        unsigned int reloadSkippedDuringSuspension : 1;
        unsigned int scheduledUpdateVisibleCells : 1;
        unsigned int scheduledUpdateVisibleCellLayoutAttributes : 1;
        unsigned int allowsSelection : 1;
        unsigned int allowsMultipleSelection : 1;
        unsigned int fadeCellsForBoundsChange : 1;
        unsigned int updatingLayout : 1;
        unsigned int needsReload : 1;
        unsigned int reloading : 1;
        unsigned int skipLayoutDuringSnapshotting : 1;
        unsigned int skipCellsUpdateDuringResizing : 1;
        unsigned int layoutInvalidatedSinceLastCellUpdate : 1;
        unsigned int doneFirstLayout : 1;
        unsigned int loadingOffscreenViews : 1;
        unsigned int updating : 1;
        unsigned int accessibilityDelegateShouldPrepareAccessibilitySection : 1;
        unsigned int accessibilityDelegateAXRoleDescription : 1;
        unsigned int viewIsPrepared : 1;
        unsigned int performingHitTest : 1;
    } _collectionViewFlags;
    CGPoint _lastLayoutOffset;
    BOOL _rearrangingEnabled;
    BOOL _rearrangingAllowAutoscroll;
    BOOL _rearrangingExternalDropEnabled;
    NSInteger _rearrangingInitiationMode;
    BOOL _rearrangingContinuouslyUpdateInsideCells;
    CGFloat _rearrangingPreviewDelay;
    CGSize _contentSize;
    BOOL _doneFirstLayout;

    // Backing storage for the public selection/reuse properties, declared here
    // (rather than auto-synthesized) so the subsystem category files can read
    // and write them directly.
    BOOL _allowsSelection;
    BOOL _allowsMultipleSelection;
    BOOL _allowsEmptySelection;
    BOOL _allowsContinuousSelection;
    BOOL _allowsLassoSelection;
    BOOL _allowsPaintingSelection;
    BOOL _lassoInvertsSelection;
    NSUInteger _purgingCellsThreshold;
    NSUInteger _extraNumberOfCellsToPreloadWhenScrollingStopped;
}
@end

// Implementation-private helpers shared across the subsystem category files but
// not part of the (Internal) cross-class surface.
@interface UXCollectionView (PrivateSubsystems)

+ (NSString *)_reuseKeyForSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)reuseIdentifier;

- (void)setNeedsLayout;
- (void)_addControlled:(BOOL)controlled subview:(NSView *)subview atZIndex:(NSInteger)zIndex;
- (NSArray *)_doubleSidedAnimationsForView:(UXCollectionReusableView *)view
              withStartingLayoutAttributes:(nullable UXCollectionViewLayoutAttributes *)startAttributes
                            startingLayout:(UXCollectionViewLayout *)startLayout
                    endingLayoutAttributes:(nullable UXCollectionViewLayoutAttributes *)endAttributes
                              endingLayout:(UXCollectionViewLayout *)endLayout
                        withAnimationSetup:(nullable void (^)(void))animationSetup
                       animationCompletion:(nullable void (^)(BOOL))animationCompletion
                    enableCustomAnimations:(BOOL)enableCustomAnimations
                      customAnimationsType:(NSUInteger)customAnimationsType;
- (void)_postSelectionAccessibilityNotification;

@end

NS_ASSUME_NONNULL_END
