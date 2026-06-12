#import "_UXCollectionViewRearrangingCoordinator.h"
#import "_UXCollectionViewLayoutProxy.h"
#import "UXCollectionView.h"
#import "UXCollectionView+Internal.h"
#import "UXCollectionViewCell.h"
#import "UXCollectionViewLayout.h"
#import "UXCollectionViewLayoutAttributes.h"
#import "UXCollectionViewPanGestureRecognizer.h"
#import "UXCollectionViewDataSource_Rearranging.h"
#import "UXCollectionViewDelegate_Rearranging.h"

typedef NS_ENUM(NSInteger, UXRearrangingInitiationMode) {
    UXRearrangingInitiationModeImmediate = 0,
    UXRearrangingInitiationModeDelayed = 1,
};

@interface _UXCollectionViewRearrangingCoordinator () <NSGestureRecognizerDelegate> {
    __weak UXCollectionView *_collectionView;
    _UXCollectionViewLayoutProxy *_layoutProxy;
    BOOL _enabled;
    BOOL _isRearranging;
    BOOL _autoscrolling;
    NSInteger _initiationMode;
    BOOL _allowDragOutsideCells;
    BOOL _continuouslyUpdateInsideCells;
    BOOL _usePileForSingleItem;
    BOOL _allowAutoscroll;
    BOOL _shouldExchange;
    BOOL _updatesLayoutOnDrag;
    CGFloat _rearrangingInitialDelay;
    CGFloat _rearrangingPreviewDelay;
    NSRange _initialIndexRange;
    NSRange _targetIndexRange;
    NSRange _movedIndexRange;
    NSRange _exchangedIndexRange;
    NSArray<NSIndexPath *> *_initialIndexPaths;
    NSArray<NSIndexPath *> *_targetIndexPaths;
    NSArray<NSIndexPath *> *_movedIndexPaths;
    NSArray<NSIndexPath *> *_exchangedIndexPaths;
    BOOL _initialIndexPathsAreContiguous;
    NSGestureRecognizer *_gestureRecognizer;
    NSEvent *_mouseDownEvent;
    CGFloat _dragStartTime;
    CGFloat _collectionViewReloadLastCallTime;
    CGFloat _dragEnteredTime;
    CGPoint _screenPoint;
    NSUInteger _sequenceNumber;
    UXCollectionViewCell *_dropTargetCell;
    NSUInteger _dropOperation;
    NSString *_dragSourceIdentifier;

    struct {
        unsigned int dataSourceImplementsCanMoveItemsAtIndexPaths : 1;
        unsigned int dataSourceImplementsShouldExchangeItemsAtIndexPathsWithProposedIndexPaths : 1;
        unsigned int dataSourceImplementsMoveItemsAtIndexPathsToIndexPath : 1;
        unsigned int dataSourceImplementsExchangeItemsAtIndexPathsWithIndexPaths : 1;
        unsigned int delegateImplementsShouldBeginDraggingSessionWithClickedItemAtIndexPath : 1;
        unsigned int delegateImplementsImageForDraggedItemAtIndexPath : 1;
        unsigned int delegateImplementsPasteboardWriterForItemAtIndexPath : 1;
        unsigned int delegateImplementsDraggingItemForIndexPathProposedDraggingItem : 1;
        unsigned int delegateImplementsUpdatesLayoutOnDrag : 1;
        unsigned int delegateImplementsPreferredDraggingFormation : 1;
        unsigned int delegateImplementsDragSourceIdentifier : 1;
        unsigned int delegateImplementsCreatedDraggingSessionForItemsAtIndexPaths : 1;
        unsigned int delegateImplementsDraggingSessionSourceOperationMaskForDraggingContext : 1;
        unsigned int delegateImplementsDraggingSessionWillBeginAtPoint : 1;
        unsigned int delegateImplementsDraggingSessionMovedToPoint : 1;
        unsigned int delegateImplementsDraggingSessionEndedAtPointDragOperation : 1;
        unsigned int delegateImplementsPrepareForDragOperation : 1;
        unsigned int delegateImplementsPerformDragOperation : 1;
        unsigned int delegateImplementsDraggingEntered : 1;
        unsigned int delegateImplementsDraggingUpdated : 1;
        unsigned int delegateImplementsDraggingExited : 1;
        unsigned int delegateImplementsDraggingEnded : 1;
    } _collectionViewFlags;
}
@end

