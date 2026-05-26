#import <OpenUXKit/UXCollectionViewLayout.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionViewLayoutAccessibility, UXCollectionReusableView;

@interface UXCollectionViewLayout ()

@property (nonatomic, readonly, nullable) UXCollectionViewLayoutAccessibility *layoutAccessibility;
@property (nonatomic, readonly, nullable) NSArray *accessibilityChildren;

- (void)_setCollectionView:(nullable UXCollectionView *)collectionView;
- (void)_setCollectionViewBoundsSize:(CGSize)boundsSize;

- (void)_prepareForTransitionToLayout:(UXCollectionViewLayout *)newLayout;
- (void)_prepareForTransitionFromLayout:(UXCollectionViewLayout *)oldLayout;
- (void)_finalizeLayoutTransition;
- (void)_didFinishLayoutTransitionAnimations:(BOOL)finished;
- (void)_finalizeCollectionViewItemAnimations;
- (void)_invalidateLayoutUsingContext:(UXCollectionViewLayoutInvalidationContext *)context;
- (BOOL)_supportsAdvancedTransitionAnimations;
- (nullable UXCollectionReusableView *)_decorationViewForLayoutAttributes:(UXCollectionViewLayoutAttributes *)layoutAttributes;

- (NSArray<NSIndexPath *> *)_indexPathsToInsertForSupplementaryViewOfKind:(NSString *)elementKind;
- (NSArray<NSIndexPath *> *)_indexPathsToInsertForDecorationViewOfKind:(NSString *)elementKind;
- (NSArray<NSIndexPath *> *)_indexPathsToDeleteForSupplementaryViewOfKind:(NSString *)elementKind;
- (NSArray<NSIndexPath *> *)_indexPathsToDeleteForDecorationViewOfKind:(NSString *)elementKind;

- (BOOL)_isValidSection:(NSInteger)section item:(NSInteger)item;
- (BOOL)_selectableItemAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
