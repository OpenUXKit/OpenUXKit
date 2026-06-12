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

NSString *const UXCollectionElementKindCell = @"UXCollectionElementKindCell";

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
}
@end

@implementation UXCollectionView

@dynamic contentSize;
@synthesize lastRightClickedIndexPath = _lastRightClickedIndexPath;
@synthesize scrollingRequest = _scrollingRequest;

#pragma mark - Class methods

+ (Class)documentClass {
    return [UXCollectionDocumentView class];
}

+ (NSString *)_reuseKeyForSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)reuseIdentifier {
    return [NSString stringWithFormat:@"%@/%@", kind, reuseIdentifier];
}

#pragma mark - Init

- (instancetype)initWithFrame:(NSRect)frame collectionViewLayout:(UXCollectionViewLayout *)layout {
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInitWithLayout:layout];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frame {
    return [self initWithFrame:frame collectionViewLayout:[[UXCollectionViewLayout alloc] init]];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self _commonInitWithLayout:[[UXCollectionViewLayout alloc] init]];
    }
    return self;
}

- (void)_commonInitWithLayout:(UXCollectionViewLayout *)layout {
    self.drawsBackground = NO;
    self.hasVerticalScroller = YES;
    self.hasHorizontalScroller = YES;
    self.autohidesScrollers = YES;

    _layout = layout;
    [(id)_layout _setCollectionView:self];

    Class documentClass = [[self class] documentClass];
    _collectionDocumentView = [[documentClass alloc] initWithFrame:self.bounds];
    _collectionDocumentView.collectionView = self;
    _collectionDocumentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.documentView = _collectionDocumentView;

    _indexPathsForSelectedItems = [[UXCollectionViewMutableIndexPathsSet alloc] init];
    _pendingDeselectionIndexPaths = [[UXCollectionViewMutableIndexPathsSet alloc] init];
    _cellReuseQueues = [[NSMutableDictionary alloc] init];
    _supplementaryViewReuseQueues = [[NSMutableDictionary alloc] init];
    _allVisibleViewsDict = [[NSMutableDictionary alloc] init];
    _clonedViewsDict = [[NSMutableDictionary alloc] init];
    _cellClassDict = [[NSMutableDictionary alloc] init];
    _cellNibDict = [[NSMutableDictionary alloc] init];
    _supplementaryViewClassDict = [[NSMutableDictionary alloc] init];
    _supplementaryViewNibDict = [[NSMutableDictionary alloc] init];
    _supplementaryElementKinds = [[NSMutableSet alloc] init];
    _notifiedDisplayedCells = [NSHashTable weakObjectsHashTable];
    _doubleClickContext = [[NSMutableDictionary alloc] init];

    _collectionViewData = [[UXCollectionViewData alloc] initWithCollectionView:self layout:layout];

    _allowsSelection = YES;
    _allowsEmptySelection = YES;
    _purgingCellsThreshold = 30;
    _extraNumberOfCellsToPreloadWhenScrollingStopped = 10;
    _minReusedViewSize = CGSizeMake(1024.0, 1024.0);

    [self _registerForLiveScrollNotifications];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [(id)_layout _setCollectionView:nil];
}

#pragma mark - Notification registration

- (void)_registerForLiveScrollNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(scrollViewWillStartLiveScrollNotification:)
                   name:NSScrollViewWillStartLiveScrollNotification
                 object:self];
    [center addObserver:self
               selector:@selector(scrollViewDidEndLiveScrollNotification:)
                   name:NSScrollViewDidEndLiveScrollNotification
                 object:self];
}

#pragma mark - Properties

- (void)setDataSource:(id<UXCollectionViewDataSource>)dataSource {
    if (dataSource && dataSource == self.dataSource) {
        return;
    }
    _dataSource = dataSource;
    _collectionViewFlags.dataSourceNumberOfSections = [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)];
    _collectionViewFlags.dataSourceViewForSupplementaryElement = [dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)];
    _collectionViewFlags.needsReload = YES;
    [self _invalidateLayoutIfNecessary];
}

- (void)setDelegate:(id<UXCollectionViewDelegate>)delegate {
    _delegate = delegate;
    _collectionViewFlags.delegateWillBeginScrolling = [delegate respondsToSelector:@selector(collectionViewWillBeginScrolling:)];
    _collectionViewFlags.delegateDidScroll = [delegate respondsToSelector:@selector(collectionViewDidScroll:)];
    _collectionViewFlags.delegateDidEndScrolling = [delegate respondsToSelector:@selector(collectionViewDidEndScrolling:)];
    _collectionViewFlags.delegateDidEndScrollingAnimation = [delegate respondsToSelector:@selector(collectionViewDidEndScrollingAnimation:)];
    _collectionViewFlags.delegateWillBeginDeceleratingTargetContentOffset = [delegate respondsToSelector:@selector(collectionViewWillBeginDecelerating:targetContentOffset:)];
    _collectionViewFlags.delegateDidEndDecelerating = [delegate respondsToSelector:@selector(collectionViewDidEndDecelerating:)];
    _collectionViewFlags.delegateShouldSelectItemAtIndexPath = [delegate respondsToSelector:@selector(collectionView:shouldSelectItemAtIndexPath:)];
    _collectionViewFlags.delegateShouldDeselectItemAtIndexPath = [delegate respondsToSelector:@selector(collectionView:shouldDeselectItemAtIndexPath:)];
    _collectionViewFlags.delegateDidSelectItemAtIndexPath = [delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)];
    _collectionViewFlags.delegateDidDeselectItemAtIndexPath = [delegate respondsToSelector:@selector(collectionView:didDeselectItemAtIndexPath:)];
    _collectionViewFlags.delegateSelectionWillAddAndRemove = [delegate respondsToSelector:@selector(collectionView:indexPathsForSelectedItemsWillAdd:remove:animated:)];
    _collectionViewFlags.delegateSelectionDidAddAndRemove = [delegate respondsToSelector:@selector(collectionView:indexPathsForSelectedItemsDidAdd:remove:animated:)];
    _collectionViewFlags.delegateSectionsForSelectAllAction = [delegate respondsToSelector:NSSelectorFromString(@"sectionsForSelectAllActionInCollectionView:")];
    _collectionViewFlags.delegateMouseDownWithEvent = [delegate respondsToSelector:@selector(collectionView:mouseDownWithEvent:)];
    _collectionViewFlags.delegateItemWasDoubleClickedAtIndexPathWithEvent = [delegate respondsToSelector:@selector(collectionView:itemWasDoubleClickedAtIndexPath:withEvent:)];
    _collectionViewFlags.delegateItemWasRightClickedAtIndexPathWithEvent = [delegate respondsToSelector:@selector(collectionView:itemWasRightClickedAtIndexPath:withEvent:)];
    _collectionViewFlags.delegateWillDisplayCell = [delegate respondsToSelector:@selector(collectionView:willDisplayCell:forItemAtIndexPath:)];
    _collectionViewFlags.delegateDidEndDisplayingCellForItemAtIndexPath = [delegate respondsToSelector:@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)];
    _collectionViewFlags.delegateDidEndDisplayingSupplementaryViewForElementOfKindAtIndexPath = [delegate respondsToSelector:@selector(collectionView:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:)];
    _collectionViewFlags.delegateDidPrepareForOverdraw = [delegate respondsToSelector:@selector(collectionView:didPrepareForOverdraw:)];
    _collectionViewFlags.delegateTargetContentOffsetForProposedContentOffset = [delegate respondsToSelector:NSSelectorFromString(@"_collectionView:targetContentOffsetForProposedContentOffset:")];
    _collectionViewFlags.delegateTargetContentOffsetOnResizeForProposedContentOffset = [delegate respondsToSelector:@selector(collectionView:targetContentOffsetOnResizeForProposedContentOffset:)];
    _collectionViewFlags.delegateAllowedDropPositionsForItemsAtIndexPathsMovedToIndexPath = [delegate respondsToSelector:NSSelectorFromString(@"collectionView:allowedDropPositionsForItemsAtIndexPaths:movedToIndexPath:")];
    _collectionViewFlags.delegateDragOperationForItemsAtIndexPathsMovedOntoItemAtIndexPath = [delegate respondsToSelector:NSSelectorFromString(@"collectionView:dragOperationForItemsAtIndexPaths:movedOntoItemAtIndexPath:")];
}

- (void)setAccessibilityDelegate:(id<UXCollectionViewAccessibilityDelegate>)accessibilityDelegate {
    _accessibilityDelegate = accessibilityDelegate;
    _collectionViewFlags.accessibilityDelegateShouldPrepareAccessibilitySection = [accessibilityDelegate respondsToSelector:@selector(collectionView:prepareAccessibilitySection:)];
    _collectionViewFlags.accessibilityDelegateAXRoleDescription = [accessibilityDelegate respondsToSelector:@selector(accessibilityRoleDescriptionForCollectionView:)];
}

- (BOOL)_dataSourceImplementsNumberOfSections {
    return _collectionViewFlags.dataSourceNumberOfSections;
}

- (UXCollectionViewData *)_collectionViewData {
    return _collectionViewData;
}

- (NSDictionary *)_visibleViewsDict {
    return _allVisibleViewsDict;
}

- (NSSet<NSString *> *)_supplementaryElementKinds {
    return _supplementaryElementKinds;
}

- (UXCollectionViewUpdate *)_currentUpdate {
    return _currentUpdate;
}

- (BOOL)isOpaque {
    return YES;
}

- (BOOL)wantsUpdateLayer {
    return YES;
}

- (BOOL)isScrolling {
    return _scrolling;
}

- (BOOL)isDecelerating {
    return _decelerating;
}

- (BOOL)isLassoSelectionInProgress {
    return _lassoSelectionLayer != nil;
}

#pragma mark - Layout

- (UXCollectionViewLayout *)collectionViewLayout {
    return _layout;
}

- (void)setCollectionViewLayout:(UXCollectionViewLayout *)layout {
    NSAssert(layout != nil, @"layout cannot be nil in setCollectionViewLayout:");
    [self setCollectionViewLayout:layout animated:NO completion:nil];
}

- (void)setCollectionViewLayout:(UXCollectionViewLayout *)layout animated:(BOOL)animated {
    [self setCollectionViewLayout:layout animated:animated completion:nil];
}

- (void)setCollectionViewLayout:(UXCollectionViewLayout *)layout animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    [self _setCollectionViewLayout:layout animated:animated isInteractive:NO completion:completion];
}

- (void)_setCollectionViewLayout:(UXCollectionViewLayout *)layout animated:(BOOL)animated isInteractive:(BOOL)isInteractive completion:(void (^)(BOOL))completion {
    if (_layout == layout) {
        if (completion) {
            completion(YES);
        }
        return;
    }

    // Invalidate the incoming layout before it goes live so its first prepare
    // pass rebuilds from the data source.
    UXCollectionViewLayoutInvalidationContext *invalidationContext = [[[[layout class] invalidationContextClass] alloc] init];
    [invalidationContext _setInvalidateEverything:YES];
    [invalidationContext _setInvalidateDataSourceCounts:YES];
    [layout _invalidateLayoutUsingContext:invalidationContext];

    // The animated cross-layout transition (UXKit's _prepareForTransitionToLayout:
    // / _animateView: anchor-tracking path) is not yet ported; until then every
    // request takes the non-animated swap, which UXKit itself uses whenever the
    // view is offscreen or has not completed its first layout.
    [layout _setCollectionView:self];
    [(id)_layout _setCollectionView:nil];
    _layout = layout;
    _collectionViewData = [[UXCollectionViewData alloc] initWithCollectionView:self layout:layout];
    [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:YES];
    if (completion) {
        completion(YES);
    }
}

- (void)updateLayout {
    @autoreleasepool {
        [self _updateVisibleCellsNow:YES];
    }
}

- (void)_invalidateLayoutWithContext:(UXCollectionViewLayoutInvalidationContext *)context {
    _minReusedViewSize = CGSizeMake(1024.0, 1024.0);
    if ([NSAnimationContext respondsToSelector:@selector(_hasActiveGrouping)]) {
        _collectionViewFlags.fadeCellsForBoundsChange = [NSAnimationContext _hasActiveGrouping];
    }
    NSDictionary *invalidatedSupplementaryViews = [context _invalidatedSupplementaryViews];
    if (invalidatedSupplementaryViews && !context.invalidateContentSize) {
        [_collectionViewData invalidateSupplementaryViews:invalidatedSupplementaryViews];
    } else {
        [_collectionViewData invalidate:!context.invalidateEverything];
    }
    _collectionViewFlags.layoutInvalidatedSinceLastCellUpdate = YES;
    [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:YES];
}

- (void)_invalidateLayoutIfNecessary {
    if ([_collectionViewData layoutIsPrepared]) {
        UXCollectionViewLayoutInvalidationContext *context = [[[[_layout class] invalidationContextClass] alloc] init];
        [context _setInvalidateDataSourceCounts:YES];
        [context _setInvalidateEverything:YES];
        [_layout _invalidateLayoutUsingContext:context];
    }
}

- (void)_setNeedsVisibleCellsUpdate:(BOOL)needsUpdate withLayoutAttributes:(BOOL)withAttributes {
    if (needsUpdate) {
        _collectionViewFlags.scheduledUpdateVisibleCells = YES;
    }
    if (withAttributes) {
        _collectionViewFlags.scheduledUpdateVisibleCellLayoutAttributes = YES;
    }
    if (_collectionViewFlags.scheduledUpdateVisibleCells || _collectionViewFlags.scheduledUpdateVisibleCellLayoutAttributes) {
        [self setNeedsLayout];
    }
}

#pragma mark - Counts

- (NSInteger)numberOfSections {
    return [_collectionViewData numberOfSections];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return [_collectionViewData numberOfItemsInSection:section];
}

- (NSUInteger)numberOfVisibleCells {
    NSUInteger count = 0;
    for (id view in _allVisibleViewsDict.objectEnumerator) {
        if ([view isKindOfClass:[UXCollectionViewCell class]]) {
            count++;
        }
    }
    return count;
}

- (NSUInteger)numberOfContentCells {
    return [self numberOfVisibleCells];
}

