#import "UXCollectionView+Private.h"

NSString *const UXCollectionElementKindCell = @"UXCollectionElementKindCell";

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
