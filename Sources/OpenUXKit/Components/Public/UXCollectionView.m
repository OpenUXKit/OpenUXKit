#import <OpenUXKit/UXCollectionView.h>
#import <OpenUXKit/UXCollectionView+Internal.h>
#import <OpenUXKit/UXCollectionViewCell.h>
#import <OpenUXKit/UXCollectionReusableView.h>
#import <OpenUXKit/UXCollectionViewLayout.h>
#import <OpenUXKit/UXCollectionViewLayout+Internal.h>
#import <OpenUXKit/UXCollectionViewLayoutAttributes.h>
#import <OpenUXKit/UXCollectionViewLayoutAttributes+Internal.h>
#import <OpenUXKit/UXCollectionViewData.h>
#import <OpenUXKit/UXCollectionViewIndexPathsSet.h>
#import <OpenUXKit/UXCollectionViewIndexPathsSet+Internal.h>
#import <OpenUXKit/UXCollectionViewMutableIndexPathsSet.h>
#import <OpenUXKit/UXCollectionDocumentView.h>
#import <OpenUXKit/_UXCollectionViewItemKey.h>
#import <OpenUXKit/_UXCollectionViewRearrangingCoordinator.h>
#import <OpenUXKit/UXCollectionViewLayoutAccessibility.h>
#import <OpenUXKit/UXCollectionViewFlowLayout.h>
#import <OpenUXKit/UXCollectionViewUpdate.h>
#import <OpenUXKit/UXCollectionViewUpdate+Internal.h>
#import <OpenUXKit/UXCollectionViewUpdateItem.h>
#import <OpenUXKit/UXCollectionViewUpdateItem+Internal.h>
#import <OpenUXKit/UXCollectionViewAnimation.h>
#import <QuartzCore/QuartzCore.h>

NSString *const UXCollectionElementKindCell = @"UXCollectionElementKindCell";

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
    CGPoint _lastLayoutOffset;
    BOOL _rearrangingEnabled;
    BOOL _rearrangingAllowAutoscroll;
    BOOL _rearrangingExternalDropEnabled;
    NSInteger _rearrangingInitiationMode;
    BOOL _rearrangingContinuouslyUpdateInsideCells;
    CGFloat _rearrangingPreviewDelay;
    CGSize _explicitContentSize;
    BOOL _hasExplicitContentSize;
    BOOL _doneFirstLayout;
    BOOL _needsReload;
    BOOL _needsVisibleCellsUpdate;
    BOOL _needsVisibleCellsLayoutAttributesUpdate;
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
    _lastPreparedOverdrawContentRect = CGRectNull;
    _visibleBounds = CGRectNull;
    _previousBounds = CGRectNull;

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

- (BOOL)_dataSourceImplementsNumberOfSections {
    return [self.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)];
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
    [(id)_layout _setCollectionView:nil];
    _layout = layout;
    [(id)_layout _setCollectionView:self];
    _collectionViewData = [[UXCollectionViewData alloc] initWithCollectionView:self layout:layout];
    [self reloadData];
    if (completion) {
        completion(YES);
    }
}

- (void)updateLayout {
    [_collectionViewData invalidate:NO];
    [self.documentView setNeedsLayout:YES];
    [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:YES];
}

- (void)_invalidateLayoutWithContext:(UXCollectionViewLayoutInvalidationContext *)context {
    [_collectionViewData invalidate:NO];
    [self.documentView setNeedsLayout:YES];
    [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:YES];
}

- (void)_invalidateLayoutIfNecessary {
    if (_needsReload || _needsVisibleCellsUpdate) {
        [self.documentView setNeedsLayout:YES];
    }
}

