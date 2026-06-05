#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXCollectionViewLayoutProxyDelegate.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionView, UXCollectionViewCell, UXCollectionViewLayout, _UXCollectionViewLayoutProxy;

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXCollectionViewRearrangingCoordinator : NSObject <UXCollectionViewLayoutProxyDelegate, NSGestureRecognizerDelegate, NSDraggingSource, NSDraggingDestination>

@property (nonatomic, weak, readonly, nullable) UXCollectionView *collectionView;
@property (nonatomic, readonly, nullable) UXCollectionViewLayout *collectionViewLayout;
@property (nonatomic, readonly, nullable) _UXCollectionViewLayoutProxy *layoutProxy;

@property (nonatomic) BOOL enabled;
@property (nonatomic, readonly) BOOL isRearranging;
@property (nonatomic) NSInteger initiationMode;
@property (nonatomic) BOOL allowDragOutsideCells;
@property (nonatomic) BOOL continuouslyUpdateInsideCells;
@property (nonatomic) BOOL usePileForSingleItem;
@property (nonatomic) BOOL allowAutoscroll;
@property (nonatomic) CGFloat rearrangingInitialDelay;
@property (nonatomic) CGFloat rearrangingPreviewDelay;

@property (nonatomic) NSRange initialIndexRange;
@property (nonatomic) NSRange targetIndexRange;
@property (nonatomic) NSRange movedIndexRange;
@property (nonatomic) NSRange exchangedIndexRange;
@property (nonatomic) BOOL shouldExchange;
@property (nonatomic, strong, nullable) UXCollectionViewCell *dropTargetCell;
@property (nonatomic) NSUInteger dropOperation;
@property (nonatomic, copy, readonly, nullable) NSString *dragSourceIdentifier;

- (instancetype)init;
- (instancetype)initWithCollectionView:(nullable UXCollectionView *)collectionView NS_DESIGNATED_INITIALIZER;

- (void)updateDraggingItemsForDrag:(nullable id<NSDraggingInfo>)draggingInfo;
- (BOOL)wantsPeriodicDraggingUpdates;

- (void)_createdDraggingSession:(NSDraggingSession *)session forItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)_finishRearrangingForLocation:(CGPoint)location shouldComplete:(BOOL)shouldComplete;
- (void)_moveItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths toIndexPaths:(NSArray<NSIndexPath *> *)toIndexPaths;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
