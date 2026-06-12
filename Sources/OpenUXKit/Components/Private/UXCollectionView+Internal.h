#import "UXCollectionView.h"

@class UXCollectionViewData, UXCollectionViewUpdate, UXCollectionViewLayoutInvalidationContext, UXCollectionViewIndexPathsSet, UXCollectionViewMutableIndexPathsSet, UXCollectionViewAnimationContext, _UXCollectionViewRearrangingCoordinator;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

NS_SWIFT_UI_ACTOR
@interface UXCollectionView (Internal)

#pragma mark - Data access

- (UXCollectionViewData *)_collectionViewData;
- (BOOL)_dataSourceImplementsNumberOfSections;
- (NSDictionary *)_visibleViewsDict;
- (NSSet<NSString *> *)_supplementaryElementKinds;
- (nullable UXCollectionViewUpdate *)_currentUpdate;

#pragma mark - Suspension / reload helpers

- (void)_suspendReloads;
- (void)_resumeReloads;
- (void)_reloadDataIfNeeded;
- (void)_setNeedsVisibleCellsUpdate:(BOOL)needsUpdate withLayoutAttributes:(BOOL)withAttributes;

#pragma mark - Layout invalidation

- (void)_invalidateLayoutWithContext:(nullable UXCollectionViewLayoutInvalidationContext *)context;
- (void)_invalidateLayoutIfNecessary;

#pragma mark - Visibility

- (CGRect)_visibleBounds;
- (void)_setVisibleBounds:(CGRect)visibleBounds;
- (BOOL)_visible;
- (BOOL)_hasAnyItems;

#pragma mark - Cell / supplementary reuse

- (void)_reuseCell:(UXCollectionViewCell *)cell;
- (void)_reuseSupplementaryView:(UXCollectionReusableView *)view;
- (NSInteger)_numberOfReusedViewsForIdentifier:(NSString *)identifier;
- (NSInteger)_maxNumberOfReusedViews;
- (__kindof UXCollectionReusableView *)_dequeueReusableViewOfKind:(NSString *)kind withIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath viewCategory:(NSUInteger)viewCategory;

#pragma mark - Layout attribute queries

- (NSArray<UXCollectionViewLayoutAttributes *> *)_layoutAttributesForItemsInRect:(CGRect)rect;

#pragma mark - Cell preparation pipeline

