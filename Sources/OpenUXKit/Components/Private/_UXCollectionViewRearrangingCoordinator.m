#import "_UXCollectionViewRearrangingCoordinator.h"
#import "_UXCollectionViewLayoutProxy.h"
#import "UXCollectionView.h"
#import "UXCollectionView+Internal.h"
#import "UXCollectionViewCell.h"
#import "UXCollectionReusableView.h"
#import "UXCollectionViewLayout.h"
#import "UXCollectionViewLayout+Internal.h"
#import "UXCollectionViewLayoutAttributes.h"
#import "UXCollectionViewPanGestureRecognizer.h"
#import "UXCollectionViewDataSource_Rearranging.h"
#import "UXCollectionViewDelegate_Rearranging.h"
#import "NSPasteboard+UXKit.h"

// UXKit stores the initiation mode as a raw NSInteger (no named enum survives in
// the binary). These names mirror the dispatch in
// -[_UXCollectionViewRearrangingCoordinator createGestureRecognizer] (0x1dbbce134):
// mode 0 (the default) installs an NSPressGestureRecognizer, so the drag only
// starts after a press-and-hold; any non-zero mode installs the
// UXCollectionViewPanGestureRecognizer, so the drag starts on the first pointer
// movement. (An earlier port had this mapping inverted, which is why OpenUXKit
// dragged on movement while the system UXKit required a press-and-hold.)
typedef NS_ENUM(NSInteger, UXRearrangingInitiationMode) {
    UXRearrangingInitiationModePressAndHold = 0,
    UXRearrangingInitiationModeDragImmediately = 1,
};

// UXKit's UXCollectionView pasteboard type carrying the dragged item's
// {item, section}; the willBegin source callback reads it back to rebuild the
// dragged index paths.
static NSString *const UXCollectionViewRearrangingPasteboardType = @"com.apple.UXCollectionView.draggingitem";

// _indexPathsFromRange (static, 0x1dbbcd9fc): [from, from+count) in `section`.
static NSArray<NSIndexPath *> *UXIndexPathsFromRange(NSUInteger fromItem, NSUInteger count, NSInteger section) {
    NSMutableArray<NSIndexPath *> *result = [NSMutableArray array];
    for (NSUInteger item = fromItem; item < fromItem + count; item++) {
        [result addObject:[NSIndexPath indexPathForItem:(NSInteger)item inSection:section]];
    }
    return result;
}

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
        _initiationMode = UXRearrangingInitiationModePressAndHold;
        // Defaults transcribed from -[_UXCollectionViewRearrangingCoordinator
        // initWithCollectionView:] (0x1dbbce444): the OWORD written at ivar offset
        // 0xa0 is {_rearrangingInitialDelay = 0.33, _rearrangingPreviewDelay = 0.1}.
        // The preview delay is load-bearing: -draggingSession:movedToPoint: debounces
        // -_updateRearrangingStateForLocation: by this interval, so it must be short
        // enough to fire on the natural pause as the pointer settles over a drop
        // target. A too-large value (the earlier 0.25) never elapses during a
        // continuous drag, so _targetIndexPaths never advances past the initial
        // selection and -_finishRearrangingForLocation:shouldComplete: cancels.
        _rearrangingInitialDelay = 0.33;
        _rearrangingPreviewDelay = 0.1;
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
        [dataSource respondsToSelector:@selector(collectionView:moveItemsAtIndexPaths:toIndexPath:dropPosition:)];
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
    // 0x1dbbce134 — faithful: drop any existing recognizer, then pick the class by
    // initiation mode and install it. Mode 0 (the default) uses an
    // NSPressGestureRecognizer, so the drag starts only after a press-and-hold;
    // any non-zero mode uses the pan recognizer, so the drag starts on the first
    // movement. Both have primary/secondary mouse-button event delaying turned OFF
    // (so the recognizer does not delay the click the cell needs). The binary does
    // NOT override the press recognizer's minimumPressDuration/allowableMovement,
    // so it keeps AppKit's defaults (~0.5s hold).
    [self removeGestureRecognizer];
    if (!_collectionView) {
        return;
    }
    Class recognizerClass = (_initiationMode == UXRearrangingInitiationModePressAndHold)
        ? [NSPressGestureRecognizer class]
        : [UXCollectionViewPanGestureRecognizer class];
    NSGestureRecognizer *recognizer = [[recognizerClass alloc] initWithTarget:self action:@selector(_gestureRecognized:)];
    recognizer.delaysPrimaryMouseButtonEvents = NO;
    recognizer.delaysSecondaryMouseButtonEvents = NO;
    recognizer.delegate = self;
    _gestureRecognizer = recognizer;
    [_collectionView addGestureRecognizer:recognizer];
}