- (BOOL)_hasAnyItems {
    NSInteger sectionCount = [self numberOfSections];
    for (NSInteger section = 0; section < sectionCount; section++) {
        if ([self numberOfItemsInSection:section] > 0) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Cell / supplementary view registration

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    NSParameterAssert(identifier);
    if (cellClass) {
        _cellClassDict[identifier] = cellClass;
        [_cellNibDict removeObjectForKey:identifier];
    } else {
        [_cellClassDict removeObjectForKey:identifier];
    }
}

- (void)registerNib:(NSNib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    NSParameterAssert(identifier);
    if (nib) {
        _cellNibDict[identifier] = nib;
        [_cellClassDict removeObjectForKey:identifier];
    } else {
        [_cellNibDict removeObjectForKey:identifier];
    }
}

- (Class)registeredClassForCellWithReuseIdentifier:(NSString *)identifier {
    return _cellClassDict[identifier];
}

- (void)registerClass:(Class)viewClass forSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier {
    NSParameterAssert(identifier);
    NSParameterAssert(elementKind);
    NSString *key = [[self class] _reuseKeyForSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
    if (viewClass) {
        _supplementaryViewClassDict[key] = viewClass;
        [_supplementaryViewNibDict removeObjectForKey:key];
    } else {
        [_supplementaryViewClassDict removeObjectForKey:key];
    }
    [_supplementaryElementKinds addObject:elementKind];
}

- (void)registerNib:(NSNib *)nib forSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier {
    NSParameterAssert(identifier);
    NSParameterAssert(elementKind);
    NSString *key = [[self class] _reuseKeyForSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
    if (nib) {
        _supplementaryViewNibDict[key] = nib;
        [_supplementaryViewClassDict removeObjectForKey:key];
    } else {
        [_supplementaryViewNibDict removeObjectForKey:key];
    }
    [_supplementaryElementKinds addObject:elementKind];
}

- (Class)registeredClassForSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier {
    NSString *key = [[self class] _reuseKeyForSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
    return _supplementaryViewClassDict[key];
}

#pragma mark - Dequeue

- (__kindof UXCollectionReusableView *)_dequeueReusableViewOfKind:(NSString *)kind withIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath viewCategory:(NSUInteger)viewCategory {
    NSMutableDictionary *reuseQueues = (viewCategory == 1) ? _cellReuseQueues : _supplementaryViewReuseQueues;
    NSString *reuseKey = (viewCategory == 1) ? identifier : [[self class] _reuseKeyForSupplementaryViewOfKind:kind withReuseIdentifier:identifier];

    // UXKit keeps recycled views in per-identifier NSMutableSets; any member is
    // an equally valid candidate, so dequeue pulls anyObject.
    NSMutableSet *queue = reuseQueues[reuseKey];
    UXCollectionReusableView *view = nil;
    if (queue.count > 0) {
        view = [queue anyObject];
        [queue removeObject:view];
    }

    if (!view) {
        NSDictionary *classDict = (viewCategory == 1) ? _cellClassDict : _supplementaryViewClassDict;
        NSDictionary *nibDict = (viewCategory == 1) ? _cellNibDict : _supplementaryViewNibDict;
        NSString *lookupKey = (viewCategory == 1) ? identifier : reuseKey;

        Class viewClass = classDict[lookupKey];
        NSNib *nib = nibDict[lookupKey];

        if (nib) {
            NSArray *objects = nil;
            if ([nib instantiateWithOwner:self topLevelObjects:&objects]) {
                for (id object in objects) {
                    if ([object isKindOfClass:[UXCollectionReusableView class]]) {
                        view = object;
                        break;
                    }
                }
            }
        } else if (viewClass) {
            view = [[viewClass alloc] initWithFrame:CGRectZero];
        }
    }

    if (view) {
        [(id)view _setReuseIdentifier:identifier];
        [(id)view _setCollectionView:self];
        [(id)view _markAsDequeued];
        [view prepareForReuse];
    }
    return view;
}

- (__kindof UXCollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    NSAssert(identifier.length > 0, @"must pass a valid reuse identifier to -[UXCollectionView %@]", NSStringFromSelector(_cmd));
    return [self _dequeueReusableViewOfKind:UXCollectionElementKindCell withIdentifier:identifier forIndexPath:indexPath viewCategory:1];
}

- (__kindof UXCollectionReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    NSAssert(identifier.length > 0, @"must pass a valid reuse identifier to -[UXCollectionView %@]", NSStringFromSelector(_cmd));
    return [self _dequeueReusableViewOfKind:kind withIdentifier:identifier forIndexPath:indexPath viewCategory:2];
}

- (NSInteger)_reuseQueueCapacityForViewSize:(CGSize)viewSize {
    // Shrink the running minimum reused-view size, then cap the recycle pool by
    // how many such views could possibly cover eight screens (UXKit's
    // _maxNumberOfReusedViews heuristic). A larger pool is allowed for smaller
    // cells; a single huge cell keeps the pool tiny.
    _minReusedViewSize.width = MIN(_minReusedViewSize.width, viewSize.width);
    _minReusedViewSize.height = MIN(_minReusedViewSize.height, viewSize.height);
    CGSize frameSize = self.frame.size;
    return (NSInteger)(ceil(frameSize.width * frameSize.height * 8.0 / fmax(_minReusedViewSize.width * _minReusedViewSize.height, 1.0)) + 1.0);
}

- (void)_recycleView:(UXCollectionReusableView *)view intoQueue:(NSMutableSet *)queue registeredClass:(Class)registeredClass {
    NSInteger capacity = [self _reuseQueueCapacityForViewSize:view.frame.size];
    if ((NSInteger)queue.count < capacity && ![queue containsObject:view] && [view class] == registeredClass) {
        // UXKit parks recycled views as hidden subviews rather than removing
        // them, avoiding add/remove churn on the next dequeue.
        [queue addObject:view];
        view.hidden = YES;
        [(id)view _setLayoutAttributes:nil];
    } else {
        [view removeFromSuperview];
    }
}

- (void)_reuseCell:(UXCollectionViewCell *)cell {
    if (!cell) {
        return;
    }
    NSString *identifier = cell.reuseIdentifier;
    NSMutableSet *queue = _cellReuseQueues[identifier];
    if (!queue) {
        queue = [NSMutableSet set];
        if (identifier) {
            _cellReuseQueues[identifier] = queue;
        }
    }
    [self _recycleView:cell intoQueue:queue registeredClass:_cellClassDict[identifier]];
    [self _notifyDidEndDisplayingCellIfNeeded:cell forIndexPath:[[(id)cell _layoutAttributes] indexPath]];
}

- (void)_reuseSupplementaryView:(UXCollectionReusableView *)view {
    if (!view) {
        return;
    }
    NSString *identifier = view.reuseIdentifier;
    UXCollectionViewLayoutAttributes *attributes = [(id)view _layoutAttributes];
    NSString *elementKind = [attributes _elementKind];
    NSString *key = (elementKind && identifier) ? [[self class] _reuseKeyForSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier] : nil;
    NSMutableSet *queue = key ? _supplementaryViewReuseQueues[key] : nil;
    if (key && !queue) {
        queue = [NSMutableSet set];
        _supplementaryViewReuseQueues[key] = queue;
    }
    if (queue) {
        [self _recycleView:view intoQueue:queue registeredClass:_supplementaryViewClassDict[key]];
    } else {
        [view removeFromSuperview];
    }
    if (_collectionViewFlags.delegateDidEndDisplayingSupplementaryViewForElementOfKindAtIndexPath && elementKind) {
        [self.delegate collectionView:self didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:attributes.indexPath];
    }
}

- (NSInteger)_numberOfReusedViewsForIdentifier:(NSString *)identifier {
    return (NSInteger)[_cellReuseQueues[identifier] count];
}

- (NSInteger)_maxNumberOfReusedViews {
    CGSize frameSize = self.frame.size;
    return (NSInteger)(ceil(frameSize.width * frameSize.height * 8.0 / fmax(_minReusedViewSize.width * _minReusedViewSize.height, 1.0)) + 1.0);
}

#pragma mark - Cell preparation pipeline

- (__kindof UXCollectionViewCell *)_createPreparedCellForItemAtIndexPath:(NSIndexPath *)indexPath withLayoutAttributes:(UXCollectionViewLayoutAttributes *)layoutAttributes applyAttributes:(BOOL)applyAttributes {
    if (![self.dataSource respondsToSelector:@selector(collectionView:cellForItemAtIndexPath:)]) {
        return nil;
    }
    UXCollectionViewCell *cell = [self.dataSource collectionView:self cellForItemAtIndexPath:indexPath];
    if (!cell) {
        return nil;
    }
    [(id)cell _setCollectionView:self];
    if (applyAttributes && layoutAttributes) {
        [(id)cell _setLayoutAttributes:layoutAttributes];
    }
    if ([_indexPathsForSelectedItems containsIndexPath:indexPath]) {
        cell.selected = YES;
    } else {
        cell.selected = NO;
    }
    [self _notifyWillDisplayCellIfNeeded:cell forIndexPath:indexPath];
    return cell;
}

- (__kindof UXCollectionReusableView *)_createPreparedSupplementaryViewForElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath withLayoutAttributes:(UXCollectionViewLayoutAttributes *)layoutAttributes applyAttributes:(BOOL)applyAttributes {
    if (![self.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
        return nil;
    }
    UXCollectionReusableView *view = [self.dataSource collectionView:self viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    if (!view) {
        return nil;
    }
    [(id)view _setCollectionView:self];
    if (applyAttributes && layoutAttributes) {
        [(id)view _setLayoutAttributes:layoutAttributes];
    }
    return view;
}

- (void)_notifyWillDisplayCellIfNeeded:(UXCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    if (!cell || [_notifiedDisplayedCells containsObject:cell]) {
        return;
    }
    [_notifiedDisplayedCells addObject:cell];
    id<UXCollectionViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(collectionView:willDisplayCell:forItemAtIndexPath:)]) {
        [delegate collectionView:self willDisplayCell:cell forItemAtIndexPath:indexPath];
    }
}

- (void)_notifyDidEndDisplayingCellIfNeeded:(UXCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    if (!cell || ![_notifiedDisplayedCells containsObject:cell]) {
        return;
    }
    [_notifiedDisplayedCells removeObject:cell];
    id<UXCollectionViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)]) {
        [delegate collectionView:self didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    }
}

- (void)_updateCellsInRect:(CGRect)rect createIfNecessary:(BOOL)createIfNecessary {
    if (_reloadingSuspendedCount > 0 || _updateAnimationCount > 0) {
        return;
    }
    if (_collectionViewFlags.updatingLayout || _collectionViewFlags.skipCellsUpdateDuringResizing) {
        return;
    }

    if ([NSAnimationContext respondsToSelector:@selector(_hasActiveGrouping)] && [NSAnimationContext _hasActiveGrouping]) {
        if (_collectionViewFlags.layoutInvalidatedSinceLastCellUpdate) {
            _collectionViewFlags.fadeCellsForBoundsChange = YES;
        }
    }
    [self _suspendReloads];

    if (_collectionViewFlags.fadeCellsForBoundsChange) {
        [_layout prepareForAnimatedBoundsChange:_previousBounds];
        CGPoint targetContentOffset = [_layout targetContentOffsetForProposedContentOffset:[self contentOffset]];
        if (_collectionViewFlags.delegateTargetContentOffsetForProposedContentOffset) {
            targetContentOffset = [(id)self.delegate _collectionView:self targetContentOffsetForProposedContentOffset:targetContentOffset];
        }
        if (!CGPointEqualToPoint(_lastContentOffset, targetContentOffset)) {
            _lastContentOffset = targetContentOffset;
            [self.contentView setBoundsOrigin:targetContentOffset];
            rect = [self _visibleBounds];
        }
    }

    NSArray<UXCollectionViewLayoutAttributes *> *attributesList = [_collectionViewData layoutAttributesForElementsInRect:rect];
    if (![self inLiveResize] && !_scrolling
        && [self extraNumberOfCellsToPreloadWhenScrollingStopped] > 0 && attributesList.count > 0) {
        CGFloat preloadRatio = (CGFloat)[self extraNumberOfCellsToPreloadWhenScrollingStopped] / (CGFloat)attributesList.count;
        rect = CGRectInset(rect, -(rect.size.width * preloadRatio), -(rect.size.height * preloadRatio));
        attributesList = [_collectionViewData layoutAttributesForElementsInRect:rect];
    }

    BOOL fadeCells = _collectionViewFlags.fadeCellsForBoundsChange;
    if (createIfNecessary) {
        _collectionViewFlags.scheduledUpdateVisibleCells = NO;
        _collectionViewFlags.fadeCellsForBoundsChange = NO;
    }
    [self setContentSize:[_collectionViewData collectionViewContentRect].size];

    if (fadeCells) {
        NSMutableArray<UXCollectionViewLayoutAttributes *> *previousAttributesList = [[NSMutableArray alloc] init];
        for (UXCollectionReusableView *view in _allVisibleViewsDict.allValues) {
            UXCollectionViewLayoutAttributes *attributesCopy = [[(id)view _layoutAttributes] copy];
            if (attributesCopy) {
                [previousAttributesList addObject:attributesCopy];
            }
        }
        [previousAttributesList sortUsingComparator:^NSComparisonResult(UXCollectionViewLayoutAttributes *first, UXCollectionViewLayoutAttributes *second) {
            if (first.zIndex < second.zIndex) {
                return NSOrderedAscending;
            }
            if (first.zIndex > second.zIndex) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        NSArray *upcomingAttributesList = [[NSArray alloc] initWithArray:attributesList copyItems:YES];
        [_layout _prepareToAnimateFromCollectionViewItems:previousAttributesList
                                          atContentOffset:_lastContentOffset
                                                  toItems:upcomingAttributesList
                                          atContentOffset:[self contentOffset]];
    }

    void (^resizeAnimationSetup)(void) = ^{
        self->_resizeAnimationCount++;
    };
    void (^resizeAnimationCompletion)(BOOL) = ^(BOOL finished) {
        self->_resizeAnimationCount--;
        if (self->_resizeAnimationCount == 0) {
            self->_resizeBoundsOffset = CGPointZero;
            [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:YES];
            self->_lastLayoutOffset = [self contentOffset];
        }
    };

    NSMutableDictionary *leftoverViewsDict = [_allVisibleViewsDict mutableCopy];
    NSMutableArray<UXCollectionViewLayoutAttributes *> *missingAttributesList = [[NSMutableArray alloc] init];
    NSMutableArray<UXCollectionReusableView *> *existingViews = [[NSMutableArray alloc] init];
    for (UXCollectionViewLayoutAttributes *attributes in attributesList) {
        _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:attributes];
        UXCollectionReusableView *view = _allVisibleViewsDict[key];
        if (view) {
            [existingViews addObject:view];
            [leftoverViewsDict removeObjectForKey:key];
        } else {
            [missingAttributesList addObject:attributes];
        }
    }

    if (![self inLiveResize]) {
        NSUInteger totalViewCount = existingViews.count + leftoverViewsDict.count + missingAttributesList.count;
        if (totalViewCount < [self purgingCellsThreshold]) {
            [existingViews addObjectsFromArray:leftoverViewsDict.allValues];
            leftoverViewsDict = nil;
        }
    }

    [leftoverViewsDict enumerateKeysAndObjectsUsingBlock:^(_UXCollectionViewItemKey *key, UXCollectionReusableView *view, BOOL *stop) {
        if ([view _isInUpdateAnimation]) {
            return;
        }
        [self->_allVisibleViewsDict removeObjectForKey:key];
        void (^recycleView)(void) = ^{
            if (key.type == UXCollectionViewItemTypeCell) {
                [self _reuseCell:(UXCollectionViewCell *)view];
            } else {
                [self _reuseSupplementaryView:view];
            }
        };
        if (!fadeCells) {
            recycleView();
            return;
        }
        UXCollectionViewLayoutAttributes *finalAttributes = nil;
        switch (key.type) {
            case UXCollectionViewItemTypeCell:
                finalAttributes = [self->_layout finalLayoutAttributesForDisappearingItemAtIndexPath:key.indexPath];
                break;
            case UXCollectionViewItemTypeSupplementaryView:
                finalAttributes = [self->_layout finalLayoutAttributesForDisappearingSupplementaryElementOfKind:key.identifier atIndexPath:key.indexPath];
                break;
            case UXCollectionViewItemTypeDecorationView:
                finalAttributes = [self->_layout finalLayoutAttributesForDisappearingDecorationElementOfKind:key.identifier atIndexPath:key.indexPath];
                break;
        }
        if (!finalAttributes) {
            finalAttributes = [[(id)view _layoutAttributes] copy];
            finalAttributes.alpha = 0.0;
        }
        resizeAnimationSetup();
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [(id)view _setLayoutAttributes:finalAttributes];
        } completionHandler:^{
            recycleView();
            resizeAnimationCompletion(YES);
        }];
    }];

    if (createIfNecessary) {
        for (UXCollectionViewLayoutAttributes *attributes in missingAttributesList) {
            _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:attributes];
            if (fadeCells) {
                UXCollectionViewLayoutAttributes *initialAttributes = nil;
                if ([attributes _isCell]) {
                    initialAttributes = [_layout initialLayoutAttributesForAppearingItemAtIndexPath:key.indexPath];
                } else if ([attributes _isDecorationView]) {
                    initialAttributes = [_layout initialLayoutAttributesForAppearingDecorationElementOfKind:key.identifier atIndexPath:key.indexPath];
                } else {
                    initialAttributes = [_layout initialLayoutAttributesForAppearingSupplementaryElementOfKind:key.identifier atIndexPath:key.indexPath];
                }
                if (!initialAttributes) {
                    initialAttributes = [attributes copy];
                    initialAttributes.alpha = 0.0;
                }
                if (initialAttributes.isHidden && attributes.isHidden) {
                    continue;
                }
                UXCollectionReusableView *view = [attributes _isCell]
                    ? [self _createPreparedCellForItemAtIndexPath:key.indexPath withLayoutAttributes:initialAttributes applyAttributes:YES]
                    : [self _createPreparedSupplementaryViewForElementOfKind:key.identifier atIndexPath:key.indexPath withLayoutAttributes:initialAttributes applyAttributes:YES];
                if (!view) {
                    continue;
                }
                resizeAnimationSetup();
                [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
                    [(id)view _setLayoutAttributes:attributes];
                } completionHandler:^{
                    resizeAnimationCompletion(YES);
                }];
                _allVisibleViewsDict[key] = view;
            } else {
                if (attributes.isHidden) {
                    continue;
                }
                UXCollectionReusableView *view = [attributes _isCell]
                    ? [self _createPreparedCellForItemAtIndexPath:key.indexPath withLayoutAttributes:attributes applyAttributes:NO]
                    : [self _createPreparedSupplementaryViewForElementOfKind:key.identifier atIndexPath:key.indexPath withLayoutAttributes:attributes applyAttributes:NO];
                if (!view) {
                    continue;
                }
                [self performWithoutAnimation:^{
                    [(id)view _setLayoutAttributes:attributes];
                    [self _addControlled:!attributes.isFloating subview:view atZIndex:[(id)view _layoutAttributes].zIndex];
                }];
                _allVisibleViewsDict[key] = view;
            }
        }
    }

    if (!_collectionViewFlags.reloadSkippedDuringSuspension) {
        _visibleBounds = [self documentVisibleRect];
        if (_collectionViewFlags.scheduledUpdateVisibleCellLayoutAttributes) {
            for (UXCollectionReusableView *view in existingViews) {
                _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:[(id)view _layoutAttributes]];
                UXCollectionViewLayoutAttributes *currentAttributes = [(id)_allVisibleViewsDict[key] _layoutAttributes];
                UXCollectionViewLayoutAttributes *newAttributes = nil;
                switch (key.type) {
                    case UXCollectionViewItemTypeCell:
                        newAttributes = [_collectionViewData layoutAttributesForItemAtIndexPath:key.indexPath];
                        break;
                    case UXCollectionViewItemTypeSupplementaryView:
                        newAttributes = [_collectionViewData layoutAttributesForSupplementaryElementOfKind:key.identifier atIndexPath:key.indexPath];
                        break;
                    case UXCollectionViewItemTypeDecorationView:
                        newAttributes = [_collectionViewData layoutAttributesForDecorationViewOfKind:key.identifier atIndexPath:key.indexPath];
                        break;
                }
                if (!fadeCells || currentAttributes.isFloating || newAttributes.isFloating) {
                    if (newAttributes.isHidden) {
                        [_allVisibleViewsDict removeObjectForKey:key];
                        if ([view _isInUpdateAnimation]) {
                            _allVisibleViewsDict[key] = view;
                        } else if ([newAttributes _isCell]) {
                            [self _reuseCell:(UXCollectionViewCell *)view];
                        } else {
                            [self _reuseSupplementaryView:view];
                        }
                    } else {
                        [self performWithoutAnimation:^{
                            [(id)view _setLayoutAttributes:newAttributes];
                            [self _addControlled:!newAttributes.isFloating subview:view atZIndex:newAttributes.zIndex];
                        }];
                    }
                } else {
                    if (newAttributes.isFloating != [(id)view isFloatingPinned]
                        || (![(id)view isFloatingPinned] && newAttributes.zIndex != [(id)view _layoutAttributes].zIndex)) {
                        [(id)view _setLayoutAttributes:[currentAttributes copy]];
                        [self _addControlled:YES subview:view atZIndex:newAttributes.zIndex];
                    }
                    NSArray *resizeAnimations = [self _doubleSidedAnimationsForView:view
                                                       withStartingLayoutAttributes:currentAttributes
                                                                     startingLayout:_layout
                                                             endingLayoutAttributes:newAttributes
                                                                       endingLayout:_layout
                                                                 withAnimationSetup:resizeAnimationSetup
                                                                animationCompletion:resizeAnimationCompletion
                                                             enableCustomAnimations:NO
                                                               customAnimationsType:0];
                    for (UXCollectionViewAnimation *animation in resizeAnimations) {
                        [animation start];
                    }
                }
            }
        }
        if (fadeCells) {
            [_layout _finalizeCollectionViewItemAnimations];
            [_layout finalizeAnimatedBoundsChange];
        }
        _collectionViewFlags.scheduledUpdateVisibleCellLayoutAttributes = NO;
    }

    _lastLayoutOffset = [self contentOffset];
    _collectionViewFlags.layoutInvalidatedSinceLastCellUpdate = NO;
    [self _resumeReloads];
}

- (void)_updateVisibleCellsNow:(BOOL)now {
    [self _updateCellsInRect:[self documentVisibleRect] createIfNecessary:now];
}

#pragma mark - Visible cells

- (NSArray<__kindof UXCollectionViewCell *> *)visibleCells {
    NSMutableArray *cells = [NSMutableArray array];
    for (id view in _allVisibleViewsDict.objectEnumerator) {
        if ([view isKindOfClass:[UXCollectionViewCell class]]) {
            [cells addObject:view];
        }
    }
    return cells;
}

- (NSArray<__kindof UXCollectionViewCell *> *)contentCells {
    return [self visibleCells];
}

- (NSArray<__kindof UXCollectionReusableView *> *)visibleSupplementaryViews {
    NSMutableArray *views = [NSMutableArray array];
    for (id view in _allVisibleViewsDict.objectEnumerator) {
        if ([view isKindOfClass:[UXCollectionReusableView class]] && ![view isKindOfClass:[UXCollectionViewCell class]]) {
            [views addObject:view];
        }
    }
    return views;
}

- (NSArray<__kindof UXCollectionReusableView *> *)contentSupplementaryViews {
    return [self visibleSupplementaryViews];
}

- (NSArray<__kindof UXCollectionReusableView *> *)visibleSupplementaryViewsOfKind:(NSString *)kind {
    return [self _visibleSupplementaryViewsOfKind:kind];
}

- (NSArray<__kindof UXCollectionReusableView *> *)_visibleSupplementaryViewsOfKind:(NSString *)kind {
    NSMutableArray *views = [NSMutableArray array];
    for (id view in _allVisibleViewsDict.objectEnumerator) {
        if (![view isKindOfClass:[UXCollectionReusableView class]] || [view isKindOfClass:[UXCollectionViewCell class]]) {
            continue;
        }
        UXCollectionViewLayoutAttributes *attributes = [(id)view _layoutAttributes];
        if ([[attributes _elementKind] isEqualToString:kind]) {
            [views addObject:view];
        }
    }
    return views;
}

- (NSArray<__kindof UXCollectionReusableView *> *)_supplementaryViewsIncludingOverdrawArea:(BOOL)overdrawArea identifier:(NSString *)identifier {
    return [self _visibleSupplementaryViewsOfKind:identifier];
}

- (void)_enumerateSupplementaryViewsIncludingOverdrawArea:(BOOL)overdrawArea identifier:(NSString *)identifier usingBlock:(void (^)(UXCollectionReusableView *view, BOOL *stop))block {
    BOOL stop = NO;
    NSArray<UXCollectionReusableView *> *views = [self _supplementaryViewsIncludingOverdrawArea:overdrawArea identifier:identifier];
    for (UXCollectionReusableView *view in views) {
        block(view, &stop);
        if (stop) {
            return;
        }
    }
}

- (NSArray<__kindof UXCollectionViewCell *> *)_cellsIncludingOverdrawArea:(BOOL)overdrawArea {
    return [self visibleCells];
}

- (NSDictionary<NSIndexPath *, __kindof UXCollectionViewCell *> *)_dictionaryOfIndexPathsAndContentCells {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [_allVisibleViewsDict enumerateKeysAndObjectsUsingBlock:^(_UXCollectionViewItemKey *key, id view, BOOL *stop) {
        if ([view isKindOfClass:[UXCollectionViewCell class]] && [key type] == UXCollectionViewItemTypeCell) {
            result[[key indexPath]] = view;
        }
    }];
    return result;
}

- (NSArray<NSIndexPath *> *)indexPathsForVisibleItems {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (_UXCollectionViewItemKey *key in _allVisibleViewsDict.keyEnumerator) {
        if ([key type] == UXCollectionViewItemTypeCell) {
            [indexPaths addObject:[key indexPath]];
        }
    }
    return indexPaths;
}

- (NSArray<NSIndexPath *> *)indexPathsForContentItems {
    return [self indexPathsForVisibleItems];
}

- (NSArray<NSIndexPath *> *)indexPathsForVisibleItemsInSections:(NSIndexSet *)sections {
    NSMutableArray *result = [NSMutableArray array];
    for (NSIndexPath *indexPath in [self indexPathsForVisibleItems]) {
        if ([sections containsIndex:(NSUInteger)indexPath.section]) {
            [result addObject:indexPath];
        }
    }
    return result;
}

- (NSArray<NSIndexPath *> *)indexPathsForContentItemsInSections:(NSIndexSet *)sections {
    return [self indexPathsForVisibleItemsInSections:sections];
}

- (NSArray<NSIndexPath *> *)_indexPathsForItemsInSections:(NSIndexSet *)sections includingOverdrawArea:(BOOL)overdrawArea {
    return [self indexPathsForVisibleItemsInSections:sections];
}

- (NSArray<NSIndexPath *> *)indexPathsForVisibleSupplementaryElementsOfKind:(NSString *)kind {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (_UXCollectionViewItemKey *key in _allVisibleViewsDict.keyEnumerator) {
        if ([key type] != UXCollectionViewItemTypeSupplementaryView) {
            continue;
        }
        if ([[key identifier] isEqualToString:kind]) {
            [indexPaths addObject:[key indexPath]];
        }
    }
    return indexPaths;
}

- (NSArray<NSIndexPath *> *)_indexPathsForVisibleSupplementaryViewsOfKind:(NSString *)kind {
    return [self indexPathsForVisibleSupplementaryElementsOfKind:kind];
}

- (UXCollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForCellWithIndexPath:indexPath];
    id view = _allVisibleViewsDict[key];
    if ([view isKindOfClass:[UXCollectionViewCell class]]) {
        return view;
    }
    return nil;
}

- (UXCollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForSupplementaryViewOfKind:kind andIndexPath:indexPath];
    return _allVisibleViewsDict[key];
}

- (__kindof UXCollectionReusableView *)_visibleSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [self _visibleSupplementaryViewOfKind:kind atIndexPath:indexPath isDecorationView:NO];
}

- (__kindof UXCollectionReusableView *)_visibleSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath isDecorationView:(BOOL)isDecorationView {
    _UXCollectionViewItemKey *key = isDecorationView
        ? [_UXCollectionViewItemKey collectionItemKeyForDecorationViewOfKind:kind andIndexPath:indexPath]
        : [_UXCollectionViewItemKey collectionItemKeyForSupplementaryViewOfKind:kind andIndexPath:indexPath];
    return _allVisibleViewsDict[key];
}

