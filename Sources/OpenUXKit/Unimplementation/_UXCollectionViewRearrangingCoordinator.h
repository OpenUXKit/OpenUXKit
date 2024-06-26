

#import <AppKit/AppKit.h>
#import <OpenUXKit/UXCollectionViewLayoutProxyDelegate-Protocol.h>

@class NSArray, NSEvent, NSGestureRecognizer, NSString, UXCollectionView, UXCollectionViewCell, UXCollectionViewLayout, _UXCollectionViewLayoutProxy;
@protocol UXCollectionViewDataSource_Rearranging, UXCollectionViewDelegate_Rearranging;

@interface _UXCollectionViewRearrangingCoordinator : NSObject <UXCollectionViewLayoutProxyDelegate, NSGestureRecognizerDelegate, NSDraggingSource, NSDraggingDestination>
{
    struct {
        unsigned int dataSourceImplementsCanMoveItemsAtIndexPaths:1;
        unsigned int dataSourceImplementsShouldExchangeItemsAtIndexPathsWithProposedIndexPaths:1;
        unsigned int dataSourceImplementsMoveItemsAtIndexPathsToIndexPath:1;
        unsigned int dataSourceImplementsExchangeItemsAtIndexPathsWithIndexPaths:1;
        unsigned int delegateImplementsShouldBeginDraggingSessionWithClickedItemAtIndexPath:1;
        unsigned int delegateImplementsImageForDraggedItemAtIndexPath:1;
        unsigned int delegateImplementsPasteboardWriterForItemAtIndexPath:1;
        unsigned int delegateImplementsDraggingItemForIndexPathProposedDraggingItem:1;
        unsigned int delegateImplementsUpdatesLayoutOnDrag:1;
        unsigned int delegateImplementsPreferredDraggingFormation:1;
        unsigned int delegateImplementsDragSourceIdentifier:1;
        unsigned int delegateImplementsCreatedDraggingSessionForItemsAtIndexPaths:1;
        unsigned int delegateImplementsDraggingSessionSourceOperationMaskForDraggingContext;
        unsigned int delegateImplementsDraggingSessionWillBeginAtPoint:1;
        unsigned int delegateImplementsDraggingSessionMovedToPoint:1;
        unsigned int delegateImplementsDraggingSessionEndedAtPointDragOperation:1;
        unsigned int delegateImplementsPrepareForDragOperation:1;
        unsigned int delegateImplementsPerformDragOperation:1;
        unsigned int delegateImplementsDraggingEntered:1;
        unsigned int delegateImplementsDraggingUpdated:1;
        unsigned int delegateImplementsDraggingExited:1;
        unsigned int delegateImplementsDraggingEnded:1;
    } _collectionViewFlags;	// 8 = 0x8
    NSArray *_initialIndexPaths;	// 24 = 0x18
    NSArray *_targetIndexPaths;	// 32 = 0x20
    NSArray *_movedIndexPaths;	// 40 = 0x28
    NSArray *_exchangedIndexPaths;	// 48 = 0x30
    CGPoint _screenPoint;	// 56 = 0x38
    BOOL _initialIndexPathsAreContiguous;	// 72 = 0x48
    NSGestureRecognizer *_gestureRecognizer;	// 80 = 0x50
    CGFloat _dragStartTime;	// 88 = 0x58
    CGFloat _collectionViewReloadLastCallTime;	// 96 = 0x60
    CGFloat _dragEnteredTime;	// 104 = 0x68
    BOOL _updatesLayoutOnDrag;	// 112 = 0x70
    BOOL _autoscrolling;	// 113 = 0x71
    NSUInteger _sequenceNumber;	// 120 = 0x78
    NSEvent *_mouseDownEvent;	// 128 = 0x80
    BOOL _isRearranging;	// 136 = 0x88
    BOOL _enabled;	// 137 = 0x89
    BOOL _allowDragOutsideCells;	// 138 = 0x8a
    BOOL _continuouslyUpdateInsideCells;	// 139 = 0x8b
    BOOL _usePileForSingleItem;	// 140 = 0x8c
    BOOL _allowAutoscroll;	// 141 = 0x8d
    BOOL _shouldExchange;	// 142 = 0x8e
    UXCollectionView *_collectionView;	// 144 = 0x90
    NSInteger _initiationMode;	// 152 = 0x98
    CGFloat _rearrangingInitialDelay;	// 160 = 0xa0
    CGFloat _rearrangingPreviewDelay;	// 168 = 0xa8
    UXCollectionViewCell *_dropTargetCell;	// 176 = 0xb0
    NSUInteger _dropOperation;	// 184 = 0xb8
    NSString *_dragSourceIdentifier;	// 192 = 0xc0
    struct _NSRange _initialIndexRange;	// 200 = 0xc8
    struct _NSRange _targetIndexRange;	// 216 = 0xd8
    struct _NSRange _movedIndexRange;	// 232 = 0xe8
    struct _NSRange _exchangedIndexRange;	// 248 = 0xf8
}