- (void)_setNeedsVisibleCellsUpdate:(BOOL)needsUpdate withLayoutAttributes:(BOOL)withAttributes {
    _needsVisibleCellsUpdate = needsUpdate || _needsVisibleCellsUpdate;
    _needsVisibleCellsLayoutAttributesUpdate = withAttributes || _needsVisibleCellsLayoutAttributesUpdate;
    if (_needsVisibleCellsUpdate) {
        [self.documentView setNeedsLayout:YES];
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

- (id)_dequeueReusableViewOfKind:(NSString *)kind withIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath viewCategory:(NSUInteger)viewCategory {
    NSMutableDictionary *reuseQueues = (viewCategory == 1) ? _cellReuseQueues : _supplementaryViewReuseQueues;
    NSString *reuseKey = (viewCategory == 1) ? identifier : [[self class] _reuseKeyForSupplementaryViewOfKind:kind withReuseIdentifier:identifier];

    NSMutableArray *queue = reuseQueues[reuseKey];
    UXCollectionReusableView *view = nil;
    if (queue.count > 0) {
        view = [queue lastObject];
        [queue removeLastObject];
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

- (void)_reuseCell:(UXCollectionViewCell *)cell {
    if (!cell) {
        return;
    }
    NSString *identifier = cell.reuseIdentifier;
    if (!identifier) {
        return;
    }
    NSMutableArray *queue = _cellReuseQueues[identifier];
    if (!queue) {
        queue = [NSMutableArray array];
        _cellReuseQueues[identifier] = queue;
    }
    if (queue.count < _purgingCellsThreshold) {
        [queue addObject:cell];
    }
    [cell removeFromSuperview];
}

- (void)_reuseSupplementaryView:(UXCollectionReusableView *)view {
    if (!view) {
        return;
    }
    NSString *identifier = view.reuseIdentifier;
    UXCollectionViewLayoutAttributes *attributes = [(id)view _layoutAttributes];
    NSString *elementKind = [attributes _elementKind];
    if (!identifier || !elementKind) {
        [view removeFromSuperview];
        return;
    }
    NSString *key = [[self class] _reuseKeyForSupplementaryViewOfKind:elementKind withReuseIdentifier:identifier];
    NSMutableArray *queue = _supplementaryViewReuseQueues[key];
    if (!queue) {
        queue = [NSMutableArray array];
        _supplementaryViewReuseQueues[key] = queue;
    }
    if (queue.count < _purgingCellsThreshold) {
        [queue addObject:view];
    }
    [view removeFromSuperview];
}

- (NSInteger)_numberOfReusedViewsForIdentifier:(NSString *)identifier {
    return [_cellReuseQueues[identifier] count];
}

- (NSInteger)_maxNumberOfReusedViews {
    return _purgingCellsThreshold;
}

#pragma mark - Cell preparation pipeline

- (id)_createPreparedCellForItemAtIndexPath:(NSIndexPath *)indexPath withLayoutAttributes:(UXCollectionViewLayoutAttributes *)layoutAttributes applyAttributes:(BOOL)applyAttributes {
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
    return cell;
}

- (id)_createPreparedSupplementaryViewForElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath withLayoutAttributes:(UXCollectionViewLayoutAttributes *)layoutAttributes applyAttributes:(BOOL)applyAttributes {
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
    [_collectionViewData validateLayoutInRect:rect];
    NSArray<UXCollectionViewLayoutAttributes *> *attributesList = [_collectionViewData layoutAttributesForElementsInRect:rect];

    NSMutableSet<_UXCollectionViewItemKey *> *visibleKeys = [NSMutableSet set];
    for (UXCollectionViewLayoutAttributes *attributes in attributesList) {
        _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:attributes];
        [visibleKeys addObject:key];

        UXCollectionReusableView *existing = _allVisibleViewsDict[key];
        if (existing) {
            [(id)existing _setLayoutAttributes:attributes];
            if (existing.superview != _collectionDocumentView) {
                [_collectionDocumentView addSubview:existing];
            }
        } else if (createIfNecessary) {
            UXCollectionReusableView *view = nil;
            if ([attributes _isCell]) {
                view = [self _createPreparedCellForItemAtIndexPath:attributes.indexPath withLayoutAttributes:attributes applyAttributes:YES];
            } else if ([attributes _isSupplementaryView]) {
                view = [self _createPreparedSupplementaryViewForElementOfKind:[attributes _elementKind]
                                                                  atIndexPath:attributes.indexPath
                                                          withLayoutAttributes:attributes
                                                              applyAttributes:YES];
            }
            if (view) {
                [_collectionDocumentView addSubview:view];
                _allVisibleViewsDict[key] = view;
                if ([view isKindOfClass:[UXCollectionViewCell class]]) {
                    [self _notifyWillDisplayCellIfNeeded:(UXCollectionViewCell *)view forIndexPath:attributes.indexPath];
                }
            }
        }
    }

    NSArray<_UXCollectionViewItemKey *> *existingKeys = [_allVisibleViewsDict.allKeys copy];
    for (_UXCollectionViewItemKey *key in existingKeys) {
        if ([visibleKeys containsObject:key]) {
            continue;
        }
        UXCollectionReusableView *view = _allVisibleViewsDict[key];
        if ([view respondsToSelector:@selector(_isInUpdateAnimation)] && [view _isInUpdateAnimation]) {
            continue;
        }
        [_allVisibleViewsDict removeObjectForKey:key];
        if ([view isKindOfClass:[UXCollectionViewCell class]]) {
            UXCollectionViewCell *cell = (UXCollectionViewCell *)view;
            [self _notifyDidEndDisplayingCellIfNeeded:cell forIndexPath:[key indexPath]];
            [self _reuseCell:cell];
        } else {
            id<UXCollectionViewDelegate> delegate = self.delegate;
            UXCollectionViewLayoutAttributes *viewAttributes = [(id)view _layoutAttributes];
            NSString *elementKind = [viewAttributes _elementKind];
            if (elementKind && [delegate respondsToSelector:@selector(collectionView:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:)]) {
                [delegate collectionView:self didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:[key indexPath]];
            }
            [self _reuseSupplementaryView:view];
        }
    }
}

- (void)_updateVisibleCellsNow:(BOOL)now {
    [self _updateCellsInRect:[self documentVisibleRect] createIfNecessary:YES];
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

- (id)_visibleSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [self _visibleSupplementaryViewOfKind:kind atIndexPath:indexPath isDecorationView:NO];
}

- (id)_visibleSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath isDecorationView:(BOOL)isDecorationView {
    _UXCollectionViewItemKey *key = isDecorationView
        ? [_UXCollectionViewItemKey collectionItemKeyForDecorationViewOfKind:kind andIndexPath:indexPath]
        : [_UXCollectionViewItemKey collectionItemKeyForSupplementaryViewOfKind:kind andIndexPath:indexPath];
    return _allVisibleViewsDict[key];
}

- (id)_visibleDecorationViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
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

- (id)_validateHitTest:(NSView *)view {
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

- (BOOL)_selectItemsInIndexPathsSet:(UXCollectionViewIndexPathsSet *)set byExtendingSelection:(BOOL)extend animated:(BOOL)animated scrollingKeyItem:(NSIndexPath *)keyItem toPosition:(UXCollectionViewScrollPosition)position notifyDelegate:(BOOL)notifyDelegate {
    id<UXCollectionViewDelegate> delegate = self.delegate;
    BOOL respondsToWillAdd = notifyDelegate && [delegate respondsToSelector:@selector(collectionView:indexPathsForSelectedItemsWillAdd:remove:animated:)];
    BOOL respondsToDidAdd = notifyDelegate && [delegate respondsToSelector:@selector(collectionView:indexPathsForSelectedItemsDidAdd:remove:animated:)];
    BOOL respondsToDidSelect = notifyDelegate && [delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)];

    NSMutableArray<NSIndexPath *> *added = [NSMutableArray array];
    NSMutableArray<NSIndexPath *> *removed = [NSMutableArray array];

    if (!extend) {
        for (NSIndexPath *indexPath in [_indexPathsForSelectedItems allIndexPaths]) {
            if (![set containsIndexPath:indexPath]) {
                [removed addObject:indexPath];
            }
        }
    }

    [set enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
        if (![_indexPathsForSelectedItems containsIndexPath:indexPath]) {
            [added addObject:indexPath];
        }
    }];

    if (added.count == 0 && removed.count == 0) {
        if (keyItem && position != UXCollectionViewScrollPositionNone) {
            [self scrollToItemAtIndexPath:keyItem atScrollPosition:position animated:animated];
        }
        return NO;
    }

    if (respondsToWillAdd) {
        [delegate collectionView:self indexPathsForSelectedItemsWillAdd:added remove:removed animated:animated];
    }

    if (removed.count) {
        [self _deselectItemsAtIndexPaths:removed animated:animated notifyDelegate:notifyDelegate];
    }

    for (NSIndexPath *indexPath in added) {
        [_indexPathsForSelectedItems addIndexPath:indexPath];
        UXCollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
        cell.selected = YES;
        if (respondsToDidSelect) {
            [delegate collectionView:self didSelectItemAtIndexPath:indexPath];
        }
    }
    _lastSelectionAnchorIndexPath = [_indexPathsForSelectedItems lastIndexPath];

    if (respondsToDidAdd) {
        [delegate collectionView:self indexPathsForSelectedItemsDidAdd:added remove:removed animated:animated];
    }

    if (keyItem && position != UXCollectionViewScrollPositionNone) {
        [self scrollToItemAtIndexPath:keyItem atScrollPosition:position animated:animated];
    }
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
    BOOL respondsToShouldDeselect = notifyDelegate && [delegate respondsToSelector:@selector(collectionView:shouldDeselectItemAtIndexPath:)];
    BOOL respondsToDidDeselect = notifyDelegate && [delegate respondsToSelector:@selector(collectionView:didDeselectItemAtIndexPath:)];

    BOOL deselectedAny = NO;
    for (NSIndexPath *indexPath in indexPaths) {
        if (![_indexPathsForSelectedItems containsIndexPath:indexPath]) {
            continue;
        }
        if (respondsToShouldDeselect && ![delegate collectionView:self shouldDeselectItemAtIndexPath:indexPath]) {
            continue;
        }
        [_indexPathsForSelectedItems removeIndexPath:indexPath];
        UXCollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
        cell.selected = NO;
        deselectedAny = YES;
        if (respondsToDidDeselect) {
            [delegate collectionView:self didDeselectItemAtIndexPath:indexPath];
        }
    }
    return deselectedAny;
}

- (void)_deselectAllAnimated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate {
    NSArray<NSIndexPath *> *all = [[_indexPathsForSelectedItems allIndexPaths] copy];
    [self _deselectItemsAtIndexPaths:all animated:animated notifyDelegate:notifyDelegate];
}

- (BOOL)_toggleSelectionStateOfItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate {
    if ([_indexPathsForSelectedItems containsIndexPath:indexPath]) {
        return [self _deselectItemsAtIndexPaths:@[indexPath] animated:animated notifyDelegate:notifyDelegate];
    }
    UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPath:indexPath];
    return [self _selectItemsInIndexPathsSet:set byExtendingSelection:YES animated:animated scrollingKeyItem:nil toPosition:UXCollectionViewScrollPositionNone notifyDelegate:notifyDelegate];
}

- (BOOL)_selectRangeOfItemsFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath byExtendingSelection:(BOOL)extend animated:(BOOL)animated scroll:(BOOL)scroll toPosition:(UXCollectionViewScrollPosition)position notifyDelegate:(BOOL)notifyDelegate candidateLastSelectedItemIndexPath:(NSIndexPath *__autoreleasing  _Nullable *)candidate {
    NSArray<NSIndexPath *> *range = [_layout indexPathsForItemRangeSelectionFrom:fromIndexPath to:toIndexPath];
    UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPaths:range];
    NSIndexPath *keyItem = scroll ? toIndexPath : nil;
    BOOL changed = [self _selectItemsInIndexPathsSet:set byExtendingSelection:extend animated:animated scrollingKeyItem:keyItem toPosition:position notifyDelegate:notifyDelegate];
    if (candidate) {
        *candidate = toIndexPath;
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
    if (!_allowsMultipleSelection) {
        return;
    }
    NSMutableArray<NSIndexPath *> *all = [NSMutableArray array];
    NSInteger sectionCount = [self numberOfSections];
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self numberOfItemsInSection:section];
        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            if ([self selectableItemAtIndexPath:indexPath]) {
                [all addObject:indexPath];
            }
        }
    }
    UXCollectionViewIndexPathsSet *set = [UXCollectionViewIndexPathsSet indexPathsSetWithIndexPaths:all];
    [self _selectItemsInIndexPathsSet:set byExtendingSelection:NO animated:NO scrollingKeyItem:nil toPosition:UXCollectionViewScrollPositionNone notifyDelegate:notifyDelegate];
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
    return [_collectionViewData collectionViewContentRect];
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
    if (_hasExplicitContentSize) {
        return _explicitContentSize;
    }
    return [self documentSize];
}

