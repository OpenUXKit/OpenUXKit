#import <OpenUXKit/UXCollectionViewLayout.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionView, UXCollectionViewFlowLayout;

typedef NS_ENUM(NSInteger, UXCollectionViewScrollDirection) {
    UXCollectionViewScrollDirectionVertical = 0,
    UXCollectionViewScrollDirectionHorizontal = 1,
} NS_SWIFT_NAME(UXCollectionView.ScrollDirection);

NS_SWIFT_UI_ACTOR
@protocol UXCollectionViewDelegateFlowLayout <NSObject>
@optional
- (CGSize)collectionView:(UXCollectionView *)collectionView layout:(UXCollectionViewLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSEdgeInsets)collectionView:(UXCollectionView *)collectionView layout:(UXCollectionViewLayout *)layout insetForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UXCollectionView *)collectionView layout:(UXCollectionViewLayout *)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UXCollectionView *)collectionView layout:(UXCollectionViewLayout *)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
- (CGSize)collectionView:(UXCollectionView *)collectionView layout:(UXCollectionViewLayout *)layout referenceSizeForHeaderInSection:(NSInteger)section;
- (CGSize)collectionView:(UXCollectionView *)collectionView layout:(UXCollectionViewLayout *)layout referenceSizeForFooterInSection:(NSInteger)section;
@end

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewFlowLayout : UXCollectionViewLayout

@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGSize headerReferenceSize;
@property (nonatomic) CGSize footerReferenceSize;
@property (nonatomic) NSEdgeInsets sectionInset;
@property (nonatomic) UXCollectionViewScrollDirection scrollDirection;

- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForHeaderInSection:(NSInteger)section;
- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForFooterInSection:(NSInteger)section;
- (nullable NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point;
- (nullable NSIndexSet *)indexesForSectionHeadersInRect:(CGRect)rect;
- (nullable NSIndexSet *)indexesForSectionFootersInRect:(CGRect)rect;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
