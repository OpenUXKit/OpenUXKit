#import "UXCollectionView+Private.h"

@implementation UXCollectionView (Rearranging)

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

@end