- (void)setContentSize:(CGSize)contentSize {
    _explicitContentSize = contentSize;
    _hasExplicitContentSize = !CGSizeEqualToSize(contentSize, CGSizeZero);
    NSRect frame = _collectionDocumentView.frame;
    frame.size = contentSize;
    _collectionDocumentView.frame = frame;
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
    if (CGRectIsNull(_visibleBounds)) {
        return [self documentVisibleRect];
    }
    return _visibleBounds;
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
    if (_scrolling) {
        return;
    }
    _scrolling = YES;
    id<UXCollectionViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(collectionViewWillBeginScrolling:)]) {
        [delegate collectionViewWillBeginScrolling:self];
    }
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
    if (_suspendClipViewBoundsDidChange > 0) {
        return;
    }
    id<UXCollectionViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(collectionViewDidScroll:)]) {
        [delegate collectionViewDidScroll:self];
    }
    [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:NO];
}

- (void)reflectScrolledClipView:(NSClipView *)clipView {
    [super reflectScrolledClipView:clipView];
    [self clipViewBoundsDidChange:nil];
}

#pragma mark - Reload / batch updates

- (void)reloadData {
    if (_updateAnimationCount > 0) {
        _needsReload = YES;
        return;
    }
    if (_reloadingSuspendedCount > 0) {
        _needsReload = YES;
        return;
    }

    // Recycle visible views (skip ones in animation)
    NSMutableDictionary *animating = [NSMutableDictionary dictionary];
    for (_UXCollectionViewItemKey *key in _allVisibleViewsDict.copy) {
        id view = _allVisibleViewsDict[key];
        if ([view respondsToSelector:@selector(_isInUpdateAnimation)] && [view _isInUpdateAnimation]) {
            animating[key] = view;
        } else if ([view isKindOfClass:[UXCollectionViewCell class]]) {
            UXCollectionViewCell *cell = (UXCollectionViewCell *)view;
            [self _notifyDidEndDisplayingCellIfNeeded:cell forIndexPath:[key indexPath]];
            [self _reuseCell:cell];
        } else {
            [self _reuseSupplementaryView:view];
        }
    }
    [_allVisibleViewsDict removeAllObjects];
    [_allVisibleViewsDict addEntriesFromDictionary:animating];
    [_indexPathsForSelectedItems removeAllIndexPaths];
    _lastSelectionAnchorIndexPath = nil;
    [_collectionViewData invalidate:NO];

    // Update document view size from layout.
    CGSize contentSize = [_collectionViewData collectionViewContentRect].size;
    NSRect documentFrame = _collectionDocumentView.frame;
    documentFrame.size = contentSize;
    _collectionDocumentView.frame = documentFrame;

    [self.documentView setNeedsLayout:YES];
    _needsReload = NO;
}

