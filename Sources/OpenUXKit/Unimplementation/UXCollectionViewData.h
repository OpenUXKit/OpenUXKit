

#import <objc/NSObject.h>

@class NSArray, NSMapTable, NSMutableArray, NSMutableDictionary, UXCollectionView, UXCollectionViewLayout;

@interface UXCollectionViewData : NSObject
{
    UXCollectionView *_collectionView;	// 8 = 0x8
    UXCollectionViewLayout *_layout;	// 16 = 0x10
    NSMapTable *_screenPageMap;	// 24 = 0x18
    id _globalItems;	// 32 = 0x20
    NSMutableDictionary *_supplementaryLayoutAttributes;	// 40 = 0x28
    NSMutableDictionary *_decorationLayoutAttributes;	// 48 = 0x30
    NSMutableDictionary *_invalidatedSupplementaryViews;	// 56 = 0x38
    CGRect _validLayoutRect;	// 64 = 0x40
    NSInteger _numItems;	// 96 = 0x60
    NSInteger _numSections;	// 104 = 0x68
    NSInteger *_sectionItemCounts;	// 112 = 0x70
    NSInteger _lastSectionTestedForNumberOfItemsBeforeSection;	// 120 = 0x78
    NSInteger _lastResultForNumberOfItemsBeforeSection;	// 128 = 0x80
    CGSize _contentSize;	// 136 = 0x88
    struct {
        unsigned int contentSizeIsValid:1;
        unsigned int itemCountsAreValid:1;
        unsigned int layoutIsPrepared:1;
        unsigned int layoutLocked:1;
    } _collectionViewDataFlags;	// 152 = 0x98
    NSMutableArray *_clonedLayoutAttributes;	// 160 = 0xa0
}

+ (void)initialize;
@property(readonly, nonatomic) NSArray *clonedLayoutAttributes; // @synthesize clonedLayoutAttributes=_clonedLayoutAttributes;
@property(nonatomic, getter=isLayoutLocked) BOOL layoutLocked;
@property(readonly, nonatomic) BOOL layoutIsPrepared;
- (id)layoutAttributesForDecorationViewOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)layoutAttributesForSupplementaryElementOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)knownDecorationElementKinds;
- (id)knownSupplementaryElementKinds;
- (id)existingSupplementaryLayoutAttributes;
- (id)existingSupplementaryLayoutAttributesWithMinimalIndexPathLength:(NSUInteger)arg1;
- (id)existingSupplementaryLayoutAttributesInSection:(NSInteger)arg1;
- (id)layoutAttributesForElementsInRect:(CGRect)arg1;
- (id)layoutAttributesForElementsInSection:(NSInteger)arg1;
- (id)layoutAttributesForGlobalItemIndex:(NSInteger)arg1;
- (id)layoutAttributesForItemAtIndexPath:(id)arg1;
- (CGRect)rectForDecorationElementOfKind:(id)arg1 atIndexPath:(id)arg2;
- (CGRect)rectForSupplementaryElementOfKind:(id)arg1 atIndexPath:(id)arg2;
- (CGRect)rectForGlobalItemIndex:(NSInteger)arg1;
- (CGRect)collectionViewContentRect;
- (CGRect)rectForItemAtIndexPath:(id)arg1;
- (id)indexPathForItemAtGlobalIndex:(NSInteger)arg1;
- (NSInteger)globalIndexForItemAtIndexPath:(id)arg1;
- (NSInteger)numberOfItemsBeforeSection:(NSInteger)arg1;
- (NSInteger)numberOfItemsInSection:(NSInteger)arg1;
- (NSInteger)numberOfItems;
- (NSInteger)numberOfSections;
- (void)validateLayoutInRect:(CGRect)arg1;
- (void)_loadEverything;
- (void)_setLayoutAttributes:(id)arg1 atGlobalItemIndex:(NSInteger)arg2;
- (id)_screenPageForPoint:(CGPoint)arg1;
- (void)_setupMutableIndexPath:(id *)arg1 forGlobalItemIndex:(NSInteger)arg2;
- (void)_prepareToLoadData;
- (void)_validateContentSize;
- (void)_validateItemCounts;
- (void)_updateItemCounts;
- (void)invalidate:(BOOL)arg1;
- (void)validateSupplementaryViews;
- (void)invalidateSupplementaryViews:(id)arg1;
- (id)description;
- (void)dealloc;
- (id)initWithCollectionView:(id)arg1 layout:(id)arg2;

@end

