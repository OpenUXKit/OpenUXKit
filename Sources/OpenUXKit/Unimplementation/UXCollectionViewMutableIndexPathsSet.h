

@interface UXCollectionViewMutableIndexPathsSet
{
}

- (void)adjustForDeletionOfIndexPath:(id)arg1;
- (void)adjustForDeletionOfItems:(id)arg1 inSection:(NSUInteger)arg2;
- (void)adjustForInsertionOfIndexPath:(id)arg1;
- (void)adjustForInsertionOfItems:(id)arg1 inSection:(NSUInteger)arg2;
- (void)adjustForDeletionOfSections:(id)arg1;
- (void)adjustForDeletionOfSection:(NSUInteger)arg1;
- (void)_adjustForDeletionOfSection:(NSUInteger)arg1;
- (void)adjustForInsertionOfSections:(id)arg1;
- (void)adjustForInsertionOfSection:(NSUInteger)arg1;
- (void)_adjustForInsertionOfSection:(NSUInteger)arg1;
- (void)intersectIndexPathsSet:(id)arg1;
- (void)removeAllIndexPaths;
- (void)removeIndexPathsSet:(id)arg1;
- (void)removeIndexPaths:(id)arg1;
- (void)removeIndexPath:(id)arg1;
- (void)removeSections:(id)arg1;
- (void)removeSection:(NSInteger)arg1;
- (void)removeSection:(NSInteger)arg1 itemsInRange:(struct _NSRange)arg2;
- (void)addSection:(NSInteger)arg1 itemsInRange:(struct _NSRange)arg2;
- (void)addIndexPathsSet:(id)arg1;
- (void)addIndexPaths:(id)arg1;
- (void)addIndexPath:(id)arg1;
- (id)copyWithZone:(struct _NSZone *)arg1;

@end