- (__kindof UXCollectionReusableView *)_visibleDecorationViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [self _visibleSupplementaryViewOfKind:kind atIndexPath:indexPath isDecorationView:YES];
}

- (NSIndexPath *)indexPathForCell:(UXCollectionViewCell *)cell {
    for (_UXCollectionViewItemKey *key in _allVisibleViewsDict) {
        if (_allVisibleViewsDict[key] == cell && [key type] == UXCollectionViewItemTypeCell) {
            return [key indexPath];
        }
    }
    return nil;
}

- (NSIndexPath *)indexPathForSupplementaryView:(UXCollectionReusableView *)supplementaryView {
    for (_UXCollectionViewItemKey *key in _allVisibleViewsDict) {
        if (_allVisibleViewsDict[key] == supplementaryView && [key type] != UXCollectionViewItemTypeCell) {
            return [key indexPath];
        }
    }
    return nil;
}

- (NSIndexPath *)_indexPathForView:(NSView *)view ofType:(NSUInteger)type {
    for (_UXCollectionViewItemKey *key in _allVisibleViewsDict) {
        id candidate = _allVisibleViewsDict[key];
        if (candidate == view && [key type] == type) {
            return [key indexPath];
        }
    }
    return nil;
}

- (NSArray<UXCollectionViewLayoutAttributes *> *)_layoutAttributesForItemsInRect:(CGRect)rect {
    NSArray<UXCollectionViewLayoutAttributes *> *all = [_collectionViewData layoutAttributesForElementsInRect:rect];
    NSMutableArray<UXCollectionViewLayoutAttributes *> *cells = [NSMutableArray array];
    for (UXCollectionViewLayoutAttributes *attributes in all) {
        if ([attributes _isCell]) {
            [cells addObject:attributes];
        }
    }
    return cells;
}

#pragma mark - Hit testing

- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point {
    if (!_doneFirstLayout) {
        [self reloadData];
        _doneFirstLayout = YES;
    }
    CGRect probeRect = CGRectMake(point.x, point.y, 1.0, 1.0);
    NSArray<UXCollectionViewLayoutAttributes *> *attributesInRect = [_collectionViewData layoutAttributesForElementsInRect:probeRect];
    __block NSIndexPath *foundIndexPath = nil;
    [attributesInRect enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UXCollectionViewLayoutAttributes *attributes, NSUInteger index, BOOL *stop) {
        if (attributes.representedElementCategory == UXCollectionElementCategoryCell) {
            foundIndexPath = attributes.indexPath;
            *stop = YES;
        }
    }];
    return foundIndexPath;
}

- (NSIndexPath *)indexPathForSupplementaryElementOfKind:(NSString *)kind atPoint:(CGPoint)point {
    CGRect probeRect = CGRectMake(point.x, point.y, 1.0, 1.0);
    NSArray<UXCollectionViewLayoutAttributes *> *attributesInRect = [_collectionViewData layoutAttributesForElementsInRect:probeRect];
    for (UXCollectionViewLayoutAttributes *attributes in attributesInRect.reverseObjectEnumerator) {
        if (attributes.representedElementCategory == UXCollectionElementCategorySupplementaryView && [[attributes _elementKind] isEqualToString:kind]) {
            return attributes.indexPath;
        }
    }
    return nil;
}

- (NSIndexPath *)indexPathForSupplementaryElementOfKind:(NSString *)kind hitByEvent:(NSEvent *)event {
    return [self _indexPathForSupplementaryElementOfKind:kind hitByEvent:event];
}

- (NSIndexPath *)_indexPathForSupplementaryElementOfKind:(NSString *)kind hitByEvent:(NSEvent *)event {
    NSPoint pointInWindow = event.locationInWindow;
    NSPoint pointInDocument = [_collectionDocumentView convertPoint:pointInWindow fromView:nil];
    return [self indexPathForSupplementaryElementOfKind:kind atPoint:pointInDocument];
}

- (NSIndexPath *)indexPathForItemHitByEvent:(NSEvent *)event {
    NSPoint pointInWindow = event.locationInWindow;
    NSPoint pointInDocument = [_collectionDocumentView convertPoint:pointInWindow fromView:nil];
    return [self indexPathForItemAtPoint:pointInDocument];
}

- (NSView *)_validateHitTest:(NSView *)view {
    if (!view) {
        return nil;
    }
    NSView *candidate = view;
    while (candidate) {
        if ([candidate isKindOfClass:[UXCollectionReusableView class]] || candidate == self || candidate == _collectionDocumentView) {
            break;
        }
        candidate = candidate.superview;
    }
    return candidate;
}

#pragma mark - Layout attribute queries

- (UXCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_collectionViewData layoutAttributesForItemAtIndexPath:indexPath];
}

- (UXCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [_collectionViewData layoutAttributesForSupplementaryElementOfKind:kind atIndexPath:indexPath];
}

#pragma mark - Selection

- (NSArray<NSIndexPath *> *)indexPathsForSelectedItems {
    return [_indexPathsForSelectedItems allIndexPaths];
}

- (NSUInteger)numberOfSelectedItems {
    return [_indexPathsForSelectedItems count];
}

- (BOOL)selectedItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_indexPathsForSelectedItems containsIndexPath:indexPath];
}

- (BOOL)selectableItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!_allowsSelection) {
        return NO;
    }
    id<UXCollectionViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(collectionView:shouldSelectItemAtIndexPath:)]) {
        return [delegate collectionView:self shouldSelectItemAtIndexPath:indexPath];
    }
    return YES;
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UXCollectionViewScrollPosition)scrollPosition {
    if (!indexPath) {
        [self deselectAllItems:animated];
        return;
    }
    [self selectItemsAtIndexPaths:@[indexPath] byExtendingSelection:NO animated:animated];
    if (scrollPosition != UXCollectionViewScrollPositionNone) {
        [self scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
    }
}

- (void)selectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths byExtendingSelection:(BOOL)extend animated:(BOOL)animated {
    [self selectItemsAtIndexPaths:indexPaths byExtendingSelection:extend animated:animated scrollItemAtIndex:nil toPosition:UXCollectionViewScrollPositionNone];
}

- (void)selectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths byExtendingSelection:(BOOL)extend animated:(BOOL)animated scrollItemAtIndex:(NSIndexPath *)indexPath toPosition:(UXCollectionViewScrollPosition)position {
    UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPaths:indexPaths ?: @[]];
    [self _selectItemsInIndexPathsSet:set byExtendingSelection:extend animated:animated scrollingKeyItem:indexPath toPosition:position notifyDelegate:NO];
}

- (void)_postSelectionAccessibilityNotification {
    id layoutAccessibility = [_layout layoutAccessibility];
    if ([layoutAccessibility respondsToSelector:@selector(accessibilityPostNotification:)]) {
        [layoutAccessibility accessibilityPostNotification:NSAccessibilitySelectedCellsChangedNotification];
    }
}

- (BOOL)_selectItemsInIndexPathsSet:(UXCollectionViewIndexPathsSet *)set byExtendingSelection:(BOOL)extend animated:(BOOL)animated scrollingKeyItem:(NSIndexPath *)keyItem toPosition:(UXCollectionViewScrollPosition)position notifyDelegate:(BOOL)notifyDelegate {
    id<UXCollectionViewDelegate> delegate = self.delegate;
    UXCollectionViewIndexPathsSet *oldSelection = [_indexPathsForSelectedItems copy];

    // Build the requested selection: gated by allowsSelection, filtered through
    // the shouldSelect: delegate, optionally extended over the current
    // selection, and collapsed to a single item when multiple selection is off.
    UXCollectionViewMutableIndexPathsSet *requestedSelection;
    if (!set || !self.allowsSelection) {
        requestedSelection = [UXCollectionViewMutableIndexPathsSet indexPathsSet];
    } else {
        requestedSelection = [set mutableCopy];
        if (_collectionViewFlags.delegateShouldSelectItemAtIndexPath) {
            [set enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
                if (![delegate collectionView:self shouldSelectItemAtIndexPath:indexPath]) {
                    [requestedSelection removeIndexPath:indexPath];
                }
            }];
        }
        if (extend) {
            [requestedSelection addIndexPathsSet:oldSelection];
        }
        if (!self.allowsMultipleSelection && requestedSelection.count >= 2) {
            NSIndexPath *survivor = [requestedSelection firstIndexPath];
            if (keyItem && [requestedSelection containsIndexPath:keyItem]) {
                survivor = keyItem;
            }
            [requestedSelection removeAllIndexPaths];
            if (survivor) {
                [requestedSelection addIndexPath:survivor];
            }
        }
    }

    // Diff the requested selection against the live one.
    UXCollectionViewMutableIndexPathsSet *added = [requestedSelection mutableCopy];
    [added removeIndexPathsSet:oldSelection];
    UXCollectionViewMutableIndexPathsSet *removed = [oldSelection mutableCopy];
    [removed removeIndexPathsSet:requestedSelection];
    if (_collectionViewFlags.delegateShouldDeselectItemAtIndexPath) {
        [[removed copy] enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
            if (![delegate collectionView:self shouldDeselectItemAtIndexPath:indexPath]) {
                [removed removeIndexPath:indexPath];
            }
        }];
    }

    // Apply the diff to a working copy of the live selection and forbid an
    // empty result when allowsEmptySelection is off.
    UXCollectionViewMutableIndexPathsSet *workingSelection = [_indexPathsForSelectedItems mutableCopy];
    [workingSelection removeIndexPathsSet:removed];
    [workingSelection addIndexPathsSet:added];
    if (workingSelection.count == 0 && !self.allowsEmptySelection) {
        if (requestedSelection.count == 0) {
            return NO;
        }
        NSIndexPath *firstSelectable = [self _firstSelectableItemIndexPath];
        if (!firstSelectable) {
            return NO;
        }
        if ([removed containsIndexPath:firstSelectable]) {
            [removed removeIndexPath:firstSelectable];
        } else {
            [added addIndexPath:firstSelectable];
        }
        [workingSelection addIndexPath:firstSelectable];
        [requestedSelection addIndexPath:firstSelectable];
    }

    if (added.count + removed.count == 0) {
        return NO;
    }

    NSArray<NSIndexPath *> *addedArray = nil;
    NSArray<NSIndexPath *> *removedArray = nil;
    if (notifyDelegate) {
        if (_collectionViewFlags.delegateSelectionWillAddAndRemove || _collectionViewFlags.delegateSelectionDidAddAndRemove) {
            addedArray = added.allIndexPaths;
            removedArray = removed.allIndexPaths;
        }
        if (_collectionViewFlags.delegateSelectionWillAddAndRemove) {
            NSAssert(addedArray && removedArray, @"item arrays have not been populated");
            [delegate collectionView:self indexPathsForSelectedItemsWillAdd:addedArray remove:removedArray animated:animated];
        }
    }

    // Commit, then update only the currently-visible cells' selected state.
    [_indexPathsForSelectedItems removeAllIndexPaths];
    [_indexPathsForSelectedItems addIndexPathsSet:workingSelection];
    NSAssert([requestedSelection isEqual:_indexPathsForSelectedItems], @"selected items synchronicity failure");

    [[self _dictionaryOfIndexPathsAndContentCells] enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UXCollectionViewCell *cell, BOOL *stop) {
        BOOL nowSelected = [added containsIndexPath:indexPath];
        if (nowSelected || [removed containsIndexPath:indexPath]) {
            [(id)cell _setSelected:nowSelected animated:animated];
        }
    }];

    if (notifyDelegate) {
        if (_collectionViewFlags.delegateDidDeselectItemAtIndexPath) {
            [removed enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
                [delegate collectionView:self didDeselectItemAtIndexPath:indexPath];
            }];
        }
        if (_collectionViewFlags.delegateDidSelectItemAtIndexPath) {
            [added enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
                [delegate collectionView:self didSelectItemAtIndexPath:indexPath];
            }];
        }
        if (_collectionViewFlags.delegateSelectionDidAddAndRemove) {
            NSAssert(addedArray && removedArray, @"item arrays have not been populated");
            [delegate collectionView:self indexPathsForSelectedItemsDidAdd:addedArray remove:removedArray animated:animated];
        }
    }

    if (keyItem && position != UXCollectionViewScrollPositionNone) {
        [self scrollToItemAtIndexPath:keyItem atScrollPosition:position animated:animated];
    }
    [self _postSelectionAccessibilityNotification];
    return YES;
}

- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self deselectItemsAtIndexPaths:@[indexPath] animated:animated];
}

- (void)deselectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths animated:(BOOL)animated {
    [self _deselectItemsAtIndexPaths:indexPaths animated:animated notifyDelegate:NO];
}

- (BOOL)_deselectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths animated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate {
    id<UXCollectionViewDelegate> delegate = self.delegate;
    UXCollectionViewMutableIndexPathsSet *toDeselect = [[UXCollectionViewMutableIndexPathsSet alloc] init];
    for (NSIndexPath *indexPath in indexPaths) {
        [toDeselect addIndexPath:indexPath];
    }
    if (_collectionViewFlags.delegateShouldDeselectItemAtIndexPath) {
        for (NSIndexPath *indexPath in indexPaths) {
            if (![delegate collectionView:self shouldDeselectItemAtIndexPath:indexPath]) {
                [toDeselect removeIndexPath:indexPath];
            }
        }
    }
    if (toDeselect.count == 0) {
        return NO;
    }

    // UXKit implements deselection as "select the complement": compute the
    // surviving selection, guard the non-empty invariant, then route through
    // _selectItemsInIndexPathsSet: so the diff/notify path stays single-sourced.
    NSIndexPath *anchorIndexPath = _lastSelectionAnchorIndexPath;
    UXCollectionViewMutableIndexPathsSet *survivingSelection = [_indexPathsForSelectedItems mutableCopy];
    [survivingSelection removeIndexPathsSet:toDeselect];
    if (survivingSelection.count == 0 && !self.allowsEmptySelection) {
        NSIndexPath *fallback = [indexPaths lastObject];
        if (!fallback || ![toDeselect containsIndexPath:fallback]) {
            fallback = [self _firstSelectableItemIndexPath];
            if (!fallback) {
                return NO;
            }
        }
        anchorIndexPath = fallback;
        [survivingSelection addIndexPath:fallback];
        NSAssert(survivingSelection.count > 0, @"unable to define a non-empty selection for %@ after deselecting %@", self, toDeselect);
    }
    if (anchorIndexPath && ![survivingSelection containsIndexPath:anchorIndexPath]) {
        anchorIndexPath = [survivingSelection firstIndexPath];
    }
    if ([self _selectItemsInIndexPathsSet:survivingSelection
                     byExtendingSelection:NO
                                 animated:animated
                         scrollingKeyItem:nil
                               toPosition:UXCollectionViewScrollPositionNone
                           notifyDelegate:notifyDelegate]) {
        _lastSelectionAnchorIndexPath = anchorIndexPath;
        [self _postSelectionAccessibilityNotification];
        return YES;
    }
    return NO;
}

- (void)_deselectAllAnimated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate {
    _lastSelectionAnchorIndexPath = nil;
    [self _selectItemsInIndexPathsSet:nil
                 byExtendingSelection:NO
                             animated:animated
                     scrollingKeyItem:nil
                           toPosition:UXCollectionViewScrollPositionNone
                       notifyDelegate:notifyDelegate];
}

- (BOOL)_toggleSelectionStateOfItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate {
    if (!indexPath) {
        return NO;
    }
    BOOL wasSelected = [_indexPathsForSelectedItems containsIndexPath:indexPath];
    UXCollectionViewIndexPathsSet *single = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPath:indexPath];
    if (wasSelected) {
        if (![self _deselectItemsAtIndexPaths:@[indexPath] animated:animated notifyDelegate:notifyDelegate]) {
            return NO;
        }
        if (![_lastSelectionAnchorIndexPath isEqual:indexPath]) {
            return YES;
        }
        _lastSelectionAnchorIndexPath = [self _keyItemIndexPathForItemIndexPathsSet:_indexPathsForSelectedItems];
    } else {
        if (![self _selectItemsInIndexPathsSet:single
                          byExtendingSelection:YES
                                      animated:animated
                              scrollingKeyItem:indexPath
                                    toPosition:(UXCollectionViewScrollPosition)64
                                notifyDelegate:notifyDelegate]) {
            return NO;
        }
        _lastSelectionAnchorIndexPath = indexPath;
    }
    return YES;
}

- (BOOL)_selectRangeOfItemsFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath byExtendingSelection:(BOOL)extend animated:(BOOL)animated scroll:(BOOL)scroll toPosition:(UXCollectionViewScrollPosition)position notifyDelegate:(BOOL)notifyDelegate candidateLastSelectedItemIndexPath:(NSIndexPath *__autoreleasing  _Nullable *)candidate {
    if (candidate) {
        *candidate = nil;
    }
    NSArray<NSIndexPath *> *range = [_layout indexPathsForItemRangeSelectionFrom:fromIndexPath to:toIndexPath];
    NSIndexPath *keyItem = scroll ? [self _keyItemIndexPathForItemIndexPaths:range] : nil;
    UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPaths:range];
    BOOL changed = [self _selectItemsInIndexPathsSet:set byExtendingSelection:extend animated:animated scrollingKeyItem:keyItem toPosition:position notifyDelegate:notifyDelegate];
    if (candidate && changed) {
        // Report the deepest range item (excluding the anchor) that ended up
        // selected, so the caller can advance its selection anchor.
        NSMutableArray<NSIndexPath *> *remainingRange = [range mutableCopy];
        [remainingRange removeObject:fromIndexPath];
        NSIndexPath *candidateIndexPath = nil;
        while (remainingRange.count > 0) {
            candidateIndexPath = [self _keyItemIndexPathForItemIndexPaths:remainingRange];
            if (!candidateIndexPath) {
                break;
            }
            if ([_indexPathsForSelectedItems containsIndexPath:candidateIndexPath]) {
                break;
            }
            [remainingRange removeObject:candidateIndexPath];
        }
        *candidate = candidateIndexPath;
    }
    return changed;
}

- (void)deselectAllItems:(BOOL)animated {
    [self _deselectAllAnimated:animated notifyDelegate:NO];
}

- (void)selectAllItems:(BOOL)animated {
    [self _selectAllItems:YES notifyDelegate:NO];
}

- (void)_selectAllItems:(BOOL)selectAll notifyDelegate:(BOOL)notifyDelegate {
    [self _reloadDataIfNeeded];
    UXCollectionViewMutableIndexPathsSet *targetSelection = [UXCollectionViewMutableIndexPathsSet indexPathsSet];
    NSInteger sectionCount = [self numberOfSections];
    NSIndexSet *sections = nil;
    if (_collectionViewFlags.delegateSectionsForSelectAllAction) {
        sections = [(id)self.delegate sectionsForSelectAllActionInCollectionView:self];
    }
    if (!sections) {
        sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, (NSUInteger)sectionCount)];
    }
    [sections enumerateIndexesInRange:NSMakeRange(0, (NSUInteger)sectionCount) options:0 usingBlock:^(NSUInteger section, BOOL *stop) {
        NSInteger itemCount = [self numberOfItemsInSection:(NSInteger)section];
        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:(NSInteger)section];
            if ([self selectableItemAtIndexPath:indexPath]) {
                [targetSelection addIndexPath:indexPath];
            }
        }
    }];
    if ([self _selectItemsInIndexPathsSet:targetSelection
                     byExtendingSelection:NO
                                 animated:NO
                         scrollingKeyItem:nil
                               toPosition:UXCollectionViewScrollPositionNone
                           notifyDelegate:notifyDelegate]) {
        _lastSelectionAnchorIndexPath = [self _keyItemIndexPathForItemIndexPathsSet:_indexPathsForSelectedItems];
    }
}

- (IBAction)selectAll:(id)sender {
    [self _selectAllItems:YES notifyDelegate:YES];
}

- (IBAction)deselectAll:(id)sender {
    [self _deselectAllAnimated:NO notifyDelegate:YES];
}

- (NSIndexPath *)_firstSelectableItemIndexPath {
    NSInteger sectionCount = [self numberOfSections];
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self numberOfItemsInSection:section];
        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *candidate = [NSIndexPath indexPathForItem:item inSection:section];
            if ([self selectableItemAtIndexPath:candidate]) {
                return candidate;
            }
        }
    }
    return nil;
}

- (NSIndexPath *)_lastSelectableItemIndexPath {
    NSInteger sectionCount = [self numberOfSections];
    for (NSInteger section = sectionCount - 1; section >= 0; section--) {
        NSInteger itemCount = [self numberOfItemsInSection:section];
        for (NSInteger item = itemCount - 1; item >= 0; item--) {
            NSIndexPath *candidate = [NSIndexPath indexPathForItem:item inSection:section];
            if ([self selectableItemAtIndexPath:candidate]) {
                return candidate;
            }
        }
    }
    return nil;
}

- (NSIndexPath *)_keyItemIndexPathForItemIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    return [indexPaths lastObject];
}

- (NSIndexPath *)_keyItemIndexPathForItemIndexPathsSet:(UXCollectionViewIndexPathsSet *)indexPathsSet {
    return [indexPathsSet lastIndexPath];
}

