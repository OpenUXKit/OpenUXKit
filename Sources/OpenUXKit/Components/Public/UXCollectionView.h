#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXCollectionViewDataSource.h>
#import <OpenUXKit/UXCollectionViewDelegate.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionViewLayout, UXCollectionViewLayoutAttributes, UXCollectionReusableView, UXCollectionViewCell, UXCollectionViewData, UXCollectionViewUpdate, UXCollectionDocumentView, UXCollectionViewIndexPathsSet, UXCollectionViewMutableIndexPathsSet;

typedef NS_OPTIONS(NSUInteger, UXCollectionViewScrollPosition) {
    UXCollectionViewScrollPositionNone                = 0,
    UXCollectionViewScrollPositionTop                 = 1 << 0,
    UXCollectionViewScrollPositionCenteredVertically  = 1 << 1,
    UXCollectionViewScrollPositionBottom              = 1 << 2,
    UXCollectionViewScrollPositionLeft                = 1 << 3,
    UXCollectionViewScrollPositionCenteredHorizontally = 1 << 4,
    UXCollectionViewScrollPositionRight               = 1 << 5,
};

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionView : NSScrollView

- (instancetype)initWithFrame:(NSRect)frame collectionViewLayout:(UXCollectionViewLayout *)layout;

@property (nonatomic, weak, nullable) id<UXCollectionViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id<UXCollectionViewDelegate> delegate;
@property (nonatomic, weak, nullable) id accessibilityDelegate;
@property (nonatomic, strong) UXCollectionViewLayout *collectionViewLayout;

@property (nonatomic) BOOL allowsSelection;
@property (nonatomic) BOOL allowsMultipleSelection;
@property (nonatomic) BOOL allowsEmptySelection;
@property (nonatomic) BOOL allowsContinuousSelection;
@property (nonatomic) BOOL allowsPaintingSelection;
@property (nonatomic) BOOL allowsLassoSelection;
@property (nonatomic) BOOL lassoInvertsSelection;
@property (nonatomic, readonly, getter=isLassoSelectionInProgress) BOOL lassoSelectionInProgress;
@property (nonatomic, readonly, getter=isScrolling) BOOL scrolling;
@property (nonatomic, readonly, getter=isDecelerating) BOOL decelerating;
@property (nonatomic) NSUInteger purgingCellsThreshold;
@property (nonatomic) NSUInteger extraNumberOfCellsToPreloadWhenScrollingStopped;
@property (nonatomic) BOOL layoutSubviewsOnSetNeedsLayout;

- (void)reloadData;

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(nullable NSNib *)nib forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerClass:(nullable Class)viewClass forSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(nullable NSNib *)nib forSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier;

- (nullable Class)registeredClassForCellWithReuseIdentifier:(NSString *)identifier;
- (nullable Class)registeredClassForSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier;

- (__kindof UXCollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
- (__kindof UXCollectionReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

- (nullable NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point;
- (nullable NSIndexPath *)indexPathForCell:(UXCollectionViewCell *)cell;
- (nullable NSIndexPath *)indexPathForSupplementaryView:(UXCollectionReusableView *)supplementaryView;
- (nullable UXCollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSArray<__kindof UXCollectionViewCell *> *)visibleCells;
- (NSArray<NSIndexPath *> *)indexPathsForVisibleItems;
- (NSArray<__kindof UXCollectionReusableView *> *)visibleSupplementaryViews;
- (NSArray<NSIndexPath *> *)indexPathsForVisibleSupplementaryElementsOfKind:(NSString *)kind;
- (NSArray<__kindof UXCollectionReusableView *> *)visibleSupplementaryViewsOfKind:(NSString *)kind;
- (nullable UXCollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

- (nullable NSArray<NSIndexPath *> *)indexPathsForSelectedItems;
- (NSUInteger)numberOfSelectedItems;
- (BOOL)selectableItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)selectedItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)selectItemAtIndexPath:(nullable NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UXCollectionViewScrollPosition)scrollPosition;
- (void)selectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths byExtendingSelection:(BOOL)extend animated:(BOOL)animated;
- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)deselectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths animated:(BOOL)animated;
- (void)selectAllItems:(BOOL)animated;
- (void)deselectAllItems:(BOOL)animated;

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UXCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;

- (void)insertSections:(NSIndexSet *)sections;
- (void)deleteSections:(NSIndexSet *)sections;
- (void)reloadSections:(NSIndexSet *)sections;
- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection;

- (void)insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)performBatchUpdates:(nullable void (^)(void))updates completion:(nullable void (^)(BOOL finished))completion;

- (void)setCollectionViewLayout:(UXCollectionViewLayout *)layout animated:(BOOL)animated;
- (void)setCollectionViewLayout:(UXCollectionViewLayout *)layout animated:(BOOL)animated completion:(nullable void (^)(BOOL finished))completion;

- (void)updateLayout;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
