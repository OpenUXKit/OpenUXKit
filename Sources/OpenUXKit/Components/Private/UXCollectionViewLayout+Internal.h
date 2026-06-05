#import <OpenUXKit/UXCollectionViewLayout.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionViewLayoutAccessibility, UXCollectionReusableView;

@interface UXCollectionViewLayout ()

- (NSInteger)dropPositionForPoint:(CGPoint)point withIndexPaths:(NSArray<NSIndexPath *> *)indexPaths movedToIndexPath:(nullable NSIndexPath *)indexPath;
- (nullable NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect withIndexPaths:(NSArray<NSIndexPath *> *)indexPaths exchangedWithIndexPaths:(NSArray<NSIndexPath *> *)exchangedIndexPaths;
- (nullable NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect withIndexPaths:(NSArray<NSIndexPath *> *)indexPaths movedToIndexPath:(NSIndexPath *)indexPath atPoint:(CGPoint)point;

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

#pragma mark - Layout transition animation

- (void)_animateView:(UXCollectionReusableView *)view
          withAction:(NSInteger)action
fromLayoutAttributes:(nullable UXCollectionViewLayoutAttributes *)fromAttributes
  toLayoutAttributes:(nullable UXCollectionViewLayoutAttributes *)toAttributes
          fromLayout:(nullable UXCollectionViewLayout *)fromLayout
withCompletionHandler:(nullable void (^)(BOOL finished))completion;

- (void)_prepareToAnimateFromCollectionViewItems:(NSArray *)fromItems
                                 atContentOffset:(CGPoint)fromContentOffset
                                         toItems:(NSArray *)toItems
                                 atContentOffset:(CGPoint)toContentOffset;

- (CGPoint)transitionContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
                                          keyItemIndexPath:(nullable NSIndexPath *)keyItemIndexPath;
- (CGPoint)updatesContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset;

- (NSCollectionViewDropOperation)dropPositionForPoint:(CGPoint)point;
- (nullable NSIndexPath *)proposedDropIndexPathForDraggingPoint:(CGPoint)point;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
