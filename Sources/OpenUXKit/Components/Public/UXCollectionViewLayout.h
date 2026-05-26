#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionView, UXCollectionViewLayoutAttributes, UXCollectionViewLayoutInvalidationContext, UXCollectionViewLayoutAccessibility;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewLayout : NSObject <NSCoding>

@property (nonatomic, weak, readonly, nullable) UXCollectionView *collectionView;

@property (nonatomic, strong, null_resettable) NSString *accessibilityIdentifier;
@property (nonatomic, strong, null_resettable) NSString *accessibilityLabel;
@property (nonatomic, strong, null_resettable) NSString *accessibilityRoleDescription;

+ (Class)layoutAttributesClass;
+ (Class)invalidationContextClass;
+ (Class)layoutAccessibilityClass;

- (void)invalidateLayout;
- (void)invalidateLayoutWithContext:(UXCollectionViewLayoutInvalidationContext *)context;
- (void)prepareLayout;

- (nullable NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect;
- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;

- (CGSize)collectionViewContentSize;
- (CGRect)bounds;

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds;
- (UXCollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds;
- (BOOL)shouldInvalidateLayoutForScaleFactorChangeFrom:(CGFloat)fromScaleFactor to:(CGFloat)toScaleFactor;

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity;
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset;

- (void)registerClass:(nullable Class)viewClass forDecorationViewOfKind:(NSString *)elementKind;
- (void)registerNib:(nullable NSNib *)nib forDecorationViewOfKind:(NSString *)elementKind;

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems;
- (void)finalizeCollectionViewUpdates;
- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds;
- (void)finalizeAnimatedBoundsChange;
- (void)prepareForTransitionToLayout:(UXCollectionViewLayout *)newLayout;
- (void)prepareForTransitionFromLayout:(UXCollectionViewLayout *)oldLayout;
- (void)finalizeLayoutTransition;

- (nullable UXCollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath;
- (nullable UXCollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath;
- (nullable UXCollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath;
- (nullable UXCollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath;
- (nullable UXCollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath;
- (nullable UXCollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath;

- (NSArray<NSIndexPath *> *)indexPathsToInsertForSupplementaryViewOfKind:(NSString *)elementKind;
- (NSArray<NSIndexPath *> *)indexPathsToInsertForDecorationViewOfKind:(NSString *)elementKind;
- (NSArray<NSIndexPath *> *)indexPathsToDeleteForSupplementaryViewOfKind:(NSString *)elementKind;
- (NSArray<NSIndexPath *> *)indexPathsToDeleteForDecorationViewOfKind:(NSString *)elementKind;

- (nullable NSIndexPath *)indexPathOfItemAbove:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)indexPathOfItemBelow:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)indexPathOfItemBefore:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)indexPathOfItemAfter:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)firstSelectableItemIndexPath;
- (nullable NSIndexPath *)lastSelectableItemIndexPath;
- (NSArray<NSIndexPath *> *)indexPathsForItemRangeSelectionFrom:(nullable NSIndexPath *)fromIndexPath to:(nullable NSIndexPath *)toIndexPath;

- (NSUserInterfaceLayoutDirection)userInterfaceLayoutDirection;
- (NSEdgeInsets)insetsForScrollingItemAtIndexPath:(NSIndexPath *)indexPath toScrollPosition:(NSUInteger)scrollPosition;
- (CGRect)backingAlignedRect:(CGRect)rect options:(NSAlignmentOptions)options;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
