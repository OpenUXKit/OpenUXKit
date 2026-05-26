

#import <AppKit/AppKit.h>

@class NSMutableDictionary, NSMutableIndexSet;

@interface UXCollectionViewIndexPathsSet : NSObject <NSCopying, NSMutableCopying>
{
    NSMutableIndexSet *_sectionIndexes;	// 8 = 0x8
    NSMutableDictionary *_sectionToItemIndexesMap;	// 16 = 0x10
}

+ (id)indexPathsSetWithIndexPathsSet:(id)arg1;
+ (id)indexPathsSetWithIndexPaths:(id)arg1;
+ (id)indexPathsSetWithIndexPath:(id)arg1;
+ (id)indexPathsSet;
- (BOOL)containsIndexPath:(id)arg1;
- (void)enumerateIndexPathsUsingBlock:(id)arg1;
- (id)lastIndexPath;
- (id)firstIndexPath;
- (id)allIndexPaths;
- (id)itemsInSection:(NSInteger)arg1;
- (id)indexPathsForSections:(id)arg1;
- (id)indexPathsForSection:(NSInteger)arg1;
- (id)sections;
- (NSUInteger)count;
- (void)_removeOneIndexPath:(id)arg1;
- (void)_addOneIndexPath:(id)arg1;
- (void)_enumerateSectionItemIndexesWithBlock:(id)arg1;
- (void)_removeItemIndexesForSection:(NSUInteger)arg1;
- (id)_itemIndexesForSection:(NSUInteger)arg1 allowingCreation:(BOOL)arg2;
- (id)mutableCopyWithZone:(struct _NSZone *)arg1;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (void)_addIndexPathsSet:(id)arg1;
- (id)description;
- (BOOL)isEqual:(id)arg1;
- (void)dealloc;
- (id)initWithIndexPathsSet:(id)arg1;
- (id)initWithIndexPaths:(id)arg1;
- (id)initWithIndexPath:(id)arg1;
- (id)init;

@end

