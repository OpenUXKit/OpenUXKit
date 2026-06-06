#import "UXCollectionReusableView.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXCollectionReusableView (Internal)

- (void)_setCollectionView:(nullable UXCollectionView *)collectionView;
- (nullable UXCollectionView *)_collectionView;
- (nullable UXCollectionViewLayoutAttributes *)_layoutAttributes;
- (void)_setLayoutAttributes:(nullable UXCollectionViewLayoutAttributes *)layoutAttributes;
- (void)_setBaseLayoutAttributes:(nullable UXCollectionViewLayoutAttributes *)baseLayoutAttributes;
- (void)_setReuseIdentifier:(nullable NSString *)reuseIdentifier;

- (void)_addUpdateAnimation;
- (void)_clearUpdateAnimation;
- (BOOL)_isInUpdateAnimation;

- (BOOL)_wasDequeued;
- (void)_markAsDequeued;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
