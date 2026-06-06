#import <Foundation/Foundation.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewIndexPathsSet : NSObject <NSCopying, NSMutableCopying>

+ (instancetype)indexPathsSet;
+ (instancetype)indexPathsSetWithIndexPath:(NSIndexPath *)indexPath;
+ (instancetype)indexPathsSetWithIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
+ (instancetype)indexPathsSetWithIndexPathsSet:(UXCollectionViewIndexPathsSet *)indexPathsSet;

- (instancetype)initWithIndexPath:(nullable NSIndexPath *)indexPath;
- (instancetype)initWithIndexPaths:(nullable NSArray<NSIndexPath *> *)indexPaths;
- (instancetype)initWithIndexPathsSet:(nullable UXCollectionViewIndexPathsSet *)indexPathsSet;

@property (nonatomic, readonly) NSUInteger count;

- (NSIndexSet *)sections;
- (NSArray<NSIndexPath *> *)allIndexPaths;
- (BOOL)containsIndexPath:(nullable NSIndexPath *)indexPath;
- (NSIndexSet *)itemsInSection:(NSInteger)section;
- (void)enumerateIndexPathsUsingBlock:(void (NS_NOESCAPE ^)(NSIndexPath *indexPath, BOOL *stop))block;
- (nullable NSIndexPath *)firstIndexPath;
- (nullable NSIndexPath *)lastIndexPath;
- (NSArray<NSIndexPath *> *)indexPathsForSection:(NSInteger)section;
- (NSArray<NSIndexPath *> *)indexPathsForSections:(NSIndexSet *)sections;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
