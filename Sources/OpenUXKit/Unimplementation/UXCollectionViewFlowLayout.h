

@class NSDictionary, NSMutableDictionary, _UXFlowLayoutInfo;

@interface UXCollectionViewFlowLayout
{
    struct {
        unsigned int delegateSizeForItem:1;
        unsigned int delegateReferenceSizeForHeader:1;
        unsigned int delegateReferenceSizeForFooter:1;
        unsigned int delegateInsetForSection:1;
        unsigned int delegateInteritemSpacingForSection:1;
        unsigned int delegateLineSpacingForSection:1;
        unsigned int delegateAlignmentOptions:1;
        unsigned int layoutDataIsValid:1;
        unsigned int delegateInfoIsValid:1;
    } _gridLayoutFlags;	// 8 = 0x8
    CGFloat _interitemSpacing;	// 16 = 0x10
    CGFloat _lineSpacing;	// 24 = 0x18
    CGSize _itemSize;	// 32 = 0x20
    CGSize _headerReferenceSize;	// 48 = 0x30
    CGSize _footerReferenceSize;	// 64 = 0x40
    NSEdgeInsets _sectionInset;	// 80 = 0x50
    _UXFlowLayoutInfo *_data;	// 112 = 0x70
    CGSize _currentLayoutSize;	// 120 = 0x78
    NSMutableDictionary *_insertedItemsAttributesDict;	// 136 = 0x88
    NSMutableDictionary *_insertedSectionHeadersAttributesDict;	// 144 = 0x90
    NSMutableDictionary *_insertedSectionFootersAttributesDict;	// 152 = 0x98
    NSMutableDictionary *_deletedItemsAttributesDict;	// 160 = 0xa0
    NSMutableDictionary *_deletedSectionHeadersAttributesDict;	// 168 = 0xa8
    NSMutableDictionary *_deletedSectionFootersAttributesDict;	// 176 = 0xb0
    NSInteger _scrollDirection;	// 184 = 0xb8
    NSDictionary *_rowAlignmentsOptionsDictionary;	// 192 = 0xc0
    CGRect _visibleBounds;	// 200 = 0xc8
}

+ (Class)invalidationContextClass;
@property(nonatomic) NSEdgeInsets sectionInset; // @synthesize sectionInset=_sectionInset;
@property(nonatomic) CGSize footerReferenceSize; // @synthesize footerReferenceSize=_footerReferenceSize;
@property(nonatomic) CGSize headerReferenceSize; // @synthesize headerReferenceSize=_headerReferenceSize;
@property(nonatomic) CGSize itemSize; // @synthesize itemSize=_itemSize;
@property(nonatomic) CGFloat minimumInteritemSpacing; // @synthesize minimumInteritemSpacing=_interitemSpacing;
@property(nonatomic) CGFloat minimumLineSpacing; // @synthesize minimumLineSpacing=_lineSpacing;
@property(nonatomic) NSInteger scrollDirection;
- (id)layoutAttributesForElementsInRect:(CGRect)arg1;
- (id)indexPathsForItemsInRect:(CGRect)arg1;
- (id)_layoutAttributesForItemsInRect:(CGRect)arg1;
- (BOOL)shouldUpdateVisibleCellLayoutAttributes;
- (id)layoutAttributesForSupplementaryViewOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)layoutAttributesForItemAtIndexPath:(id)arg1;
- (id)layoutAttributesForFooterInSection:(NSInteger)arg1;
- (id)layoutAttributesForHeaderInSection:(NSInteger)arg1;
- (id)layoutAttributesForItemAtIndexPath:(id)arg1 usingData:(id)arg2;
- (id)layoutAttributesForFooterInSection:(NSInteger)arg1 usingData:(id)arg2;
- (id)layoutAttributesForHeaderInSection:(NSInteger)arg1 usingData:(id)arg2;
- (id)indexPathOfItemAfter:(id)arg1;
- (id)indexPathOfItemBefore:(id)arg1;
- (id)indexPathOfItemAbove:(id)arg1;
- (id)indexPathOfItemBelow:(id)arg1;
- (id)indexPathForItemAtPoint:(CGPoint)arg1;
- (id)indexesForSectionFootersInRect:(CGRect)arg1;
- (id)indexesForSectionHeadersInRect:(CGRect)arg1;
- (id)indexPathsForItemsInRect:(CGRect)arg1 usingData:(id)arg2;
- (id)indexesForSectionFootersInRect:(CGRect)arg1 usingData:(id)arg2;
- (id)indexesForSectionHeadersInRect:(CGRect)arg1 usingData:(id)arg2;
- (CGSize)collectionViewContentSize;
- (id)invalidationContextForBoundsChange:(CGRect)arg1;
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)arg1;
- (void)invalidateLayoutWithContext:(id)arg1;
- (void)dealloc;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)init;
- (void)_invalidateButKeepAllInfo;
- (void)_invalidateButKeepDelegateInfo;
- (CGSize)synchronizeLayout;
- (id)finalLayoutAttributesForFooterInDeletedSection:(NSInteger)arg1;
- (id)finalLayoutAttributesForHeaderInDeletedSection:(NSInteger)arg1;
- (id)finalLayoutAttributesForDeletedItemAtIndexPath:(id)arg1;
- (id)initialLayoutAttributesForFooterInInsertedSection:(NSInteger)arg1;
- (id)initialLayoutAttributesForHeaderInInsertedSection:(NSInteger)arg1;
- (id)initialLayoutAttributesForInsertedItemAtIndexPath:(id)arg1;
- (void)finalizeCollectionViewUpdates;
- (CGRect)_frameForFooterInSection:(NSInteger)arg1 usingData:(id)arg2;
- (CGRect)_frameForHeaderInSection:(NSInteger)arg1 usingData:(id)arg2;
- (CGRect)_frameForItemAtSection:(NSInteger)arg1 andRow:(NSInteger)arg2 usingData:(id)arg3;
- (void)_fetchItemsInfo;
- (void)_updateItemsLayout;
- (void)_getSizingInfos;
- (void)_updateDelegateFlags;
@property(strong, nonatomic, setter=_setRowAlignmentsOptions:) NSDictionary *_rowAlignmentOptions;

@end

