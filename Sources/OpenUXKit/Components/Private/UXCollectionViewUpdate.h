#import <AppKit/AppKit.h>
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionView, UXCollectionViewData, UXCollectionViewUpdateItem;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewUpdate : NSObject

@property (nonatomic, copy, readonly, nullable) NSArray<UXCollectionViewUpdateItem *> *updateItemsSortedByIndexPaths;

- (instancetype)initWithCollectionView:(UXCollectionView *)collectionView updateItems:(NSArray<UXCollectionViewUpdateItem *> *)updateItems oldModel:(UXCollectionViewData *)oldModel newModel:(UXCollectionViewData *)newModel oldVisibleBounds:(CGRect)oldVisibleBounds newVisibleBounds:(CGRect)newVisibleBounds;

- (nullable NSIndexPath *)newIndexPathForSupplementaryElementOfKind:(NSString *)kind oldIndexPath:(NSIndexPath *)oldIndexPath;
- (nullable NSIndexPath *)oldIndexPathForSupplementaryElementOfKind:(NSString *)kind newIndexPath:(NSIndexPath *)newIndexPath;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
