#import <OpenUXKit/UXCollectionViewIndexPathsSet.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewMutableIndexPathsSet : UXCollectionViewIndexPathsSet

- (void)addIndexPath:(nullable NSIndexPath *)indexPath;
- (void)addIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)addIndexPathsSet:(nullable UXCollectionViewIndexPathsSet *)indexPathsSet;
- (void)addSection:(NSInteger)section itemsInRange:(NSRange)range;

- (void)removeIndexPath:(nullable NSIndexPath *)indexPath;
- (void)removeIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)removeIndexPathsSet:(UXCollectionViewIndexPathsSet *)indexPathsSet;
- (void)removeAllIndexPaths;
- (void)removeSection:(NSInteger)section;
- (void)removeSection:(NSInteger)section itemsInRange:(NSRange)range;
- (void)removeSections:(NSIndexSet *)sections;

- (void)intersectIndexPathsSet:(UXCollectionViewIndexPathsSet *)indexPathsSet;

- (void)adjustForDeletionOfIndexPath:(nullable NSIndexPath *)indexPath;
- (void)adjustForDeletionOfItems:(NSIndexSet *)items inSection:(NSUInteger)section;
- (void)adjustForDeletionOfSection:(NSUInteger)section;
- (void)adjustForDeletionOfSections:(NSIndexSet *)sections;
- (void)adjustForInsertionOfIndexPath:(nullable NSIndexPath *)indexPath;
- (void)adjustForInsertionOfItems:(NSIndexSet *)items inSection:(NSUInteger)section;
- (void)adjustForInsertionOfSection:(NSUInteger)section;
- (void)adjustForInsertionOfSections:(NSIndexSet *)sections;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
