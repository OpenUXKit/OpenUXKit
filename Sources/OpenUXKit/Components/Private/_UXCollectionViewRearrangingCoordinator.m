#import <OpenUXKit/_UXCollectionViewRearrangingCoordinator.h>
#import <OpenUXKit/UXCollectionView.h>
#import <OpenUXKit/UXCollectionViewCell.h>

@interface _UXCollectionViewRearrangingCoordinator () {
    __weak UXCollectionView *_collectionView;
    BOOL _enabled;
    BOOL _isRearranging;
    NSInteger _initiationMode;
    BOOL _allowDragOutsideCells;
    BOOL _continuouslyUpdateInsideCells;
    BOOL _usePileForSingleItem;
    BOOL _allowAutoscroll;
    BOOL _shouldExchange;
    CGFloat _rearrangingInitialDelay;
    CGFloat _rearrangingPreviewDelay;
    NSRange _initialIndexRange;
    NSRange _targetIndexRange;
    NSRange _movedIndexRange;
    NSRange _exchangedIndexRange;
    UXCollectionViewCell *_dropTargetCell;
    NSUInteger _dropOperation;
    NSString *_dragSourceIdentifier;
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

- (instancetype)initWithCollectionView:(UXCollectionView *)collectionView {
    self = [super init];
    if (self) {
        _collectionView = collectionView;
    }
    return self;
}

- (UXCollectionView *)collectionView {
    return _collectionView;
}

- (BOOL)isRearranging {
    return _isRearranging;
}

- (void)updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo {
}

- (BOOL)wantsPeriodicDraggingUpdates {
    return YES;
}

#pragma mark - NSDraggingSource

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    return NSDragOperationGeneric;
}

#pragma mark - NSDraggingDestination

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
    return NSDragOperationNone;
}

- (void)draggingExited:(nullable id<NSDraggingInfo>)sender {
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    return NO;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    return NO;
}

- (void)concludeDragOperation:(nullable id<NSDraggingInfo>)sender {
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender {
}

@end