- (void)removeGestureRecognizer {
    if (_gestureRecognizer && _collectionView) {
        [_collectionView removeGestureRecognizer:_gestureRecognizer];
    }
    _gestureRecognizer = nil;
}

- (BOOL)gestureRecognizerShouldBegin:(NSGestureRecognizer *)gestureRecognizer {
    // UXKit only blocks the gesture while the collection view is mid-update
    // (0x1dbbce094); the per-item eligibility is decided in _gestureRecognized:.
    return ![_collectionView isBusy];
}

- (BOOL)_allowRearranging {
    // 0x1dbbcde74 — a time gate: the live reorder engages only after the initial
    // delay elapses from the drag start (it is NOT a selection check).
    return CFAbsoluteTimeGetCurrent() > _dragStartTime + _rearrangingInitialDelay;
}

- (void)_gestureRecognized:(NSGestureRecognizer *)recognizer {
    // UXKit only kicks off the drag on Began/Changed; the NSDraggingSession
    // callbacks drive the rest of the state machine (0x1dbbcdeac).
    NSGestureRecognizerState state = recognizer.state;
    if (state != NSGestureRecognizerStateBegan && state != NSGestureRecognizerStateChanged) {
        return;
    }
    UXCollectionView *collectionView = _collectionView;
    NSPoint location = [recognizer locationInView:collectionView.contentView];
    NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:location];
    NSView *hitView = [collectionView.documentView hitTest:location];
    if (!collectionView.rearrangingEnabled_) {
        return;
    }
    BOOL hitReusableView = NO;
    for (NSView *view = hitView; view != nil; view = view.superview) {
        if ([view isKindOfClass:[UXCollectionReusableView class]]) {
            hitReusableView = YES;
            break;
        }
    }
    if (!indexPath || !hitReusableView) {
        return;
    }
    NSArray<NSIndexPath *> *indexPaths = collectionView.allowsSelection
        ? [collectionView indexPathsForSelectedItems]
        : @[indexPath];
    BOOL shouldBegin;
    if (indexPaths.count > 0) {
        shouldBegin = _collectionViewFlags.delegateImplementsShouldBeginDraggingSessionWithClickedItemAtIndexPath
            ? [self.delegate collectionView:collectionView shouldBeginDraggingSessionWithClickedItemAtIndexPath:indexPath]
            : YES;
    } else {
        shouldBegin = NO;
    }
    if ([recognizer isKindOfClass:[NSPanGestureRecognizer class]]) {
        NSPoint translation = [(NSPanGestureRecognizer *)recognizer translationInView:collectionView];
        if (fabs(translation.x) >= 3.0) {
            if (!shouldBegin) {
                return;
            }
        } else if (!(fabs(translation.y) >= 3.0 && shouldBegin)) {
            return;
        }
        if ([recognizer isKindOfClass:[UXCollectionViewPanGestureRecognizer class]]) {
            _mouseDownEvent = [(UXCollectionViewPanGestureRecognizer *)recognizer mouseDownEvent];
            [(UXCollectionViewPanGestureRecognizer *)recognizer uxCancel];
        }
    }
    [self _beginDraggingSessionForIndexPaths:indexPaths];
}

#pragma mark - Rearranging lifecycle

- (void)_beginRearrangingItemsWithIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    // Called by the NSDraggingSource willBegin callback (0x1dbbcddec); the
    // session is already running, so this only seeds the rearranging state.
    _isRearranging = YES;
    _dragStartTime = CFAbsoluteTimeGetCurrent();
    _initialIndexPathsAreContiguous = YES;
    _initialIndexPaths = [indexPaths sortedArrayUsingSelector:@selector(compare:)];
    _movedIndexPaths = indexPaths;
    _targetIndexPaths = indexPaths;
    [self.collectionViewLayout invalidateLayout];
}

- (void)_updateRearrangingStateForLocation:(NSValue *)value {
    // 0x1dbbcdb40 — the argument is an NSValue boxing a document-space point so
    // it can ride through performSelector:withObject:afterDelay: (preview delay).
    NSPoint location = value.pointValue;
    UXCollectionView *collectionView = _collectionView;
    NSPoint locationInView = [collectionView convertPoint:location fromView:collectionView.documentView];
    _isRearranging = CGRectContainsPoint(collectionView.bounds, locationInView);

    UXCollectionViewLayout *layout = self.collectionViewLayout;
    NSIndexPath *indexPath = [[[layout layoutAttributesForElementsInRect:CGRectMake(location.x, location.y, 1.0, 1.0)] firstObject] indexPath];
    if (!indexPath) {
        indexPath = [layout proposedDropIndexPathForDraggingPoint:location];
    }
    if (!indexPath || indexPath.item == NSNotFound) {
        self.dropTargetCell = nil;
        self.dropOperation = 0;
        if (_updatesLayoutOnDrag && _continuouslyUpdateInsideCells) {
            [self _reloadCollectionViewWithAnimation];
        }
        return;
    }

    NSArray<NSIndexPath *> *range = UXIndexPathsFromRange((NSUInteger)indexPath.item, _initialIndexPaths.count, indexPath.section);
    _shouldExchange = NO;
    NSArray<NSIndexPath *> *target;
    if (_initialIndexPathsAreContiguous
        && _collectionViewFlags.dataSourceImplementsShouldExchangeItemsAtIndexPathsWithProposedIndexPaths
        && (_shouldExchange = [self.dataSource collectionView:collectionView shouldExchangeItemsAtIndexPaths:_initialIndexPaths withProposedIndexPaths:range])) {
        target = range;
        if ([_exchangedIndexPaths containsObject:indexPath] && (NSUInteger)indexPath.item == _initialIndexRange.location) {
            indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:0];
        }
    } else {
        target = @[indexPath];
        if ([layout dropPositionForPoint:location withIndexPaths:_initialIndexPaths movedToIndexPath:indexPath] == 4) {
            self.dropTargetCell = [collectionView cellForItemAtIndexPath:indexPath];
            self.dropOperation = [collectionView dragOperationForItemsAtIndexPaths:_initialIndexPaths movedOntoItemAtIndexPath:indexPath];
        } else {
            self.dropTargetCell = nil;
            self.dropOperation = 0;
        }
    }

    if (_updatesLayoutOnDrag && (_continuouslyUpdateInsideCells || ![_targetIndexPaths containsObject:indexPath])) {
        _targetIndexPaths = target;
        [self _reloadCollectionViewWithAnimation];
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
    // 0x1dbbccfa8. The collection view is the NSDraggingSource; each dragging
    // item carries the {item, section} plist the willBegin callback reads back.
    if (indexPaths.count == 0) {
        NSLog(@"Error attempting to begin a rearranging drag session with no index paths.");
        return;
    }
    UXCollectionView *collectionView = _collectionView;
    if (_collectionViewFlags.dataSourceImplementsCanMoveItemsAtIndexPaths
        && ![self.dataSource collectionView:collectionView canMoveItemsAtIndexPaths:indexPaths]) {
        return;
    }
    _updatesLayoutOnDrag = _collectionViewFlags.delegateImplementsUpdatesLayoutOnDrag
        ? [self.delegate collectionViewUpdatesLayoutOnDrag:collectionView]
        : YES;
    NSEvent *event = _mouseDownEvent ?: collectionView.window.currentEvent;
    NSMutableArray<NSDraggingItem *> *draggingItems = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
        UXCollectionViewLayoutAttributes *attributes = [collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
        NSImage *image = [self _imageForItemAtIndexPath:indexPath];
        CGRect frame = attributes.frame;
        CGFloat width = MAX(image.size.width, 1.0);
        CGFloat height = MAX(image.size.height, 1.0);
        NSDictionary *plist = @{ @"item": @(indexPath.item), @"section": @(indexPath.section) };
        id<NSPasteboardWriting> writer = nil;
        if (_collectionViewFlags.delegateImplementsPasteboardWriterForItemAtIndexPath) {
            writer = [self.delegate collectionView:collectionView pasteboardWriterForItemAtIndexPath:indexPath];
        }
        if (!writer) {
            NSPasteboardItem *pasteboardItem = [[NSPasteboardItem alloc] init];
            [pasteboardItem setPropertyList:plist forType:UXCollectionViewRearrangingPasteboardType];
            writer = pasteboardItem;
        }
        NSDraggingItem *item = [[NSDraggingItem alloc] initWithPasteboardWriter:writer];
        [item setDraggingFrame:CGRectMake(frame.origin.x, frame.origin.y, width, height) contents:image];
        if (_collectionViewFlags.delegateImplementsDraggingItemForIndexPathProposedDraggingItem) {
            NSDraggingItem *override = [self.delegate collectionView:collectionView draggingItemForIndexPath:indexPath proposedDraggingItem:item];
            if (override) {
                item = override;
            }
        }
        if (item) {
            [draggingItems addObject:item];
        }
    }
    [collectionView registerForDraggedTypes:@[UXCollectionViewRearrangingPasteboardType]];
    NSDraggingSession *session = [collectionView.documentView beginDraggingSessionWithItems:draggingItems
                                                                                      event:event
                                                                                     source:(id<NSDraggingSource>)collectionView];
    [self _createdDraggingSession:session forItemsAtIndexPaths:indexPaths];
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
    // 0x1dbbcc724 — rebuild the dragged index paths from the dragging-item plist
    // and seed the rearranging state.
    _autoscrolling = NO;
    _screenPoint = screenPoint;
    UXCollectionView *collectionView = _collectionView;
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
    [session enumerateDraggingItemsWithOptions:0
                                       forView:collectionView.documentView
                                       classes:@[[NSPasteboardItem class]]
                                 searchOptions:@{}
                                    usingBlock:^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop) {
        id propertyList = [draggingItem.item propertyListForType:UXCollectionViewRearrangingPasteboardType];
        if ([propertyList isKindOfClass:[NSArray class]]) {
            propertyList = [(NSArray *)propertyList firstObject];
        }
        if ([propertyList isKindOfClass:[NSDictionary class]]) {
            NSUInteger item = [[(NSDictionary *)propertyList objectForKey:@"item"] unsignedIntegerValue];
            if (item != NSNotFound) {
                NSUInteger section = [[(NSDictionary *)propertyList objectForKey:@"section"] unsignedIntegerValue];
                [indexPaths addObject:[NSIndexPath indexPathForItem:(NSInteger)item inSection:(NSInteger)section]];
            }
        }
    }];
    if (_collectionViewFlags.delegateImplementsDraggingSessionWillBeginAtPoint) {
        [self.delegate collectionView:collectionView draggingSession:session willBeginAtPoint:screenPoint];
    }
    [self _beginRearrangingItemsWithIndexPaths:indexPaths];
}