@implementation _UXCollectionViewRearrangingCoordinator

@synthesize enabled = _enabled;
@synthesize initiationMode = _initiationMode;
@synthesize allowDragOutsideCells = _allowDragOutsideCells;
@synthesize continuouslyUpdateInsideCells = _continuouslyUpdateInsideCells;
@synthesize usePileForSingleItem = _usePileForSingleItem;
@synthesize allowAutoscroll = _allowAutoscroll;
@synthesize shouldExchange = _shouldExchange;
@synthesize rearrangingInitialDelay = _rearrangingInitialDelay;
@synthesize rearrangingPreviewDelay = _rearrangingPreviewDelay;
@synthesize initialIndexRange = _initialIndexRange;
@synthesize targetIndexRange = _targetIndexRange;
@synthesize movedIndexRange = _movedIndexRange;
@synthesize exchangedIndexRange = _exchangedIndexRange;
@synthesize dropTargetCell = _dropTargetCell;
@synthesize dropOperation = _dropOperation;
@synthesize dragSourceIdentifier = _dragSourceIdentifier;

- (instancetype)init {
    return [self initWithCollectionView:nil];
}

- (instancetype)initWithCollectionView:(UXCollectionView *)collectionView {
    self = [super init];
    if (self) {
        _collectionView = collectionView;
        _initiationMode = UXRearrangingInitiationModeImmediate;
        _rearrangingInitialDelay = 0.5;
        _rearrangingPreviewDelay = 0.25;
        _initialIndexRange = NSMakeRange(NSNotFound, 0);
        _targetIndexRange = NSMakeRange(NSNotFound, 0);
        _movedIndexRange = NSMakeRange(NSNotFound, 0);
        _exchangedIndexRange = NSMakeRange(NSNotFound, 0);
        [self _refreshDataSourceFlags];
        [self _refreshDelegateFlags];
    }
    return self;
}

- (UXCollectionView *)collectionView {
    return _collectionView;
}

- (UXCollectionViewLayout *)collectionViewLayout {
    return _collectionView.collectionViewLayout;
}

- (BOOL)isRearranging {
    return _isRearranging;
}

#pragma mark - Capability detection

- (void)_refreshDataSourceFlags {
    id dataSource = _collectionView.dataSource;
    _collectionViewFlags.dataSourceImplementsCanMoveItemsAtIndexPaths =
        [dataSource respondsToSelector:@selector(collectionView:canMoveItemsAtIndexPaths:)];
    _collectionViewFlags.dataSourceImplementsShouldExchangeItemsAtIndexPathsWithProposedIndexPaths =
        [dataSource respondsToSelector:@selector(collectionView:shouldExchangeItemsAtIndexPaths:withProposedIndexPaths:)];
    _collectionViewFlags.dataSourceImplementsMoveItemsAtIndexPathsToIndexPath =
        [dataSource respondsToSelector:@selector(collectionView:moveItemsAtIndexPaths:toIndexPath:)];
    _collectionViewFlags.dataSourceImplementsExchangeItemsAtIndexPathsWithIndexPaths =
        [dataSource respondsToSelector:@selector(collectionView:exchangeItemsAtIndexPaths:withIndexPaths:)];
}

