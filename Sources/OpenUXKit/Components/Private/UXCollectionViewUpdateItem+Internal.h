#import "UXCollectionViewUpdateItem.h"

@class UXCollectionViewUpdateGap;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXCollectionViewUpdateItem ()

- (BOOL)_isSectionOperation;
- (NSComparisonResult)inverseCompareIndexPaths:(UXCollectionViewUpdateItem *)other;
- (NSComparisonResult)compareIndexPaths:(UXCollectionViewUpdateItem *)other;
- (UXCollectionUpdateAction)_action;
- (nullable NSIndexPath *)_indexPath;
- (nullable NSIndexPath *)_newIndexPath;
- (void)_setNewIndexPath:(nullable NSIndexPath *)newIndexPath;
- (nullable UXCollectionViewUpdateGap *)_gap;
- (void)_setGap:(nullable UXCollectionViewUpdateGap *)gap;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
