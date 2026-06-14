#import "UXCollectionView+Private.h"
#import "UXCollectionViewDataSource_Rearranging.h"

@implementation UXCollectionView (Rearranging)

#pragma mark - Drag & drop hooks

- (NSInteger)allowedDropPositionsForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths movedToIndexPath:(NSIndexPath *)indexPath {
    // UXKit forwards the drop-position query to the rearranging data source.
    id<UXCollectionViewDataSource_Rearranging> dataSource = (id<UXCollectionViewDataSource_Rearranging>)self.dataSource;
    if ([dataSource respondsToSelector:@selector(collectionView:allowedDropPositionsForItemsAtIndexPaths:movedToIndexPath:)]) {
        return [dataSource collectionView:self allowedDropPositionsForItemsAtIndexPaths:indexPaths movedToIndexPath:indexPath];
    }
    return 0;
}

- (NSUInteger)dragOperationForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths movedOntoItemAtIndexPath:(NSIndexPath *)indexPath {
    id<UXCollectionViewDataSource_Rearranging> dataSource = (id<UXCollectionViewDataSource_Rearranging>)self.dataSource;
    if ([dataSource respondsToSelector:@selector(collectionView:dragOperationForItemsAtIndexPaths:movedOntoItemAtIndexPath:)]) {
        return [dataSource collectionView:self dragOperationForItemsAtIndexPaths:indexPaths movedOntoItemAtIndexPath:indexPath];
    }
    return NSDragOperationNone;
}

// The collection view is itself the NSDraggingSource / NSDraggingDestination
// (the session is started with `source:self` and the view is registered for the
// dragged type); UXKit forwards every callback to the rearranging coordinator
// (see -[UXCollectionView(Rearranging) draggingEntered:] etc. at 0x1dbbe51f8).

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    return [[self _rearrangingCoordinator] draggingSession:session sourceOperationMaskForDraggingContext:context];
}

- (void)draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)point {
    [[self _rearrangingCoordinator] draggingSession:session willBeginAtPoint:point];
}

- (void)draggingSession:(NSDraggingSession *)session movedToPoint:(NSPoint)point {
    [[self _rearrangingCoordinator] draggingSession:session movedToPoint:point];
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)point operation:(NSDragOperation)operation {
    [[self _rearrangingCoordinator] draggingSession:session endedAtPoint:point operation:operation];
}

- (BOOL)wantsPeriodicDraggingUpdates {
    return [[self _rearrangingCoordinator] wantsPeriodicDraggingUpdates];
}

- (void)updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo {
    [[self _rearrangingCoordinator] updateDraggingItemsForDrag:draggingInfo];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    return [[self _rearrangingCoordinator] draggingEntered:sender];
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
    return [[self _rearrangingCoordinator] draggingUpdated:sender];
}

- (void)draggingExited:(nullable id<NSDraggingInfo>)sender {
    [[self _rearrangingCoordinator] draggingExited:sender];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    return [[self _rearrangingCoordinator] prepareForDragOperation:sender];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    return [[self _rearrangingCoordinator] performDragOperation:sender];
}

- (void)concludeDragOperation:(nullable id<NSDraggingInfo>)sender {
    [[self _rearrangingCoordinator] concludeDragOperation:sender];
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender {
    [[self _rearrangingCoordinator] draggingEnded:sender];
}

#pragma mark - Rearranging

- (BOOL)isRearranging_ {
    return [_rearrangingCoordinator isRearranging];
}

- (BOOL)rearrangingEnabled_ {
    return _rearrangingEnabled;
}

- (void)setRearrangingEnabled_:(BOOL)rearrangingEnabled {
    // UXKit routes this through the lazily-created coordinator's -setEnabled:,
    // which installs/removes the gesture recognizer. The earlier OpenUXKit path
    // created a coordinator with a nil collection view and never enabled it, so
    // no gesture was ever installed.
    _rearrangingEnabled = rearrangingEnabled;
    [[self _rearrangingCoordinator] setEnabled:rearrangingEnabled];
}

- (BOOL)rearrangingAllowAutoscroll_ {
    return [[self _rearrangingCoordinator] allowAutoscroll];
}

- (void)setRearrangingAllowAutoscroll_:(BOOL)allowAutoscroll {
    // 0x1dbbe5530 — forwards to the coordinator; the value lives there, not on the
    // collection view (the earlier port stored a dead collection-view ivar, so the
    // setting never reached the coordinator).
    [[self _rearrangingCoordinator] setAllowAutoscroll:allowAutoscroll];
}

- (BOOL)rearrangingExternalDropEnabled_ {
    return _rearrangingExternalDropEnabled;
}

- (void)setRearrangingExternalDropEnabled_:(BOOL)externalDropEnabled {
    _rearrangingExternalDropEnabled = externalDropEnabled;
}

- (NSInteger)rearrangingInitiationMode_ {
    return [[self _rearrangingCoordinator] initiationMode];
}

- (void)setRearrangingInitiationMode_:(NSInteger)mode {
    // 0x1dbbe53d0 — forwards to the coordinator's -setInitiationMode:, which
    // reinstalls the gesture recognizer (press-and-hold for 0, pan for non-zero).
    [[self _rearrangingCoordinator] setInitiationMode:mode];
}

- (BOOL)rearrangingContinuouslyUpdateInsideCells_ {
    return [[self _rearrangingCoordinator] continuouslyUpdateInsideCells];
}

- (void)setRearrangingContinuouslyUpdateInsideCells_:(BOOL)continuouslyUpdate {
    // 0x1dbbe5388 — forwards to the coordinator.
    [[self _rearrangingCoordinator] setContinuouslyUpdateInsideCells:continuouslyUpdate];
}

- (CGFloat)rearrangingPreviewDelay_ {
    return [[self _rearrangingCoordinator] rearrangingPreviewDelay];
}

- (void)setRearrangingPreviewDelay_:(CGFloat)delay {
    // 0x1dbbe5340 — forwards to the coordinator.
    [[self _rearrangingCoordinator] setRearrangingPreviewDelay:delay];
}

- (_UXCollectionViewRearrangingCoordinator *)_rearrangingCoordinator {
    // Lazily create the coordinator bound to this collection view (matching
    // UXKit's -_rearrangingCoordinator), so it always has a live collection view.
    if (!_rearrangingCoordinator) {
        _rearrangingCoordinator = [[_UXCollectionViewRearrangingCoordinator alloc] initWithCollectionView:self];
    }
    return _rearrangingCoordinator;
}

- (void)rearrangingCoordinatorReloadLayout_ {
    [self updateLayout];
}

@end
