#import <OpenUXKit/UXCollectionView.h>
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
#import <OpenUXKit/UXCollectionViewLayoutAccessibility.h>
#import <OpenUXKit/UXCollectionViewFlowLayout.h>

NSString *const UXCollectionElementKindCell = @"UXCollectionElementKindCell";

@interface NSObject (UXCollectionViewLayoutSPI_Internal)
- (void)_setCollectionView:(UXCollectionView *)collectionView;
- (void)_setCollectionViewBoundsSize:(CGSize)boundsSize;
- (UXCollectionView *)_collectionView;
- (void)_setCollectionView:(UXCollectionView *)collectionView;
- (void)_setReuseIdentifier:(nullable NSString *)reuseIdentifier;
- (void)_markAsDequeued;
- (UXCollectionViewLayoutAttributes *)_layoutAttributes;
- (BOOL)_wasDequeued;
@end

@interface UXCollectionView () {
    UXCollectionDocumentView *_collectionDocumentView;
    UXCollectionViewLayout *_layout;
    UXCollectionViewMutableIndexPathsSet *_indexPathsForSelectedItems;
    NSMutableDictionary *_cellReuseQueues;
    NSMutableDictionary *_supplementaryViewReuseQueues;
    NSMutableDictionary *_allVisibleViewsDict;
    UXCollectionViewData *_collectionViewData;
    NSMutableDictionary *_cellClassDict;
    NSMutableDictionary *_cellNibDict;
    NSMutableDictionary *_supplementaryViewClassDict;
    NSMutableDictionary *_supplementaryViewNibDict;
    NSMutableSet *_supplementaryElementKinds;
    BOOL _doneFirstLayout;
    NSInteger _reloadingSuspendedCount;
    NSInteger _updateAnimationCount;
}
@end

@implementation UXCollectionView

@dynamic contentSize;

+ (Class)documentClass {
    return [UXCollectionDocumentView class];
}

+ (NSString *)_reuseKeyForSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)reuseIdentifier {
    return [NSString stringWithFormat:@"%@/%@", kind, reuseIdentifier];
}

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
    self.documentView = _collectionDocumentView;

    _indexPathsForSelectedItems = [[UXCollectionViewMutableIndexPathsSet alloc] init];
    _cellReuseQueues = [[NSMutableDictionary alloc] init];
    _supplementaryViewReuseQueues = [[NSMutableDictionary alloc] init];
    _allVisibleViewsDict = [[NSMutableDictionary alloc] init];
    _cellClassDict = [[NSMutableDictionary alloc] init];
    _cellNibDict = [[NSMutableDictionary alloc] init];
    _supplementaryViewClassDict = [[NSMutableDictionary alloc] init];
    _supplementaryViewNibDict = [[NSMutableDictionary alloc] init];
    _supplementaryElementKinds = [[NSMutableSet alloc] init];

    _collectionViewData = [[UXCollectionViewData alloc] initWithCollectionView:self layout:layout];

    _allowsSelection = YES;
    _allowsEmptySelection = YES;
    _purgingCellsThreshold = 30;
    _extraNumberOfCellsToPreloadWhenScrollingStopped = 10;
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

- (BOOL)isOpaque {
    return YES;
}

- (BOOL)wantsUpdateLayer {
    return YES;
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
}

- (void)_invalidateLayoutWithContext:(UXCollectionViewLayoutInvalidationContext *)context {
    [_collectionViewData invalidate:NO];
    [self.documentView setNeedsLayout:YES];
}

- (void)_invalidateLayoutIfNecessary {
    [self.documentView setNeedsLayout:YES];
}

#pragma mark - Counts

- (NSInteger)numberOfSections {
    return [_collectionViewData numberOfSections];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return [_collectionViewData numberOfItemsInSection:section];
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
    NSAssert(identifier.length > 0, @"must pass a valid reuse identifier to -[UICollectionView %@]", NSStringFromSelector(_cmd));
    return [self _dequeueReusableViewOfKind:UXCollectionElementKindCell withIdentifier:identifier forIndexPath:indexPath viewCategory:1];
}

- (__kindof UXCollectionReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    NSAssert(identifier.length > 0, @"must pass a valid reuse identifier to -[UICollectionView %@]", NSStringFromSelector(_cmd));
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
        [cell removeFromSuperview];
    }
}

- (void)_reuseSupplementaryView:(UXCollectionReusableView *)view {
    if (!view) {
        return;
    }
    NSString *identifier = view.reuseIdentifier;
    UXCollectionViewLayoutAttributes *attributes = [(id)view _layoutAttributes];
    NSString *elementKind = [attributes _elementKind];
    if (!identifier || !elementKind) {
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
        [view removeFromSuperview];
    }
}

- (NSInteger)_numberOfReusedViewsForIdentifier:(NSString *)identifier {
    return [_cellReuseQueues[identifier] count];
}