- (NSIndexPath *)_selectableIndexPathForItemContainingHitView:(NSView *)hitView {
    NSView *currentView = hitView;
    while (currentView) {
        if ([currentView isKindOfClass:[UXCollectionViewCell class]] || [currentView isKindOfClass:[UXCollectionView class]]) {
            break;
        }
        currentView = currentView.superview;
    }
    if (![currentView isKindOfClass:[UXCollectionViewCell class]]) {
        return nil;
    }
    return [self indexPathForCell:(UXCollectionViewCell *)currentView];
}

- (NSIndexPath *)_indexPathOfSelectableItemHitByEvent:(NSEvent *)event {
    NSView *documentSuperview = [_collectionDocumentView superview];
    NSPoint pointInWindow = event.locationInWindow;
    NSPoint pointInSuperview = [documentSuperview convertPoint:pointInWindow fromView:nil];
    NSView *hitView = [_collectionDocumentView hitTest:pointInSuperview];
    if (!hitView) {
        return nil;
    }
    return [self _selectableIndexPathForItemContainingHitView:hitView];
}

#pragma mark - Accessibility selection

- (void)accessibilitySelectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPaths:indexPaths];
    [self _selectItemsInIndexPathsSet:set byExtendingSelection:NO animated:NO scrollingKeyItem:nil toPosition:UXCollectionViewScrollPositionNone notifyDelegate:YES];
}

- (void)accessibilitySelected:(BOOL)selected itemAtIndexPath:(NSIndexPath *)indexPath {
    if (selected) {
        UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPath:indexPath];
        [self _selectItemsInIndexPathsSet:set byExtendingSelection:_allowsMultipleSelection animated:NO scrollingKeyItem:nil toPosition:UXCollectionViewScrollPositionNone notifyDelegate:YES];
    } else {
        [self _deselectItemsAtIndexPaths:@[indexPath] animated:NO notifyDelegate:YES];
    }
}

- (BOOL)accessibilityPerformPressWithItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![self selectableItemAtIndexPath:indexPath]) {
        return NO;
    }
    [self accessibilitySelected:YES itemAtIndexPath:indexPath];
    return YES;
}

#pragma mark - Geometry

- (CGRect)documentContentRect {
    CGRect preparedRect = [self.documentView preparedContentRect];
    CGRect visibleRect = [self documentVisibleRect];
    if (CGRectIntersectsRect(preparedRect, visibleRect)
        && preparedRect.size.width >= visibleRect.size.width
        && preparedRect.size.height >= visibleRect.size.height) {
        return CGRectUnion(preparedRect, visibleRect);
    }
    return visibleRect;
}

- (CGSize)documentSize {
    return [_collectionViewData collectionViewContentRect].size;
}

- (CGRect)documentBounds {
    return _collectionDocumentView.bounds;
}

- (void)setDocumentBounds:(CGRect)documentBounds {
    [_collectionDocumentView setBoundsOrigin:documentBounds.origin];
}

- (CGSize)contentSize {
    if (CGSizeEqualToSize(_contentSize, CGSizeZero)) {
        return [self documentSize];
    }
    return _contentSize;
}

- (void)setContentSize:(CGSize)contentSize {
    CGSize roundedSize = CGSizeMake(round(contentSize.width), round(contentSize.height));
    if (CGSizeEqualToSize(roundedSize, _contentSize) && CGSizeEqualToSize(roundedSize, [self documentSize])) {
        return;
    }
    _contentSize = roundedSize;
    [self.documentView setFrameSize:roundedSize];
}

- (CGPoint)contentOffset {
    return self.contentView.bounds.origin;
}

- (void)setContentOffset:(CGPoint)contentOffset {
    [self.contentView setBoundsOrigin:contentOffset];
    [self reflectScrolledClipView:self.contentView];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    if (animated) {
        [self.contentView.animator setBoundsOrigin:contentOffset];
    } else {
        [self.contentView setBoundsOrigin:contentOffset];
    }
    [self reflectScrolledClipView:self.contentView];
}

- (CGSize)frameSizeForContentSize:(CGSize)contentSize {
    return [NSScrollView frameSizeForContentSize:contentSize horizontalScrollerClass:self.hasHorizontalScroller ? self.horizontalScroller.class : nil verticalScrollerClass:self.hasVerticalScroller ? self.verticalScroller.class : nil borderType:self.borderType controlSize:NSControlSizeRegular scrollerStyle:self.scrollerStyle];
}

- (CGSize)contentSizeForFrameSize:(CGSize)frameSize {
    return [NSScrollView contentSizeForFrameSize:frameSize horizontalScrollerClass:self.hasHorizontalScroller ? self.horizontalScroller.class : nil verticalScrollerClass:self.hasVerticalScroller ? self.verticalScroller.class : nil borderType:self.borderType controlSize:NSControlSizeRegular scrollerStyle:self.scrollerStyle];
}

- (CGPoint)collectionViewPointForLayoutPoint:(CGPoint)layoutPoint {
    return [_collectionDocumentView convertPoint:layoutPoint toView:self];
}

- (CGPoint)layoutPointForCollectionViewPoint:(CGPoint)collectionViewPoint {
    return [_collectionDocumentView convertPoint:collectionViewPoint fromView:self];
}

- (CGRect)_visibleBounds {
    CGRect rect = [self documentContentRect];
    BOOL hasActiveGrouping = [NSAnimationContext respondsToSelector:@selector(_hasActiveGrouping)] && [NSAnimationContext _hasActiveGrouping];
    if (_collectionViewFlags.loadingOffscreenViews || hasActiveGrouping) {
        if (CGRectIntersectsRect(rect, _visibleBounds)) {
            rect = CGRectUnion(rect, _visibleBounds);
        }
    }
    return rect;
}

- (void)_setVisibleBounds:(CGRect)visibleBounds {
    _visibleBounds = visibleBounds;
}

#pragma mark - Scrolling

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UXCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated {
    [self scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated userInteractivelyScrolling:NO];
}

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UXCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated userInteractivelyScrolling:(BOOL)userInteractivelyScrolling {
    UXCollectionViewLayoutAttributes *attributes = [_collectionViewData layoutAttributesForItemAtIndexPath:indexPath];
    if (!attributes) {
        return;
    }
    NSEdgeInsets insets = [_layout insetsForScrollingItemAtIndexPath:indexPath toScrollPosition:scrollPosition];
    [self _scrollRect:attributes.frame toScrollPosition:scrollPosition withInsets:insets animated:animated userInteractivelyScrolling:userInteractivelyScrolling];
}

- (void)scrollRect:(CGRect)rect toScrollPosition:(UXCollectionViewScrollPosition)scrollPosition withInsets:(NSEdgeInsets)insets animated:(BOOL)animated {
    [self _scrollRect:rect toScrollPosition:scrollPosition withInsets:insets animated:animated userInteractivelyScrolling:NO];
}

- (void)_scrollRect:(CGRect)rect toScrollPosition:(UXCollectionViewScrollPosition)scrollPosition withInsets:(NSEdgeInsets)insets animated:(BOOL)animated userInteractivelyScrolling:(BOOL)userInteractivelyScrolling {
    NSClipView *clipView = self.contentView;
    NSRect destination = clipView.bounds;
    destination.origin.x += insets.left;
    destination.origin.y += insets.top;
    destination.size.width -= (insets.left + insets.right);
    destination.size.height -= (insets.top + insets.bottom);

    CGPoint amount = [self _scrollAmountForMovingRect:rect toScrollPosition:scrollPosition inDestinationRect:destination];
    NSPoint target = NSMakePoint(clipView.bounds.origin.x + amount.x, clipView.bounds.origin.y + amount.y);
    if (animated) {
        [clipView.animator setBoundsOrigin:target];
    } else {
        [clipView setBoundsOrigin:target];
    }
    [self reflectScrolledClipView:clipView];
}

- (CGPoint)_scrollAmountForMovingRect:(CGRect)movingRect toScrollPosition:(UXCollectionViewScrollPosition)position inDestinationRect:(CGRect)destinationRect {
    CGFloat dx = 0.0;
    CGFloat dy = 0.0;

    if (position & UXCollectionViewScrollPositionCenteredVertically) {
        dy = CGRectGetMidY(movingRect) - CGRectGetMidY(destinationRect);
    } else if (position & UXCollectionViewScrollPositionTop) {
        dy = CGRectGetMinY(movingRect) - CGRectGetMinY(destinationRect);
    } else if (position & UXCollectionViewScrollPositionBottom) {
        dy = CGRectGetMaxY(movingRect) - CGRectGetMaxY(destinationRect);
    }

    if (position & UXCollectionViewScrollPositionCenteredHorizontally) {
        dx = CGRectGetMidX(movingRect) - CGRectGetMidX(destinationRect);
    } else if (position & UXCollectionViewScrollPositionLeft) {
        dx = CGRectGetMinX(movingRect) - CGRectGetMinX(destinationRect);
    } else if (position & UXCollectionViewScrollPositionRight) {
        dx = CGRectGetMaxX(movingRect) - CGRectGetMaxX(destinationRect);
    }

    return CGPointMake(dx, dy);
}

- (void)_scrollToEnd:(BOOL)end {
    NSIndexPath *target = end ? [self _lastSelectableItemIndexPath] : [self _firstSelectableItemIndexPath];
    if (target) {
        [self scrollToItemAtIndexPath:target
                     atScrollPosition:end ? UXCollectionViewScrollPositionBottom : UXCollectionViewScrollPositionTop
                             animated:NO];
    }
}

- (void)_scrollPage:(BOOL)pageDown {
    NSClipView *clipView = self.contentView;
    CGRect bounds = clipView.bounds;
    CGFloat delta = pageDown ? bounds.size.height : -bounds.size.height;
    NSPoint target = NSMakePoint(bounds.origin.x, bounds.origin.y + delta);
    [clipView setBoundsOrigin:target];
    [self reflectScrolledClipView:clipView];
}

- (BOOL)_performScrollingForKey:(uint16_t)key {
    switch (key) {
        case NSPageUpFunctionKey:
            [self _scrollPage:NO];
            return YES;
        case NSPageDownFunctionKey:
            [self _scrollPage:YES];
            return YES;
        case NSHomeFunctionKey:
            [self _scrollToEnd:NO];
            return YES;
        case NSEndFunctionKey:
            [self _scrollToEnd:YES];
            return YES;
    }
    return NO;
}

- (void)_submitScrollingRequest:(void (^)(void))request {
    if (request) {
        request();
    }
}

- (void)resetScrollingOverdraw {
    _lastPreparedOverdrawContentRect = CGRectNull;
}

#pragma mark - Scrolling lifecycle

- (void)scrollViewWillStartLiveScrollNotification:(NSNotification *)notification {
    _liveScrolling = YES;
    [self _willStartScrolling:notification];
}

- (void)scrollViewDidEndLiveScrollNotification:(NSNotification *)notification {
    _liveScrolling = NO;
    [self _didEndScrolling:notification];
}

- (void)_willStartScrolling:(id)sender {
    // The pending _didEndScrolling: dispatched by clipViewBoundsDidChange: is
    // cancelled here so a fresh scroll restarts the idle timer cleanly.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_didEndScrolling:) object:self];
    if (_scrolling) {
        return;
    }
    _decelerating = NO;
    _lastScrollingDistance = CGPointZero;
    _lastScrollingTime = 0.0;
    if (_collectionViewFlags.delegateWillBeginScrolling) {
        [self.delegate collectionViewWillBeginScrolling:self];
    }
    _scrolling = YES;
}

- (void)scrollWheel:(NSEvent *)event {
    _involvesScrollWheel = YES;
    [super scrollWheel:event];
}

- (void)_didEndScrolling:(id)sender {
    if (!_scrolling) {
        return;
    }
    _scrolling = NO;
    id<UXCollectionViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(collectionViewDidEndScrolling:)]) {
        [delegate collectionViewDidEndScrolling:self];
    }
}

- (void)_didEndScrollingAnimation {
    id<UXCollectionViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(collectionViewDidEndScrollingAnimation:)]) {
        [delegate collectionViewDidEndScrollingAnimation:self];
    }
}

- (void)willStartScrollingFromExternalControl {
    _scrollingFromExternalControl = YES;
    [self _willStartScrolling:nil];
}

- (void)willEndScrollingFromExternalControl {
    // No-op: matches Apple's symbol signature; clients hook in scrolling notification flow.
}

- (void)didEndScrollingFromExternalControl {
    _scrollingFromExternalControl = NO;
    [self _didEndScrolling:nil];
}

- (void)clipViewBoundsDidChange:(NSNotification *)notification {
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    CGRect newBounds;
    if (_currentUpdate) {
        newBounds = [_currentUpdate _newVisibleBounds];
    } else {
        newBounds = self.contentView.bounds;
    }
    if (CGPointEqualToPoint(newBounds.origin, _lastContentOffset)) {
        return;
    }

    if (!_scrolling && !_liveScrolling && _involvesScrollWheel && _suspendClipViewBoundsDidChange == 0) {
        [self _willStartScrolling:self];
    }

    id<UXCollectionViewDelegate> delegate = self.delegate;
    CGPoint scrollingDistance = CGPointMake(newBounds.origin.x - _lastContentOffset.x,
                                            newBounds.origin.y - _lastContentOffset.y);
    if (!CGPointEqualToPoint(_lastScrollingDistance, CGPointZero) && _lastScrollingTime != 0.0) {
        double distance = sqrt(scrollingDistance.x * scrollingDistance.x + scrollingDistance.y * scrollingDistance.y);
        _scrollingVelocity = (float)(distance * 0.001 / (currentTime - _lastScrollingTime));
    }

    if (_scrolling && _canDetectDeceleration && _involvesScrollWheel) {
        if (!_decelerating) {
            _decelerating = YES;
            if (_collectionViewFlags.delegateWillBeginDeceleratingTargetContentOffset && _suspendClipViewBoundsDidChange == 0) {
                [delegate collectionViewWillBeginDecelerating:self targetContentOffset:newBounds.origin];
            }
        }
    } else if (!_scrollingFromExternalControl && _decelerating) {
        _decelerating = NO;
        if (_collectionViewFlags.delegateDidEndDecelerating && _suspendClipViewBoundsDidChange == 0) {
            [delegate collectionViewDidEndDecelerating:self];
        }
    }

    _lastScrollingDistance = scrollingDistance;
    _lastContentOffset = newBounds.origin;
    _lastScrollingTime = currentTime;

    if ([_layout shouldUpdateVisibleCellLayoutAttributes]) {
        _collectionViewFlags.scheduledUpdateVisibleCellLayoutAttributes = YES;
    }
    if ([_layout shouldInvalidateLayoutForBoundsChange:newBounds]) {
        [_layout _invalidateLayoutUsingContext:[_layout invalidationContextForBoundsChange:newBounds]];
    } else {
        [self updateLayout];
    }

    if (_collectionViewFlags.delegateDidScroll && _suspendClipViewBoundsDidChange == 0) {
        [delegate collectionViewDidScroll:self];
    }

    if (_scrolling && !_liveScrolling && _involvesScrollWheel) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_didEndScrolling:) object:self];
        [self performSelector:@selector(_didEndScrolling:)
                   withObject:self
                   afterDelay:0.25
                      inModes:@[(__bridge NSRunLoopMode)kCFRunLoopCommonModes, NSModalPanelRunLoopMode]];
    }
}

- (void)reflectScrolledClipView:(NSClipView *)clipView {
    [super reflectScrolledClipView:clipView];
    [self clipViewBoundsDidChange:nil];
}

#pragma mark - Reload / batch updates

- (void)reloadData {
    if (_reloadingSuspendedCount > 0) {
        _collectionViewFlags.reloadSkippedDuringSuspension = YES;
        return;
    }
    _collectionViewFlags.reloading = YES;
    [self _suspendReloads];

    NSMutableDictionary *animatingViews = [NSMutableDictionary dictionary];
    for (_UXCollectionViewItemKey *key in _allVisibleViewsDict.copy) {
        UXCollectionReusableView *view = _allVisibleViewsDict[key];
        if ([view _isInUpdateAnimation]) {
            animatingViews[key] = view;
        } else if ([[(id)view _layoutAttributes] _isCell]) {
            [self _reuseCell:(UXCollectionViewCell *)view];
        } else {
            [self _reuseSupplementaryView:view];
        }
    }
    [_supplementaryElementKinds removeAllObjects];
    [_allVisibleViewsDict removeAllObjects];
    [_allVisibleViewsDict addEntriesFromDictionary:animatingViews];
    [_indexPathsForSelectedItems removeAllIndexPaths];
    _pendingSelectionIndexPath = nil;
    _pendingDeselectionIndexPaths = nil;
    _lastSelectionAnchorIndexPath = nil;
    _keyboardRangeSelectionPreviouslySelectedItems = nil;
    _keyboardRangeSelectionFirstSelectedItem = nil;
    _keyboardRangeSelectionLastSelectedItem = nil;

    [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:YES];
    [self _invalidateLayoutIfNecessary];
    [_collectionViewData invalidate:NO];
    _collectionViewFlags.needsReload = NO;
    _collectionViewFlags.reloading = NO;

    if (![self allowsEmptySelection]) {
        NSIndexPath *firstSelectableIndexPath = [self _firstSelectableItemIndexPath];
        if (firstSelectableIndexPath) {
            UXCollectionViewIndexPathsSet *selectionSet = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPath:firstSelectableIndexPath];
            // The scroll position literal 64 matches the UXKit binary (a position
            // bit above the public mask); it falls through every position check
            // and therefore scrolls nowhere while still passing a key item.
            if ([self _selectItemsInIndexPathsSet:selectionSet
                             byExtendingSelection:NO
                                         animated:NO
                                 scrollingKeyItem:firstSelectableIndexPath
                                       toPosition:(UXCollectionViewScrollPosition)64
                                   notifyDelegate:YES]) {
                _lastSelectionAnchorIndexPath = firstSelectableIndexPath;
                _keyboardRangeSelectionPreviouslySelectedItems = selectionSet;
                _keyboardRangeSelectionFirstSelectedItem = firstSelectableIndexPath;
                _keyboardRangeSelectionLastSelectedItem = firstSelectableIndexPath;
            }
        }
    }
    [self _resumeReloads];
}

- (void)_reloadDataIfNeeded {
    if (_collectionViewFlags.needsReload && _reloadingSuspendedCount == 0 && !_collectionViewFlags.reloading) {
        [self reloadData];
    }
}

- (void)_suspendReloads {
    _reloadingSuspendedCount++;
}

- (void)_resumeReloads {
    _reloadingSuspendedCount--;
    if (_reloadingSuspendedCount == 0) {
        if (_collectionViewFlags.reloadSkippedDuringSuspension) {
            _collectionViewFlags.reloadSkippedDuringSuspension = NO;
            [self reloadData];
        } else if (_collectionViewFlags.scheduledUpdateVisibleCells) {
            [self setNeedsLayout];
        }
    }
}

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion {
    if (![self _visible]) {
        _collectionViewFlags.needsReload = YES;
        if (updates) {
            updates();
        }
        if (completion) {
            completion(YES);
        }
        return;
    }

    void (^previousCompletionHandler)(BOOL) = _updateCompletionHandler;
    _updateCompletionHandler = [^(BOOL finished) {
        if (previousCompletionHandler) {
            previousCompletionHandler(finished);
        }
        if (completion) {
            completion(finished);
        }
    } copy];

    [self _beginUpdates];
    if (updates) {
        updates();
        if (![_collectionViewData layoutIsPrepared]) {
            [_collectionViewData validateLayoutInRect:[self _visibleBounds]];
            [_collectionViewData _prepareToLoadData];
        }
    }
    [self _endUpdates];
}

- (void)_beginUpdates {
    if (_updateCount == 0) {
        [self _setupCellAnimations];
    }
    _updateCount++;
}

- (void)_endUpdates {
    _updateCount--;
    if (_updateCount == 0) {
        [self _endItemAnimations];
    }
}

- (void)_setupCellAnimations {
    [self _updateVisibleCellsNow:NO];
    [_collectionViewData _prepareToLoadData];
    _collectionViewFlags.updating = YES;
    [self _suspendReloads];
}

