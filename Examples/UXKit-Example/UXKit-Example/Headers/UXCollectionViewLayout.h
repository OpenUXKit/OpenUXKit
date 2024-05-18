/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */


#import "UXKit-Structs.h"
@class NSMutableDictionary, NSMutableIndexSet, UXCollectionViewLayoutInvalidationContext, UXCollectionView, NSArray, UXCollectionViewLayoutAccessibility, NSString;

@interface UXCollectionViewLayout : NSObject {

	CGSize _collectionViewBoundsSize;
	NSMutableDictionary* _initialAnimationLayoutAttributesDict;
	NSMutableDictionary* _finalAnimationLayoutAttributesDict;
	NSMutableDictionary* _deletedSupplementaryIndexPathsDict;
	NSMutableDictionary* _insertedSupplementaryIndexPathsDict;
	NSMutableDictionary* _deletedDecorationIndexPathsDict;
	NSMutableDictionary* _insertedDecorationIndexPathsDict;
	NSMutableIndexSet* _deletedSectionsSet;
	NSMutableIndexSet* _insertedSectionsSet;
	NSMutableDictionary* _decorationViewClassDict;
	NSMutableDictionary* _decorationViewNibDict;
	UXCollectionViewLayout* _transitioningFromLayout;
	UXCollectionViewLayout* _transitioningToLayout;
	BOOL _inTransitionFromTransitionLayout;
	BOOL _inTransitionToTransitionLayout;
	UXCollectionViewLayoutInvalidationContext* _invalidationContext;
	UXCollectionView* _collectionView;
	NSArray* _accessibilityChildren;
	UXCollectionViewLayoutAccessibility* _layoutAccessibility;
	NSString* _accessibilityIdentifier;
	NSString* _accessibilityLabel;
	NSString* _accessibilityRoleDescription;

}

