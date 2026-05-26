#import <OpenUXKit/UXCollectionViewLayoutInvalidationContext.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXCollectionViewLayoutInvalidationContext ()

- (nullable NSArray *)_updateItems;
- (void)_setUpdateItems:(nullable NSArray *)updateItems;
- (void)_setInvalidateEverything:(BOOL)invalidateEverything;
- (void)_setInvalidateDataSourceCounts:(BOOL)invalidateDataSourceCounts;
- (nullable NSDictionary *)_invalidatedSupplementaryViews;
- (void)_setInvalidatedSupplementaryViews:(nullable NSDictionary *)invalidatedSupplementaryViews;
- (void)_invalidateSupplementaryElementsOfKind:(nullable NSString *)elementKind atIndexPaths:(nullable NSArray<NSIndexPath *> *)indexPaths;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