- (NSArray *)_viewAnimationsForCurrentUpdate {
    UXCollectionViewUpdate *update = _currentUpdate;
    UXCollectionViewData *oldModel = [update _oldModel];
    UXCollectionViewData *newModel = [update _newModel];
    NSArray *previouslyVisibleViews = [_allVisibleViewsDict allValues];
    NSMutableDictionary *newVisibleViewsDict = [[NSMutableDictionary alloc] init];

    // Stage 0: migrate the surviving entries of _allVisibleViewsDict to their
    // post-update keys (cells through the global item map, supplementary views
    // through the section map; one-index keys move unchanged).
    [_allVisibleViewsDict enumerateKeysAndObjectsUsingBlock:^(_UXCollectionViewItemKey *key, UXCollectionReusableView *view, BOOL *stop) {
        if (key.type == UXCollectionViewItemTypeCell) {
            NSInteger oldGlobalIndex = [oldModel globalIndexForItemAtIndexPath:key.indexPath];
            if (oldGlobalIndex == NSNotFound) {
                return;
            }
            NSInteger newGlobalIndex = [update _oldGlobalItemMapValueAtIndex:oldGlobalIndex];
            if (newGlobalIndex == NSNotFound) {
                return;
            }
            NSIndexPath *newIndexPath = [newModel indexPathForItemAtGlobalIndex:newGlobalIndex];
            _UXCollectionViewItemKey *newKey = [[_UXCollectionViewItemKey alloc] initWithType:UXCollectionViewItemTypeCell
                                                                                    indexPath:newIndexPath
                                                                                   identifier:key.identifier
                                                                                        clone:key.isClone];
            newVisibleViewsDict[newKey] = view;
        } else if (key.indexPath.length == 1) {
            newVisibleViewsDict[key] = view;
        } else {
            NSInteger newSection = [update _oldSectionMapValueAtIndex:key.indexPath.section];
            if (newSection == NSNotFound) {
                return;
            }
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:key.indexPath.item inSection:newSection];
            _UXCollectionViewItemKey *newKey = [[_UXCollectionViewItemKey alloc] initWithType:key.type
                                                                                    indexPath:newIndexPath
                                                                                   identifier:key.identifier
                                                                                        clone:key.isClone];
            newVisibleViewsDict[newKey] = view;
        }
    }];

    NSMutableArray<UXCollectionViewAnimation *> *animations = [[NSMutableArray alloc] init];
    NSMutableIndexSet *processedOldGlobalIndexes = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet *animatedNewGlobalIndexes = [[NSMutableIndexSet alloc] init];
    CGRect animationRect = [update _newVisibleBounds];
    animationRect.size = [self _visibleBounds].size;

    void (^deleteCellAnimation)(NSInteger) = ^(NSInteger oldGlobalIndex) {
        if (oldGlobalIndex == NSNotFound) {
            return;
        }
        NSIndexPath *oldIndexPath = [oldModel indexPathForItemAtGlobalIndex:oldGlobalIndex];
        _UXCollectionViewItemKey *oldKey = [_UXCollectionViewItemKey collectionItemKeyForCellWithIndexPath:oldIndexPath];
        UXCollectionReusableView *view = self->_allVisibleViewsDict[oldKey];
        if (!view) {
            return;
        }
        UXCollectionViewLayoutAttributes *finalAttributes = [self->_layout finalLayoutAttributesForDisappearingItemAtIndexPath:oldIndexPath];
        if (!finalAttributes) {
            finalAttributes = [[(id)view _layoutAttributes] copy];
            finalAttributes.alpha = 0.0;
        }
        UXCollectionViewAnimation *animation = [[UXCollectionViewAnimation alloc] initWithView:view
                                                                                      viewType:UXCollectionViewItemTypeCell
                                                                         finalLayoutAttributes:finalAttributes
                                                                                 startFraction:0.0
                                                                                   endFraction:1.0
                                                                    animateFromCurrentPosition:YES
                                                                          deleteAfterAnimation:YES
                                                                              customAnimations:[self->_layout _animationForReusableView:view toLayoutAttributes:finalAttributes type:2]];
        [self->_allVisibleViewsDict removeObjectForKey:oldKey];
        [animations addObject:animation];
    };

    // Stage 1: deletions (cells through the old model; whole sections also pull
    // their supplementary views out of the visible dictionary).
    for (UXCollectionViewUpdateItem *deleteItem in _deleteItems) {
        if ([deleteItem _isSectionOperation]) {
            NSInteger section = [[deleteItem _indexPath] section];
            NSInteger itemCount = [oldModel numberOfItemsInSection:section];
            if (itemCount >= 1) {
                NSInteger firstGlobalIndex = [oldModel globalIndexForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
                NSAssert(firstGlobalIndex != NSNotFound, @"unexpected global item index for the first item in section %ld", (long)section);
                for (NSInteger itemOffset = 0; itemOffset < itemCount; itemOffset++) {
                    deleteCellAnimation(firstGlobalIndex + itemOffset);
                }
            }
            for (UXCollectionViewLayoutAttributes *attributes in [oldModel existingSupplementaryLayoutAttributesInSection:section]) {
                _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:attributes];
                UXCollectionReusableView *view = _allVisibleViewsDict[key];
                if (!view) {
                    continue;
                }
                UXCollectionViewLayoutAttributes *finalAttributes = [attributes _isDecorationView]
                    ? [_layout finalLayoutAttributesForDisappearingDecorationElementOfKind:[attributes _elementKind] atIndexPath:attributes.indexPath]
                    : [_layout finalLayoutAttributesForDisappearingSupplementaryElementOfKind:[attributes _elementKind] atIndexPath:attributes.indexPath];
                if (!finalAttributes) {
                    finalAttributes = [attributes copy];
                    finalAttributes.alpha = 0.0;
                }
                UXCollectionViewAnimation *animation = [[UXCollectionViewAnimation alloc] initWithView:view
                                                                                              viewType:UXCollectionViewItemTypeSupplementaryView
                                                                                 finalLayoutAttributes:finalAttributes
                                                                                         startFraction:0.0
                                                                                           endFraction:1.0
                                                                            animateFromCurrentPosition:YES
                                                                                  deleteAfterAnimation:YES
                                                                                      customAnimations:[_layout _animationForReusableView:view toLayoutAttributes:finalAttributes type:2]];
                [_allVisibleViewsDict removeObjectForKey:key];
                [animations addObject:animation];
            }
        } else {
            deleteCellAnimation([oldModel globalIndexForItemAtIndexPath:[deleteItem _indexPath]]);
        }
    }

    UXCollectionViewAnimation *(^appearSupplementaryAnimation)(UXCollectionViewLayoutAttributes *) = ^UXCollectionViewAnimation *(UXCollectionViewLayoutAttributes *attributes) {
        BOOL isDecorationView = [attributes _isDecorationView];
        NSString *elementKind = [attributes _elementKind];
        NSIndexPath *indexPath = attributes.indexPath;
        UXCollectionViewLayoutAttributes *initialAttributes = isDecorationView
            ? [self->_layout initialLayoutAttributesForAppearingDecorationElementOfKind:elementKind atIndexPath:indexPath]
            : [self->_layout initialLayoutAttributesForAppearingSupplementaryElementOfKind:elementKind atIndexPath:indexPath];
        if (!CGRectIntersectsRect(animationRect, CGRectUnion(initialAttributes.frame, attributes.frame))) {
            return nil;
        }
        UXCollectionReusableView *view = [self _createPreparedSupplementaryViewForElementOfKind:elementKind
                                                                                    atIndexPath:indexPath
                                                                           withLayoutAttributes:initialAttributes
                                                                                applyAttributes:YES];
        if (!view) {
            return nil;
        }
        _UXCollectionViewItemKey *key = isDecorationView
            ? [_UXCollectionViewItemKey collectionItemKeyForDecorationViewOfKind:elementKind andIndexPath:indexPath]
            : [_UXCollectionViewItemKey collectionItemKeyForSupplementaryViewOfKind:elementKind andIndexPath:indexPath];
        newVisibleViewsDict[key] = view;
        [self _addControlled:YES subview:view atZIndex:attributes.zIndex];
        return [[UXCollectionViewAnimation alloc] initWithView:view
                                                      viewType:UXCollectionViewItemTypeSupplementaryView
                                         finalLayoutAttributes:attributes
                                                 startFraction:0.0
                                                   endFraction:1.0
                                    animateFromCurrentPosition:NO
                                          deleteAfterAnimation:NO
                                              customAnimations:[self->_layout _animationForReusableView:view toLayoutAttributes:attributes type:2]];
    };

    void (^insertCellAnimation)(NSInteger) = ^(NSInteger newGlobalIndex) {
        NSIndexPath *newIndexPath = [newModel indexPathForItemAtGlobalIndex:newGlobalIndex];
        UXCollectionViewLayoutAttributes *initialAttributes = [self->_layout initialLayoutAttributesForAppearingItemAtIndexPath:newIndexPath];
        UXCollectionViewLayoutAttributes *targetAttributes = [newModel layoutAttributesForItemAtIndexPath:newIndexPath];
        if (!initialAttributes) {
            initialAttributes = [targetAttributes copy];
            initialAttributes.alpha = 0.0;
        }
        if (!CGRectIntersectsRect(animationRect, CGRectUnion(initialAttributes.frame, targetAttributes.frame))) {
            return;
        }
        if (initialAttributes.isHidden && targetAttributes.isHidden) {
            return;
        }
        UXCollectionViewCell *cell = [self _createPreparedCellForItemAtIndexPath:newIndexPath
                                                            withLayoutAttributes:initialAttributes
                                                                 applyAttributes:YES];
        if (!cell) {
            return;
        }
        UXCollectionViewAnimation *animation = [[UXCollectionViewAnimation alloc] initWithView:cell
                                                                                      viewType:UXCollectionViewItemTypeCell
                                                                         finalLayoutAttributes:targetAttributes
                                                                                 startFraction:0.0
                                                                                   endFraction:1.0
                                                                    animateFromCurrentPosition:NO
                                                                          deleteAfterAnimation:NO
                                                                              customAnimations:[self->_layout _animationForReusableView:cell toLayoutAttributes:targetAttributes type:2]];
        [animations addObject:animation];
        newVisibleViewsDict[[_UXCollectionViewItemKey collectionItemKeyForCellWithIndexPath:newIndexPath]] = cell;
    };

    // Stage 2: insertions (cells through the new model; whole sections also
    // bring their supplementary views in).
    for (UXCollectionViewUpdateItem *insertItem in _insertItems) {
        if ([insertItem _isSectionOperation]) {
            NSInteger section = [[insertItem _indexPath] section];
            NSInteger itemCount = [newModel numberOfItemsInSection:section];
            if (itemCount >= 1) {
                NSInteger firstGlobalIndex = [newModel globalIndexForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
                NSAssert(firstGlobalIndex != NSNotFound, @"unexpected global item index for the first item in section %ld", (long)section);
                for (NSInteger itemOffset = 0; itemOffset < itemCount; itemOffset++) {
                    insertCellAnimation(firstGlobalIndex + itemOffset);
                }
            }
            for (UXCollectionViewLayoutAttributes *attributes in [newModel existingSupplementaryLayoutAttributesInSection:section]) {
                UXCollectionViewAnimation *animation = appearSupplementaryAnimation(attributes);
                if (animation) {
                    [animations addObject:animation];
                }
            }
        } else {
            insertCellAnimation([newModel globalIndexForItemAtIndexPath:[insertItem _indexPath]]);
        }
    }

    // Stage 3: collect target attributes for the cells that survive the update
    // (still visible) or scroll into the new visible bounds.
    NSMutableArray<UXCollectionViewLayoutAttributes *> *movedAttributesList = [[NSMutableArray alloc] init];
    for (UXCollectionReusableView *view in _allVisibleViewsDict.objectEnumerator) {
        if (![previouslyVisibleViews containsObject:view]) {
            continue;
        }
        UXCollectionViewLayoutAttributes *attributes = [(id)view _layoutAttributes];
        if (![attributes _isCell]) {
            continue;
        }
        NSInteger oldGlobalIndex = [oldModel globalIndexForItemAtIndexPath:attributes.indexPath];
        if (oldGlobalIndex == NSNotFound) {
            continue;
        }
        NSInteger newGlobalIndex = [update _oldGlobalItemMapValueAtIndex:oldGlobalIndex];
        if (newGlobalIndex != NSNotFound) {
            UXCollectionViewLayoutAttributes *newAttributes = [newModel layoutAttributesForGlobalItemIndex:newGlobalIndex];
            if (newAttributes) {
                [movedAttributesList addObject:newAttributes];
            }
        }
        [processedOldGlobalIndexes addIndex:(NSUInteger)oldGlobalIndex];
    }
    for (UXCollectionViewLayoutAttributes *attributes in [newModel layoutAttributesForElementsInRect:animationRect]) {
        if (![attributes _isCell]) {
            continue;
        }
        NSInteger newGlobalIndex = [newModel globalIndexForItemAtIndexPath:attributes.indexPath];
        if (newGlobalIndex == NSNotFound) {
            continue;
        }
        NSInteger oldGlobalIndex = [update _newGlobalItemMapValueAtIndex:newGlobalIndex];
        if (oldGlobalIndex == NSNotFound || [processedOldGlobalIndexes containsIndex:(NSUInteger)oldGlobalIndex]) {
            continue;
        }
        [movedAttributesList addObject:attributes];
    }

    // Stage 4: double-sided animations for every surviving cell.
    for (UXCollectionViewLayoutAttributes *targetAttributes in movedAttributesList) {
        if (![targetAttributes _isCell]) {
            continue;
        }
        NSIndexPath *newIndexPath = targetAttributes.indexPath;
        NSInteger newGlobalIndex = [newModel globalIndexForItemAtIndexPath:newIndexPath];
        if (newGlobalIndex == NSNotFound) {
            continue;
        }
        NSInteger oldGlobalIndex = [update _newGlobalItemMapValueAtIndex:newGlobalIndex];
        UXCollectionViewLayoutAttributes *startingAttributes = [oldModel layoutAttributesForGlobalItemIndex:oldGlobalIndex];
        _UXCollectionViewItemKey *oldKey = [_UXCollectionViewItemKey collectionItemKeyForCellWithIndexPath:[oldModel indexPathForItemAtGlobalIndex:oldGlobalIndex]];
        if (!startingAttributes) {
            startingAttributes = [(id)_allVisibleViewsDict[oldKey] _layoutAttributes];
            if (!startingAttributes) {
                startingAttributes = [_layout initialLayoutAttributesForAppearingItemAtIndexPath:[newModel indexPathForItemAtGlobalIndex:newGlobalIndex]];
                if (!startingAttributes) {
                    startingAttributes = [targetAttributes copy];
                    startingAttributes.alpha = 0.0;
                }
            }
        }
        if (!CGRectIntersectsRect(animationRect, CGRectUnion(startingAttributes.frame, targetAttributes.frame))) {
            continue;
        }
        UXCollectionReusableView *view = _allVisibleViewsDict[oldKey];
        if (!view) {
            if (startingAttributes.isHidden && targetAttributes.isHidden) {
                continue;
            }
            view = [self _createPreparedCellForItemAtIndexPath:newIndexPath withLayoutAttributes:startingAttributes applyAttributes:YES];
            if (!view) {
                continue;
            }
            newVisibleViewsDict[[_UXCollectionViewItemKey collectionItemKeyForCellWithIndexPath:newIndexPath]] = view;
        }
        if (targetAttributes.zIndex != [(id)view _layoutAttributes].zIndex) {
            [self _addControlled:YES subview:view atZIndex:targetAttributes.zIndex];
        }
        [animations addObjectsFromArray:[self _doubleSidedAnimationsForView:view
                                               withStartingLayoutAttributes:startingAttributes
                                                             startingLayout:_layout
                                                     endingLayoutAttributes:targetAttributes
                                                               endingLayout:_layout
                                                         withAnimationSetup:nil
                                                        animationCompletion:nil
                                                     enableCustomAnimations:YES
                                                       customAnimationsType:2]];
        NSAssert(![animatedNewGlobalIndexes containsIndex:(NSUInteger)newGlobalIndex],
                 @"attempt to create two animations for new global item index %ld", (long)newGlobalIndex);
        [animatedNewGlobalIndexes addIndex:(NSUInteger)newGlobalIndex];
    }

    // Stage 5: surviving and deleted supplementary views from the old model.
    for (UXCollectionViewLayoutAttributes *oldAttributes in [oldModel existingSupplementaryLayoutAttributes]) {
        NSIndexPath *oldIndexPath = oldAttributes.indexPath;
        NSInteger oldSection = (oldIndexPath.length < 2) ? NSNotFound : oldIndexPath.section;
        if ([[update _deletedSections] containsIndex:(NSUInteger)oldSection]) {
            continue;
        }
        NSString *elementKind = [oldAttributes _elementKind];
        BOOL isDecorationView = [oldAttributes _isDecorationView];
        BOOL deleted;
        if (oldSection == NSNotFound) {
            deleted = [[update _deletedSupplementaryTopLevelIndexesDict][elementKind] containsIndex:[oldIndexPath indexAtPosition:0]];
        } else {
            deleted = [[[update _deletedSupplementaryIndexesSectionArray][oldSection] valueForKey:elementKind] containsIndex:(NSUInteger)oldIndexPath.item];
        }
        if (!deleted) {
            NSIndexPath *newIndexPath = [update newIndexPathForSupplementaryElementOfKind:elementKind oldIndexPath:oldIndexPath];
            if (!newIndexPath) {
                continue;
            }
            CGRect newRect = isDecorationView
                ? [newModel rectForDecorationElementOfKind:elementKind atIndexPath:newIndexPath]
                : [newModel rectForSupplementaryElementOfKind:elementKind atIndexPath:newIndexPath];
            if (!CGRectIntersectsRect(animationRect, CGRectUnion(oldAttributes.frame, newRect))) {
                continue;
            }
            UXCollectionReusableView *view = [self _visibleSupplementaryViewOfKind:elementKind atIndexPath:oldIndexPath isDecorationView:isDecorationView];
            UXCollectionViewLayoutAttributes *newAttributes = isDecorationView
                ? [newModel layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:newIndexPath]
                : [newModel layoutAttributesForSupplementaryElementOfKind:elementKind atIndexPath:newIndexPath];
            if (!view) {
                if (oldAttributes.isHidden && newAttributes.isHidden) {
                    continue;
                }
                view = [self _createPreparedSupplementaryViewForElementOfKind:elementKind
                                                                  atIndexPath:newIndexPath
                                                         withLayoutAttributes:oldAttributes
                                                              applyAttributes:YES];
                if (!view) {
                    continue;
                }
                _UXCollectionViewItemKey *newKey = isDecorationView
                    ? [_UXCollectionViewItemKey collectionItemKeyForDecorationViewOfKind:elementKind andIndexPath:newIndexPath]
                    : [_UXCollectionViewItemKey collectionItemKeyForSupplementaryViewOfKind:elementKind andIndexPath:newIndexPath];
                newVisibleViewsDict[newKey] = view;
            }
            if (newAttributes.isFloating != [(id)view isFloatingPinned]
                || (![(id)view isFloatingPinned] && newAttributes.zIndex != [(id)view _layoutAttributes].zIndex)) {
                [self _addControlled:YES subview:view atZIndex:newAttributes.zIndex];
            }
            if (newAttributes) {
                [animations addObjectsFromArray:[self _doubleSidedAnimationsForView:view
                                                       withStartingLayoutAttributes:oldAttributes
                                                                     startingLayout:_layout
                                                             endingLayoutAttributes:newAttributes
                                                                       endingLayout:_layout
                                                                 withAnimationSetup:nil
                                                                animationCompletion:nil
                                                             enableCustomAnimations:YES
                                                               customAnimationsType:2]];
            } else {
                UXCollectionViewLayoutAttributes *finalAttributes = isDecorationView
                    ? [_layout finalLayoutAttributesForDisappearingDecorationElementOfKind:elementKind atIndexPath:oldIndexPath]
                    : [_layout finalLayoutAttributesForDisappearingSupplementaryElementOfKind:elementKind atIndexPath:oldIndexPath];
                UXCollectionViewAnimation *animation = [[UXCollectionViewAnimation alloc] initWithView:view
                                                                                              viewType:UXCollectionViewItemTypeSupplementaryView
                                                                                 finalLayoutAttributes:finalAttributes
                                                                                         startFraction:0.0
                                                                                           endFraction:1.0
                                                                            animateFromCurrentPosition:YES
                                                                                  deleteAfterAnimation:YES
                                                                                      customAnimations:[_layout _animationForReusableView:view toLayoutAttributes:finalAttributes type:2]];
                [animations addObject:animation];
                [_allVisibleViewsDict removeObjectForKey:[_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:oldAttributes]];
            }
        } else {
            UXCollectionViewLayoutAttributes *finalAttributes = isDecorationView
                ? [_layout finalLayoutAttributesForDisappearingDecorationElementOfKind:elementKind atIndexPath:oldIndexPath]
                : [_layout finalLayoutAttributesForDisappearingSupplementaryElementOfKind:elementKind atIndexPath:oldIndexPath];
            if (!CGRectIntersectsRect(animationRect, CGRectUnion(oldAttributes.frame, finalAttributes.frame))) {
                continue;
            }
            UXCollectionReusableView *view = [self _visibleSupplementaryViewOfKind:elementKind atIndexPath:oldIndexPath isDecorationView:isDecorationView];
            if (!view) {
                continue;
            }
            UXCollectionViewAnimation *animation = [[UXCollectionViewAnimation alloc] initWithView:view
                                                                                          viewType:UXCollectionViewItemTypeSupplementaryView
                                                                             finalLayoutAttributes:finalAttributes
                                                                                     startFraction:0.0
                                                                                       endFraction:1.0
                                                                        animateFromCurrentPosition:YES
                                                                              deleteAfterAnimation:YES
                                                                                  customAnimations:[_layout _animationForReusableView:view toLayoutAttributes:finalAttributes type:2]];
            [animations addObject:animation];
            [_allVisibleViewsDict removeObjectForKey:[_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:oldAttributes]];
        }
    }

    // Stage 6: supplementary views inserted by the update (per-section table,
    // then the top-level one-index table).
    NSInteger newSectionCount = [newModel numberOfSections];
    NSArray *insertedSectionArray = [update _insertedSupplementaryIndexesSectionArray];
    for (UXCollectionViewLayoutAttributes *attributes in [newModel existingSupplementaryLayoutAttributesWithMinimalIndexPathLength:2]) {
        NSIndexPath *indexPath = attributes.indexPath;
        if (indexPath.section >= newSectionCount) {
            continue;
        }
        if (![[insertedSectionArray[indexPath.section] valueForKey:[attributes _elementKind]] containsIndex:(NSUInteger)indexPath.item]) {
            continue;
        }
        UXCollectionViewAnimation *animation = appearSupplementaryAnimation(attributes);
        if (animation) {
            [animations addObject:animation];
        }
    }
    [[update _insertedSupplementaryTopLevelIndexesDict] enumerateKeysAndObjectsUsingBlock:^(NSString *elementKind, NSIndexSet *indexes, BOOL *stop) {
        BOOL isDecorationView = [[newModel knownDecorationElementKinds] containsObject:elementKind];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *innerStop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:index];
            UXCollectionViewLayoutAttributes *attributes = isDecorationView
                ? [newModel layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath]
                : [newModel layoutAttributesForSupplementaryElementOfKind:elementKind atIndexPath:indexPath];
            UXCollectionViewAnimation *animation = appearSupplementaryAnimation(attributes);
            if (animation) {
                [animations addObject:animation];
            }
        }];
    }];

    _allVisibleViewsDict = newVisibleViewsDict;
    return animations;
}