- (void)_refreshDelegateFlags {
    id delegate = _collectionView.delegate;
    _collectionViewFlags.delegateImplementsShouldBeginDraggingSessionWithClickedItemAtIndexPath =
        [delegate respondsToSelector:@selector(collectionView:shouldBeginDraggingSessionWithClickedItemAtIndexPath:)];
    _collectionViewFlags.delegateImplementsImageForDraggedItemAtIndexPath =
        [delegate respondsToSelector:@selector(collectionView:imageForDraggedItemAtIndexPath:)];
    _collectionViewFlags.delegateImplementsPasteboardWriterForItemAtIndexPath =
        [delegate respondsToSelector:@selector(collectionView:pasteboardWriterForItemAtIndexPath:)];
    _collectionViewFlags.delegateImplementsDraggingItemForIndexPathProposedDraggingItem =
        [delegate respondsToSelector:@selector(collectionView:draggingItemForIndexPath:proposedDraggingItem:)];
    _collectionViewFlags.delegateImplementsUpdatesLayoutOnDrag =
        [delegate respondsToSelector:@selector(collectionViewUpdatesLayoutOnDrag:)];
    _collectionViewFlags.delegateImplementsPreferredDraggingFormation =
        [delegate respondsToSelector:@selector(collectionView:preferredDraggingFormationForIndexPaths:)];
    _collectionViewFlags.delegateImplementsDragSourceIdentifier =
        [delegate respondsToSelector:@selector(dragSourceIdentifierForCollectionView:)];
    _collectionViewFlags.delegateImplementsCreatedDraggingSessionForItemsAtIndexPaths =
        [delegate respondsToSelector:@selector(collectionView:createdDraggingSession:forItemsAtIndexPaths:)];
    _collectionViewFlags.delegateImplementsDraggingSessionSourceOperationMaskForDraggingContext =
        [delegate respondsToSelector:@selector(collectionView:draggingSession:sourceOperationMaskForDraggingContext:)];
    _collectionViewFlags.delegateImplementsDraggingSessionWillBeginAtPoint =
        [delegate respondsToSelector:@selector(collectionView:draggingSession:willBeginAtPoint:)];
    _collectionViewFlags.delegateImplementsDraggingSessionMovedToPoint =
        [delegate respondsToSelector:@selector(collectionView:draggingSession:movedToPoint:)];
    _collectionViewFlags.delegateImplementsDraggingSessionEndedAtPointDragOperation =
        [delegate respondsToSelector:@selector(collectionView:draggingSession:endedAtPoint:dragOperation:)];
    _collectionViewFlags.delegateImplementsPrepareForDragOperation =
        [delegate respondsToSelector:@selector(collectionView:prepareForDragOperation:)];
    _collectionViewFlags.delegateImplementsPerformDragOperation =
        [delegate respondsToSelector:@selector(collectionView:performDragOperation:)];
    _collectionViewFlags.delegateImplementsDraggingEntered =
        [delegate respondsToSelector:@selector(collectionView:draggingEntered:)];
    _collectionViewFlags.delegateImplementsDraggingUpdated =
        [delegate respondsToSelector:@selector(collectionView:draggingUpdated:)];
    _collectionViewFlags.delegateImplementsDraggingExited =
        [delegate respondsToSelector:@selector(collectionView:draggingExited:)];
    _collectionViewFlags.delegateImplementsDraggingEnded =
        [delegate respondsToSelector:@selector(collectionView:draggingEnded:)];
    _updatesLayoutOnDrag = _collectionViewFlags.delegateImplementsUpdatesLayoutOnDrag &&
        [(id<UXCollectionViewDelegate_Rearranging>)delegate collectionViewUpdatesLayoutOnDrag:_collectionView];
}

- (id<UXCollectionViewDataSource_Rearranging>)dataSource {
    return (id<UXCollectionViewDataSource_Rearranging>)_collectionView.dataSource;
}

- (id<UXCollectionViewDelegate_Rearranging>)delegate {
    return (id<UXCollectionViewDelegate_Rearranging>)_collectionView.delegate;
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled == enabled) {
        return;
    }
    _enabled = enabled;
    if (enabled) {
        if (!_gestureRecognizer) {
            [self createGestureRecognizer];
        }
        [self _refreshDataSourceFlags];
        [self _refreshDelegateFlags];
    } else if (_gestureRecognizer) {
        [self removeGestureRecognizer];
    }
}

- (void)setInitiationMode:(NSInteger)initiationMode {
    _initiationMode = initiationMode;
    if (_gestureRecognizer && _enabled) {
        [self removeGestureRecognizer];
        [self createGestureRecognizer];
    }
}

#pragma mark - Gesture recognizer lifecycle

- (void)createGestureRecognizer {
    if (_gestureRecognizer || !_collectionView) {
        return;
    }
    if (_initiationMode == UXRearrangingInitiationModeDelayed) {
        NSPressGestureRecognizer *press = [[NSPressGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureRecognized:)];
        press.minimumPressDuration = _rearrangingInitialDelay;
        press.allowableMovement = 5.0;
        press.delegate = self;
        _gestureRecognizer = press;
    } else {
        UXCollectionViewPanGestureRecognizer *pan = [[UXCollectionViewPanGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureRecognized:)];
        pan.delegate = self;
        _gestureRecognizer = pan;
    }
    [_collectionView addGestureRecognizer:_gestureRecognizer];
}

- (void)removeGestureRecognizer {
    if (_gestureRecognizer && _collectionView) {
        [_collectionView removeGestureRecognizer:_gestureRecognizer];
    }
    _gestureRecognizer = nil;
}

