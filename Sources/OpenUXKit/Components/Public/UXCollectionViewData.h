#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionView, UXCollectionViewLayout, UXCollectionViewLayoutAttributes;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewData : NSObject

- (instancetype)initWithCollectionView:(UXCollectionView *)collectionView layout:(UXCollectionViewLayout *)layout;

@property (nonatomic, readonly) NSArray<UXCollectionViewLayoutAttributes *> *clonedLayoutAttributes;
@property (nonatomic, getter=isLayoutLocked) BOOL layoutLocked;
@property (nonatomic, readonly) BOOL layoutIsPrepared;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItems;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSInteger)numberOfItemsBeforeSection:(NSInteger)section;

- (NSInteger)globalIndexForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)indexPathForItemAtGlobalIndex:(NSInteger)globalIndex;

- (CGRect)collectionViewContentRect;
- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)rectForGlobalItemIndex:(NSInteger)globalIndex;
- (CGRect)rectForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
- (CGRect)rectForDecorationElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForGlobalItemIndex:(NSInteger)globalIndex;
- (nullable NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInSection:(NSInteger)section;
- (nullable NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect;
- (nullable NSArray<UXCollectionViewLayoutAttributes *> *)existingSupplementaryLayoutAttributes;
- (nullable NSArray<UXCollectionViewLayoutAttributes *> *)existingSupplementaryLayoutAttributesWithMinimalIndexPathLength:(NSUInteger)length;
- (nullable NSArray<UXCollectionViewLayoutAttributes *> *)existingSupplementaryLayoutAttributesInSection:(NSInteger)section;
- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

- (nullable NSSet<NSString *> *)knownSupplementaryElementKinds;
- (nullable NSSet<NSString *> *)knownDecorationElementKinds;

- (void)validateLayoutInRect:(CGRect)rect;
- (void)validateSupplementaryViews;
- (void)invalidate:(BOOL)keepItemCounts;
- (void)invalidateSupplementaryViews:(nullable NSSet<NSString *> *)kinds;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
