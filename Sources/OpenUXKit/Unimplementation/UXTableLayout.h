

@class NSMutableArray, NSMutableDictionary;
@protocol UXCollectionViewDelegateFlowLayout;

@interface UXTableLayout
{
    struct {
        unsigned int delegateSupplementaryViewDidBeginFloating:1;
        unsigned int delegateSupplementaryViewDidEndFloating:1;
        unsigned int delegateRreferenceSizeForHeaderInSection:1;
        unsigned int delegateLayoutInsetForSectionAtIndex:1;
        unsigned int needsDelegateFlagsUpdate:1;
        unsigned int floatingHeadersDisabled:1;
        unsigned int preparingForUpdates:1;
        unsigned int showsSectionHeaderForSingleSection:1;
        unsigned int showsSectionFooterForSingleSection:1;
    } _tableLayoutFlags;	// 8 = 0x8
    NSMutableArray *_layoutAttributesArray;	// 16 = 0x10
    NSMutableDictionary *_headerAttributesByIndexPath;	// 24 = 0x18
}


@property(readonly, nonatomic) NSMutableDictionary *headerAttributesByIndexPath; // @synthesize headerAttributesByIndexPath=_headerAttributesByIndexPath;
@property(readonly, nonatomic) NSMutableArray *layoutAttributesArray; // @synthesize layoutAttributesArray=_layoutAttributesArray;
- (id)layoutAttributesForSupplementaryViewOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)layoutAttributesForElementsInRect:(CGRect)arg1;
- (void)invalidateLayoutWithContext:(id)arg1;
- (id)invalidationContextForBoundsChange:(CGRect)arg1;
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)arg1;
- (void)prepareLayout;
- (BOOL)_wantsHeaderForSection:(NSUInteger)arg1;
- (NSEdgeInsets)insetForSection:(NSInteger)arg1;
@property(nonatomic) BOOL showsSectionFooterForSingleSection;
@property(nonatomic) BOOL showsSectionHeaderForSingleSection;
@property(nonatomic) BOOL floatingHeadersDisabled;
@property(readonly, nonatomic) id <UXCollectionViewDelegateFlowLayout> delegateFlowLayout;
- (void)_setCollectionView:(id)arg1;
- (id)init;

@end

