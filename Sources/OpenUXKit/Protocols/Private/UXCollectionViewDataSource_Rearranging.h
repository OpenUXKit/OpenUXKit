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
- (BOOL)collectionView:(UXCollectionView *)collectionView moveItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths toIndexPath:(NSIndexPath *)toIndexPath;
- (BOOL)collectionView:(UXCollectionView *)collectionView exchangeItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withIndexPaths:(NSArray<NSIndexPath *> *)withIndexPaths;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
