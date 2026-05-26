

#import <objc/NSObject.h>

@class NSArray, NSMutableDictionary, NSMutableIndexSet, NSString, UXCollectionView, UXCollectionViewLayoutAccessibility, UXCollectionViewLayoutInvalidationContext;

@interface UXCollectionViewLayout : NSObject
{
    CGSize _collectionViewBoundsSize;	// 8 = 0x8
    NSMutableDictionary *_initialAnimationLayoutAttributesDict;	// 24 = 0x18
    NSMutableDictionary *_finalAnimationLayoutAttributesDict;	// 32 = 0x20
    NSMutableDictionary *_deletedSupplementaryIndexPathsDict;	// 40 = 0x28
    NSMutableDictionary *_insertedSupplementaryIndexPathsDict;	// 48 = 0x30
    NSMutableDictionary *_deletedDecorationIndexPathsDict;	// 56 = 0x38
    NSMutableDictionary *_insertedDecorationIndexPathsDict;	// 64 = 0x40
    NSMutableIndexSet *_deletedSectionsSet;	// 72 = 0x48
    NSMutableIndexSet *_insertedSectionsSet;	// 80 = 0x50
    NSMutableDictionary *_decorationViewClassDict;	// 88 = 0x58
    NSMutableDictionary *_decorationViewNibDict;	// 96 = 0x60
    UXCollectionViewLayout *_transitioningFromLayout;	// 104 = 0x68
    UXCollectionViewLayout *_transitioningToLayout;	// 112 = 0x70
    BOOL _inTransitionFromTransitionLayout;	// 120 = 0x78
    BOOL _inTransitionToTransitionLayout;	// 121 = 0x79
    UXCollectionViewLayoutInvalidationContext *_invalidationContext;	// 128 = 0x80
    UXCollectionView *_collectionView;	// 136 = 0x88
    NSArray *_accessibilityChildren;	// 144 = 0x90
    UXCollectionViewLayoutAccessibility *_layoutAccessibility;	// 152 = 0x98
    NSString *_accessibilityIdentifier;	// 160 = 0xa0
    NSString *_accessibilityLabel;	// 168 = 0xa8
    NSString *_accessibilityRoleDescription;	// 176 = 0xb0
}

+ (Class)layoutAccessibilityClass;
+ (Class)invalidationContextClass;
+ (Class)layoutAttributesClass;