- (NSArray *)_doubleSidedAnimationsForView:(UXCollectionReusableView *)view
                withStartingLayoutAttributes:(UXCollectionViewLayoutAttributes *)startAttributes
                              startingLayout:(UXCollectionViewLayout *)startLayout
                       endingLayoutAttributes:(UXCollectionViewLayoutAttributes *)endAttributes
                                endingLayout:(UXCollectionViewLayout *)endLayout
                          withAnimationSetup:(void (^)(void))animationSetup
                          animationCompletion:(void (^)(BOOL))animationCompletion
                        enableCustomAnimations:(BOOL)enableCustomAnimations
                          customAnimationsType:(NSUInteger)customAnimationsType {
    UXCollectionViewLayoutAttributes *finalAttributes = nil;
    UXCollectionViewLayoutAttributes *initialAttributes = nil;
    if ([startAttributes _isCell]) {
        finalAttributes = [startLayout finalLayoutAttributesForDisappearingItemAtIndexPath:startAttributes.indexPath];
        initialAttributes = [endLayout initialLayoutAttributesForAppearingItemAtIndexPath:endAttributes.indexPath];
    } else if ([startAttributes _isDecorationView]) {
        finalAttributes = [[startLayout finalLayoutAttributesForDisappearingDecorationElementOfKind:[startAttributes _elementKind] atIndexPath:startAttributes.indexPath] copy];
        initialAttributes = [endLayout initialLayoutAttributesForAppearingDecorationElementOfKind:[startAttributes _elementKind] atIndexPath:endAttributes.indexPath];
    } else {
        finalAttributes = [startLayout finalLayoutAttributesForDisappearingSupplementaryElementOfKind:[startAttributes _elementKind] atIndexPath:startAttributes.indexPath];
        initialAttributes = [endLayout initialLayoutAttributesForAppearingSupplementaryElementOfKind:[startAttributes _elementKind] atIndexPath:endAttributes.indexPath];
    }
    if (!finalAttributes) {
        if (endAttributes && [initialAttributes _isEquivalentTo:startAttributes]) {
            finalAttributes = endAttributes;
        } else {
            finalAttributes = [startAttributes copy];
            finalAttributes.alpha = 0.0;
        }
    }

    NSUInteger viewType = [endAttributes _isCell] ? UXCollectionViewItemTypeCell : UXCollectionViewItemTypeSupplementaryView;
    id customAnimations = nil;
    if (enableCustomAnimations) {
        customAnimations = [endLayout _animationForReusableView:view toLayoutAttributes:endAttributes type:customAnimationsType];
    }
    UXCollectionViewAnimation *animation = [[UXCollectionViewAnimation alloc] initWithView:view
                                                                                  viewType:viewType
                                                                     finalLayoutAttributes:endAttributes
                                                                             startFraction:0.0
                                                                               endFraction:1.0
                                                                animateFromCurrentPosition:NO
                                                                      deleteAfterAnimation:NO
                                                                          customAnimations:customAnimations];
    if (animationSetup) {
        [animation addStartupHandler:animationSetup];
    }
    if (animationCompletion) {
        [animation addCompletionHandler:^{
            animationCompletion(YES);
        }];
    }
    return @[animation];
}

- (void)_updateAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(UXCollectionViewAnimationContext *)context {
    context.animationCount--;
    _updateAnimationCount--;
    if (context.animationCount != 0) {
        return;
    }
    for (UXCollectionViewAnimation *animation in context.viewAnimations) {
        NSView *animationView = animation.view;
        if ([animationView isKindOfClass:[_UXCollectionSnapshotView class]]) {
            continue;
        }
        [(id)animationView _clearUpdateAnimation];
        if (animation.resetRasterizationAfterAnimation) {
            animationView.layer.shouldRasterize = animation.rasterizeAfterAnimation;
        }
        if (![(id)animationView _isInUpdateAnimation] && !animation.deleteAfterAnimation) {
            if (!CGRectIntersectsRect(animationView.frame, [self _visibleBounds])) {
                [_allVisibleViewsDict removeObjectForKey:[_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:[(id)animationView _layoutAttributes]]];
            }
        }
        if (![_allVisibleViewsDict.allValues containsObject:animationView] && ![(id)animationView _isInUpdateAnimation]) {
            if (animation.viewType == UXCollectionViewItemTypeCell) {
                [self _reuseCell:(UXCollectionViewCell *)animationView];
            } else if (animation.viewType == UXCollectionViewItemTypeSupplementaryView) {
                [self _reuseSupplementaryView:(UXCollectionReusableView *)animationView];
            } else {
                NSAssert(NO, @"UICollectionView finished animating a view of unknown type: %@", animationView);
            }
        }
    }
    [self performWithoutAnimation:^{
        [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:NO];
    }];
    void (^completionHandler)(BOOL) = context.completionHandler;
    if (completionHandler) {
        completionHandler([finished boolValue]);
    }
}

- (void)_endItemAnimations {
    _updateCount++;
    [_doubleClickContext removeAllObjects];
    if (_collectionViewData) {
        // Step 1: retire the old model and build the new one.
        UXCollectionViewData *oldModel = _collectionViewData;
        [oldModel setLayoutLocked:YES];
        _collectionViewData = [[UXCollectionViewData alloc] initWithCollectionView:self layout:_layout];

        // Step 2: sort the four families (deletes descending, the rest ascending).
        NSArray *sortedDeletes = [[self _arrayForUpdateAction:UXCollectionUpdateActionDelete] sortedArrayUsingSelector:@selector(inverseCompareIndexPaths:)];
        NSArray *sortedInserts = [[self _arrayForUpdateAction:UXCollectionUpdateActionInsert] sortedArrayUsingSelector:@selector(compareIndexPaths:)];
        NSMutableArray *reloadItems = [[_reloadItems sortedArrayUsingSelector:@selector(compareIndexPaths:)] mutableCopy];
        NSMutableArray *moveItems = [[_moveItems sortedArrayUsingSelector:@selector(compareIndexPaths:)] mutableCopy];
        _originalDeleteItems = [sortedDeletes copy];
        _originalInsertItems = [sortedInserts copy];

        // Step 3: decompose every reload into a delete at the old position and
        // an insert at the position adjusted by the other pending operations.
        for (UXCollectionViewUpdateItem *reloadItem in reloadItems) {
            NSIndexPath *reloadIndexPath = [reloadItem _indexPath];
            NSInteger adjustedSection = reloadIndexPath.section;
            NSInteger adjustedItem = reloadIndexPath.item;
            for (UXCollectionViewUpdateItem *deleteItem in sortedDeletes) {
                NSIndexPath *deleteIndexPath = [deleteItem _indexPath];
                NSAssert(![deleteIndexPath isEqual:reloadIndexPath],
                         @"attempt to delete and reload the same index path (%@)", deleteIndexPath);
                if ([deleteItem _isSectionOperation] && deleteIndexPath.section == reloadIndexPath.section) {
                    continue;
                }
                if ([deleteItem _isSectionOperation]) {
                    adjustedSection -= (deleteIndexPath.section <= adjustedSection);
                }
                if (![reloadItem _isSectionOperation] && ![deleteItem _isSectionOperation]
                    && deleteIndexPath.section == adjustedSection) {
                    adjustedItem -= (deleteIndexPath.item <= adjustedItem);
                }
            }
            for (UXCollectionViewUpdateItem *insertItem in sortedInserts) {
                NSIndexPath *insertIndexPath = [insertItem _indexPath];
                if ([insertItem _isSectionOperation] && insertIndexPath.section <= adjustedSection) {
                    adjustedSection++;
                }
                if (![reloadItem _isSectionOperation] && ![insertItem _isSectionOperation]
                    && insertIndexPath.section == adjustedSection && insertIndexPath.item <= adjustedItem) {
                    adjustedItem++;
                }
            }
            UXCollectionViewUpdateItem *decomposedDelete = [[UXCollectionViewUpdateItem alloc] initWithAction:UXCollectionUpdateActionDelete
                                                                                                 forIndexPath:[NSIndexPath indexPathForItem:reloadIndexPath.item inSection:reloadIndexPath.section]];
            [_deleteItems addObject:decomposedDelete];
            UXCollectionViewUpdateItem *decomposedInsert = [[UXCollectionViewUpdateItem alloc] initWithAction:UXCollectionUpdateActionInsert
                                                                                                 forIndexPath:[NSIndexPath indexPathForItem:adjustedItem inSection:adjustedSection]];
            [reloadItem _setNewIndexPath:[decomposedInsert _indexPath]];
            [_insertItems addObject:decomposedInsert];
        }

        // Step 4: re-sort the merged families.
        NSMutableArray *allDeletes = [[_deleteItems sortedArrayUsingSelector:@selector(inverseCompareIndexPaths:)] mutableCopy];
        NSMutableArray *allInserts = [[_insertItems sortedArrayUsingSelector:@selector(compareIndexPaths:)] mutableCopy];

        // Step 5a: validate deletes against the old model.
        for (NSUInteger deleteIndex = 0; deleteIndex < allDeletes.count; deleteIndex++) {
            UXCollectionViewUpdateItem *deleteItem = allDeletes[deleteIndex];
            NSIndexPath *deleteIndexPath = [deleteItem _indexPath];
            if ([deleteItem _isSectionOperation]) {
                NSAssert(deleteIndexPath.section < [oldModel numberOfSections],
                         @"attempt to delete section %ld, but there are only %ld sections before the update",
                         (long)deleteIndexPath.section, (long)[oldModel numberOfSections]);
                for (NSUInteger scanIndex = 0; scanIndex < allDeletes.count;) {
                    UXCollectionViewUpdateItem *scanItem = allDeletes[scanIndex];
                    if (![scanItem _isSectionOperation]
                        && [[scanItem _indexPath] section] == deleteIndexPath.section) {
                        [allDeletes removeObjectAtIndex:scanIndex];
                        if (scanIndex < deleteIndex) {
                            deleteIndex--;
                        }
                    } else {
                        scanIndex++;
                    }
                }
                for (UXCollectionViewUpdateItem *moveItem in moveItems) {
                    NSIndexPath *moveIndexPath = [moveItem _indexPath];
                    if ([moveIndexPath isEqual:deleteIndexPath]) {
                        if ([moveItem _isSectionOperation]) {
                            NSAssert(NO, @"attempt to perform a delete and a move from the same section (%ld)", (long)deleteIndexPath.section);
                        } else {
                            NSAssert(NO, @"attempt to perform a delete and a move from the same index path (%@)", deleteIndexPath);
                        }
                    } else if ([deleteItem _isSectionOperation]
                               && deleteIndexPath.section == moveIndexPath.section) {
                        NSAssert(NO, @"cannot move an item from a deleted section (%ld)", (long)deleteIndexPath.section);
                    }
                }
            } else {
                NSAssert(deleteIndexPath.section < [oldModel numberOfSections],
                         @"attempt to delete item %ld from section %ld, but there are only %ld sections before the update",
                         (long)deleteIndexPath.item, (long)deleteIndexPath.section, (long)[oldModel numberOfSections]);
                NSAssert(deleteIndexPath.item < [oldModel numberOfItemsInSection:deleteIndexPath.section],
                         @"attempt to delete item %ld from section %ld which only contains %ld items before the update",
                         (long)deleteIndexPath.item, (long)deleteIndexPath.section,
                         (long)[oldModel numberOfItemsInSection:deleteIndexPath.section]);
            }
        }

        // Step 5b: validate inserts against the new model.
        for (NSUInteger insertIndex = 0; insertIndex < allInserts.count; insertIndex++) {
            UXCollectionViewUpdateItem *insertItem = allInserts[insertIndex];
            NSIndexPath *insertIndexPath = [insertItem _indexPath];
            if ([insertItem _isSectionOperation]) {
                NSAssert(insertIndexPath.section < [_collectionViewData numberOfSections],
                         @"attempt to insert section %ld but there are only %ld sections after the update",
                         (long)insertIndexPath.section, (long)[_collectionViewData numberOfSections]);
                for (NSUInteger scanIndex = 0; scanIndex < allInserts.count;) {
                    UXCollectionViewUpdateItem *scanItem = allInserts[scanIndex];
                    if (![scanItem _isSectionOperation]
                        && [[scanItem _indexPath] section] == insertIndexPath.section) {
                        [allInserts removeObjectAtIndex:scanIndex];
                        if (scanIndex < insertIndex) {
                            insertIndex--;
                        }
                    } else {
                        scanIndex++;
                    }
                }
                for (UXCollectionViewUpdateItem *moveItem in moveItems) {
                    if ([[moveItem _newIndexPath] isEqual:insertIndexPath]) {
                        if ([moveItem _isSectionOperation]) {
                            NSAssert(NO, @"attempt to perform an insert and a move to the same section (%ld)", (long)insertIndexPath.section);
                        } else {
                            NSAssert(NO, @"attempt to perform an insert and a move to the same index path (%@)", insertIndexPath);
                        }
                    } else if ([insertItem _isSectionOperation]
                               && insertIndexPath.section == [[moveItem _newIndexPath] section]) {
                        NSAssert(NO, @"cannot move an item into a newly inserted section (%ld)", (long)insertIndexPath.section);
                    }
                }
            } else {
                NSAssert(insertIndexPath.section < [_collectionViewData numberOfSections],
                         @"attempt to insert item %ld into section %ld, but there are only %ld sections after the update",
                         (long)insertIndexPath.item, (long)insertIndexPath.section, (long)[_collectionViewData numberOfSections]);
                NSAssert(insertIndexPath.item < [_collectionViewData numberOfItemsInSection:insertIndexPath.section],
                         @"attempt to insert item %ld into section %ld, but there are only %ld items in section %ld after the update",
                         (long)insertIndexPath.item, (long)insertIndexPath.section,
                         (long)[_collectionViewData numberOfItemsInSection:insertIndexPath.section], (long)insertIndexPath.section);
            }
        }

        // Step 5c: validate moves on both sides and drop exact duplicates.
        for (NSUInteger moveIndex = 0; moveIndex < moveItems.count; moveIndex++) {
            UXCollectionViewUpdateItem *moveItem = moveItems[moveIndex];
            NSIndexPath *fromIndexPath = [moveItem _indexPath];
            NSIndexPath *toIndexPath = [moveItem _newIndexPath];
            if ([moveItem _isSectionOperation]) {
                NSAssert(fromIndexPath.section < [oldModel numberOfSections],
                         @"attempt to move section %ld, but there are only %ld sections before the update",
                         (long)fromIndexPath.section, (long)[oldModel numberOfSections]);
                NSAssert(toIndexPath.section < [_collectionViewData numberOfSections],
                         @"attempt to to move section %ld to section %ld, but there are only %ld sections after the update",
                         (long)fromIndexPath.section, (long)toIndexPath.section, (long)[_collectionViewData numberOfSections]);
            } else {
                NSAssert(fromIndexPath.section < [oldModel numberOfSections],
                         @"attempt to move index path (%@) from a section that does not exist - there are only %ld sections before the update",
                         fromIndexPath, (long)[oldModel numberOfSections]);
                NSAssert(fromIndexPath.item < [oldModel numberOfItemsInSection:fromIndexPath.section],
                         @"attempt to move index path (%@) that does not exist - there are only %ld items in section %ld before the update",
                         fromIndexPath, (long)[oldModel numberOfItemsInSection:fromIndexPath.section], (long)fromIndexPath.section);
                NSAssert(toIndexPath.section < [_collectionViewData numberOfSections],
                         @"attempt to move index path (%@) to index path (%@) in section that does not exist - there are only %ld sections after the update",
                         fromIndexPath, toIndexPath, (long)[_collectionViewData numberOfSections]);
                NSAssert(toIndexPath.item < [_collectionViewData numberOfItemsInSection:toIndexPath.section],
                         @"attempt to move index path (%@) to index path (%@) that does not exist - there are only %ld items in section %ld after the update",
                         fromIndexPath, toIndexPath, (long)[_collectionViewData numberOfItemsInSection:toIndexPath.section], (long)toIndexPath.section);
            }
            for (NSUInteger scanIndex = moveIndex + 1; scanIndex < moveItems.count;) {
                UXCollectionViewUpdateItem *scanItem = moveItems[scanIndex];
                BOOL sameSource = [fromIndexPath isEqual:[scanItem _indexPath]];
                BOOL sameDestination = [toIndexPath isEqual:[scanItem _newIndexPath]];
                if (sameSource && sameDestination) {
                    [moveItems removeObjectAtIndex:scanIndex];
                    continue;
                }
                if (sameSource) {
                    if ([moveItem _isSectionOperation]) {
                        NSAssert(NO, @"attempt to move section %ld to both section %ld and section %ld",
                                 (long)fromIndexPath.section, (long)toIndexPath.section, (long)[[scanItem _newIndexPath] section]);
                    } else {
                        NSAssert(NO, @"attempt to move item at index path %@ to both %@ and %@",
                                 fromIndexPath, toIndexPath, [scanItem _newIndexPath]);
                    }
                } else if (sameDestination) {
                    if ([moveItem _isSectionOperation]) {
                        NSAssert(NO, @"attempt to move both section %ld and section %ld to section %ld",
                                 (long)fromIndexPath.section, (long)[[scanItem _indexPath] section], (long)toIndexPath.section);
                    } else {
                        NSAssert(NO, @"attempt to move both item at index path %@ and %@ to %@",
                                 fromIndexPath, [scanItem _indexPath], toIndexPath);
                    }
                }
                scanIndex++;
            }
        }

        // Step 6: assemble the final update vector — descending deletes, moves,
        // ascending inserts. This ordering is what _computeGaps expects.
        NSMutableArray *allUpdateItems = [[NSMutableArray alloc] init];
        [allUpdateItems addObjectsFromArray:[allDeletes sortedArrayUsingSelector:@selector(inverseCompareIndexPaths:)]];
        [allUpdateItems addObjectsFromArray:moveItems];
        [allUpdateItems addObjectsFromArray:[allInserts sortedArrayUsingSelector:@selector(compareIndexPaths:)]];

        // Step 7: invalidate the layout with the update items and load the new model.
        UXCollectionViewLayoutInvalidationContext *invalidationContext = [[[[_layout class] invalidationContextClass] alloc] init];
        [invalidationContext _setInvalidateDataSourceCounts:YES];
        [invalidationContext _setUpdateItems:allUpdateItems];
        [_layout _invalidateLayoutUsingContext:invalidationContext];
        [_collectionViewData _prepareToLoadData];
        [_collectionViewData validateLayoutInRect:[self _visibleBounds]];

        // Step 8: compute the new visible bounds, pulling the viewport back in
        // when it now hangs past the shrunken content rect.
        CGRect oldVisibleBounds = [self documentVisibleRect];
        CGRect contentRect = [_collectionViewData collectionViewContentRect];
        NSEdgeInsets contentInsets = [self contentInsets];
        contentRect.size.width += contentInsets.left + contentInsets.right;
        contentRect.size.height += contentInsets.top + contentInsets.bottom;
        CGPoint newVisibleOrigin = oldVisibleBounds.origin;
        if (!CGRectContainsRect(contentRect, oldVisibleBounds)) {
            if (CGRectGetMaxY(oldVisibleBounds) > CGRectGetMaxY(contentRect)
                && CGRectGetHeight(contentRect) > CGRectGetHeight(oldVisibleBounds)) {
                newVisibleOrigin.y -= CGRectGetMaxY(oldVisibleBounds) - CGRectGetMaxY(contentRect);
            }
            if (CGRectGetMaxX(oldVisibleBounds) > CGRectGetMaxX(contentRect)
                && CGRectGetWidth(contentRect) > CGRectGetWidth(oldVisibleBounds)) {
                newVisibleOrigin.x -= CGRectGetMaxX(oldVisibleBounds) - CGRectGetMaxX(contentRect);
            }
        }

        // Step 9: build the update object, run the count consistency checks and
        // hand over to _updateWithItems:.
        _currentUpdate = [[UXCollectionViewUpdate alloc] initWithCollectionView:self
                                                                    updateItems:allUpdateItems
                                                                       oldModel:oldModel
                                                                       newModel:_collectionViewData
                                                               oldVisibleBounds:oldVisibleBounds
                                                               newVisibleBounds:CGRectMake(newVisibleOrigin.x, newVisibleOrigin.y,
                                                                                           oldVisibleBounds.size.width, oldVisibleBounds.size.height)];

        NSInteger oldSectionCount = [oldModel numberOfSections];
        NSInteger newSectionCount = [_collectionViewData numberOfSections];
        NSInteger *oldItemCounts = calloc((size_t)MAX(oldSectionCount, 1), sizeof(NSInteger));
        NSInteger *insertedCounts = calloc((size_t)MAX(newSectionCount, 1), sizeof(NSInteger));
        NSInteger *deletedCounts = calloc((size_t)MAX(oldSectionCount, 1), sizeof(NSInteger));
        NSInteger *movedInCounts = calloc((size_t)MAX(newSectionCount, 1), sizeof(NSInteger));
        NSInteger *movedOutCounts = calloc((size_t)MAX(oldSectionCount, 1), sizeof(NSInteger));
        for (NSInteger section = 0; section < oldSectionCount; section++) {
            oldItemCounts[section] = [oldModel numberOfItemsInSection:section];
        }
        NSInteger insertedSectionCount = 0;
        NSInteger deletedSectionCount = 0;
        NSInteger expectedSectionCount = oldSectionCount;
        for (UXCollectionViewUpdateItem *updateItem in allUpdateItems) {
            NSInteger section = [[updateItem _indexPath] section];
            if ([updateItem _isSectionOperation]) {
                if ([updateItem _action] == UXCollectionUpdateActionInsert) {
                    insertedSectionCount++;
                    expectedSectionCount++;
                } else if ([updateItem _action] == UXCollectionUpdateActionDelete) {
                    deletedSectionCount++;
                    expectedSectionCount--;
                }
            } else if ([updateItem _action] == UXCollectionUpdateActionInsert) {
                insertedCounts[section]++;
            } else if ([updateItem _action] == UXCollectionUpdateActionDelete) {
                deletedCounts[section]++;
            } else if ([updateItem _action] == UXCollectionUpdateActionMove) {
                NSInteger destinationSection = [[updateItem _newIndexPath] section];
                if (section != destinationSection) {
                    movedOutCounts[section]++;
                    movedInCounts[destinationSection]++;
                }
            }
        }
        BOOL updateIsValid = YES;
        if (expectedSectionCount != newSectionCount) {
            NSAssert(NO, @"Invalid update: invalid number of sections.  The number of sections contained in the collection view after the update (%ld) must be equal to the number of sections contained in the collection view before the update (%ld), plus or minus the number of sections inserted or deleted (%ld inserted, %ld deleted).",
                     (long)newSectionCount, (long)oldSectionCount, (long)insertedSectionCount, (long)deletedSectionCount);
        }
        for (NSInteger newSection = 0; newSection < newSectionCount; newSection++) {
            NSInteger oldSection = [_currentUpdate _newSectionMapValueAtIndex:newSection];
            if (oldSection == NSNotFound) {
                continue;
            }
            NSInteger newItemCount = [_collectionViewData numberOfItemsInSection:newSection];
            if (newItemCount < 0) {
                NSAssert(NO, @"Invalid update: invalid number of items in section %ld.  Attempt to delete more items than exist in section.", (long)oldSection);
                updateIsValid = NO;
            }
            NSInteger expectedItemCount = oldItemCounts[oldSection] + insertedCounts[newSection] + movedInCounts[newSection]
                                        - (deletedCounts[oldSection] + movedOutCounts[oldSection]);
            if (newItemCount != expectedItemCount) {
                NSAssert(NO, @"Invalid update: invalid number of items in section %ld.  The number of items contained in an existing section after the update (%ld) must be equal to the number of items contained in that section before the update (%ld), plus or minus the number of items inserted or deleted from that section (%ld inserted, %ld deleted) and plus or minus the number of items moved into or out of that section (%ld moved in, %ld moved out).",
                         (long)newSection, (long)newItemCount, (long)oldItemCounts[oldSection],
                         (long)insertedCounts[newSection], (long)deletedCounts[oldSection],
                         (long)movedInCounts[newSection], (long)movedOutCounts[oldSection]);
                updateIsValid = NO;
            }
        }
        free(oldItemCounts);
        free(insertedCounts);
        free(deletedCounts);
        free(movedInCounts);
        free(movedOutCounts);

        if (updateIsValid) {
            [self _updateWithItems:allUpdateItems];
        }
    }
    _updateCount--;
    _insertItems = nil;
    _deleteItems = nil;
    _reloadItems = nil;
    _moveItems = nil;
    _originalDeleteItems = nil;
    _originalInsertItems = nil;
    _collectionViewFlags.updating = NO;
    [self _resumeReloads];
}

