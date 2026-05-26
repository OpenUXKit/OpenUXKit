

#import <AppKit/AppKit.h>

@class NSMutableIndexSet;

@interface _UXCollectionViewSectionItemIndexes : NSObject <NSCopying>
{
    NSMutableIndexSet *_itemIndexesSet;	// 8 = 0x8
}

- (id)itemIndexPathsForSection:(NSUInteger)arg1;
- (void)enumerateItemsUsingBlock:(id)arg1;
- (void)adjustForDeletionOfItems:(id)arg1;
- (void)adjustForDeletionOfItem:(NSUInteger)arg1;
- (void)adjustForInsertionOfItems:(id)arg1;
- (void)adjustForInsertionOfItem:(NSUInteger)arg1;
- (void)removeSectionItemIndexes:(id)arg1;
- (void)removeItemsInRange:(struct _NSRange)arg1;
- (void)removeItem:(NSUInteger)arg1;
- (void)addSectionItemIndexes:(id)arg1;
- (void)addItemsInRange:(struct _NSRange)arg1;
- (void)addItem:(NSUInteger)arg1;
- (BOOL)containsItem:(NSUInteger)arg1;
- (id)items;
- (NSUInteger)lastItem;
- (NSUInteger)firstItem;
- (NSUInteger)itemCount;
- (id)description;
- (BOOL)isEqual:(id)arg1;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (void)dealloc;
- (id)init;

@end