- (NSInteger)_maxNumberOfReusedViews {
    return _purgingCellsThreshold;
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

- (NSArray<__kindof UXCollectionReusableView *> *)visibleSupplementaryViews {
    NSMutableArray *views = [NSMutableArray array];
    for (id view in _allVisibleViewsDict.objectEnumerator) {
        if ([view isKindOfClass:[UXCollectionReusableView class]] && ![view isKindOfClass:[UXCollectionViewCell class]]) {
            [views addObject:view];
        }
    }
    return views;
}

- (NSArray<__kindof UXCollectionReusableView *> *)visibleSupplementaryViewsOfKind:(NSString *)kind {
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

- (NSArray<NSIndexPath *> *)indexPathsForVisibleItems {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (_UXCollectionViewItemKey *key in _allVisibleViewsDict.keyEnumerator) {
        if ([key type] == UXCollectionViewItemTypeCell) {
            [indexPaths addObject:[key indexPath]];
        }
    }
    return indexPaths;
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

- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point {
    if ([_layout respondsToSelector:@selector(indexPathForItemAtPoint:)]) {
        return [(UXCollectionViewFlowLayout *)_layout indexPathForItemAtPoint:point];
    }
    return nil;
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
    if (!extend) {
        [self deselectAllItems:NO];
    }
    for (NSIndexPath *indexPath in indexPaths) {
        [_indexPathsForSelectedItems addIndexPath:indexPath];
        UXCollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
        cell.selected = YES;
    }
}

- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self deselectItemsAtIndexPaths:@[indexPath] animated:animated];
}

- (void)deselectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths animated:(BOOL)animated {
    for (NSIndexPath *indexPath in indexPaths) {
        [_indexPathsForSelectedItems removeIndexPath:indexPath];
        UXCollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
        cell.selected = NO;
    }
}

- (void)deselectAllItems:(BOOL)animated {
    NSArray<NSIndexPath *> *selected = [self indexPathsForSelectedItems];
    [self deselectItemsAtIndexPaths:selected animated:animated];
}

- (void)selectAllItems:(BOOL)animated {
    if (!_allowsMultipleSelection) {
        return;
    }
    NSMutableArray<NSIndexPath *> *all = [NSMutableArray array];
    NSInteger sectionCount = [self numberOfSections];
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self numberOfItemsInSection:section];
        for (NSInteger item = 0; item < itemCount; item++) {
            [all addObject:[NSIndexPath indexPathForItem:item inSection:section]];
        }
    }
    [self selectItemsAtIndexPaths:all byExtendingSelection:NO animated:animated];
}

#pragma mark - Scrolling

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UXCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated {
    UXCollectionViewLayoutAttributes *attributes = [_collectionViewData layoutAttributesForItemAtIndexPath:indexPath];
    if (!attributes) {
        return;
    }
    CGRect frame = attributes.frame;
    NSClipView *clipView = self.contentView;
    NSRect target = clipView.bounds;
    if (scrollPosition & UXCollectionViewScrollPositionCenteredVertically) {
        target.origin.y = CGRectGetMidY(frame) - target.size.height / 2.0;
    } else if (scrollPosition & UXCollectionViewScrollPositionTop) {
        target.origin.y = CGRectGetMinY(frame);
    } else if (scrollPosition & UXCollectionViewScrollPositionBottom) {
        target.origin.y = CGRectGetMaxY(frame) - target.size.height;
    }
    if (scrollPosition & UXCollectionViewScrollPositionCenteredHorizontally) {
        target.origin.x = CGRectGetMidX(frame) - target.size.width / 2.0;
    } else if (scrollPosition & UXCollectionViewScrollPositionLeft) {
        target.origin.x = CGRectGetMinX(frame);
    } else if (scrollPosition & UXCollectionViewScrollPositionRight) {
        target.origin.x = CGRectGetMaxX(frame) - target.size.width;
    }
    if (animated) {
        [clipView.animator setBoundsOrigin:target.origin];
    } else {
        [clipView setBoundsOrigin:target.origin];
    }
    [self reflectScrolledClipView:clipView];
}

#pragma mark - Reload / batch updates

- (void)reloadData {
    if (_updateAnimationCount > 0) {
        return;
    }

    // Recycle visible views (skip ones in animation)
    NSMutableDictionary *animating = [NSMutableDictionary dictionary];
    for (_UXCollectionViewItemKey *key in _allVisibleViewsDict.copy) {
        id view = _allVisibleViewsDict[key];
        if ([view respondsToSelector:@selector(_isInUpdateAnimation)] && [view _isInUpdateAnimation]) {
            animating[key] = view;
        } else if ([view isKindOfClass:[UXCollectionViewCell class]]) {
            [self _reuseCell:view];
        } else {
            [self _reuseSupplementaryView:view];
        }
    }
    [_allVisibleViewsDict removeAllObjects];
    [_allVisibleViewsDict addEntriesFromDictionary:animating];
    [_indexPathsForSelectedItems removeAllIndexPaths];
    [_collectionViewData invalidate:NO];
    [self.documentView setNeedsLayout:YES];
}

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion {
    _updateAnimationCount++;
    if (updates) {
        updates();
    }
    [self reloadData];
    _updateAnimationCount--;
    if (completion) {
        completion(YES);
    }
}

