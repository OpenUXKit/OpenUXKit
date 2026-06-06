#import "UXCollectionViewIndexPathsSet.h"

@class _UXCollectionViewSectionItemIndexes;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXCollectionViewIndexPathsSet () {
    @protected
    NSMutableIndexSet *_sectionIndexes;
    NSMutableDictionary<NSNumber *, _UXCollectionViewSectionItemIndexes *> *_sectionToItemIndexesMap;
}

- (void)_addOneIndexPath:(NSIndexPath *)indexPath;
- (void)_removeOneIndexPath:(NSIndexPath *)indexPath;
- (void)_addIndexPathsSet:(UXCollectionViewIndexPathsSet *)indexPathsSet;
- (void)_enumerateSectionItemIndexesWithBlock:(void (NS_NOESCAPE ^)(NSUInteger section, _UXCollectionViewSectionItemIndexes *itemIndexes, BOOL *stop))block;
- (nullable _UXCollectionViewSectionItemIndexes *)_itemIndexesForSection:(NSUInteger)section allowingCreation:(BOOL)allowingCreation;
- (void)_removeItemIndexesForSection:(NSUInteger)section;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