- (void)_reloadDataIfNeeded {
    if (_needsReload) {
        [self reloadData];
    }
}

- (void)_suspendReloads {
    _reloadingSuspendedCount++;
}

- (void)_resumeReloads {
    if (_reloadingSuspendedCount > 0) {
        _reloadingSuspendedCount--;
    }
    if (_reloadingSuspendedCount == 0) {
        [self _reloadDataIfNeeded];
    }
}

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion {
    if (!_doneFirstLayout) {
        [self reloadData];
        _doneFirstLayout = YES;
    }

    [self _suspendReloads];
    _updateAnimationCount++;

    UXCollectionViewData *oldModel = _collectionViewData;
    CGRect oldVisibleBounds = [self documentVisibleRect];

    [self _beginUpdates];
    if (updates) {
        updates();
    }

    NSArray<UXCollectionViewUpdateItem *> *updateItems = [self _allUpdateItems];

    UXCollectionViewData *newModel = [[UXCollectionViewData alloc] initWithCollectionView:self layout:_layout];
    [newModel invalidate:NO];

    _currentUpdate = [[UXCollectionViewUpdate alloc] initWithCollectionView:self
                                                                 updateItems:updateItems
                                                                    oldModel:oldModel
                                                                    newModel:newModel
                                                            oldVisibleBounds:oldVisibleBounds
                                                            newVisibleBounds:oldVisibleBounds];

    [_layout prepareForCollectionViewUpdates:updateItems];

    _collectionViewData = newModel;

    CGSize contentSize = [newModel collectionViewContentRect].size;
    NSRect documentFrame = _collectionDocumentView.frame;
    documentFrame.size = contentSize;
    _collectionDocumentView.frame = documentFrame;

    _updateCompletionHandler = [completion copy];
    [self _setupCellAnimations];
    [self _endUpdates];
    [self _resumeReloads];

    NSArray<UXCollectionViewAnimation *> *animations = [self _viewAnimationsForCurrentUpdate];
    if (animations.count == 0) {
        [self _finalizeBatchUpdatesWithFinished:YES];
        return;
    }

    __block NSInteger pending = (NSInteger)animations.count;
    for (UXCollectionViewAnimation *animation in animations) {
        [animation addCompletionHandler:^{
            pending--;
            if (pending <= 0) {
                [self _finalizeBatchUpdatesWithFinished:YES];
            }
        }];
        [animation start];
    }
}