- (void)draggingSession:(NSDraggingSession *)session movedToPoint:(NSPoint)screenPoint {
    // 0x1dbbcc5b0
    _screenPoint = screenPoint;
    UXCollectionView *collectionView = _collectionView;
    if (_collectionViewFlags.delegateImplementsDraggingSessionMovedToPoint) {
        [self.delegate collectionView:collectionView draggingSession:session movedToPoint:screenPoint];
    }
    if ([self _allowRearranging] && !_autoscrolling) {
        NSPoint locationInWindow = [collectionView.window convertRectFromScreen:NSMakeRect(screenPoint.x, screenPoint.y, 0.0, 0.0)].origin;
        NSPoint locationInDocument = [collectionView.documentView convertPoint:locationInWindow fromView:nil];
        NSValue *value = [NSValue valueWithPoint:locationInDocument];
        if (_rearrangingPreviewDelay <= 0.0) {
            [self _updateRearrangingStateForLocation:value];
        } else {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(_updateRearrangingStateForLocation:) withObject:value afterDelay:_rearrangingPreviewDelay];
        }
    }
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    // 0x1dbbcc3d8 — finish, then synthesize the mouseUp that ends the pan
    // gesture recognizer's synchronous event-tracking loop.
    _autoscrolling = NO;
    _screenPoint = screenPoint;
    UXCollectionView *collectionView = _collectionView;
    NSPoint locationInWindow = [collectionView.window convertRectFromScreen:NSMakeRect(screenPoint.x, screenPoint.y, 0.0, 0.0)].origin;
    NSPoint locationInDocument = [collectionView.documentView convertPoint:locationInWindow fromView:nil];
    NSPoint locationInView = [collectionView convertPoint:locationInDocument fromView:collectionView.documentView];
    BOOL shouldComplete = (operation != 0) && NSPointInRect(locationInView, collectionView.bounds);
    [self _finishRearrangingForLocation:locationInDocument shouldComplete:shouldComplete];
    if (_collectionViewFlags.delegateImplementsDraggingSessionEndedAtPointDragOperation) {
        [self.delegate collectionView:collectionView draggingSession:session endedAtPoint:screenPoint dragOperation:operation];
    }
    [collectionView mouseUp:[NSEvent mouseEventWithType:NSEventTypeLeftMouseUp
                                               location:locationInWindow
                                          modifierFlags:0
                                              timestamp:[[NSProcessInfo processInfo] systemUptime]
                                           windowNumber:0
                                                context:nil
                                            eventNumber:0
                                             clickCount:1
                                               pressure:1.0]];
    [session.draggingPasteboard ux_setSourceIdentifier:nil];
    _mouseDownEvent = nil;
}