- (nullable __kindof UXCollectionViewCell *)_createPreparedCellForItemAtIndexPath:(NSIndexPath *)indexPath withLayoutAttributes:(UXCollectionViewLayoutAttributes *)layoutAttributes applyAttributes:(BOOL)applyAttributes;
- (nullable __kindof UXCollectionReusableView *)_createPreparedSupplementaryViewForElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath withLayoutAttributes:(UXCollectionViewLayoutAttributes *)layoutAttributes applyAttributes:(BOOL)applyAttributes;
- (void)_updateCellsInRect:(CGRect)rect createIfNecessary:(BOOL)createIfNecessary;
- (void)_updateVisibleCellsNow:(BOOL)now;
- (void)_notifyWillDisplayCellIfNeeded:(UXCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
- (void)_notifyDidEndDisplayingCellIfNeeded:(UXCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Selection helpers

- (BOOL)_deselectItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths animated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate;
- (void)_deselectAllAnimated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate;
- (BOOL)_toggleSelectionStateOfItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate;
- (BOOL)_selectItemsInIndexPathsSet:(nullable UXCollectionViewIndexPathsSet *)set byExtendingSelection:(BOOL)extend animated:(BOOL)animated scrollingKeyItem:(nullable NSIndexPath *)key toPosition:(UXCollectionViewScrollPosition)position notifyDelegate:(BOOL)notifyDelegate;
- (BOOL)_selectRangeOfItemsFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath byExtendingSelection:(BOOL)extend animated:(BOOL)animated scroll:(BOOL)scroll toPosition:(UXCollectionViewScrollPosition)position notifyDelegate:(BOOL)notifyDelegate candidateLastSelectedItemIndexPath:(NSIndexPath * _Nullable * _Nullable)candidate;
- (void)_selectAllItems:(BOOL)selectAll notifyDelegate:(BOOL)notifyDelegate;
- (nullable NSIndexPath *)_firstSelectableItemIndexPath;
- (nullable NSIndexPath *)_lastSelectableItemIndexPath;
- (nullable NSIndexPath *)_keyItemIndexPathForItemIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (nullable NSIndexPath *)_keyItemIndexPathForItemIndexPathsSet:(UXCollectionViewIndexPathsSet *)indexPathsSet;
- (BOOL)_performItemSelectionForKey:(uint16_t)key withModifiers:(NSUInteger)modifiers;
- (void)_performItemSelectionForMouseEvent:(NSEvent *)event onCell:(nullable UXCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)_selectableIndexPathForItemContainingHitView:(NSView *)view;
- (nullable NSIndexPath *)_indexPathOfSelectableItemHitByEvent:(NSEvent *)event;
- (nullable NSIndexPath *)_indexPathForSupplementaryElementOfKind:(NSString *)kind hitByEvent:(NSEvent *)event;
- (nullable NSIndexPath *)_indexPathForView:(NSView *)view ofType:(NSUInteger)type;
- (nullable NSView *)_validateHitTest:(nullable NSView *)view;

#pragma mark - Scrolling helpers

- (BOOL)_performScrollingForKey:(uint16_t)key;
- (void)_scrollPage:(BOOL)pageDown;
- (void)_scrollToEnd:(BOOL)end;
- (void)_scrollRect:(CGRect)rect toScrollPosition:(UXCollectionViewScrollPosition)position withInsets:(NSEdgeInsets)insets animated:(BOOL)animated userInteractivelyScrolling:(BOOL)userInteractivelyScrolling;
- (CGPoint)_scrollAmountForMovingRect:(CGRect)movingRect toScrollPosition:(UXCollectionViewScrollPosition)position inDestinationRect:(CGRect)destinationRect;
- (void)_submitScrollingRequest:(void (^)(void))request;

#pragma mark - Visibility helpers

- (nullable __kindof UXCollectionReusableView *)_visibleSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
- (nullable __kindof UXCollectionReusableView *)_visibleSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath isDecorationView:(BOOL)isDecorationView;
- (nullable __kindof UXCollectionReusableView *)_visibleDecorationViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
- (NSArray<__kindof UXCollectionReusableView *> *)_visibleSupplementaryViewsOfKind:(NSString *)kind;
- (NSArray<__kindof UXCollectionReusableView *> *)_supplementaryViewsIncludingOverdrawArea:(BOOL)overdrawArea identifier:(NSString *)identifier;
- (NSArray<NSIndexPath *> *)_indexPathsForVisibleSupplementaryViewsOfKind:(NSString *)kind;
- (NSArray<__kindof UXCollectionViewCell *> *)_cellsIncludingOverdrawArea:(BOOL)overdrawArea;
- (NSDictionary<NSIndexPath *, __kindof UXCollectionViewCell *> *)_dictionaryOfIndexPathsAndContentCells;
- (NSArray<NSIndexPath *> *)_indexPathsForItemsInSections:(NSIndexSet *)sections includingOverdrawArea:(BOOL)overdrawArea;
- (void)_enumerateSupplementaryViewsIncludingOverdrawArea:(BOOL)overdrawArea identifier:(NSString *)identifier usingBlock:(void (^)(UXCollectionReusableView *view, BOOL *stop))block;

#pragma mark - Accessibility

- (nullable NSString *)_retrieveAccessibiltyRoleDescriptionFromAXDelegate;
- (void)_notifyAccessibilityDelegateToPrepareSection:(id)section;

#pragma mark - View lifecycle

- (void)_viewPrepare;
- (void)_viewCleanup;
- (void)_updateFirstResponderView;
- (BOOL)_highlightColorDependsOnWindowState;
- (BOOL)_selectionBorderShouldUsePrimaryColor;

#pragma mark - Rearranging

@property (nonatomic, readonly) BOOL isRearranging_;
@property (nonatomic) BOOL rearrangingEnabled_;
@property (nonatomic) BOOL rearrangingAllowAutoscroll_;
@property (nonatomic) BOOL rearrangingExternalDropEnabled_;
@property (nonatomic) NSInteger rearrangingInitiationMode_;
@property (nonatomic) BOOL rearrangingContinuouslyUpdateInsideCells_;
@property (nonatomic) CGFloat rearrangingPreviewDelay_;

- (void)rearrangingCoordinatorReloadLayout_;
- (nullable _UXCollectionViewRearrangingCoordinator *)_rearrangingCoordinator;

#pragma mark - Batch updates

- (void)_beginUpdates;
- (void)_endUpdates;
- (void)_setupCellAnimations;
- (NSArray *)_viewAnimationsForCurrentUpdate;
- (void)_updateAnimationDidStop:(nullable NSString *)animationID finished:(NSNumber *)finished context:(UXCollectionViewAnimationContext *)context;
- (void)_endItemAnimations;
- (void)_prepareLayoutForUpdates;
- (NSMutableArray *)_arrayForUpdateAction:(NSInteger)updateAction;
- (void)_updateRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths updateAction:(NSInteger)updateAction;
- (void)_updateSections:(NSIndexSet *)sections updateAction:(NSInteger)updateAction;
- (void)_updateWithItems:(NSArray *)items;

#pragma mark - Dictionary helpers

- (void)_addEntriesFromDictionary:(NSDictionary *)source inDictionary:(NSMutableDictionary *)destination;
- (void)_addEntriesFromDictionary:(NSDictionary *)source inDictionary:(NSMutableDictionary *)destination andSet:(NSMutableSet *)set;
- (NSArray *)_keysForObject:(id)object inDictionary:(NSDictionary *)dictionary;
- (nullable id)_objectInDictionary:(NSDictionary *)dictionary forKind:(NSString *)kind indexPath:(NSIndexPath *)indexPath;
- (void)_setObject:(nullable id)object inDictionary:(NSMutableDictionary *)dictionary forKind:(NSString *)kind indexPath:(NSIndexPath *)indexPath;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
