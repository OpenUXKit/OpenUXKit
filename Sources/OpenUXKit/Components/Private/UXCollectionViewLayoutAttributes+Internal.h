#import "UXCollectionViewLayoutAttributes.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXCollectionViewLayoutAttributes ()

- (BOOL)_isCell;
- (BOOL)_isSupplementaryView;
- (BOOL)_isDecorationView;
- (BOOL)_isEquivalentTo:(UXCollectionViewLayoutAttributes *)attributes;
- (BOOL)_isTransitionVisibleTo:(UXCollectionViewLayoutAttributes *)attributes;

- (nullable NSString *)_elementKind;
- (void)_setElementKind:(nullable NSString *)elementKind;
- (nullable NSString *)_reuseIdentifier;
- (void)_setReuseIdentifier:(nullable NSString *)reuseIdentifier;
- (void)_setIndexPath:(nullable NSIndexPath *)indexPath;
- (BOOL)_isClone;
- (void)_setIsClone:(BOOL)isClone;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