#pragma mark - NSDraggingDestination

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    // 0x1dbbcc060
    [self _updateDragSourceIdentifier];
    UXCollectionView *collectionView = _collectionView;
    // UXKit asks the delegate for an entered-formation (a method not in the
    // OpenUXKit informal protocol); otherwise it passes the raw value 2, which is
    // NSDraggingFormationPile in AppKit's enum (0x1dbbcc060).
    [sender setDraggingFormation:NSDraggingFormationPile];
    __block NSInteger validItemCount = 0;
    [sender enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationConcurrent
                                      forView:collectionView.documentView
                                      classes:@[[NSPasteboardItem class]]
                                searchOptions:@{}
                                   usingBlock:^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop) {
        validItemCount++;
    }];
    if (validItemCount > 0) {
        [sender setNumberOfValidItemsForDrop:validItemCount];
    }
    _dragEnteredTime = CFAbsoluteTimeGetCurrent();
    if ([self _shouldHandleExternalDrop:sender] && _collectionViewFlags.delegateImplementsDraggingEntered) {
        return [self.delegate collectionView:collectionView draggingEntered:sender];
    }
    return NSDragOperationMove;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
    // 0x1dbbcbf78
    BOOL external = [self _shouldHandleExternalDrop:sender];
    if ([self _allowAutoscrollForDraggingInfo:sender]) {
        if (!(external && CFAbsoluteTimeGetCurrent() <= _dragEnteredTime + 0.33)) {
            [self _autoscrollWithWindowLocation:sender.draggingLocation];
        }
    }
    if (external && _collectionViewFlags.delegateImplementsDraggingUpdated) {
        return [self.delegate collectionView:_collectionView draggingUpdated:sender];
    }
    if (!_isRearranging) {
        return NSDragOperationMove;
    }
    return (self.dropOperation == NSDragOperationCopy) ? NSDragOperationCopy : NSDragOperationMove;
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
    // 0x1dbbcbdf4
    if ([self _shouldHandleExternalDrop:sender] && _collectionViewFlags.delegateImplementsPerformDragOperation) {
        return [self.delegate collectionView:_collectionView performDragOperation:sender];
    }
    return YES;
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
    if (_collectionViewFlags.delegateImplementsCreatedDraggingSessionForItemsAtIndexPaths) {
        [self.delegate collectionView:_collectionView createdDraggingSession:session forItemsAtIndexPaths:indexPaths];
    }
}

