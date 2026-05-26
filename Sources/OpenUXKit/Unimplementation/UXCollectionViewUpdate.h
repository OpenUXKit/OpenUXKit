

#import <objc/NSObject.h>

@class NSArray, NSMutableArray, NSMutableDictionary, NSMutableIndexSet, UXCollectionView, UXCollectionViewData;

@interface UXCollectionViewUpdate : NSObject
{
    UXCollectionView *_collectionView;	// 8 = 0x8
    NSArray *_updateItems;	// 16 = 0x10
    UXCollectionViewData *_oldModel;	// 24 = 0x18
    UXCollectionViewData *_newModel;	// 32 = 0x20
    CGRect _oldVisibleBounds;	// 40 = 0x28
    CGRect _newVisibleBounds;	// 72 = 0x48
    NSMutableIndexSet *_movedItems;	// 104 = 0x68
    NSMutableIndexSet *_movedSections;	// 112 = 0x70
    NSMutableIndexSet *_deletedSections;	// 120 = 0x78
    NSMutableIndexSet *_insertedSections;	// 128 = 0x80
    NSInteger *_oldSectionMap;	// 136 = 0x88
    NSInteger *_newSectionMap;	// 144 = 0x90
    NSInteger *_oldGlobalItemMap;	// 152 = 0x98
    NSInteger *_newGlobalItemMap;	// 160 = 0xa0
    NSMutableArray *_deletedSupplementaryIndexesSectionArray;	// 168 = 0xa8
    NSMutableArray *_insertedSupplementaryIndexesSectionArray;	// 176 = 0xb0
    NSMutableDictionary *_deletedSupplementaryTopLevelIndexesDict;	// 184 = 0xb8
    NSMutableDictionary *_insertedSupplementaryTopLevelIndexesDict;	// 192 = 0xc0
    NSMutableArray *_viewAnimations;	// 200 = 0xc8
    NSMutableArray *_gaps;	// 208 = 0xd0
    NSArray *_updateItemsSortedByIndexPaths;	// 216 = 0xd8
}

- (id)oldIndexPathForSupplementaryElementOfKind:(id)arg1 newIndexPath:(id)arg2;
- (id)newIndexPathForSupplementaryElementOfKind:(id)arg1 oldIndexPath:(id)arg2;
@property(readonly, copy, nonatomic) NSArray *updateItemsSortedByIndexPaths; // @synthesize updateItemsSortedByIndexPaths=_updateItemsSortedByIndexPaths;
- (void)_computeGaps;
- (void)_computeSupplementaryUpdates;
- (void)_computeItemUpdates;
- (void)_computeSectionUpdates;
- (void)dealloc;
- (id)initWithCollectionView:(id)arg1 updateItems:(id)arg2 oldModel:(id)arg3 newModel:(id)arg4 oldVisibleBounds:(CGRect)arg5 newVisibleBounds:(CGRect)arg6;

@end

