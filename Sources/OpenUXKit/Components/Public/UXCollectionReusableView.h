#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionViewLayoutAttributes, UXCollectionView, UXCollectionViewLayout;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionReusableView : NSView

@property (nonatomic, copy, readonly, nullable) NSString *reuseIdentifier;
@property (nonatomic, getter=isFloatingPinned) BOOL isFloatingPinned;

- (void)applyLayoutAttributes:(nullable UXCollectionViewLayoutAttributes *)layoutAttributes;
- (void)didTransitionFromLayout:(nullable UXCollectionViewLayout *)layout toLayout:(nullable UXCollectionViewLayout *)toLayout;
- (void)willTransitionFromLayout:(nullable UXCollectionViewLayout *)layout toLayout:(nullable UXCollectionViewLayout *)toLayout;
- (void)prepareForReuse;

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
- (BOOL)accessibilityPerformScrollToVisible;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