- (BOOL)gestureRecognizerShouldBegin:(NSGestureRecognizer *)gestureRecognizer {
    if (!_enabled) {
        return NO;
    }
    NSPoint locationInView = [gestureRecognizer locationInView:_collectionView];
    NSPoint locationInDocument = [_collectionView.documentView convertPoint:locationInView fromView:_collectionView];
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:locationInDocument];
    if (!indexPath) {
        return NO;
    }
    if (_collectionViewFlags.delegateImplementsShouldBeginDraggingSessionWithClickedItemAtIndexPath) {
        return [self.delegate collectionView:_collectionView shouldBeginDraggingSessionWithClickedItemAtIndexPath:indexPath];
    }
    return _enabled && [self _allowRearranging];
}

- (BOOL)_allowRearranging {
    if (!_enabled || !_collectionView) {
        return NO;
    }
    if (![[_collectionView indexPathsForSelectedItems] count] && !_usePileForSingleItem) {
        return NO;
    }
    if (_collectionViewFlags.dataSourceImplementsCanMoveItemsAtIndexPaths) {
        NSArray<NSIndexPath *> *selected = [_collectionView indexPathsForSelectedItems];
        return [self.dataSource collectionView:_collectionView canMoveItemsAtIndexPaths:selected ?: @[]];
    }
    return _collectionViewFlags.dataSourceImplementsMoveItemsAtIndexPathsToIndexPath ||
           _collectionViewFlags.dataSourceImplementsExchangeItemsAtIndexPathsWithIndexPaths;
}

- (void)_gestureRecognized:(NSGestureRecognizer *)recognizer {
    NSPoint locationInView = [recognizer locationInView:_collectionView];
    NSPoint locationInDocument = [_collectionView.documentView convertPoint:locationInView fromView:_collectionView];
    switch (recognizer.state) {
        case NSGestureRecognizerStateBegan: {
            NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:locationInDocument];
            if (!indexPath) {
                return;
            }
            NSArray<NSIndexPath *> *selected = [_collectionView indexPathsForSelectedItems];
            NSArray<NSIndexPath *> *indexPaths = ([selected containsObject:indexPath] && selected.count > 0) ? selected : @[indexPath];
            [self _beginRearrangingItemsWithIndexPaths:indexPaths];
            break;
        }
        case NSGestureRecognizerStateChanged: {
            [self _updateRearrangingStateForLocation:locationInDocument];
            if (_allowAutoscroll) {
                [self _autoscrollWithWindowLocation:[recognizer locationInView:nil]];
            }
            break;
        }
        case NSGestureRecognizerStateEnded:
            [self _finishRearrangingForLocation:locationInDocument];
            break;
        case NSGestureRecognizerStateCancelled:
        case NSGestureRecognizerStateFailed:
            _isRearranging = NO;
            _initialIndexPaths = nil;
            _targetIndexPaths = nil;
            _movedIndexPaths = nil;
            _exchangedIndexPaths = nil;
            break;
        default:
            break;
    }
}

#pragma mark - Rearranging lifecycle

- (void)_beginRearrangingItemsWithIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (indexPaths.count == 0) {
        return;
    }
    _isRearranging = YES;
    _initialIndexPaths = [indexPaths copy];
    _targetIndexPaths = [indexPaths copy];
    _movedIndexPaths = nil;
    _exchangedIndexPaths = nil;
    _dragStartTime = CFAbsoluteTimeGetCurrent();
    _initialIndexPathsAreContiguous = [self _indexPathsAreContiguous:indexPaths];
    if (indexPaths.count > 0) {
        _initialIndexRange = NSMakeRange([[indexPaths firstObject] item], indexPaths.count);
    }
    [self _beginDraggingSessionForIndexPaths:indexPaths];
}

- (BOOL)_indexPathsAreContiguous:(NSArray<NSIndexPath *> *)indexPaths {
    if (indexPaths.count <= 1) {
        return YES;
    }
    NSArray<NSIndexPath *> *sorted = [indexPaths sortedArrayUsingSelector:@selector(compare:)];
    NSInteger previousItem = NSNotFound;
    NSInteger previousSection = NSNotFound;
    for (NSIndexPath *indexPath in sorted) {
        if (previousItem != NSNotFound) {
            if (indexPath.section != previousSection || indexPath.item != previousItem + 1) {
                return NO;
            }
        }
        previousItem = indexPath.item;
        previousSection = indexPath.section;
    }
    return YES;
}

