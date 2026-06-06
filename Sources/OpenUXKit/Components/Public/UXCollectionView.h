#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXCollectionViewDataSource.h>
#import <OpenUXKit/UXCollectionViewDelegate.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionViewLayout, UXCollectionViewLayoutAttributes, UXCollectionReusableView, UXCollectionViewCell;
@protocol UXCollectionViewAccessibilityDelegate;

typedef NS_OPTIONS(NSUInteger, UXCollectionViewScrollPosition) {
    UXCollectionViewScrollPositionNone                 = 0,
    UXCollectionViewScrollPositionTop                  = 1 << 0,
    UXCollectionViewScrollPositionCenteredVertically   = 1 << 1,
    UXCollectionViewScrollPositionBottom               = 1 << 2,
    UXCollectionViewScrollPositionLeft                 = 1 << 3,
    UXCollectionViewScrollPositionCenteredHorizontally = 1 << 4,
    UXCollectionViewScrollPositionRight                = 1 << 5,
} NS_SWIFT_NAME(UXCollectionView.ScrollPosition);

UXKIT_EXTERN NSString *const UXCollectionElementKindCell;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionView : NSScrollView

- (instancetype)initWithFrame:(NSRect)frame collectionViewLayout:(UXCollectionViewLayout *)layout;

@property (nonatomic, weak, nullable) id<UXCollectionViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id<UXCollectionViewDelegate> delegate;
@property (nonatomic, weak, nullable) id<UXCollectionViewAccessibilityDelegate> accessibilityDelegate;
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
@property (nonatomic, strong, nullable) NSIndexPath *lastRightClickedIndexPath;
@property (nonatomic, copy, nullable) void (^scrollingRequest)(void);

#pragma mark - Reload

- (void)reloadData;

#pragma mark - Cell registration

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(nullable NSNib *)nib forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerClass:(nullable Class)viewClass forSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(nullable NSNib *)nib forSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier;

- (nullable Class)registeredClassForCellWithReuseIdentifier:(NSString *)identifier;
- (nullable Class)registeredClassForSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier;

- (__kindof UXCollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
- (__kindof UXCollectionReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Counts

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSUInteger)numberOfVisibleCells;
- (NSUInteger)numberOfContentCells;

#pragma mark - Layout queries

- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Hit testing

- (nullable NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point;
- (nullable NSIndexPath *)indexPathForItemHitByEvent:(NSEvent *)event;
- (nullable NSIndexPath *)indexPathForSupplementaryElementOfKind:(NSString *)kind atPoint:(CGPoint)point;
- (nullable NSIndexPath *)indexPathForSupplementaryElementOfKind:(NSString *)kind hitByEvent:(NSEvent *)event;
- (nullable NSIndexPath *)indexPathForCell:(UXCollectionViewCell *)cell;
- (nullable NSIndexPath *)indexPathForSupplementaryView:(UXCollectionReusableView *)supplementaryView;
- (nullable UXCollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Visible items

- (NSArray<__kindof UXCollectionViewCell *> *)visibleCells;
- (NSArray<__kindof UXCollectionViewCell *> *)contentCells;
- (NSArray<NSIndexPath *> *)indexPathsForVisibleItems;
- (NSArray<NSIndexPath *> *)indexPathsForContentItems;
- (NSArray<NSIndexPath *> *)indexPathsForVisibleItemsInSections:(NSIndexSet *)sections;
- (NSArray<NSIndexPath *> *)indexPathsForContentItemsInSections:(NSIndexSet *)sections;
- (NSArray<__kindof UXCollectionReusableView *> *)visibleSupplementaryViews;
- (NSArray<__kindof UXCollectionReusableView *> *)contentSupplementaryViews;
- (NSArray<NSIndexPath *> *)indexPathsForVisibleSupplementaryElementsOfKind:(NSString *)kind;
- (NSArray<__kindof UXCollectionReusableView *> *)visibleSupplementaryViewsOfKind:(NSString *)kind;
- (nullable UXCollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Navigation

- (nullable NSIndexPath *)nextIndexPath:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)previousIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Selection

- (nullable NSArray<NSIndexPath *> *)indexPathsForSelectedItems;
- (NSUInteger)numberOfSelectedItems;
- (BOOL)selectableItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)selectedItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)selectItemAtIndexPath:(nullable NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UXCollectionViewScrollPosition)scrollPosition;
- (void)selectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths byExtendingSelection:(BOOL)extend animated:(BOOL)animated;
- (void)selectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths byExtendingSelection:(BOOL)extend animated:(BOOL)animated scrollItemAtIndex:(nullable NSIndexPath *)indexPath toPosition:(UXCollectionViewScrollPosition)position;
- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)deselectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths animated:(BOOL)animated;
- (void)selectAllItems:(BOOL)animated;
- (void)deselectAllItems:(BOOL)animated;
- (IBAction)selectAll:(nullable id)sender;
- (IBAction)deselectAll:(nullable id)sender;

#pragma mark - Geometry

@property (nonatomic) CGPoint contentOffset;
@property (nonatomic) CGSize contentSize;
@property (nonatomic) CGRect documentBounds;

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;
- (CGRect)documentContentRect;
- (CGSize)documentSize;
- (CGSize)frameSizeForContentSize:(CGSize)contentSize;
- (CGSize)contentSizeForFrameSize:(CGSize)frameSize;
- (CGPoint)collectionViewPointForLayoutPoint:(CGPoint)layoutPoint;
- (CGPoint)layoutPointForCollectionViewPoint:(CGPoint)collectionViewPoint;

#pragma mark - Scrolling

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UXCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UXCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated userInteractivelyScrolling:(BOOL)userInteractivelyScrolling;
- (void)scrollRect:(CGRect)rect toScrollPosition:(UXCollectionViewScrollPosition)scrollPosition withInsets:(NSEdgeInsets)insets animated:(BOOL)animated;
- (void)resetScrollingOverdraw;
- (void)willStartScrollingFromExternalControl;
- (void)willEndScrollingFromExternalControl;
- (void)didEndScrollingFromExternalControl;

#pragma mark - Updates

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

#pragma mark - Drag and drop

- (NSInteger)allowedDropPositionsForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths movedToIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)dragOperationForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths movedOntoItemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Accessibility

- (void)accessibilitySelectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)accessibilitySelected:(BOOL)selected itemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)accessibilityPerformPressWithItemAtIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - Accessibility delegate

NS_SWIFT_UI_ACTOR
@protocol UXCollectionViewAccessibilityDelegate <NSObject>
@optional
- (nullable NSString *)accessibilityRoleDescriptionForCollectionView:(UXCollectionView *)collectionView;
- (void)collectionView:(UXCollectionView *)collectionView prepareAccessibilitySection:(id)section;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