- (NSArray<UXCollectionViewUpdateItem *> *)_allUpdateItems {
    NSMutableArray<UXCollectionViewUpdateItem *> *all = [NSMutableArray array];
    if (_insertItems) [all addObjectsFromArray:_insertItems];
    if (_deleteItems) [all addObjectsFromArray:_deleteItems];
    if (_reloadItems) [all addObjectsFromArray:_reloadItems];
    if (_moveItems) [all addObjectsFromArray:_moveItems];
    return all;
}

- (void)_finalizeBatchUpdatesWithFinished:(BOOL)finished {
    [self _endItemAnimations];
    [_layout finalizeCollectionViewUpdates];

    NSMutableDictionary *survivingViews = [NSMutableDictionary dictionary];
    for (_UXCollectionViewItemKey *key in [_allVisibleViewsDict.allKeys copy]) {
        UXCollectionReusableView *view = _allVisibleViewsDict[key];
        if ([view respondsToSelector:@selector(_isInUpdateAnimation)] && [view _isInUpdateAnimation]) {
            continue;
        }
        if ([view isKindOfClass:[UXCollectionViewCell class]]) {
            UXCollectionViewCell *cell = (UXCollectionViewCell *)view;
            [self _notifyDidEndDisplayingCellIfNeeded:cell forIndexPath:[key indexPath]];
            [self _reuseCell:cell];
        } else {
            [self _reuseSupplementaryView:view];
        }
        [_allVisibleViewsDict removeObjectForKey:key];
    }
    [_allVisibleViewsDict addEntriesFromDictionary:survivingViews];

    _currentUpdate = nil;
    [self.documentView setNeedsLayout:YES];

    void (^handler)(BOOL) = _updateCompletionHandler;
    _updateCompletionHandler = nil;
    if (_updateAnimationCount > 0) {
        _updateAnimationCount--;
    }
    if (handler) {
        handler(finished);
    }
}

