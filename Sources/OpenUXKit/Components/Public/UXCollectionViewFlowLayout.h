#import <OpenUXKit/UXCollectionViewLayout.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSInteger, UXCollectionViewScrollDirection) {
    UXCollectionViewScrollDirectionVertical = 0,
    UXCollectionViewScrollDirectionHorizontal = 1,
};

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