@property(readonly, nonatomic) NSString *dragSourceIdentifier; // @synthesize dragSourceIdentifier=_dragSourceIdentifier;
@property(nonatomic) NSUInteger dropOperation; // @synthesize dropOperation=_dropOperation;
@property(strong, nonatomic) UXCollectionViewCell *dropTargetCell; // @synthesize dropTargetCell=_dropTargetCell;
@property(nonatomic) BOOL shouldExchange; // @synthesize shouldExchange=_shouldExchange;
@property(nonatomic) struct _NSRange exchangedIndexRange; // @synthesize exchangedIndexRange=_exchangedIndexRange;
@property(nonatomic) struct _NSRange movedIndexRange; // @synthesize movedIndexRange=_movedIndexRange;
@property(nonatomic) struct _NSRange targetIndexRange; // @synthesize targetIndexRange=_targetIndexRange;
@property(nonatomic) struct _NSRange initialIndexRange; // @synthesize initialIndexRange=_initialIndexRange;
@property(nonatomic) CGFloat rearrangingPreviewDelay; // @synthesize rearrangingPreviewDelay=_rearrangingPreviewDelay;
@property(nonatomic) CGFloat rearrangingInitialDelay; // @synthesize rearrangingInitialDelay=_rearrangingInitialDelay;
@property(nonatomic) BOOL allowAutoscroll; // @synthesize allowAutoscroll=_allowAutoscroll;
@property(nonatomic) BOOL usePileForSingleItem; // @synthesize usePileForSingleItem=_usePileForSingleItem;
@property(nonatomic) BOOL continuouslyUpdateInsideCells; // @synthesize continuouslyUpdateInsideCells=_continuouslyUpdateInsideCells;
@property(nonatomic) BOOL allowDragOutsideCells; // @synthesize allowDragOutsideCells=_allowDragOutsideCells;
@property(nonatomic) NSInteger initiationMode; // @synthesize initiationMode=_initiationMode;
@property(nonatomic) BOOL enabled; // @synthesize enabled=_enabled;
@property(readonly, nonatomic) BOOL isRearranging; // @synthesize isRearranging=_isRearranging;
@property(readonly, nonatomic) UXCollectionView *collectionView; // @synthesize collectionView=_collectionView;
- (void)updateDraggingItemsForDrag:(id)arg1;
- (BOOL)wantsPeriodicDraggingUpdates;
- (void)draggingEnded:(id)arg1;
- (void)concludeDragOperation:(id)arg1;
- (BOOL)performDragOperation:(id)arg1;
- (BOOL)prepareForDragOperation:(id)arg1;
- (void)draggingExited:(id)arg1;
- (NSUInteger)draggingUpdated:(id)arg1;
- (NSUInteger)draggingEntered:(id)arg1;
- (BOOL)_isEquivalentSourceOfDraggingInfo:(id)arg1;
- (BOOL)_isSourceOfDraggingInfo:(id)arg1;
- (BOOL)_allowAutoscrollForDraggingInfo:(id)arg1;
- (BOOL)_shouldHandleExternalDrop:(id)arg1;
- (void)draggingSession:(id)arg1 endedAtPoint:(CGPoint)arg2 operation:(NSUInteger)arg3;
- (void)draggingSession:(id)arg1 movedToPoint:(CGPoint)arg2;
- (void)draggingSession:(id)arg1 willBeginAtPoint:(CGPoint)arg2;
- (void)_createdDraggingSession:(id)arg1 forItemsAtIndexPaths:(id)arg2;
- (NSUInteger)draggingSession:(id)arg1 sourceOperationMaskForDraggingContext:(NSInteger)arg2;
- (void)_autoscrollWithWindowLocation:(CGPoint)arg1;
- (void)_moveItemsAtIndexPaths:(id)arg1 toIndexPaths:(id)arg2;
- (void)_beginDraggingSessionForIndexPaths:(id)arg1;
- (id)_imageForItemAtIndexPath:(id)arg1;
- (id)layoutAttributesForElementsInRect:(CGRect)arg1;
- (void)_finishRearrangingForLocation:(CGPoint)arg1 shouldComplete:(BOOL)arg2;
- (void)_reloadCollectionViewWithAnimation;
- (void)_updateRearrangingStateForLocation:(id)arg1;
- (void)_beginRearrangingItemsWithIndexPaths:(id)arg1;
- (BOOL)_allowRearranging;
- (void)_gestureRecognized:(id)arg1;
- (BOOL)gestureRecognizerShouldBegin:(id)arg1;
- (void)_updateDragSourceIdentifier;
- (void)createGestureRecognizer;
- (void)removeGestureRecognizer;
@property(readonly, nonatomic) id <UXCollectionViewDelegate_Rearranging> delegate;
@property(readonly, nonatomic) id <UXCollectionViewDataSource_Rearranging> dataSource;
@property(readonly, nonatomic) _UXCollectionViewLayoutProxy *layoutProxy;
@property(readonly, nonatomic) UXCollectionViewLayout *collectionViewLayout;
- (void)reloadLayout;
- (void)dealloc;
- (id)initWithCollectionView:(id)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) NSUInteger hash;
@property(readonly) Class superclass;

@end