- (void)_updateRearrangingStateForLocation:(NSPoint)location {
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:location];
    if (!indexPath) {
        return;
    }

    BOOL exchangeMode = _shouldExchange;
    if (_collectionViewFlags.dataSourceImplementsShouldExchangeItemsAtIndexPathsWithProposedIndexPaths) {
        exchangeMode = [self.dataSource collectionView:_collectionView shouldExchangeItemsAtIndexPaths:_initialIndexPaths withProposedIndexPaths:@[indexPath]];
    }

    if (exchangeMode) {
        _exchangedIndexPaths = @[indexPath];
        _exchangedIndexRange = NSMakeRange(indexPath.item, 1);
    } else {
        _targetIndexPaths = @[indexPath];
        _targetIndexRange = NSMakeRange(indexPath.item, _initialIndexPaths.count);
        UXCollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
        if (cell != _dropTargetCell) {
            _dropTargetCell = cell;
        }
    }

    if (_continuouslyUpdateInsideCells && _updatesLayoutOnDrag) {
        [_collectionView updateLayout];
    }
}

- (void)_finishRearrangingForLocation:(NSPoint)location {
    NSIndexPath *targetIndexPath = [_collectionView indexPathForItemAtPoint:location];
    NSArray<NSIndexPath *> *initial = _initialIndexPaths ?: @[];

    BOOL didChange = NO;
    if (targetIndexPath) {
        if (_shouldExchange && _collectionViewFlags.dataSourceImplementsExchangeItemsAtIndexPathsWithIndexPaths) {
            didChange = [self.dataSource collectionView:_collectionView
                                exchangeItemsAtIndexPaths:initial
                                          withIndexPaths:@[targetIndexPath]];
        } else if (_collectionViewFlags.dataSourceImplementsMoveItemsAtIndexPathsToIndexPath) {
            didChange = [self.dataSource collectionView:_collectionView
                                  moveItemsAtIndexPaths:initial
                                            toIndexPath:targetIndexPath];
        }
    }

    if (didChange) {
        _movedIndexPaths = targetIndexPath ? @[targetIndexPath] : nil;
        [self _reloadCollectionViewWithAnimation];
    } else if (_continuouslyUpdateInsideCells) {
        [_collectionView updateLayout];
    }

    _isRearranging = NO;
    _dropTargetCell = nil;
    _initialIndexPaths = nil;
    _targetIndexPaths = nil;
    _exchangedIndexPaths = nil;
    _initialIndexRange = NSMakeRange(NSNotFound, 0);
    _targetIndexRange = NSMakeRange(NSNotFound, 0);
    _exchangedIndexRange = NSMakeRange(NSNotFound, 0);
}

- (void)_moveItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (_collectionViewFlags.dataSourceImplementsMoveItemsAtIndexPathsToIndexPath && _initialIndexPaths.count) {
        NSIndexPath *target = [indexPaths firstObject] ?: [_initialIndexPaths firstObject];
        if (target) {
            [self.dataSource collectionView:_collectionView
                      moveItemsAtIndexPaths:_initialIndexPaths
                                toIndexPath:target];
        }
    }
}

- (void)_reloadCollectionViewWithAnimation {
    _collectionViewReloadLastCallTime = CFAbsoluteTimeGetCurrent();
    [_collectionView performBatchUpdates:^{
        // The data source has already mutated; performBatchUpdates will refresh visible cells.
    } completion:nil];
}

- (void)reloadLayout {
    [self _reloadCollectionViewWithAnimation];
}

#pragma mark - Autoscroll

- (void)_autoscrollWithWindowLocation:(NSPoint)windowLocation {
    if (_autoscrolling) {
        return;
    }
    NSClipView *clipView = _collectionView.contentView;
    NSPoint locationInClip = [clipView convertPoint:windowLocation fromView:nil];
    CGRect bounds = clipView.bounds;
    CGFloat edgeThreshold = 40.0;
    CGPoint scrollDelta = CGPointZero;
    if (locationInClip.y < CGRectGetMinY(bounds) + edgeThreshold) {
        scrollDelta.y = -10.0;
    } else if (locationInClip.y > CGRectGetMaxY(bounds) - edgeThreshold) {
        scrollDelta.y = 10.0;
    }
    if (locationInClip.x < CGRectGetMinX(bounds) + edgeThreshold) {
        scrollDelta.x = -10.0;
    } else if (locationInClip.x > CGRectGetMaxX(bounds) - edgeThreshold) {
        scrollDelta.x = 10.0;
    }
    if (CGPointEqualToPoint(scrollDelta, CGPointZero)) {
        return;
    }
    _autoscrolling = YES;
    CGPoint newOrigin = CGPointMake(bounds.origin.x + scrollDelta.x, bounds.origin.y + scrollDelta.y);
    [clipView setBoundsOrigin:newOrigin];
    [_collectionView reflectScrolledClipView:clipView];
    _autoscrolling = NO;
}