@property (nonatomic, readonly) UXCollectionViewLayoutAccessibility *layoutAccessibility;              //@synthesize layoutAccessibility=_layoutAccessibility - In the implementation block
@property (nonatomic, readonly) NSArray *accessibilityChildren;                                        //@synthesize accessibilityChildren=_accessibilityChildren - In the implementation block
@property (nonatomic, strong) NSString *accessibilityIdentifier;                                       //@synthesize accessibilityIdentifier=_accessibilityIdentifier - In the implementation block
@property (nonatomic, strong) NSString *accessibilityLabel;                                            //@synthesize accessibilityLabel=_accessibilityLabel - In the implementation block
@property (nonatomic, strong) NSString *accessibilityRoleDescription;                                  //@synthesize accessibilityRoleDescription=_accessibilityRoleDescription - In the implementation block
@property (nonatomic, weak, readonly) UXCollectionView *collectionView;                                //@synthesize collectionView=_collectionView - In the implementation block
+ (Class)invalidationContextClass;
+ (Class)layoutAttributesClass;
+ (Class)layoutAccessibilityClass;
- (void)dealloc;
- (id)init;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (void)prepareForAnimatedBoundsChange:(CGRect)arg1;
- (void)prepareForTransitionFromLayout:(id)arg1;
- (/*^block*/id)_animationForReusableView:(id)arg1 toLayoutAttributes:(id)arg2;
- (/*^block*/id)_animationForReusableView:(id)arg1 toLayoutAttributes:(id)arg2 type:(unsigned long long)arg3;
- (id)_decorationViewForLayoutAttributes:(id)arg1;
- (void)_didFinishLayoutTransitionAnimations:(BOOL)arg1;
- (void)_finalizeCollectionViewItemAnimations;
- (void)_finalizeLayoutTransition;
- (void)_invalidateLayoutUsingContext:(id)arg1;
- (void)_prepareForTransitionFromLayout:(id)arg1;
- (void)_prepareForTransitionToLayout:(id)arg1;
- (void)_prepareToAnimateFromCollectionViewItems:(id)arg1 atContentOffset:(CGPoint)arg2 toItems:(id)arg3 atContentOffset:(CGPoint)arg4;
- (void)_setCollectionView:(id)arg1;
- (void)_setCollectionViewBoundsSize:(CGSize)arg1;
- (BOOL)_supportsAdvancedTransitionAnimations;
- (id)accessibilityChildren;
- (id)accessibilityIdentifier;
- (id)accessibilityLabel;
- (id)accessibilityRoleDescription;
- (CGRect)backingAlignedRect:(CGRect)arg1 options:(unsigned long long)arg2;
- (CGRect)bounds;
- (id)collectionView;
- (CGSize)collectionViewContentSize;
- (id)finalLayoutAttributesForDisappearingDecorationElementOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)finalLayoutAttributesForDisappearingItemAtIndexPath:(id)arg1;
- (id)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(id)arg1 atIndexPath:(id)arg2;
- (void)finalizeAnimatedBoundsChange;
- (void)finalizeCollectionViewUpdates;
- (void)finalizeLayoutTransition;
- (id)indexPathsToDeleteForDecorationViewOfKind:(id)arg1;
- (id)indexPathsToDeleteForSupplementaryViewOfKind:(id)arg1;
- (id)indexPathsToInsertForDecorationViewOfKind:(id)arg1;
- (id)indexPathsToInsertForSupplementaryViewOfKind:(id)arg1;
- (id)initialLayoutAttributesForAppearingDecorationElementOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)initialLayoutAttributesForAppearingItemAtIndexPath:(id)arg1;
- (id)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(id)arg1 atIndexPath:(id)arg2;
- (void)invalidateLayout;
- (void)invalidateLayoutWithContext:(id)arg1;
- (id)invalidationContextForBoundsChange:(CGRect)arg1;
- (id)layoutAttributesForDecorationViewOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)layoutAttributesForElementsInRect:(CGRect)arg1;
- (id)layoutAttributesForItemAtIndexPath:(id)arg1;
- (id)layoutAttributesForSupplementaryViewOfKind:(id)arg1 atIndexPath:(id)arg2;
- (void)prepareForCollectionViewUpdates:(id)arg1;
- (void)prepareForTransitionToLayout:(id)arg1;
- (void)prepareLayout;
- (void)registerClass:(Class)arg1 forDecorationViewOfKind:(id)arg2;
- (void)registerNib:(id)arg1 forDecorationViewOfKind:(id)arg2;
- (void)setAccessibilityIdentifier:(id)arg1;
- (void)setAccessibilityLabel:(id)arg1;
- (void)setAccessibilityRoleDescription:(id)arg1;
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)arg1;
- (id)snapshottedLayoutAttributeForItemAtIndexPath:(id)arg1;
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)arg1;
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)arg1 withScrollingVelocity:(CGPoint)arg2;
- (CGPoint)transitionContentOffsetForProposedContentOffset:(CGPoint)arg1 keyItemIndexPath:(id)arg2;
- (CGPoint)updatesContentOffsetForProposedContentOffset:(CGPoint)arg1;
- (long long)userInterfaceLayoutDirection;
- (id)_indexPathsToDeleteForDecorationViewOfKind:(id)arg1;
- (id)_indexPathsToDeleteForSupplementaryViewOfKind:(id)arg1;
- (id)_indexPathsToInsertForDecorationViewOfKind:(id)arg1;
- (id)_indexPathsToInsertForSupplementaryViewOfKind:(id)arg1;
- (void)_animateView:(id)arg1 withAction:(long long)arg2 fromLayoutAttributes:(id)arg3 toLayoutAttributes:(id)arg4 fromLayout:(id)arg5 withCompletionHandler:(/*^block*/id)arg6;
- (BOOL)_isValidSection:(long long)arg1 item:(long long)arg2;
- (BOOL)_selectableItemAtIndexPath:(id)arg1;
- (long long)dropPositionForPoint:(CGPoint)arg1 withIndexPaths:(id)arg2 movedToIndexPath:(id)arg3;
- (id)firstSelectableItemIndexPath;
- (id)indexPathOfItemAbove:(id)arg1;
- (id)indexPathOfItemAfter:(id)arg1;
- (id)indexPathOfItemBefore:(id)arg1;
- (id)indexPathOfItemBelow:(id)arg1;
- (id)indexPathsForItemRangeSelectionFrom:(id)arg1 to:(id)arg2;
- (NSEdgeInsets)insetsForScrollingItemAtIndexPath:(id)arg1 toScrollPosition:(unsigned long long)arg2;
- (id)lastSelectableItemIndexPath;
- (id)layoutAccessibility;
- (id)layoutAttributesForElementsInRect:(CGRect)arg1 withIndexPaths:(id)arg2 exchangedWithIndexPaths:(id)arg3;
- (id)layoutAttributesForElementsInRect:(CGRect)arg1 withIndexPaths:(id)arg2 movedToIndexPath:(id)arg3 atPoint:(CGPoint)arg4;
- (id)proposedDropIndexPathForDraggingPoint:(CGPoint)arg1;
- (BOOL)shouldInvalidateLayoutForScaleFactorChangeFrom:(double)arg1 to:(double)arg2;
@end

