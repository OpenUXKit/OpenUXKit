/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import "UXCollectionViewLayout.h"

@class _UXFlowLayoutInfo, NSMutableDictionary, NSDictionary;

@interface UXCollectionViewFlowLayout : UXCollectionViewLayout {

	struct {
		unsigned delegateSizeForItem : 1;
		unsigned delegateReferenceSizeForHeader : 1;
		unsigned delegateReferenceSizeForFooter : 1;
		unsigned delegateInsetForSection : 1;
		unsigned delegateInteritemSpacingForSection : 1;
		unsigned delegateLineSpacingForSection : 1;
		unsigned delegateAlignmentOptions : 1;
		unsigned layoutDataIsValid : 1;
		unsigned delegateInfoIsValid : 1;
	}  _gridLayoutFlags;
	double _interitemSpacing;
	double _lineSpacing;
	CGSize _itemSize;
	CGSize _headerReferenceSize;
	CGSize _footerReferenceSize;
	NSEdgeInsets _sectionInset;
	_UXFlowLayoutInfo* _data;
	CGSize _currentLayoutSize;
	NSMutableDictionary* _insertedItemsAttributesDict;
	NSMutableDictionary* _insertedSectionHeadersAttributesDict;
	NSMutableDictionary* _insertedSectionFootersAttributesDict;
	NSMutableDictionary* _deletedItemsAttributesDict;
	NSMutableDictionary* _deletedSectionHeadersAttributesDict;
	NSMutableDictionary* _deletedSectionFootersAttributesDict;
	long long _scrollDirection;
	NSDictionary* _rowAlignmentsOptionsDictionary;
	CGRect _visibleBounds;

}

@property (setter=_setRowAlignmentsOptions:, nonatomic, strong) NSDictionary *_rowAlignmentOptions; 
@property (nonatomic) double minimumLineSpacing;                                                                 //@synthesize lineSpacing=_lineSpacing - In the implementation block
@property (nonatomic) double minimumInteritemSpacing;                                                            //@synthesize interitemSpacing=_interitemSpacing - In the implementation block
@property (nonatomic) CGSize itemSize;                                                                           //@synthesize itemSize=_itemSize - In the implementation block
@property (nonatomic) long long scrollDirection; 
@property (nonatomic) CGSize headerReferenceSize;                                                                //@synthesize headerReferenceSize=_headerReferenceSize - In the implementation block
@property (nonatomic) CGSize footerReferenceSize;                                                                //@synthesize footerReferenceSize=_footerReferenceSize - In the implementation block
@property (nonatomic) NSEdgeInsets sectionInset;                                                                 //@synthesize sectionInset=_sectionInset - In the implementation block
+ (Class)invalidationContextClass;
- (void)dealloc;
- (id)init;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)indexesForSectionFootersInRect:(CGRect)arg1;
- (long long)scrollDirection;
- (id)indexesForSectionHeadersInRect:(CGRect)arg1;
- (CGRect)_frameForFooterInSection:(long long)arg1 usingData:(id)arg2;
- (CGRect)_frameForHeaderInSection:(long long)arg1 usingData:(id)arg2;
- (void)_invalidateButKeepAllInfo;
- (void)_invalidateButKeepDelegateInfo;
- (id)_layoutAttributesForItemsInRect:(CGRect)arg1;
- (id)_rowAlignmentOptions;
- (void)_setRowAlignmentsOptions:(id)arg1;
- (void)_updateDelegateFlags;
- (CGSize)collectionViewContentSize;
- (id)finalLayoutAttributesForDeletedItemAtIndexPath:(id)arg1;
- (id)finalLayoutAttributesForFooterInDeletedSection:(long long)arg1;
- (id)finalLayoutAttributesForHeaderInDeletedSection:(long long)arg1;
- (void)finalizeCollectionViewUpdates;
- (CGSize)footerReferenceSize;
- (CGSize)headerReferenceSize;
- (id)indexPathForItemAtPoint:(CGPoint)arg1;
- (id)indexesForSectionFootersInRect:(CGRect)arg1 usingData:(id)arg2;
- (id)indexesForSectionHeadersInRect:(CGRect)arg1 usingData:(id)arg2;
- (id)initialLayoutAttributesForFooterInInsertedSection:(long long)arg1;
- (id)initialLayoutAttributesForHeaderInInsertedSection:(long long)arg1;
- (id)initialLayoutAttributesForInsertedItemAtIndexPath:(id)arg1;
- (void)invalidateLayoutWithContext:(id)arg1;
- (id)invalidationContextForBoundsChange:(CGRect)arg1;
- (CGSize)itemSize;
- (id)layoutAttributesForElementsInRect:(CGRect)arg1;
- (id)layoutAttributesForFooterInSection:(long long)arg1;
- (id)layoutAttributesForFooterInSection:(long long)arg1 usingData:(id)arg2;
- (id)layoutAttributesForHeaderInSection:(long long)arg1;
- (id)layoutAttributesForHeaderInSection:(long long)arg1 usingData:(id)arg2;
- (id)layoutAttributesForItemAtIndexPath:(id)arg1;
- (id)layoutAttributesForItemAtIndexPath:(id)arg1 usingData:(id)arg2;
- (id)layoutAttributesForSupplementaryViewOfKind:(id)arg1 atIndexPath:(id)arg2;
- (double)minimumInteritemSpacing;
- (double)minimumLineSpacing;
- (NSEdgeInsets)sectionInset;
- (void)setFooterReferenceSize:(CGSize)arg1;
- (void)setHeaderReferenceSize:(CGSize)arg1;
- (void)setItemSize:(CGSize)arg1;
- (void)setMinimumInteritemSpacing:(double)arg1;
- (void)setMinimumLineSpacing:(double)arg1;
- (void)setScrollDirection:(long long)arg1;
- (void)setSectionInset:(NSEdgeInsets)arg1;
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)arg1;
- (CGSize)synchronizeLayout;
- (void)_fetchItemsInfo;
- (void)_getSizingInfos;
- (CGRect)_frameForItemAtSection:(long long)arg1 andRow:(long long)arg2 usingData:(id)arg3;
- (void)_updateItemsLayout;
- (id)indexPathOfItemAbove:(id)arg1;
- (id)indexPathOfItemAfter:(id)arg1;
- (id)indexPathOfItemBefore:(id)arg1;
- (id)indexPathOfItemBelow:(id)arg1;
- (id)indexPathsForItemsInRect:(CGRect)arg1;
- (id)indexPathsForItemsInRect:(CGRect)arg1 usingData:(id)arg2;
- (BOOL)shouldUpdateVisibleCellLayoutAttributes;
@end

