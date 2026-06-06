#import "UXCollectionViewUpdate.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXCollectionViewUpdate ()

@property (nonatomic, readonly, nullable) UXCollectionViewData *_oldModel;
@property (nonatomic, readonly, nullable) UXCollectionViewData *_newModel;
@property (nonatomic, readonly, nullable) NSArray *_insertedSupplementaryIndexesSectionArray;
@property (nonatomic, readonly, nullable) NSArray *_deletedSupplementaryIndexesSectionArray;

- (NSInteger)_oldGlobalItemMapValueAtIndex:(NSInteger)index;
- (NSInteger)_newGlobalItemMapValueAtIndex:(NSInteger)index;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