- (void)_prepareLayoutForUpdates {
    NSMutableArray *sortedUpdateItems = [[NSMutableArray alloc] init];
    [sortedUpdateItems addObjectsFromArray:[_originalDeleteItems sortedArrayUsingSelector:@selector(compareIndexPaths:)]];
    [sortedUpdateItems addObjectsFromArray:[_originalInsertItems sortedArrayUsingSelector:@selector(compareIndexPaths:)]];
    [sortedUpdateItems addObjectsFromArray:[_reloadItems sortedArrayUsingSelector:@selector(compareIndexPaths:)]];
    [sortedUpdateItems addObjectsFromArray:[_moveItems sortedArrayUsingSelector:@selector(compareIndexPaths:)]];
    [_layout prepareForCollectionViewUpdates:sortedUpdateItems];
}

- (NSMutableArray *)_arrayForUpdateAction:(NSInteger)updateAction {
    switch (updateAction) {
        case UXCollectionUpdateActionInsert:
            if (!_insertItems) {
                _insertItems = [[NSMutableArray alloc] init];
            }
            return _insertItems;
        case UXCollectionUpdateActionDelete:
            if (!_deleteItems) {
                _deleteItems = [[NSMutableArray alloc] init];
            }
            return _deleteItems;
        case UXCollectionUpdateActionReload:
            if (!_reloadItems) {
                _reloadItems = [[NSMutableArray alloc] init];
            }
            return _reloadItems;
        case UXCollectionUpdateActionMove:
            if (!_moveItems) {
                _moveItems = [[NSMutableArray alloc] init];
            }
            return _moveItems;
        default:
            NSAssert(NO, @"Invalid update action encountered %ld", (long)updateAction);
            return nil;
    }
}

- (void)_updateRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths updateAction:(NSInteger)updateAction {
    if (![self _visible]) {
        _collectionViewFlags.needsReload = YES;
        return;
    }
    [self _reloadDataIfNeeded];
    BOOL wasUpdating = _collectionViewFlags.updating;
    if (!wasUpdating) {
        [self _setupCellAnimations];
    }
    NSMutableArray *target = [self _arrayForUpdateAction:updateAction];
    for (NSIndexPath *indexPath in indexPaths) {
        UXCollectionViewUpdateItem *item = [[UXCollectionViewUpdateItem alloc] initWithAction:updateAction forIndexPath:indexPath];
        [target addObject:item];
    }
    if (!wasUpdating) {
        [self _endItemAnimations];
    }
}

- (void)_updateSections:(NSIndexSet *)sections updateAction:(NSInteger)updateAction {
    if (![self _visible]) {
        _collectionViewFlags.needsReload = YES;
        return;
    }
    [self _reloadDataIfNeeded];
    BOOL wasUpdating = _collectionViewFlags.updating;
    if (!wasUpdating) {
        [self _setupCellAnimations];
    }
    NSMutableArray *target = [self _arrayForUpdateAction:updateAction];
    [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
        UXCollectionViewUpdateItem *item = [[UXCollectionViewUpdateItem alloc] initWithAction:updateAction
                                                                                 forIndexPath:[NSIndexPath indexPathForItem:NSNotFound inSection:(NSInteger)section]];
        [target addObject:item];
    }];
    if (!wasUpdating) {
        [self _endItemAnimations];
    }
}

- (void)_updateWithItems:(NSArray *)items {
    UXCollectionViewUpdate *update = _currentUpdate;
    UXCollectionViewData *oldModel = [update _oldModel];

    // Remap every selection-related index path container from the old model to
    // the new one through the update's global item map.
    NSIndexPath *(^adjustedIndexPath)(NSIndexPath *) = ^NSIndexPath *(NSIndexPath *indexPath) {
        if (!indexPath) {
            return nil;
        }
        NSInteger oldGlobalIndex = [oldModel globalIndexForItemAtIndexPath:indexPath];
        if (oldGlobalIndex == NSNotFound) {
            return nil;
        }
        NSInteger newGlobalIndex = [update _oldGlobalItemMapValueAtIndex:oldGlobalIndex];
        if (newGlobalIndex == NSNotFound) {
            return nil;
        }
        return [self->_collectionViewData indexPathForItemAtGlobalIndex:newGlobalIndex];
    };
    UXCollectionViewMutableIndexPathsSet *(^adjustedIndexPathsSet)(UXCollectionViewIndexPathsSet *) = ^(UXCollectionViewIndexPathsSet *indexPathsSet) {
        UXCollectionViewMutableIndexPathsSet *adjustedSet = [[UXCollectionViewMutableIndexPathsSet alloc] init];
        [indexPathsSet enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
            NSIndexPath *adjusted = adjustedIndexPath(indexPath);
            if (adjusted) {
                [adjustedSet addIndexPath:adjusted];
            }
        }];
        return adjustedSet;
    };
    _indexPathsForSelectedItems = adjustedIndexPathsSet(_indexPathsForSelectedItems);
    _pendingDeselectionIndexPaths = adjustedIndexPathsSet(_pendingDeselectionIndexPaths);
    _lassoInitiallySelectedItems = adjustedIndexPathsSet(_lassoInitiallySelectedItems);
    _keyboardRangeSelectionPreviouslySelectedItems = adjustedIndexPathsSet(_keyboardRangeSelectionPreviouslySelectedItems);
    _pendingSelectionIndexPath = adjustedIndexPath(_pendingSelectionIndexPath);
    _lastSelectionAnchorIndexPath = adjustedIndexPath(_lastSelectionAnchorIndexPath);
    _keyboardRangeSelectionFirstSelectedItem = adjustedIndexPath(_keyboardRangeSelectionFirstSelectedItem);
    _keyboardRangeSelectionLastSelectedItem = adjustedIndexPath(_keyboardRangeSelectionLastSelectedItem);

    [self _prepareLayoutForUpdates];
    [update _computeSupplementaryUpdates];

    CGPoint proposedContentOffset = [update _newVisibleBounds].origin;
    proposedContentOffset = [_layout updatesContentOffsetForProposedContentOffset:proposedContentOffset];
    proposedContentOffset = [_layout targetContentOffsetForProposedContentOffset:proposedContentOffset];
    if (_collectionViewFlags.delegateTargetContentOffsetForProposedContentOffset) {
        proposedContentOffset = [(id)self.delegate _collectionView:self targetContentOffsetForProposedContentOffset:proposedContentOffset];
    }
    CGRect newVisibleBounds = [update _newVisibleBounds];
    newVisibleBounds.origin = proposedContentOffset;
    [update _setNewVisibleBounds:newVisibleBounds];

    UXCollectionViewAnimationContext *animationContext = [[UXCollectionViewAnimationContext alloc] initWithCompletionHandler:_updateCompletionHandler];
    _updateCompletionHandler = nil;
    _suspendClipViewBoundsDidChange++;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *animationGroupContext) {
        if (![CATransaction disableActions]) {
            animationGroupContext.allowsImplicitAnimation = YES;
            animationGroupContext.duration = 0.25;
        }
        if (!animationGroupContext.timingFunction) {
            animationGroupContext.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        }
        self->_updateAnimationCount++;
        animationContext.animationCount++;
        [self setContentSize:[self->_layout collectionViewContentSize]];
        [self.contentView setBoundsOrigin:[self->_currentUpdate _newVisibleBounds].origin];

        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *innerContext) {
            innerContext.allowsImplicitAnimation = NO;
            innerContext.duration = 0.0;
            animationContext.viewAnimations = [self _viewAnimationsForCurrentUpdate];
        } completionHandler:nil];

        NSMutableSet *remainingViews = [[NSMutableSet alloc] initWithArray:self->_allVisibleViewsDict.allValues];
        [self->_allVisibleViewsDict removeAllObjects];
        for (UXCollectionViewAnimation *animation in animationContext.viewAnimations) {
            NSView *animationView = animation.view;
            if (![animationView isKindOfClass:[_UXCollectionSnapshotView class]]) {
                [(id)animationView _addUpdateAnimation];
                [remainingViews removeObject:animationView];
                if (!animation.deleteAfterAnimation) {
                    self->_allVisibleViewsDict[[_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:animation.finalLayoutAttributes]] = animationView;
                }
            }
            animationContext.animationCount++;
            self->_updateAnimationCount++;
            [animation addCompletionHandler:^{
                [self _updateAnimationDidStop:nil finished:@YES context:animationContext];
            }];
            [animation start];
        }
        for (UXCollectionReusableView *remainingView in remainingViews) {
            if ([remainingView _isInUpdateAnimation]) {
                self->_allVisibleViewsDict[[_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:[(id)remainingView _layoutAttributes]]] = remainingView;
            } else if ([[(id)remainingView _layoutAttributes] _isCell]) {
                [self _reuseCell:(UXCollectionViewCell *)remainingView];
            } else {
                [self _reuseSupplementaryView:remainingView];
            }
        }
        [self->_layout finalizeCollectionViewUpdates];
    } completionHandler:^{
        self->_suspendClipViewBoundsDidChange--;
        [self _updateAnimationDidStop:nil finished:@YES context:animationContext];
    }];
    _currentUpdate = nil;
}

- (void)_addMoveUpdateItemFromIndexPath:(NSIndexPath *)initialIndexPath toIndexPath:(NSIndexPath *)finalIndexPath {
    if (![self _visible]) {
        _collectionViewFlags.needsReload = YES;
        return;
    }
    [self _reloadDataIfNeeded];
    BOOL wasUpdating = _collectionViewFlags.updating;
    if (!wasUpdating) {
        [self _setupCellAnimations];
    }
    UXCollectionViewUpdateItem *item = [[UXCollectionViewUpdateItem alloc] initWithInitialIndexPath:initialIndexPath
                                                                                     finalIndexPath:finalIndexPath
                                                                                       updateAction:UXCollectionUpdateActionMove];
    [[self _arrayForUpdateAction:UXCollectionUpdateActionMove] addObject:item];
    if (!wasUpdating) {
        [self _endItemAnimations];
    }
}

- (void)insertSections:(NSIndexSet *)sections {
    [self _updateSections:sections updateAction:UXCollectionUpdateActionInsert];
}

- (void)deleteSections:(NSIndexSet *)sections {
    [self _updateSections:sections updateAction:UXCollectionUpdateActionDelete];
}

- (void)reloadSections:(NSIndexSet *)sections {
    [self _updateSections:sections updateAction:UXCollectionUpdateActionReload];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    [self _addMoveUpdateItemFromIndexPath:[NSIndexPath indexPathForItem:NSNotFound inSection:section]
                              toIndexPath:[NSIndexPath indexPathForItem:NSNotFound inSection:newSection]];
}

- (void)insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self _updateRowsAtIndexPaths:indexPaths updateAction:UXCollectionUpdateActionInsert];
}

- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self _updateRowsAtIndexPaths:indexPaths updateAction:UXCollectionUpdateActionDelete];
}

- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self _updateRowsAtIndexPaths:indexPaths updateAction:UXCollectionUpdateActionReload];
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self _addMoveUpdateItemFromIndexPath:indexPath toIndexPath:newIndexPath];
}

#pragma mark - Layout

- (void)layoutSubviews {
    if (_collectionViewFlags.updatingLayout || _collectionViewFlags.skipLayoutDuringSnapshotting) {
        return;
    }
    [self _reloadDataIfNeeded];
    [_collectionViewData validateLayoutInRect:[self _visibleBounds]];
    if (_collectionViewFlags.scheduledUpdateVisibleCells && _reloadingSuspendedCount == 0) {
        @autoreleasepool {
            [self _updateVisibleCellsNow:YES];
        }
    }
    _collectionViewFlags.doneFirstLayout = YES;
    _doneFirstLayout = YES;
}

- (void)setNeedsLayout {
    if (self.layoutSubviewsOnSetNeedsLayout) {
        [self layoutSubviews];
    } else {
        [self setNeedsLayout:YES];
    }
}

- (void)layout {
    [super layout];
    // AppKit drives -layout; UXKit routes the work through -layoutSubviews so
    // the scheduled-update flags decide whether visible cells refresh.
    [self layoutSubviews];
}

#pragma mark - Drag & drop hooks

- (NSInteger)allowedDropPositionsForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths movedToIndexPath:(NSIndexPath *)indexPath {
    id<UXCollectionViewDelegate> delegate = self.delegate;
    SEL selector = NSSelectorFromString(@"collectionView:allowedDropPositionsForItemsAtIndexPaths:movedToIndexPath:");
    if ([delegate respondsToSelector:selector]) {
        NSMethodSignature *signature = [(NSObject *)delegate methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = delegate;
        invocation.selector = selector;
        UXCollectionView *me = self;
        [invocation setArgument:&me atIndex:2];
        [invocation setArgument:&indexPaths atIndex:3];
        [invocation setArgument:&indexPath atIndex:4];
        [invocation invoke];
        NSInteger value = 0;
        [invocation getReturnValue:&value];
        return value;
    }
    return 0;
}

- (NSUInteger)dragOperationForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths movedOntoItemAtIndexPath:(NSIndexPath *)indexPath {
    return NSDragOperationNone;
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender {
}

- (void)draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)point {
}

- (void)draggingSession:(NSDraggingSession *)session movedToPoint:(NSPoint)point {
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)point operation:(NSDragOperation)operation {
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    return NSDragOperationCopy | NSDragOperationMove;
}

- (BOOL)wantsPeriodicDraggingUpdates {
    return YES;
}

- (void)updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo {
}

#pragma mark - Rearranging

- (BOOL)isRearranging_ {
    return [_rearrangingCoordinator isRearranging];
}

- (BOOL)rearrangingEnabled_ {
    return _rearrangingEnabled;
}

- (void)setRearrangingEnabled_:(BOOL)rearrangingEnabled {
    _rearrangingEnabled = rearrangingEnabled;
    if (rearrangingEnabled && !_rearrangingCoordinator) {
        _rearrangingCoordinator = [[_UXCollectionViewRearrangingCoordinator alloc] init];
    }
}

- (BOOL)rearrangingAllowAutoscroll_ {
    return _rearrangingAllowAutoscroll;
}

- (void)setRearrangingAllowAutoscroll_:(BOOL)allowAutoscroll {
    _rearrangingAllowAutoscroll = allowAutoscroll;
}

- (BOOL)rearrangingExternalDropEnabled_ {
    return _rearrangingExternalDropEnabled;
}

- (void)setRearrangingExternalDropEnabled_:(BOOL)externalDropEnabled {
    _rearrangingExternalDropEnabled = externalDropEnabled;
}

- (NSInteger)rearrangingInitiationMode_ {
    return _rearrangingInitiationMode;
}

- (void)setRearrangingInitiationMode_:(NSInteger)mode {
    _rearrangingInitiationMode = mode;
}

- (BOOL)rearrangingContinuouslyUpdateInsideCells_ {
    return _rearrangingContinuouslyUpdateInsideCells;
}

- (void)setRearrangingContinuouslyUpdateInsideCells_:(BOOL)continuouslyUpdate {
    _rearrangingContinuouslyUpdateInsideCells = continuouslyUpdate;
}

- (CGFloat)rearrangingPreviewDelay_ {
    return _rearrangingPreviewDelay;
}

- (void)setRearrangingPreviewDelay_:(CGFloat)delay {
    _rearrangingPreviewDelay = delay;
}

- (_UXCollectionViewRearrangingCoordinator *)_rearrangingCoordinator {
    return _rearrangingCoordinator;
}

- (void)rearrangingCoordinatorReloadLayout_ {
    [self updateLayout];
}

#pragma mark - Mouse / Key Selection

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)mouseDown:(NSEvent *)event {
    id<UXCollectionViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(collectionView:mouseDownWithEvent:)]) {
        [delegate collectionView:self mouseDownWithEvent:event];
    }
    NSIndexPath *hitIndexPath = [self _indexPathOfSelectableItemHitByEvent:event];
    if (hitIndexPath) {
        UXCollectionViewCell *cell = [self cellForItemAtIndexPath:hitIndexPath];
        [self _performItemSelectionForMouseEvent:event onCell:cell atIndexPath:hitIndexPath];
        if (event.clickCount == 2 && [delegate respondsToSelector:@selector(collectionView:itemWasDoubleClickedAtIndexPath:withEvent:)]) {
            [delegate collectionView:self itemWasDoubleClickedAtIndexPath:hitIndexPath withEvent:event];
        }
        [super mouseDown:event];
        return;
    }

    NSEventModifierFlags modifiers = event.modifierFlags;
    BOOL shiftHeld = (modifiers & NSEventModifierFlagShift) != 0;

    if (_allowsLassoSelection && _allowsMultipleSelection) {
        [self _beginLassoSelectionAtEvent:event extending:shiftHeld];
        [super mouseDown:event];
        return;
    }
    if (_allowsPaintingSelection && _allowsMultipleSelection) {
        [self _beginPaintingSelectionAtEvent:event];
        [super mouseDown:event];
        return;
    }

    if (_allowsEmptySelection && !shiftHeld) {
        [self _deselectAllAnimated:YES notifyDelegate:YES];
    }
    [super mouseDown:event];
}