- (void)_beginUpdates {
    if (_updateCount == 0) {
        _insertItems = [NSMutableArray array];
        _deleteItems = [NSMutableArray array];
        _reloadItems = [NSMutableArray array];
        _moveItems = [NSMutableArray array];
    }
    _updateCount++;
}

- (void)_endUpdates {
    if (_updateCount > 0) {
        _updateCount--;
    }
    if (_updateCount == 0) {
        _originalInsertItems = [_insertItems copy];
        _originalDeleteItems = [_deleteItems copy];
        _insertItems = nil;
        _deleteItems = nil;
        _reloadItems = nil;
        _moveItems = nil;
    }
}

- (void)_setupCellAnimations {
    if (!_currentUpdate) {
        return;
    }

    UXCollectionViewData *newModel = [_currentUpdate _newModel];
    CGRect visibleRect = CGRectUnion([self documentVisibleRect], [self _visibleBounds]);
    NSArray<UXCollectionViewLayoutAttributes *> *upcoming = [newModel layoutAttributesForElementsInRect:visibleRect];

    for (UXCollectionViewLayoutAttributes *attributes in upcoming) {
        _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:attributes];
        if (_allVisibleViewsDict[key]) {
            continue;
        }
        UXCollectionReusableView *view = nil;
        UXCollectionViewLayoutAttributes *initialAttributes = nil;
        if ([attributes _isCell]) {
            initialAttributes = [_layout initialLayoutAttributesForAppearingItemAtIndexPath:attributes.indexPath];
            view = [self _createPreparedCellForItemAtIndexPath:attributes.indexPath withLayoutAttributes:initialAttributes ?: attributes applyAttributes:YES];
        } else if ([attributes _isSupplementaryView]) {
            initialAttributes = [_layout initialLayoutAttributesForAppearingSupplementaryElementOfKind:[attributes _elementKind] atIndexPath:attributes.indexPath];
            view = [self _createPreparedSupplementaryViewForElementOfKind:[attributes _elementKind] atIndexPath:attributes.indexPath withLayoutAttributes:initialAttributes ?: attributes applyAttributes:YES];
        }
        if (view) {
            [_collectionDocumentView addSubview:view];
            _allVisibleViewsDict[key] = view;
            if ([view isKindOfClass:[UXCollectionViewCell class]]) {
                [self _notifyWillDisplayCellIfNeeded:(UXCollectionViewCell *)view forIndexPath:attributes.indexPath];
            }
        }
    }
}