- (BOOL)_allowAutoscrollForDraggingInfo:(id<NSDraggingInfo>)draggingInfo {
    return _allowAutoscroll;
}

#pragma mark - Dragging session

- (void)_beginDraggingSessionForIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (!_mouseDownEvent) {
        return;
    }
    NSMutableArray<NSDraggingItem *> *draggingItems = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
        id<NSPasteboardWriting> writer = nil;
        if (_collectionViewFlags.delegateImplementsPasteboardWriterForItemAtIndexPath) {
            writer = [self.delegate collectionView:_collectionView pasteboardWriterForItemAtIndexPath:indexPath];
        }
        if (!writer) {
            writer = [[NSPasteboardItem alloc] init];
        }
        NSDraggingItem *item = [[NSDraggingItem alloc] initWithPasteboardWriter:writer];
        NSImage *image = [self _imageForItemAtIndexPath:indexPath];
        UXCollectionViewLayoutAttributes *attributes = [_collectionView layoutAttributesForItemAtIndexPath:indexPath];
        CGRect frame = attributes.frame;
        if (image) {
            [item setDraggingFrame:frame contents:image];
        } else {
            [item setDraggingFrame:frame contents:nil];
        }
        if (_collectionViewFlags.delegateImplementsDraggingItemForIndexPathProposedDraggingItem) {
            NSDraggingItem *override = [self.delegate collectionView:_collectionView draggingItemForIndexPath:indexPath proposedDraggingItem:item];
            if (override) {
                item = override;
            }
        }
        [draggingItems addObject:item];
    }
    if (draggingItems.count == 0) {
        return;
    }
    NSDraggingSession *session = [_collectionView beginDraggingSessionWithItems:draggingItems
                                                                          event:_mouseDownEvent
                                                                         source:self];
    if (_collectionViewFlags.delegateImplementsPreferredDraggingFormation) {
        session.draggingFormation = [self.delegate collectionView:_collectionView preferredDraggingFormationForIndexPaths:indexPaths];
    }
    [self _createdDraggingSession:session];
    [self _updateDragSourceIdentifier];
}

- (void)_createdDraggingSession:(NSDraggingSession *)session {
    if (_collectionViewFlags.delegateImplementsCreatedDraggingSessionForItemsAtIndexPaths) {
        [self.delegate collectionView:_collectionView createdDraggingSession:session forItemsAtIndexPaths:_initialIndexPaths];
    }
}

- (void)_updateDragSourceIdentifier {
    if (_collectionViewFlags.delegateImplementsDragSourceIdentifier) {
        _dragSourceIdentifier = [[self.delegate dragSourceIdentifierForCollectionView:_collectionView] copy];
    } else {
        _dragSourceIdentifier = [[NSString alloc] initWithFormat:@"_UXCollectionViewDrag-%p-%lu", _collectionView, (unsigned long)_sequenceNumber++];
    }
}

- (NSImage *)_imageForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_collectionViewFlags.delegateImplementsImageForDraggedItemAtIndexPath) {
        NSImage *image = [self.delegate collectionView:_collectionView imageForDraggedItemAtIndexPath:indexPath];
        if (image) {
            return image;
        }
    }
    UXCollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
    if (!cell) {
        return nil;
    }
    NSBitmapImageRep *rep = [cell bitmapImageRepForCachingDisplayInRect:cell.bounds];
    if (!rep) {
        return nil;
    }
    [cell cacheDisplayInRect:cell.bounds toBitmapImageRep:rep];
    NSImage *image = [[NSImage alloc] initWithSize:cell.bounds.size];
    [image addRepresentation:rep];
    return image;
}