@property(strong, nonatomic) NSString *accessibilityRoleDescription; // @synthesize accessibilityRoleDescription=_accessibilityRoleDescription;
@property(strong, nonatomic) NSString *accessibilityLabel; // @synthesize accessibilityLabel=_accessibilityLabel;
@property(strong, nonatomic) NSString *accessibilityIdentifier; // @synthesize accessibilityIdentifier=_accessibilityIdentifier;
@property(readonly, nonatomic) UXCollectionViewLayoutAccessibility *layoutAccessibility; // @synthesize layoutAccessibility=_layoutAccessibility;
@property(readonly, nonatomic) __weak UXCollectionView *collectionView; // @synthesize collectionView=_collectionView;
@property(readonly, nonatomic) NSArray *accessibilityChildren; // @synthesize accessibilityChildren=_accessibilityChildren;
- (id)indexPathOfItemBelow:(id)arg1;
- (id)indexPathOfItemAbove:(id)arg1;
- (id)indexPathOfItemAfter:(id)arg1;
- (id)indexPathOfItemBefore:(id)arg1;
- (id)indexPathsForItemRangeSelectionFrom:(id)arg1 to:(id)arg2;
- (id)lastSelectableItemIndexPath;
- (id)firstSelectableItemIndexPath;
- (BOOL)_selectableItemAtIndexPath:(id)arg1;
- (BOOL)_isValidSection:(NSInteger)arg1 item:(NSInteger)arg2;
- (NSEdgeInsets)insetsForScrollingItemAtIndexPath:(id)arg1 toScrollPosition:(NSUInteger)arg2;
- (CGRect)backingAlignedRect:(CGRect)arg1 options:(NSUInteger)arg2;
- (NSInteger)userInterfaceLayoutDirection;
- (CGPoint)updatesContentOffsetForProposedContentOffset:(CGPoint)arg1;
- (CGPoint)transitionContentOffsetForProposedContentOffset:(CGPoint)arg1 keyItemIndexPath:(id)arg2;
- (void)_didFinishLayoutTransitionAnimations:(BOOL)arg1;
- (void)finalizeLayoutTransition;
- (void)prepareForTransitionFromLayout:(id)arg1;
- (void)prepareForTransitionToLayout:(id)arg1;
- (void)_finalizeLayoutTransition;
- (void)_prepareForTransitionFromLayout:(id)arg1;
- (void)_prepareForTransitionToLayout:(id)arg1;
- (void)registerNib:(id)arg1 forDecorationViewOfKind:(id)arg2;
- (void)registerClass:(Class)arg1 forDecorationViewOfKind:(id)arg2;
- (id)snapshottedLayoutAttributeForItemAtIndexPath:(id)arg1;
- (void)finalizeCollectionViewUpdates;
- (void)prepareForCollectionViewUpdates:(id)arg1;
- (CGRect)bounds;
- (CGSize)collectionViewContentSize;
- (id)_animationForReusableView:(id)arg1 toLayoutAttributes:(id)arg2;
- (id)_animationForReusableView:(id)arg1 toLayoutAttributes:(id)arg2 type:(NSUInteger)arg3;
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)arg1;
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)arg1 withScrollingVelocity:(CGPoint)arg2;
- (id)invalidationContextForBoundsChange:(CGRect)arg1;
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)arg1;
- (BOOL)shouldInvalidateLayoutForScaleFactorChangeFrom:(CGFloat)arg1 to:(CGFloat)arg2;
- (void)invalidateLayoutWithContext:(id)arg1;
- (void)invalidateLayout;
- (void)prepareLayout;
- (id)layoutAttributesForDecorationViewOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)layoutAttributesForSupplementaryViewOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)layoutAttributesForItemAtIndexPath:(id)arg1;
- (id)layoutAttributesForElementsInRect:(CGRect)arg1;
- (void)dealloc;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)init;
- (void)_animateView:(id)arg1 withAction:(NSInteger)arg2 fromLayoutAttributes:(id)arg3 toLayoutAttributes:(id)arg4 fromLayout:(id)arg5 withCompletionHandler:(id)arg6;
- (void)_invalidateLayoutUsingContext:(id)arg1;
- (BOOL)_supportsAdvancedTransitionAnimations;
- (id)_decorationViewForLayoutAttributes:(id)arg1;
- (void)_finalizeCollectionViewItemAnimations;
- (id)indexPathsToInsertForDecorationViewOfKind:(id)arg1;
- (id)indexPathsToInsertForSupplementaryViewOfKind:(id)arg1;
- (id)indexPathsToDeleteForDecorationViewOfKind:(id)arg1;
- (id)indexPathsToDeleteForSupplementaryViewOfKind:(id)arg1;
- (id)_indexPathsToInsertForDecorationViewOfKind:(id)arg1;
- (id)_indexPathsToInsertForSupplementaryViewOfKind:(id)arg1;
- (id)_indexPathsToDeleteForDecorationViewOfKind:(id)arg1;
- (id)_indexPathsToDeleteForSupplementaryViewOfKind:(id)arg1;
- (id)finalLayoutAttributesForDisappearingDecorationElementOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)initialLayoutAttributesForAppearingDecorationElementOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)finalLayoutAttributesForDisappearingItemAtIndexPath:(id)arg1;
- (id)initialLayoutAttributesForAppearingItemAtIndexPath:(id)arg1;
- (void)_prepareToAnimateFromCollectionViewItems:(id)arg1 atContentOffset:(CGPoint)arg2 toItems:(id)arg3 atContentOffset:(CGPoint)arg4;
- (void)finalizeAnimatedBoundsChange;
- (void)prepareForAnimatedBoundsChange:(CGRect)arg1;
- (void)_setCollectionViewBoundsSize:(CGSize)arg1;
- (void)_setCollectionView:(id)arg1;
- (id)proposedDropIndexPathForDraggingPoint:(CGPoint)arg1;
- (id)layoutAttributesForElementsInRect:(CGRect)arg1 withIndexPaths:(id)arg2 exchangedWithIndexPaths:(id)arg3;
- (id)layoutAttributesForElementsInRect:(CGRect)arg1 withIndexPaths:(id)arg2 movedToIndexPath:(id)arg3 atPoint:(CGPoint)arg4;
- (NSInteger)dropPositionForPoint:(CGPoint)arg1 withIndexPaths:(id)arg2 movedToIndexPath:(id)arg3;

@end

