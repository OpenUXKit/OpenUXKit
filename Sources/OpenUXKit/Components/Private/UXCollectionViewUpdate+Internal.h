#import "UXCollectionViewUpdate.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXCollectionViewUpdate ()

@property (nonatomic, readonly, nullable) UXCollectionViewData *_oldModel;
@property (nonatomic, readonly, nullable) UXCollectionViewData *_newModel;
@property (nonatomic, readonly, nullable) NSArray *_insertedSupplementaryIndexesSectionArray;
@property (nonatomic, readonly, nullable) NSArray *_deletedSupplementaryIndexesSectionArray;
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSIndexSet *> *_deletedSupplementaryTopLevelIndexesDict;
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSIndexSet *> *_insertedSupplementaryTopLevelIndexesDict;
@property (nonatomic, readonly, nullable) NSIndexSet *_deletedSections;
@property (nonatomic, setter=_setNewVisibleBounds:) CGRect _newVisibleBounds;

- (NSInteger)_oldGlobalItemMapValueAtIndex:(NSInteger)index;
- (NSInteger)_newGlobalItemMapValueAtIndex:(NSInteger)index;
- (NSInteger)_oldSectionMapValueAtIndex:(NSInteger)index;
- (NSInteger)_newSectionMapValueAtIndex:(NSInteger)index;
- (void)_computeSupplementaryUpdates;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
