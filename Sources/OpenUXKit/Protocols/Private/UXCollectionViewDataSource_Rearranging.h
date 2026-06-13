#import <AppKit/AppKit.h>
#import "UXKitDefines.h"
#import "UXCollectionViewDataSource.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionView;

NS_SWIFT_UI_ACTOR
@protocol UXCollectionViewDataSource_Rearranging <UXCollectionViewDataSource>

@optional
- (BOOL)collectionView:(UXCollectionView *)collectionView canMoveItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (BOOL)collectionView:(UXCollectionView *)collectionView shouldExchangeItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withProposedIndexPaths:(NSArray<NSIndexPath *> *)proposedIndexPaths;
// The drop position is UXKit's internal position mask (2 = before, 4 = on,
// 8 = after); the rearranging coordinator passes the value resolved through
// -[UXCollectionView allowedDropPositionsForItemsAtIndexPaths:movedToIndexPath:].
- (BOOL)collectionView:(UXCollectionView *)collectionView moveItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths toIndexPath:(NSIndexPath *)toIndexPath dropPosition:(NSInteger)dropPosition;
- (BOOL)collectionView:(UXCollectionView *)collectionView exchangeItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withIndexPaths:(NSArray<NSIndexPath *> *)withIndexPaths;
// Drop-target queries the coordinator forwards through UXCollectionView; the
// returned position mask gates whether a move commits (see the coordinator's
// _finishRearrangingForLocation:shouldComplete:).
- (NSInteger)collectionView:(UXCollectionView *)collectionView allowedDropPositionsForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths movedToIndexPath:(NSIndexPath *)indexPath;
- (NSDragOperation)collectionView:(UXCollectionView *)collectionView dragOperationForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths movedOntoItemAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