- (void)mouseDragged:(NSEvent *)event {
    if (_lassoSelectionLayer) {
        [self _updateLassoSelectionAtEvent:event];
        return;
    }
    if (_isPaintingSelectionRunning) {
        [self _updatePaintingSelectionAtEvent:event];
        return;
    }
    [super mouseDragged:event];
}

- (void)mouseUp:(NSEvent *)event {
    if (_lassoSelectionLayer) {
        [self _endLassoSelectionAtEvent:event];
        return;
    }
    if (_isPaintingSelectionRunning) {
        [self _endPaintingSelectionAtEvent:event];
        return;
    }
    [super mouseUp:event];
}

#pragma mark - Lasso selection

- (NSPoint)_lassoPointForEvent:(NSEvent *)event {
    return [_collectionDocumentView convertPoint:event.locationInWindow fromView:nil];
}

- (void)_beginLassoSelectionAtEvent:(NSEvent *)event extending:(BOOL)extending {
    _lassoSelectionStartPoint = [self _lassoPointForEvent:event];
    _lassoInitiallySelectedItems = extending
        ? [[UXCollectionViewIndexPathsSet alloc] initWithIndexPathsSet:_indexPathsForSelectedItems]
        : [UXCollectionViewIndexPathsSet indexPathsSet];

    if (!extending) {
        [self _deselectAllAnimated:NO notifyDelegate:YES];
    }

    CALayer *layer = [CALayer layer];
    layer.borderColor = [NSColor selectedControlColor].CGColor;
    layer.borderWidth = 1.0;
    layer.backgroundColor = [[NSColor selectedControlColor] colorWithAlphaComponent:0.15].CGColor;
    layer.frame = CGRectMake(_lassoSelectionStartPoint.x, _lassoSelectionStartPoint.y, 0.0, 0.0);
    layer.zPosition = 9999.0;
    _collectionDocumentView.wantsLayer = YES;
    [_collectionDocumentView.layer addSublayer:layer];
    _lassoSelectionLayer = layer;
}

- (void)_updateLassoSelectionAtEvent:(NSEvent *)event {
    NSPoint current = [self _lassoPointForEvent:event];
    CGRect rect = CGRectMake(MIN(_lassoSelectionStartPoint.x, current.x),
                             MIN(_lassoSelectionStartPoint.y, current.y),
                             fabs(current.x - _lassoSelectionStartPoint.x),
                             fabs(current.y - _lassoSelectionStartPoint.y));
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _lassoSelectionLayer.frame = rect;
    [CATransaction commit];

    NSArray<UXCollectionViewLayoutAttributes *> *hits = [_collectionViewData layoutAttributesForElementsInRect:rect];
    UXCollectionViewMutableIndexPathsSet *enclosed = [[UXCollectionViewMutableIndexPathsSet alloc] init];
    for (UXCollectionViewLayoutAttributes *attributes in hits) {
        if (![attributes _isCell]) {
            continue;
        }
        if (![self selectableItemAtIndexPath:attributes.indexPath]) {
            continue;
        }
        [enclosed addIndexPath:attributes.indexPath];
    }

    UXCollectionViewMutableIndexPathsSet *targetSet = [[UXCollectionViewMutableIndexPathsSet alloc] init];
    if (_lassoInvertsSelection) {
        [targetSet addIndexPathsSet:_lassoInitiallySelectedItems];
        [enclosed enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
            if ([targetSet containsIndexPath:indexPath]) {
                [targetSet removeIndexPath:indexPath];
            } else {
                [targetSet addIndexPath:indexPath];
            }
        }];
    } else {
        [targetSet addIndexPathsSet:_lassoInitiallySelectedItems];
        [targetSet addIndexPathsSet:enclosed];
    }

    [self _selectItemsInIndexPathsSet:targetSet
                 byExtendingSelection:NO
                             animated:NO
                     scrollingKeyItem:nil
                           toPosition:UXCollectionViewScrollPositionNone
                       notifyDelegate:YES];
}

- (void)_endLassoSelectionAtEvent:(NSEvent *)event {
    [_lassoSelectionLayer removeFromSuperlayer];
    _lassoSelectionLayer = nil;
    _lassoInitiallySelectedItems = nil;
}

#pragma mark - Painting selection

- (void)_beginPaintingSelectionAtEvent:(NSEvent *)event {
    _isPaintingSelectionRunning = YES;
    NSIndexPath *indexPath = [self _indexPathOfSelectableItemHitByEvent:event];
    if (indexPath) {
        BOOL alreadySelected = [_indexPathsForSelectedItems containsIndexPath:indexPath];
        _paintingSelectionType = !alreadySelected;
        if (_paintingSelectionType) {
            UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPath:indexPath];
            [self _selectItemsInIndexPathsSet:set byExtendingSelection:YES animated:NO scrollingKeyItem:nil toPosition:UXCollectionViewScrollPositionNone notifyDelegate:YES];
        } else {
            [self _deselectItemsAtIndexPaths:@[indexPath] animated:NO notifyDelegate:YES];
        }
    }
}

- (void)_updatePaintingSelectionAtEvent:(NSEvent *)event {
    NSIndexPath *indexPath = [self _indexPathOfSelectableItemHitByEvent:event];
    if (!indexPath) {
        return;
    }
    BOOL alreadySelected = [_indexPathsForSelectedItems containsIndexPath:indexPath];
    if (_paintingSelectionType && !alreadySelected) {
        UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPath:indexPath];
        [self _selectItemsInIndexPathsSet:set byExtendingSelection:YES animated:NO scrollingKeyItem:nil toPosition:UXCollectionViewScrollPositionNone notifyDelegate:YES];
    } else if (!_paintingSelectionType && alreadySelected) {
        [self _deselectItemsAtIndexPaths:@[indexPath] animated:NO notifyDelegate:YES];
    }
}

- (void)_endPaintingSelectionAtEvent:(NSEvent *)event {
    _isPaintingSelectionRunning = NO;
    _paintingSelectionType = NO;
}

- (void)rightMouseDown:(NSEvent *)event {
    id<UXCollectionViewDelegate> delegate = self.delegate;
    NSIndexPath *hitIndexPath = [self _indexPathOfSelectableItemHitByEvent:event];
    self.lastRightClickedIndexPath = hitIndexPath;
    if (hitIndexPath && [delegate respondsToSelector:@selector(collectionView:itemWasRightClickedAtIndexPath:withEvent:)]) {
        [delegate collectionView:self itemWasRightClickedAtIndexPath:hitIndexPath withEvent:event];
    }
    [super rightMouseDown:event];
}

- (void)keyDown:(NSEvent *)event {
    NSString *characters = event.charactersIgnoringModifiers;
    if (characters.length == 0) {
        [super keyDown:event];
        return;
    }
    unichar keyCharacter = [characters characterAtIndex:0];
    NSEventModifierFlags modifiers = event.modifierFlags;
    if ([self _performScrollingForKey:keyCharacter]) {
        return;
    }
    if (![self _performItemSelectionForKey:keyCharacter withModifiers:modifiers]) {
        [super keyDown:event];
    }
}

- (void)_performItemSelectionForMouseEvent:(NSEvent *)event onCell:(UXCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSEventModifierFlags modifiers = event.modifierFlags;
    BOOL commandPressed = (modifiers & NSEventModifierFlagCommand) != 0;
    BOOL shiftPressed = (modifiers & NSEventModifierFlagShift) != 0;
    BOOL extendingModifierPressed = commandPressed || shiftPressed;

    if (cell.selected) {
        BOOL allowDeselect = commandPressed || _allowsContinuousSelection;
        if (allowDeselect) {
            [self _deselectItemsAtIndexPaths:@[indexPath] animated:YES notifyDelegate:YES];
        }
        return;
    }
    if (![self selectableItemAtIndexPath:indexPath]) {
        return;
    }

    if (shiftPressed && _allowsMultipleSelection && _lastSelectionAnchorIndexPath) {
        NSIndexPath *anchor = _lastSelectionAnchorIndexPath;
        [self _selectRangeOfItemsFromIndexPath:anchor
                                   toIndexPath:indexPath
                          byExtendingSelection:commandPressed
                                      animated:YES
                                        scroll:NO
                                    toPosition:UXCollectionViewScrollPositionNone
                                notifyDelegate:YES
                  candidateLastSelectedItemIndexPath:NULL];
        return;
    }

    BOOL extend = extendingModifierPressed && _allowsMultipleSelection;
    UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPath:indexPath];
    [self _selectItemsInIndexPathsSet:set
                  byExtendingSelection:extend
                              animated:YES
                       scrollingKeyItem:nil
                            toPosition:UXCollectionViewScrollPositionNone
                        notifyDelegate:YES];
}

- (BOOL)_performItemSelectionForKey:(uint16_t)key withModifiers:(NSUInteger)modifiers {
    if ((modifiers & NSEventModifierFlagCommand) != 0) {
        return NO;
    }
    BOOL shiftHeld = (modifiers & NSEventModifierFlagShift) != 0;
    BOOL rangeMode = shiftHeld && _allowsMultipleSelection;

    NSIndexPath *anchorIndexPath = _keyboardRangeSelectionLastSelectedItem ?: [_indexPathsForSelectedItems lastIndexPath];
    NSIndexPath *targetIndexPath = nil;
    switch (key) {
        case NSUpArrowFunctionKey:
        case NSLeftArrowFunctionKey:
            targetIndexPath = [self _indexPathByMovingFromIndexPath:anchorIndexPath delta:-1 fallback:[self _firstSelectableItemIndexPath]];
            break;
        case NSDownArrowFunctionKey:
        case NSRightArrowFunctionKey:
            targetIndexPath = [self _indexPathByMovingFromIndexPath:anchorIndexPath delta:1 fallback:[self _firstSelectableItemIndexPath]];
            break;
        case NSHomeFunctionKey:
            targetIndexPath = [self _firstSelectableItemIndexPath];
            break;
        case NSEndFunctionKey:
            targetIndexPath = [self _lastSelectableItemIndexPath];
            break;
        default:
            return NO;
    }
    if (!targetIndexPath) {
        return NO;
    }

    if (rangeMode) {
        if (!_keyboardRangeSelectionFirstSelectedItem) {
            _keyboardRangeSelectionFirstSelectedItem = anchorIndexPath ?: targetIndexPath;
            _keyboardRangeSelectionPreviouslySelectedItems = [[UXCollectionViewIndexPathsSet alloc] initWithIndexPathsSet:_indexPathsForSelectedItems];
        }
        _keyboardRangeSelectionLastSelectedItem = targetIndexPath;
        NSArray<NSIndexPath *> *range = [_layout indexPathsForItemRangeSelectionFrom:_keyboardRangeSelectionFirstSelectedItem
                                                                                  to:targetIndexPath];
        UXCollectionViewMutableIndexPathsSet *combined = [[UXCollectionViewMutableIndexPathsSet alloc] init];
        [combined addIndexPathsSet:_keyboardRangeSelectionPreviouslySelectedItems];
        for (NSIndexPath *indexPath in range) {
            [combined addIndexPath:indexPath];
        }
        [self _selectItemsInIndexPathsSet:combined
                     byExtendingSelection:NO
                                 animated:NO
                          scrollingKeyItem:targetIndexPath
                                toPosition:UXCollectionViewScrollPositionNone
                            notifyDelegate:YES];
    } else {
        _keyboardRangeSelectionFirstSelectedItem = nil;
        _keyboardRangeSelectionLastSelectedItem = nil;
        _keyboardRangeSelectionPreviouslySelectedItems = nil;
        UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPath:targetIndexPath];
        [self _selectItemsInIndexPathsSet:set
                     byExtendingSelection:NO
                                 animated:NO
                          scrollingKeyItem:targetIndexPath
                                toPosition:UXCollectionViewScrollPositionNone
                            notifyDelegate:YES];
    }
    return YES;
}

- (NSIndexPath *)_indexPathByMovingFromIndexPath:(NSIndexPath *)indexPath delta:(NSInteger)delta fallback:(NSIndexPath *)fallback {
    if (!indexPath) {
        return fallback;
    }
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item + delta;
    NSInteger sectionCount = [self numberOfSections];
    while (section >= 0 && section < sectionCount) {
        NSInteger itemCount = [self numberOfItemsInSection:section];
        if (item < 0) {
            section--;
            if (section < 0) {
                return nil;
            }
            item = [self numberOfItemsInSection:section] - 1;
            continue;
        }
        if (item >= itemCount) {
            section++;
            item = 0;
            continue;
        }
        NSIndexPath *candidate = [NSIndexPath indexPathForItem:item inSection:section];
        if ([self selectableItemAtIndexPath:candidate]) {
            return candidate;
        }
        item += (delta >= 0) ? 1 : -1;
    }
    return nil;
}

#pragma mark - Navigation

- (NSIndexPath *)nextIndexPath:(NSIndexPath *)indexPath {
    return [_layout indexPathOfItemAfter:indexPath];
}

- (NSIndexPath *)previousIndexPath:(NSIndexPath *)indexPath {
    return [_layout indexPathOfItemBefore:indexPath];
}

#pragma mark - Window lifecycle

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];
    NSWindow *currentWindow = self.window;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (currentWindow) {
        [center removeObserver:self name:NSWindowDidBecomeKeyNotification object:currentWindow];
        [center removeObserver:self name:NSWindowDidResignKeyNotification object:currentWindow];
        [center removeObserver:self name:NSWindowDidChangeBackingPropertiesNotification object:currentWindow];
    }
    if (newWindow) {
        [center addObserver:self selector:@selector(windowDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:newWindow];
        [center addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignKeyNotification object:newWindow];
        [center addObserver:self selector:@selector(windowDidChangeBackingProperties:) name:NSWindowDidChangeBackingPropertiesNotification object:newWindow];
    }
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    if (self.window) {
        [self _viewPrepare];
    } else {
        [self _viewCleanup];
    }
}

- (void)_viewPrepare {
    [self _reloadDataIfNeeded];
}

- (void)_viewCleanup {
}

- (BOOL)_visible {
    return self.window != nil && !self.hidden;
}

- (void)_updateFirstResponderView {
    // Real implementation would route to a target cell; leave as a marker until selection focus lands.
}

- (BOOL)_highlightColorDependsOnWindowState {
    return YES;
}

- (BOOL)_selectionBorderShouldUsePrimaryColor {
    return self.window.isKeyWindow;
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    for (UXCollectionViewCell *cell in self.visibleCells) {
        [cell setNeedsDisplay:YES];
    }
}

- (void)windowDidResignKey:(NSNotification *)notification {
    for (UXCollectionViewCell *cell in self.visibleCells) {
        [cell setNeedsDisplay:YES];
    }
}

- (void)windowDidChangeBackingProperties:(NSNotification *)notification {
    [self.documentView setNeedsLayout:YES];
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item {
    SEL action = [item action];
    if (action == @selector(selectAll:)) {
        return _allowsMultipleSelection && [self _hasAnyItems];
    }
    if (action == @selector(deselectAll:)) {
        return [_indexPathsForSelectedItems count] > 0;
    }
    return YES;
}

#pragma mark - Accessibility

- (NSString *)_retrieveAccessibiltyRoleDescriptionFromAXDelegate {
    id<UXCollectionViewAccessibilityDelegate> delegate = self.accessibilityDelegate;
    if ([delegate respondsToSelector:@selector(accessibilityRoleDescriptionForCollectionView:)]) {
        return [delegate accessibilityRoleDescriptionForCollectionView:self];
    }
    return nil;
}

- (void)_notifyAccessibilityDelegateToPrepareSection:(id)section {
    id<UXCollectionViewAccessibilityDelegate> delegate = self.accessibilityDelegate;
    if ([delegate respondsToSelector:@selector(collectionView:prepareAccessibilitySection:)]) {
        [delegate collectionView:self prepareAccessibilitySection:section];
    }
}

- (id)accessibilityChildren {
    return [_layout layoutAccessibility].accessibilityChildren;
}

#pragma mark - Dictionary helpers

- (void)_addEntriesFromDictionary:(NSDictionary *)source inDictionary:(NSMutableDictionary *)destination {
    [destination addEntriesFromDictionary:source];
}

- (void)_addEntriesFromDictionary:(NSDictionary *)source inDictionary:(NSMutableDictionary *)destination andSet:(NSMutableSet *)set {
    [destination addEntriesFromDictionary:source];
    [set addObjectsFromArray:source.allValues];
}

- (NSArray *)_keysForObject:(id)object inDictionary:(NSDictionary *)dictionary {
    return [dictionary allKeysForObject:object];
}

- (id)_objectInDictionary:(NSDictionary *)dictionary forKind:(NSString *)kind indexPath:(NSIndexPath *)indexPath {
    NSDictionary *nested = dictionary[kind];
    return nested[indexPath];
}

- (void)_setObject:(id)object inDictionary:(NSMutableDictionary *)dictionary forKind:(NSString *)kind indexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *nested = dictionary[kind];
    if (!nested) {
        nested = [NSMutableDictionary dictionary];
        dictionary[kind] = nested;
    }
    if (object) {
        nested[indexPath] = object;
    } else {
        [nested removeObjectForKey:indexPath];
    }
}

#pragma mark - Overdraw

- (void)_prepareCellsForOverdraw:(CGRect)rect {
    if (CGRectEqualToRect(rect, _lastPreparedOverdrawContentRect)) {
        return;
    }
    _lastPreparedOverdrawContentRect = rect;
    if (_collectionViewFlags.delegateDidPrepareForOverdraw) {
        [self.delegate collectionView:self didPrepareForOverdraw:rect];
    }
}

#pragma mark - Controlled subviews + z-order

- (void)_addControlled:(BOOL)controlled subview:(NSView *)subview atZIndex:(NSInteger)zIndex {
    if (controlled) {
        [(id)subview setIsFloatingPinned:NO];
        [subview setHidden:NO];
        if (subview.superview == _collectionDocumentView) {
            return;
        }
        NSArray<NSView *> *siblings = _collectionDocumentView.subviews;
        if (siblings.count == 0) {
            [_collectionDocumentView addSubview:subview positioned:NSWindowBelow relativeTo:nil];
            return;
        }
        NSView *topSibling = siblings.lastObject;
        if ([topSibling isKindOfClass:[UXCollectionReusableView class]]
            && [(id)topSibling _layoutAttributes].zIndex <= zIndex
            && !topSibling.isHidden) {
            [_collectionDocumentView addSubview:subview];
            return;
        }
        for (NSView *sibling in siblings.reverseObjectEnumerator) {
            if ([sibling isKindOfClass:[UXCollectionReusableView class]]
                && !sibling.isHidden
                && [(id)sibling _layoutAttributes].zIndex <= zIndex) {
                [_collectionDocumentView addSubview:subview positioned:NSWindowAbove relativeTo:sibling];
                return;
            }
        }
        [_collectionDocumentView addSubview:subview positioned:NSWindowBelow relativeTo:nil];
    } else if (![(id)subview isFloatingPinned]) {
        [(id)subview setIsFloatingPinned:YES];
        [subview setHidden:NO];
        [self addFloatingSubview:subview forAxis:NSEventGestureAxisVertical];
    }
}

#pragma mark - Double click + busy state

- (BOOL)isBusy {
    return _updateAnimationCount > 0 || _reloadingSuspendedCount > 0;
}

- (void)_respondToDoubleClick {
    NSIndexPath *indexPath = _doubleClickContext[@"indexPath"];
    if (!indexPath) {
        return;
    }
    id<UXCollectionViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(collectionView:itemWasDoubleClickedAtIndexPath:withEvent:)]) {
        [delegate collectionView:self itemWasDoubleClickedAtIndexPath:indexPath withEvent:_doubleClickContext[@"event"]];
    }
    [_doubleClickContext removeAllObjects];
}

#pragma mark - Accessibility navigation

- (id)accessibilityContentSiblingCellFromIndexPath:(NSIndexPath *)indexPath direction:(id)direction {
    if ([direction isKindOfClass:[NSString class]]) {
        NSString *directionString = (NSString *)direction;
        if ([directionString isEqualToString:@"Next"]) {
            NSIndexPath *next = [self nextIndexPath:indexPath];
            return next ? [self cellForItemAtIndexPath:next] : nil;
        }
        if ([directionString isEqualToString:@"Previous"]) {
            NSIndexPath *previous = [self previousIndexPath:indexPath];
            return previous ? [self cellForItemAtIndexPath:previous] : nil;
        }
    }
    return nil;
}

#pragma mark - Content offset helpers

- (CGPoint)_contentOffsetForNewFrame:(CGRect)newFrame oldFrame:(CGRect)oldFrame newContentSize:(CGSize)newContentSize andOldContentSize:(CGSize)oldContentSize {
    CGPoint offset = self.contentOffset;
    if (oldContentSize.width > 0 && newContentSize.width > 0) {
        CGFloat ratio = newContentSize.width / oldContentSize.width;
        offset.x *= ratio;
    }
    if (oldContentSize.height > 0 && newContentSize.height > 0) {
        CGFloat ratio = newContentSize.height / oldContentSize.height;
        offset.y *= ratio;
    }
    return offset;
}

@end