- (void)insertSections:(NSIndexSet *)sections {
    [self performBatchUpdates:^{} completion:nil];
}

- (void)deleteSections:(NSIndexSet *)sections {
    [self performBatchUpdates:^{} completion:nil];
}

- (void)reloadSections:(NSIndexSet *)sections {
    [self performBatchUpdates:^{} completion:nil];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    [self performBatchUpdates:^{} completion:nil];
}

- (void)insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self performBatchUpdates:^{} completion:nil];
}

- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self performBatchUpdates:^{} completion:nil];
}

- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self performBatchUpdates:^{} completion:nil];
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self performBatchUpdates:^{} completion:nil];
}

#pragma mark - Layout

- (CGRect)documentContentRect {
    return [_collectionViewData collectionViewContentRect];
}

- (void)layoutSubviews {
    if (!_doneFirstLayout) {
        [self reloadData];
        _doneFirstLayout = YES;
    }
}

- (void)layout {
    [super layout];
    [self _updateVisibleCells];
}

- (void)_updateVisibleCells {
    CGRect visibleRect = self.documentVisibleRect;
    [_collectionViewData validateLayoutInRect:visibleRect];

    NSArray<UXCollectionViewLayoutAttributes *> *attributesList = [_collectionViewData layoutAttributesForElementsInRect:visibleRect];

    NSMutableSet<_UXCollectionViewItemKey *> *visibleKeys = [NSMutableSet set];
    for (UXCollectionViewLayoutAttributes *attributes in attributesList) {
        _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:attributes];
        [visibleKeys addObject:key];

        if (!_allVisibleViewsDict[key]) {
            UXCollectionReusableView *view = nil;
            if ([attributes _isCell]) {
                if ([self.dataSource respondsToSelector:@selector(collectionView:cellForItemAtIndexPath:)]) {
                    view = (UXCollectionReusableView *)[self.dataSource collectionView:self cellForItemAtIndexPath:attributes.indexPath];
                }
            } else if ([attributes _isSupplementaryView]) {
                if ([self.dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
                    view = [self.dataSource collectionView:self viewForSupplementaryElementOfKind:[attributes _elementKind] atIndexPath:attributes.indexPath];
                }
            }
            if (view) {
                [(id)view _setLayoutAttributes:attributes];
                view.frame = attributes.frame;
                [_collectionDocumentView addSubview:view];
                _allVisibleViewsDict[key] = view;
            }
        } else {
            UXCollectionReusableView *view = _allVisibleViewsDict[key];
            [(id)view _setLayoutAttributes:attributes];
            view.frame = attributes.frame;
        }
    }

    for (_UXCollectionViewItemKey *key in [_allVisibleViewsDict.allKeys copy]) {
        if (![visibleKeys containsObject:key]) {
            UXCollectionReusableView *view = _allVisibleViewsDict[key];
            [_allVisibleViewsDict removeObjectForKey:key];
            if ([view isKindOfClass:[UXCollectionViewCell class]]) {
                [self _reuseCell:(UXCollectionViewCell *)view];
            } else {
                [self _reuseSupplementaryView:view];
            }
        }
    }
}

#pragma mark - Accessibility

- (id)_retrieveAccessibiltyRoleDescriptionFromAXDelegate {
    if ([self.accessibilityDelegate respondsToSelector:@selector(accessibilityRoleDescriptionForCollectionView:)]) {
        return [self.accessibilityDelegate performSelector:@selector(accessibilityRoleDescriptionForCollectionView:) withObject:self];
    }
    return nil;
}

- (void)_notifyAccessibilityDelegateToPrepareSection:(id)section {
    if ([self.accessibilityDelegate respondsToSelector:@selector(collectionView:prepareAccessibilitySection:)]) {
        [self.accessibilityDelegate performSelector:@selector(collectionView:prepareAccessibilitySection:) withObject:self withObject:section];
    }
}

- (id)accessibilityChildren {
    return [_layout layoutAccessibility].accessibilityChildren;
}

#pragma mark - Stubs

- (void)_prepareCellsForOverdraw:(CGRect)rect {
}

- (NSArray<NSIndexPath *> *)nextIndexPath:(NSIndexPath *)indexPath {
    return [_layout indexPathOfItemAfter:indexPath];
}

- (NSIndexPath *)previousIndexPath:(NSIndexPath *)indexPath {
    return [_layout indexPathOfItemBefore:indexPath];
}

- (id)_currentUpdate {
    return nil;
}

@end