- (void)_finishRearrangingForLocation:(CGPoint)location shouldComplete:(BOOL)shouldComplete {
    // 0x1dbbcd678. Structure kept faithful to the binary, including the branches
    // that are unreachable under the current data-source contract (see
    // IDA-Notes/P10b-Rearranging-NSDragging.md §3.2).
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.dropTargetCell = nil;
    if (!_isRearranging) {
        return;
    }
    UXCollectionView *collectionView = _collectionView;
    if (!(shouldComplete || !_updatesLayoutOnDrag)) {
        // !shouldComplete && updatesLayoutOnDrag: cancel but keep the live layout.
        _isRearranging = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_reloadCollectionViewWithAnimation) object:nil];
        [collectionView performBatchUpdates:^{} completion:nil];
        return;
    }

    NSInteger dropPosition = 0;
    BOOL reachedCommit = NO;
    // (A) UXKit bails to the cancel path whenever _shouldExchange is set, which
    // makes the exchange-commit branch below unreachable.
    if (!_shouldExchange) {
        dropPosition = [self.collectionViewLayout dropPositionForPoint:location withIndexPaths:_initialIndexPaths movedToIndexPath:[_targetIndexPaths firstObject]];
        if (dropPosition != 0 && ![_initialIndexPaths isEqualToArray:_targetIndexPaths]) {
            if (_shouldExchange) {
                // DEAD (A guarantees _shouldExchange == NO here): faithful to the binary.
                if (_collectionViewFlags.dataSourceImplementsExchangeItemsAtIndexPathsWithIndexPaths) {
                    [self.dataSource collectionView:collectionView exchangeItemsAtIndexPaths:_initialIndexPaths withIndexPaths:_targetIndexPaths];
                }
                reachedCommit = YES;
            } else if (_collectionViewFlags.dataSourceImplementsMoveItemsAtIndexPathsToIndexPath) {
                [self.dataSource collectionView:collectionView moveItemsAtIndexPaths:_initialIndexPaths toIndexPath:[_targetIndexPaths firstObject] dropPosition:dropPosition];
                reachedCommit = YES;
            }
        }
    }

    _isRearranging = NO;
    if (reachedCommit) {
        if (_shouldExchange) {
            // DEAD: faithful to the binary.
            NSMutableArray<NSIndexPath *> *reloadPaths = [NSMutableArray arrayWithArray:_initialIndexPaths];
            [reloadPaths addObjectsFromArray:_targetIndexPaths];
            [collectionView reloadItemsAtIndexPaths:reloadPaths];
        } else if (dropPosition == 8 || dropPosition == 2) {
            // DEAD under the current contract (dropPosition is masked to {0,4} by
            // -dropPositionForPoint:withIndexPaths:movedToIndexPath:), transcribed
            // faithfully: shift the destination by the source items removed before
            // it, then animate the move.
            NSIndexPath *target = [_targetIndexPaths firstObject];
            NSInteger base = target.item + (dropPosition == 8 ? 1 : 0);
            NSInteger adjusted = base;
            for (NSIndexPath *initialIndexPath in _initialIndexPaths) {
                if (initialIndexPath.section == target.section && initialIndexPath.item < base) {
                    adjusted -= 1;
                }
            }
            [self _moveItemsAtIndexPaths:_initialIndexPaths toIndexPaths:UXIndexPathsFromRange((NSUInteger)adjusted, _initialIndexPaths.count, target.section)];
        } else {
            [self.collectionViewLayout invalidateLayout];
        }
    } else {
        [self.collectionViewLayout invalidateLayout];
    }

    _initialIndexPaths = nil;
    _targetIndexPaths = nil;
    _movedIndexPaths = nil;
    [_gestureRecognizer setState:NSGestureRecognizerStateCancelled];
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