- (NSArray *)_viewAnimationsForCurrentUpdate {
    if (!_currentUpdate) {
        return @[];
    }

    NSMutableArray<UXCollectionViewAnimation *> *animations = [NSMutableArray array];
    UXCollectionViewData *newModel = [_currentUpdate _newModel];

    for (_UXCollectionViewItemKey *key in [_allVisibleViewsDict.allKeys copy]) {
        UXCollectionReusableView *view = _allVisibleViewsDict[key];
        UXCollectionViewLayoutAttributes *currentAttributes = [(id)view _layoutAttributes];
        NSIndexPath *indexPath = [key indexPath];
        UXCollectionViewLayoutAttributes *targetAttributes = nil;

        if ([key type] == UXCollectionViewItemTypeCell) {
            targetAttributes = [newModel layoutAttributesForItemAtIndexPath:indexPath];
        } else if ([key type] == UXCollectionViewItemTypeSupplementaryView) {
            targetAttributes = [newModel layoutAttributesForSupplementaryElementOfKind:[key identifier] atIndexPath:indexPath];
        }

        if (!targetAttributes) {
            UXCollectionViewLayoutAttributes *finalAttributes = nil;
            if ([key type] == UXCollectionViewItemTypeCell) {
                finalAttributes = [_layout finalLayoutAttributesForDisappearingItemAtIndexPath:indexPath];
            } else if ([key type] == UXCollectionViewItemTypeSupplementaryView) {
                finalAttributes = [_layout finalLayoutAttributesForDisappearingSupplementaryElementOfKind:[key identifier] atIndexPath:indexPath];
            }
            if (!finalAttributes) {
                finalAttributes = [currentAttributes copy];
                [finalAttributes setAlpha:0.0];
            }
            UXCollectionViewAnimation *animation = [[UXCollectionViewAnimation alloc] initWithView:view
                                                                                          viewType:[key type]
                                                                             finalLayoutAttributes:finalAttributes
                                                                                     startFraction:0.0
                                                                                       endFraction:1.0
                                                                        animateFromCurrentPosition:YES
                                                                              deleteAfterAnimation:YES
                                                                                  customAnimations:nil];
            [view _addUpdateAnimation];
            [animation addCompletionHandler:^{
                [view _clearUpdateAnimation];
                [view removeFromSuperview];
            }];
            [animations addObject:animation];
        } else if (![currentAttributes isEqual:targetAttributes]) {
            UXCollectionViewAnimation *animation = [[UXCollectionViewAnimation alloc] initWithView:view
                                                                                          viewType:[key type]
                                                                             finalLayoutAttributes:targetAttributes
                                                                                     startFraction:0.0
                                                                                       endFraction:1.0
                                                                        animateFromCurrentPosition:YES
                                                                              deleteAfterAnimation:NO
                                                                                  customAnimations:nil];
            [view _addUpdateAnimation];
            [animation addCompletionHandler:^{
                [view _clearUpdateAnimation];
            }];
            [animations addObject:animation];
        }
    }

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
    NSMutableArray<UXCollectionViewAnimation *> *animations = [NSMutableArray array];

    UXCollectionViewAnimation *appearAnimation = [[UXCollectionViewAnimation alloc] initWithView:view
                                                                                        viewType:0
                                                                           finalLayoutAttributes:endAttributes
                                                                                   startFraction:0.0
                                                                                     endFraction:1.0
                                                                      animateFromCurrentPosition:NO
                                                                            deleteAfterAnimation:NO
                                                                                customAnimations:nil];
    if (animationSetup) {
        [appearAnimation addStartupHandler:animationSetup];
    }
    if (animationCompletion) {
        [appearAnimation addCompletionHandler:^{
            animationCompletion(YES);
        }];
    }
    [animations addObject:appearAnimation];

    return animations;
}

- (void)_updateAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [self _finalizeBatchUpdatesWithFinished:[finished boolValue]];
}

- (void)_endItemAnimations {
    [_layout _finalizeCollectionViewItemAnimations];
}

- (void)_prepareLayoutForUpdates {
    NSArray *updateItems = [self _allUpdateItems];
    [_layout prepareForCollectionViewUpdates:updateItems ?: @[]];
}

- (NSMutableArray *)_arrayForUpdateAction:(NSInteger)updateAction {
    switch (updateAction) {
        case UXCollectionUpdateActionInsert:
            return _insertItems;
        case UXCollectionUpdateActionDelete:
            return _deleteItems;
        case UXCollectionUpdateActionReload:
            return _reloadItems;
        case UXCollectionUpdateActionMove:
            return _moveItems;
    }
    return nil;
}

