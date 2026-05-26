#import <Foundation/Foundation.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXCollectionViewSectionItemIndexes : NSObject <NSCopying>

@property (nonatomic, readonly) NSUInteger itemCount;
@property (nonatomic, readonly) NSUInteger firstItem;
@property (nonatomic, readonly) NSUInteger lastItem;

- (void)addItem:(NSUInteger)item;
- (void)removeItem:(NSUInteger)item;
- (BOOL)containsItem:(NSUInteger)item;
- (void)addItemsInRange:(NSRange)range;
- (void)removeItemsInRange:(NSRange)range;
- (void)addSectionItemIndexes:(nullable _UXCollectionViewSectionItemIndexes *)sectionItemIndexes;
- (void)removeSectionItemIndexes:(nullable _UXCollectionViewSectionItemIndexes *)sectionItemIndexes;
- (void)adjustForDeletionOfItem:(NSUInteger)item;
- (void)adjustForDeletionOfItems:(NSIndexSet *)items;
- (void)adjustForInsertionOfItem:(NSUInteger)item;
- (void)adjustForInsertionOfItems:(NSIndexSet *)items;
- (NSIndexSet *)items;
- (NSArray<NSIndexPath *> *)itemIndexPathsForSection:(NSUInteger)section;
- (void)enumerateItemsUsingBlock:(void (NS_NOESCAPE ^)(NSUInteger item, BOOL *stop))block;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