- (BOOL)_isSourceOfDraggingInfo:(id<NSDraggingInfo>)draggingInfo {
    if (![draggingInfo respondsToSelector:@selector(draggingSource)]) {
        return NO;
    }
    return draggingInfo.draggingSource == self || draggingInfo.draggingSource == _collectionView;
}

- (BOOL)_isEquivalentSourceOfDraggingInfo:(id<NSDraggingInfo>)draggingInfo {
    return [self _isSourceOfDraggingInfo:draggingInfo];
}

- (BOOL)_shouldHandleExternalDrop:(id<NSDraggingInfo>)draggingInfo {
    if ([self _isSourceOfDraggingInfo:draggingInfo]) {
        return NO;
    }
    return _collectionView.rearrangingExternalDropEnabled_;
}

#pragma mark - NSDraggingSource

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    if (_collectionViewFlags.delegateImplementsDraggingSessionSourceOperationMaskForDraggingContext) {
        return [self.delegate collectionView:_collectionView draggingSession:session sourceOperationMaskForDraggingContext:context];
    }
    return NSDragOperationMove | NSDragOperationCopy | NSDragOperationGeneric;
}

- (void)draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint {
    _screenPoint = screenPoint;
    if (_collectionViewFlags.delegateImplementsDraggingSessionWillBeginAtPoint) {
        [self.delegate collectionView:_collectionView draggingSession:session willBeginAtPoint:screenPoint];
    }
}

- (void)draggingSession:(NSDraggingSession *)session movedToPoint:(NSPoint)screenPoint {
    _screenPoint = screenPoint;
    if (_collectionViewFlags.delegateImplementsDraggingSessionMovedToPoint) {
        [self.delegate collectionView:_collectionView draggingSession:session movedToPoint:screenPoint];
    }
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    if (_collectionViewFlags.delegateImplementsDraggingSessionEndedAtPointDragOperation) {
        [self.delegate collectionView:_collectionView draggingSession:session endedAtPoint:screenPoint dragOperation:operation];
    }
}

#pragma mark - NSDraggingDestination

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    _dragEnteredTime = CFAbsoluteTimeGetCurrent();
    if (_collectionViewFlags.delegateImplementsDraggingEntered) {
        return [self.delegate collectionView:_collectionView draggingEntered:sender];
    }
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
    if (_collectionViewFlags.delegateImplementsDraggingUpdated) {
        return [self.delegate collectionView:_collectionView draggingUpdated:sender];
    }
    return [self _isSourceOfDraggingInfo:sender] ? NSDragOperationMove : NSDragOperationNone;
}

- (void)draggingExited:(nullable id<NSDraggingInfo>)sender {
    if (_collectionViewFlags.delegateImplementsDraggingExited) {
        [self.delegate collectionView:_collectionView draggingExited:sender];
    }
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    if (_collectionViewFlags.delegateImplementsPrepareForDragOperation) {
        return [self.delegate collectionView:_collectionView prepareForDragOperation:sender];
    }
    return [self _isSourceOfDraggingInfo:sender];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    if (_collectionViewFlags.delegateImplementsPerformDragOperation) {
        return [self.delegate collectionView:_collectionView performDragOperation:sender];
    }
    return NO;
}

- (void)concludeDragOperation:(nullable id<NSDraggingInfo>)sender {
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender {
    if (_collectionViewFlags.delegateImplementsDraggingEnded) {
        [self.delegate collectionView:_collectionView draggingEnded:sender];
    }
}

- (void)updateDraggingItemsForDrag:(nullable id<NSDraggingInfo>)draggingInfo {
}

- (BOOL)wantsPeriodicDraggingUpdates {
    return YES;
}

#pragma mark - UXCollectionViewLayoutProxyDelegate

- (NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return nil;
}

#pragma mark - SPI hooks

- (void)_createdDraggingSession:(NSDraggingSession *)session forItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
}

- (void)_finishRearrangingForLocation:(CGPoint)location shouldComplete:(BOOL)shouldComplete {
}

- (void)_moveItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths toIndexPaths:(NSArray<NSIndexPath *> *)toIndexPaths {
    NSAssert(indexPaths.count == toIndexPaths.count, @"source and destination index paths need to have the same count");
    [_collectionView performBatchUpdates:^{
        for (NSUInteger index = 0; index < indexPaths.count; index++) {
            [self->_collectionView moveItemAtIndexPath:indexPaths[index] toIndexPath:toIndexPaths[index]];
        }
    } completion:nil];
}

@end