- (void)_updateRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths updateAction:(NSInteger)updateAction {
    [self _beginUpdates];
    NSMutableArray *target = [self _arrayForUpdateAction:updateAction];
    for (NSIndexPath *indexPath in indexPaths) {
        UXCollectionViewUpdateItem *item = [[UXCollectionViewUpdateItem alloc] initWithAction:updateAction forIndexPath:indexPath];
        [target addObject:item];
    }
    [self _endUpdates];
}

- (void)_updateSections:(NSIndexSet *)sections updateAction:(NSInteger)updateAction {
    [self _beginUpdates];
    NSMutableArray *target = [self _arrayForUpdateAction:updateAction];
    [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
        UXCollectionViewUpdateItem *item = [[UXCollectionViewUpdateItem alloc] initWithAction:updateAction forIndexPath:[NSIndexPath indexPathWithIndex:section]];
        [target addObject:item];
    }];
    [self _endUpdates];
}

- (void)_updateWithItems:(NSArray *)items {
    // Apply the unified update vector. The full animated path requires UXCollectionViewUpdate
    // to walk old/new models; we treat the request as a reload until that pipeline arrives.
    [self reloadData];
}

- (void)insertSections:(NSIndexSet *)sections {
    [self performBatchUpdates:^{
        [self _updateSections:sections updateAction:UXCollectionUpdateActionInsert];
    } completion:nil];
}

- (void)deleteSections:(NSIndexSet *)sections {
    [self performBatchUpdates:^{
        [self _updateSections:sections updateAction:UXCollectionUpdateActionDelete];
    } completion:nil];
}

- (void)reloadSections:(NSIndexSet *)sections {
    [self performBatchUpdates:^{
        [self _updateSections:sections updateAction:UXCollectionUpdateActionReload];
    } completion:nil];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    [self performBatchUpdates:^{
        [self _beginUpdates];
        UXCollectionViewUpdateItem *item = [[UXCollectionViewUpdateItem alloc] initWithInitialIndexPath:[NSIndexPath indexPathWithIndex:section]
                                                                                           finalIndexPath:[NSIndexPath indexPathWithIndex:newSection]
                                                                                             updateAction:UXCollectionUpdateActionMove];
        [_moveItems addObject:item];
        [self _endUpdates];
    } completion:nil];
}

- (void)insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self performBatchUpdates:^{
        [self _updateRowsAtIndexPaths:indexPaths updateAction:UXCollectionUpdateActionInsert];
    } completion:nil];
}

- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self performBatchUpdates:^{
        [self _updateRowsAtIndexPaths:indexPaths updateAction:UXCollectionUpdateActionDelete];
    } completion:nil];
}

- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self performBatchUpdates:^{
        [self _updateRowsAtIndexPaths:indexPaths updateAction:UXCollectionUpdateActionReload];
    } completion:nil];
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self performBatchUpdates:^{
        [self _beginUpdates];
        UXCollectionViewUpdateItem *item = [[UXCollectionViewUpdateItem alloc] initWithInitialIndexPath:indexPath
                                                                                           finalIndexPath:newIndexPath
                                                                                             updateAction:UXCollectionUpdateActionMove];
        [_moveItems addObject:item];
        [self _endUpdates];
    } completion:nil];
}

#pragma mark - Layout

- (void)layoutSubviews {
    if (!_doneFirstLayout) {
        [self reloadData];
        _doneFirstLayout = YES;
    }
}

- (void)layout {
    [super layout];
    [self _updateVisibleCellsNow:YES];
    _needsVisibleCellsUpdate = NO;
    _needsVisibleCellsLayoutAttributesUpdate = NO;
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

    CGRect visibleRect = [self documentVisibleRect];
    if (_extraNumberOfCellsToPreloadWhenScrollingStopped > 0 && !_scrolling) {
        CGFloat insetY = -((CGFloat)_extraNumberOfCellsToPreloadWhenScrollingStopped * 0.5) * CGRectGetHeight(visibleRect);
        rect = CGRectUnion(rect, CGRectInset(visibleRect, 0.0, insetY));
    }

    _lastPreparedOverdrawContentRect = rect;
    [self _updateCellsInRect:rect createIfNecessary:YES];
    id<UXCollectionViewDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(collectionView:didPrepareForOverdraw:)]) {
        [delegate collectionView:self didPrepareForOverdraw:rect];
    }
}

#pragma mark - Controlled subviews + z-order

- (void)_addControlled:(BOOL)controlled subview:(NSView *)subview atZIndex:(NSInteger)zIndex {
    if (!subview) {
        return;
    }
    [_collectionDocumentView addSubview:subview];
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
