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

- (nullable CGImageRef)_snapshot:(BOOL)flipped CF_RETURNS_RETAINED;

#pragma mark - Accessibility

- (nullable NSIndexPath *)_accessibilityIndexPath;
- (nullable NSString *)_accessibilityDefaultRole;
- (nullable id)_dynamicAccessibilityParent;
- (nullable id)_layoutSectionAccessibility;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
