

#import <AppKit/NSScrollView.h>

@class CALayer, NSArray, NSHashTable, NSIndexPath, NSMutableArray, NSMutableDictionary, NSMutableSet, NSObject, UXCollectionDocumentView, UXCollectionViewData, UXCollectionViewIndexPathsSet, UXCollectionViewLayout, UXCollectionViewMutableIndexPathsSet, UXCollectionViewUpdate, _UXCollectionViewRearrangingCoordinator;
@protocol UXCollectionViewAccessibilityDelegate, UXCollectionViewDataSource, UXCollectionViewDelegate;

@interface UXCollectionView : NSScrollView
{
    UXCollectionDocumentView *_collectionDocumentView;	// 128 = 0x80
    UXCollectionViewLayout *_layout;	// 136 = 0x88
    UXCollectionViewMutableIndexPathsSet *_indexPathsForSelectedItems;	// 144 = 0x90
    NSHashTable *_notifiedDisplayedCells;	// 152 = 0x98
    NSMutableDictionary *_cellReuseQueues;	// 160 = 0xa0
    NSMutableDictionary *_supplementaryViewReuseQueues;	// 168 = 0xa8
    NSInteger _reloadingSuspendedCount;	// 176 = 0xb0
    NSInteger _updateAnimationCount;	// 184 = 0xb8
    NSMutableDictionary *_allVisibleViewsDict;	// 192 = 0xc0
    NSMutableDictionary *_clonedViewsDict;	// 200 = 0xc8
    NSIndexPath *_lastSelectionAnchorIndexPath;	// 208 = 0xd0
    NSIndexPath *_pendingSelectionIndexPath;	// 216 = 0xd8
    UXCollectionViewMutableIndexPathsSet *_pendingDeselectionIndexPaths;	// 224 = 0xe0
    UXCollectionViewData *_collectionViewData;	// 232 = 0xe8
    UXCollectionViewUpdate *_currentUpdate;	// 240 = 0xf0
    CGRect _visibleBounds;	// 248 = 0xf8
    CGRect _previousBounds;	// 280 = 0x118
    CGPoint _resizeBoundsOffset;	// 312 = 0x138
    NSInteger _resizeAnimationCount;	// 328 = 0x148
    NSInteger _updateCount;	// 336 = 0x150
    NSMutableArray *_insertItems;	// 344 = 0x158
    NSMutableArray *_deleteItems;	// 352 = 0x160
    NSMutableArray *_reloadItems;	// 360 = 0x168
    NSMutableArray *_moveItems;	// 368 = 0x170
    NSArray *_originalInsertItems;	// 376 = 0x178
    NSArray *_originalDeleteItems;	// 384 = 0x180
    id _updateCompletionHandler;	// 392 = 0x188
    NSMutableDictionary *_cellClassDict;	// 400 = 0x190
    NSMutableDictionary *_cellNibDict;	// 408 = 0x198
    NSMutableDictionary *_supplementaryViewClassDict;	// 416 = 0x1a0
    NSMutableDictionary *_supplementaryViewNibDict;	// 424 = 0x1a8
    NSMutableSet *_supplementaryElementKinds;	// 432 = 0x1b0
    BOOL _allowsSelection;	// 440 = 0x1b8
    BOOL _allowsMultipleSelection;	// 441 = 0x1b9
    BOOL _allowsEmptySelection;	// 442 = 0x1ba
    BOOL _allowsContinuousSelection;	// 443 = 0x1bb
    BOOL _allowsPaintingSelection;	// 444 = 0x1bc
    BOOL _allowsLassoSelection;	// 445 = 0x1bd
    BOOL _rightMouseSimulated;	// 446 = 0x1be
    CGSize _minReusedViewSize;	// 448 = 0x1c0
    BOOL _doneFirstLayout;	// 464 = 0x1d0
    CGPoint _lastContentOffset;	// 472 = 0x1d8
    CGSize _contentSize;	// 488 = 0x1e8
    NSInteger _layoutTransitionAnimationCount;	// 504 = 0x1f8
    BOOL _scrolling;	// 512 = 0x200
    BOOL _liveScrolling;	// 513 = 0x201
    NSUInteger _extraNumberOfCellsToPreloadWhenScrollingStopped;	// 520 = 0x208
    NSUInteger _purgingCellsThreshold;	// 528 = 0x210
    BOOL _involvesScrollWheel;	// 536 = 0x218
    BOOL _decelerating;	// 537 = 0x219
    BOOL _canDetectDeceleration;	// 538 = 0x21a
    BOOL _scrollingFromExternalControl;	// 539 = 0x21b
    CGPoint _lastScrollingDistance;	// 544 = 0x220
    float _scrollingVelocity;	// 560 = 0x230
    CGFloat _lastScrollingTime;	// 568 = 0x238
    CGRect _lastPreparedOverdrawContentRect;	// 576 = 0x240
    CGPoint _normalizedSavedScrollViewPosition;	// 608 = 0x260
    BOOL _isPaintingSelectionRunning;	// 624 = 0x270
    BOOL _paintingSelectionType;	// 625 = 0x271
    CALayer *_lassoSelectionLayer;	// 632 = 0x278
    CGPoint _lassoSelectionStartPoint;	// 640 = 0x280
    UXCollectionViewIndexPathsSet *_lassoInitiallySelectedItems;	// 656 = 0x290
    BOOL _lassoInvertsSelection;	// 664 = 0x298
    BOOL _layoutSubviewsOnSetNeedsLayout;	// 665 = 0x299
    UXCollectionViewIndexPathsSet *_keyboardRangeSelectionPreviouslySelectedItems;	// 672 = 0x2a0
    NSIndexPath *_keyboardRangeSelectionFirstSelectedItem;	// 680 = 0x2a8
    NSIndexPath *_keyboardRangeSelectionLastSelectedItem;	// 688 = 0x2b0
    NSMutableDictionary *_CGFloatClickContext;	// 696 = 0x2b8
    _UXCollectionViewRearrangingCoordinator *_rearrangingCoordinator;	// 704 = 0x2c0
    NSInteger _suspendClipViewBoundsDidChange;	// 712 = 0x2c8
    struct {
        unsigned int delegateWillBeginScrolling:1;
        unsigned int delegateDidScroll:1;
        unsigned int delegateDidEndScrolling:1;
        unsigned int delegateDidEndScrollingAnimation:1;
        unsigned int delegateWillBeginDeceleratingTargetContentOffset:1;
        unsigned int delegateDidEndDecelerating:1;
        unsigned int delegateShouldSelectItemAtIndexPath:1;
        unsigned int delegateShouldDeselectItemAtIndexPath:1;
        unsigned int delegateDidSelectItemAtIndexPath:1;
        unsigned int delegateDidDeselectItemAtIndexPath:1;
        unsigned int delegateSelectionWillAddAndRemove:1;
        unsigned int delegateSelectionDidAddAndRemove:1;
        unsigned int delegateSectionsForSelectAllAction:1;
        unsigned int delegateMouseDownWithEvent:1;
        unsigned int delegateItemWasCGFloatClickedAtIndexPathWithEvent:1;
        unsigned int delegateItemWasRightClickedAtIndexPathWithEvent:1;
        unsigned int delegateWillDisplayCell:1;
        unsigned int delegateDidEndDisplayingCellForItemAtIndexPath:1;
        unsigned int delegateDidEndDisplayingSupplementaryViewForElementOfKindAtIndexPath:1;
        unsigned int delegateDidPrepareForOverdraw:1;
        unsigned int delegateTargetContentOffsetForProposedContentOffset:1;
        unsigned int delegateTargetContentOffsetOnResizeForProposedContentOffset:1;
        unsigned int delegateAllowedDropPositionsForItemsAtIndexPathsMovedToIndexPath:1;
        unsigned int delegateDragOperationForItemsAtIndexPathsMovedOntoItemAtIndexPath:1;
        unsigned int dataSourceNumberOfSections:1;
        unsigned int dataSourceViewForSupplementaryElement:1;
        unsigned int reloadSkippedDuringSuspension:1;
        unsigned int scheduledUpdateVisibleCells:1;
        unsigned int scheduledUpdateVisibleCellLayoutAttributes:1;
        unsigned int allowsSelection:1;
        unsigned int allowsMultipleSelection:1;
        unsigned int fadeCellsForBoundsChange:1;
        unsigned int updatingLayout:1;
        unsigned int needsReload:1;
        unsigned int reloading:1;
        unsigned int skipLayoutDuringSnapshotting:1;
        unsigned int skipCellsUpdateDuringResizing:1;
        unsigned int layoutInvalidatedSinceLastCellUpdate:1;
        unsigned int doneFirstLayout:1;
        unsigned int loadingOffscreenViews:1;
        unsigned int updating:1;
        unsigned int accessibilityDelegateShouldPrepareAccessibilitySection:1;
        unsigned int accessibilityDelegateAXRoleDescription:1;
        unsigned int viewIsPrepared:1;
        unsigned int performingHitTest:1;
    } _collectionViewFlags;	// 720 = 0x2d0
    CGPoint _lastLayoutOffset;	// 728 = 0x2d8
    NSObject<UXCollectionViewDataSource> *_dataSource;	// 744 = 0x2e8
    NSObject<UXCollectionViewDelegate> *_delegate;	// 752 = 0x2f0
    NSObject<UXCollectionViewAccessibilityDelegate> *_accessibilityDelegate;	// 760 = 0x2f8
    NSIndexPath *_lastRightClickedIndexPath;	// 768 = 0x300
    id _scrollingRequest;	// 776 = 0x308
}

+ (id)_reuseKeyForSupplementaryViewOfKind:(id)arg1 withReuseIdentifier:(id)arg2;
+ (BOOL)isCompatibleWithResponsiveScrolling;
+ (void)initialize;
+ (Class)documentClass;

@property(copy, nonatomic) id scrollingRequest; // @synthesize scrollingRequest=_scrollingRequest;
@property(strong, nonatomic) NSIndexPath *lastRightClickedIndexPath; // @synthesize lastRightClickedIndexPath=_lastRightClickedIndexPath;
@property(readonly, nonatomic, getter=isDecelerating) BOOL decelerating; // @synthesize decelerating=_decelerating;
@property(nonatomic) NSUInteger purgingCellsThreshold; // @synthesize purgingCellsThreshold=_purgingCellsThreshold;
@property(nonatomic) NSUInteger extraNumberOfCellsToPreloadWhenScrollingStopped; // @synthesize extraNumberOfCellsToPreloadWhenScrollingStopped=_extraNumberOfCellsToPreloadWhenScrollingStopped;
@property(readonly, nonatomic, getter=isScrolling) BOOL scrolling; // @synthesize scrolling=_scrolling;
@property(nonatomic) BOOL allowsPaintingSelection; // @synthesize allowsPaintingSelection=_allowsPaintingSelection;
@property(nonatomic) BOOL allowsLassoSelection; // @synthesize allowsLassoSelection=_allowsLassoSelection;
@property(nonatomic) BOOL allowsContinuousSelection; // @synthesize allowsContinuousSelection=_allowsContinuousSelection;
@property(nonatomic) __weak NSObject<UXCollectionViewDelegate> *delegate; // @synthesize delegate=_delegate;
@property(nonatomic) __weak NSObject<UXCollectionViewDataSource> *dataSource; // @synthesize dataSource=_dataSource;
@property(strong, nonatomic) UXCollectionViewLayout *collectionViewLayout; // @synthesize collectionViewLayout=_layout;
- (BOOL)isLassoSelectionInProgress;
- (BOOL)lassoInvertsSelection;
- (void)setLassoInvertsSelection:(BOOL)arg1;
- (id)accessibilityHitTest:(CGPoint)arg1;
- (BOOL)accessibilityPerformPressWithItemAtIndexPath:(id)arg1;
- (id)accessibilityChildren;
- (id)accessibilityContentSiblingCellFromIndexPath:(id)arg1 direction:(id)arg2;
- (void)keyDown:(id)arg1;
- (BOOL)_performScrollingForKey:(unsigned short)arg1;
- (void)_scrollPage:(BOOL)arg1;
- (void)_scrollToEnd:(BOOL)arg1;
- (BOOL)_performItemSelectionForKey:(unsigned short)arg1 withModifiers:(NSUInteger)arg2;
- (void)mouseUp:(id)arg1;
- (void)mouseDragged:(id)arg1;
- (void)rightMouseDown:(id)arg1;
- (void)accessibilitySelectItemsAtIndexPaths:(id)arg1;
- (void)accessibilitySelected:(BOOL)arg1 itemAtIndexPath:(id)arg2;
- (id)_retrieveAccessibiltyRoleDescriptionFromAXDelegate;
- (void)_notifyAccessibilityDelegateToPrepareSection:(id)arg1;
- (void)mouseDown:(id)arg1;
- (id)menuForEvent:(id)arg1;
- (id)_indexPathForSupplementaryElementOfKind:(id)arg1 hitByEvent:(id)arg2;
- (id)_indexPathOfSelectableItemHitByEvent:(id)arg1;
- (void)_respondToCGFloatClick;
- (void)_performItemSelectionForMouseEvent:(id)arg1 onCell:(id)arg2 atIndexPath:(id)arg3;
- (id)_selectableIndexPathForItemContainingHitView:(id)arg1;
- (BOOL)_hasAnyItems;
- (void)deselectAll:(id)arg1;
- (void)selectAll:(id)arg1;
- (BOOL)validateUserInterfaceItem:(id)arg1;
- (void)performBatchUpdates:(id)arg1 completion:(id)arg2;
- (void)_endUpdates;
- (void)_beginUpdates;
- (void)_updateAnimationDidStop:(id)arg1 finished:(id)arg2 context:(id)arg3;
- (void)_updateWithItems:(id)arg1;
- (id)_viewAnimationsForCurrentUpdate;
- (void)_prepareLayoutForUpdates;
- (void)_endItemAnimations;
- (void)_setupCellAnimations;
- (void)moveItemAtIndexPath:(id)arg1 toIndexPath:(id)arg2;
- (void)reloadItemsAtIndexPaths:(id)arg1;
- (void)deleteItemsAtIndexPaths:(id)arg1;
- (void)insertItemsAtIndexPaths:(id)arg1;
- (void)_updateRowsAtIndexPaths:(id)arg1 updateAction:(NSInteger)arg2;
- (void)moveSection:(NSInteger)arg1 toSection:(NSInteger)arg2;
- (void)reloadSections:(id)arg1;
- (void)deleteSections:(id)arg1;
- (void)insertSections:(id)arg1;
- (void)_updateSections:(id)arg1 updateAction:(NSInteger)arg2;
- (id)_arrayForUpdateAction:(NSInteger)arg1;
- (id)_currentUpdate;
- (void)scrollRect:(CGRect)arg1 toScrollPosition:(NSUInteger)arg2 withInsets:(NSEdgeInsets)arg3 animated:(BOOL)arg4;
- (void)scrollToItemAtIndexPath:(id)arg1 atScrollPosition:(NSUInteger)arg2 animated:(BOOL)arg3;
- (void)scrollToItemAtIndexPath:(id)arg1 atScrollPosition:(NSUInteger)arg2 animated:(BOOL)arg3 userInteractivelyScrolling:(BOOL)arg4;
- (void)_scrollRect:(CGRect)arg1 toScrollPosition:(NSUInteger)arg2 withInsets:(NSEdgeInsets)arg3 animated:(BOOL)arg4 userInteractivelyScrolling:(BOOL)arg5;
- (CGPoint)_scrollAmountForMovingRect:(CGRect)arg1 toScrollPosition:(NSUInteger)arg2 inDestinationRect:(CGRect)arg3;
- (id)nextIndexPath:(id)arg1;
- (id)previousIndexPath:(id)arg1;
- (id)contentSupplementaryViews;
- (id)visibleSupplementaryViews;
- (id)_indexPathsForVisibleSupplementaryViewsOfKind:(id)arg1;
- (id)_visibleSupplementaryViewsOfKind:(id)arg1;
- (id)_supplementaryViewsIncludingOverdrawArea:(BOOL)arg1 identifier:(id)arg2;
- (void)_enumerateSupplementaryViewsIncludingOverdrawArea:(BOOL)arg1 identifier:(id)arg2 usingBlock:(id)arg3;
- (id)indexPathsForContentItemsInSections:(id)arg1;
- (id)indexPathsForContentItems;
- (id)indexPathsForVisibleItemsInSections:(id)arg1;
- (id)indexPathsForVisibleItems;
- (id)_indexPathsForItemsInSections:(id)arg1 includingOverdrawArea:(BOOL)arg2;
- (id)contentCells;
- (id)visibleCells;
- (id)_cellsIncludingOverdrawArea:(BOOL)arg1;
- (id)_dictionaryOfIndexPathsAndContentCells;
- (NSUInteger)numberOfContentCells;
- (NSUInteger)numberOfVisibleCells;
- (id)indexPathsForVisibleSupplementaryElementsOfKind:(id)arg1;
- (id)visibleSupplementaryViewsOfKind:(id)arg1;
- (id)viewForSupplementaryElementOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)cellForItemAtIndexPath:(id)arg1;
- (id)indexPathForSupplementaryView:(id)arg1;
- (id)indexPathForCell:(id)arg1;
- (id)_indexPathForView:(id)arg1 ofType:(NSUInteger)arg2;
- (id)indexPathForSupplementaryElementOfKind:(id)arg1 atPoint:(CGPoint)arg2;
- (id)indexPathForSupplementaryElementOfKind:(id)arg1 hitByEvent:(id)arg2;
- (id)indexPathForItemAtPoint:(CGPoint)arg1;
- (id)indexPathForItemHitByEvent:(id)arg1;
- (id)layoutAttributesForSupplementaryElementOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)layoutAttributesForItemAtIndexPath:(id)arg1;
- (NSInteger)numberOfItemsInSection:(NSInteger)arg1;
- (NSInteger)numberOfSections;
- (void)_prepareCellsForOverdraw:(CGRect)arg1;
- (void)resetScrollingOverdraw;
- (CGRect)documentContentRect;
- (void)_addControlled:(BOOL)arg1 subview:(id)arg2 atZIndex:(NSInteger)arg3;
- (void)updateLayout;
- (void)_setCollectionViewLayout:(id)arg1 animated:(BOOL)arg2 isInteractive:(BOOL)arg3 completion:(id)arg4;
- (void)setCollectionViewLayout:(id)arg1 animated:(BOOL)arg2 completion:(id)arg3;
- (void)setCollectionViewLayout:(id)arg1 animated:(BOOL)arg2;
- (void)_reuseSupplementaryView:(id)arg1;
- (void)_reuseCell:(id)arg1;
- (NSInteger)_maxNumberOfReusedViews;
- (NSInteger)_numberOfReusedViewsForIdentifier:(id)arg1;
- (id)dequeueReusableSupplementaryViewOfKind:(id)arg1 withReuseIdentifier:(id)arg2 forIndexPath:(id)arg3;
- (id)dequeueReusableCellWithReuseIdentifier:(id)arg1 forIndexPath:(id)arg2;
- (id)_dequeueReusableViewOfKind:(id)arg1 withIdentifier:(id)arg2 forIndexPath:(id)arg3 viewCategory:(NSUInteger)arg4;
- (void)registerNib:(id)arg1 forSupplementaryViewOfKind:(id)arg2 withReuseIdentifier:(id)arg3;
- (void)registerClass:(Class)arg1 forSupplementaryViewOfKind:(id)arg2 withReuseIdentifier:(id)arg3;
- (Class)registeredClassForSupplementaryViewOfKind:(id)arg1 withReuseIdentifier:(id)arg2;
- (void)registerNib:(id)arg1 forCellWithReuseIdentifier:(id)arg2;
- (void)registerClass:(Class)arg1 forCellWithReuseIdentifier:(id)arg2;
- (Class)registeredClassForCellWithReuseIdentifier:(id)arg1;
- (BOOL)_visible;
- (void)layoutSubviews;
- (void)layout;
- (CGSize)contentSizeForFrameSize:(CGSize)arg1;
- (CGSize)frameSizeForContentSize:(CGSize)arg1;
- (void)windowDidResignKey:(id)arg1;
- (void)windowDidBecomeKey:(id)arg1;
- (void)windowDidChangeBackingProperties:(id)arg1;
- (void)clipViewBoundsDidChange:(id)arg1;
- (void)touchesEndedWithEvent:(id)arg1;
- (void)touchesBeganWithEvent:(id)arg1;
- (void)_didEndScrollingAnimation;
- (void)didEndScrollingFromExternalControl;
- (void)willEndScrollingFromExternalControl;
- (void)willStartScrollingFromExternalControl;
- (void)scrollViewDidEndLiveScrollNotification:(id)arg1;
- (void)scrollViewWillStartLiveScrollNotification:(id)arg1;
- (void)_didEndScrolling:(id)arg1;
- (void)_willStartScrolling:(id)arg1;
- (void)scrollWheel:(id)arg1;
- (void)setContentOffset:(CGPoint)arg1 animated:(BOOL)arg2;
- (void)setContentOffset:(CGPoint)arg1;
- (void)_submitScrollingRequest:(id)arg1;
@property(nonatomic) CGSize contentSize; // @dynamic contentSize;
- (void)setDocumentBounds:(CGRect)arg1;
- (CGRect)documentBounds;
- (CGSize)documentSize;
- (CGPoint)contentOffset;
- (BOOL)wantsUpdateLayer;
- (BOOL)isOpaque;
- (void)viewWillMoveToSuperview:(id)arg1;
- (void)viewDidMoveToWindow;
- (void)viewWillMoveToWindow:(id)arg1;
- (void)_viewPrepare;
- (void)_viewCleanup;
- (BOOL)shouldDelayWindowOrderingForEvent:(id)arg1;
- (BOOL)acceptsFirstMouse:(id)arg1;
- (id)hitTest:(CGPoint)arg1;
- (id)_validateHitTest:(id)arg1;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
- (void)_updateFirstResponderView;
- (BOOL)_selectionBorderShouldUsePrimaryColor;
- (BOOL)_highlightColorDependsOnWindowState;
- (id)_CGFloatSidedAnimationsForView:(id)arg1 withStartingLayoutAttributes:(id)arg2 startingLayout:(id)arg3 endingLayoutAttributes:(id)arg4 endingLayout:(id)arg5 withAnimationSetup:(id)arg6 animationCompletion:(id)arg7 enableCustomAnimations:(BOOL)arg8 customAnimationsType:(NSUInteger)arg9;
- (void)_updateCellsInRect:(CGRect)arg1 createIfNecessary:(BOOL)arg2;
- (void)_updateVisibleCellsNow:(BOOL)arg1;
- (id)_createPreparedSupplementaryViewForElementOfKind:(id)arg1 atIndexPath:(id)arg2 withLayoutAttributes:(id)arg3 applyAttributes:(BOOL)arg4;
- (id)_createPreparedCellForItemAtIndexPath:(id)arg1 withLayoutAttributes:(id)arg2 applyAttributes:(BOOL)arg3;
- (void)_notifyDidEndDisplayingCellIfNeeded:(id)arg1 forIndexPath:(id)arg2;
- (void)_notifyWillDisplayCellIfNeeded:(id)arg1 forIndexPath:(id)arg2;
- (CGPoint)layoutPointForCollectionViewPoint:(CGPoint)arg1;
- (CGPoint)collectionViewPointForLayoutPoint:(CGPoint)arg1;
- (void)setScrollerStyle:(NSInteger)arg1;
- (void)_setVisibleBounds:(CGRect)arg1;
- (CGRect)_visibleBounds;
- (void)setContentInsets:(NSEdgeInsets)arg1;
- (void)setFrame:(CGRect)arg1;
- (void)setBounds:(CGRect)arg1;
- (CGPoint)_contentOffsetForNewFrame:(CGRect)arg1 oldFrame:(CGRect)arg2 newContentSize:(CGSize)arg3 andOldContentSize:(CGSize)arg4;
- (BOOL)layoutSubviewsOnSetNeedsLayout;
- (void)setLayoutSubviewsOnSetNeedsLayout:(BOOL)arg1;
- (BOOL)isBusy;
- (void)_invalidateLayoutWithContext:(id)arg1;
- (void)_invalidateLayoutIfNecessary;
- (void)reloadData;
- (void)_setNeedsVisibleCellsUpdate:(BOOL)arg1 withLayoutAttributes:(BOOL)arg2;
- (void)_resumeReloads;
- (void)_suspendReloads;
- (void)setNeedsLayout;
@property(nonatomic) BOOL allowsEmptySelection; // @synthesize allowsEmptySelection=_allowsEmptySelection;
@property(nonatomic) BOOL allowsMultipleSelection; // @synthesize allowsMultipleSelection=_allowsMultipleSelection;
@property(nonatomic) BOOL allowsSelection; // @synthesize allowsSelection=_allowsSelection;
- (void)deselectAllItems:(BOOL)arg1;
- (void)_selectAllItems:(BOOL)arg1 notifyDelegate:(BOOL)arg2;
- (void)selectAllItems:(BOOL)arg1;
- (void)deselectItemsAtIndexPaths:(id)arg1 animated:(BOOL)arg2;
- (void)deselectItemAtIndexPath:(id)arg1 animated:(BOOL)arg2;
- (BOOL)_toggleSelectionStateOfItemAtIndexPath:(id)arg1 animated:(BOOL)arg2 notifyDelegate:(BOOL)arg3;
- (BOOL)_deselectItemsAtIndexPaths:(id)arg1 animated:(BOOL)arg2 notifyDelegate:(BOOL)arg3;
- (void)selectItemsAtIndexPaths:(id)arg1 byExtendingSelection:(BOOL)arg2 animated:(BOOL)arg3 scrollItemAtIndex:(id)arg4 toPosition:(NSUInteger)arg5;
- (void)selectItemsAtIndexPaths:(id)arg1 byExtendingSelection:(BOOL)arg2 animated:(BOOL)arg3;
- (void)selectItemAtIndexPath:(id)arg1 animated:(BOOL)arg2 scrollPosition:(NSUInteger)arg3;
- (void)_deselectAllAnimated:(BOOL)arg1 notifyDelegate:(BOOL)arg2;
- (BOOL)_selectRangeOfItemsFromIndexPath:(id)arg1 toIndexPath:(id)arg2 byExtendingSelection:(BOOL)arg3 animated:(BOOL)arg4 scroll:(BOOL)arg5 toPosition:(NSUInteger)arg6 notifyDelegate:(BOOL)arg7 candidateLastSelectedItemIndexPath:(id *)arg8;
- (BOOL)_selectItemsInIndexPathsSet:(id)arg1 byExtendingSelection:(BOOL)arg2 animated:(BOOL)arg3 scrollingKeyItem:(id)arg4 toPosition:(NSUInteger)arg5 notifyDelegate:(BOOL)arg6;
- (id)_firstSelectableItemIndexPath;
- (BOOL)selectedItemAtIndexPath:(id)arg1;
- (BOOL)selectableItemAtIndexPath:(id)arg1;
- (NSUInteger)numberOfSelectedItems;
- (id)_keyItemIndexPathForItemIndexPathsSet:(id)arg1;
- (id)_keyItemIndexPathForItemIndexPaths:(id)arg1;
- (id)_visibleViewsDict;
- (id)_collectionViewData;
- (id)_layoutAttributesForItemsInRect:(CGRect)arg1;
- (id)indexPathsForSelectedItems;
- (BOOL)_dataSourceImplementsNumberOfSections;
- (void)_reloadDataIfNeeded;
@property(nonatomic) __weak NSObject<UXCollectionViewAccessibilityDelegate> *accessibilityDelegate; // @synthesize accessibilityDelegate=_accessibilityDelegate;
- (id)_visibleDecorationViewOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)_visibleSupplementaryViewOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)_visibleSupplementaryViewOfKind:(id)arg1 atIndexPath:(id)arg2 isDecorationView:(BOOL)arg3;
- (id)_keysForObject:(id)arg1 inDictionary:(id)arg2;
- (void)_addEntriesFromDictionary:(id)arg1 inDictionary:(id)arg2;
- (void)_addEntriesFromDictionary:(id)arg1 inDictionary:(id)arg2 andSet:(id)arg3;
- (void)_setObject:(id)arg1 inDictionary:(id)arg2 forKind:(id)arg3 indexPath:(id)arg4;
- (id)_objectInDictionary:(id)arg1 forKind:(id)arg2 indexPath:(id)arg3;
- (id)description;
- (void)dealloc;
- (id)initWithCoder:(id)arg1;
- (id)initWithFrame:(CGRect)arg1 collectionViewLayout:(id)arg2;
- (id)initWithFrame:(CGRect)arg1;
- (void)updateDraggingItemsForDrag:(id)arg1;
- (BOOL)wantsPeriodicDraggingUpdates;
- (void)draggingEnded:(id)arg1;
- (void)concludeDragOperation:(id)arg1;
- (BOOL)performDragOperation:(id)arg1;
- (BOOL)prepareForDragOperation:(id)arg1;
- (void)draggingExited:(id)arg1;
- (NSUInteger)draggingUpdated:(id)arg1;
- (NSUInteger)draggingEntered:(id)arg1;
- (void)draggingSession:(id)arg1 endedAtPoint:(CGPoint)arg2 operation:(NSUInteger)arg3;
- (void)draggingSession:(id)arg1 movedToPoint:(CGPoint)arg2;
- (void)draggingSession:(id)arg1 willBeginAtPoint:(CGPoint)arg2;
- (NSUInteger)draggingSession:(id)arg1 sourceOperationMaskForDraggingContext:(NSInteger)arg2;
- (NSUInteger)dragOperationForItemsAtIndexPaths:(id)arg1 movedOntoItemAtIndexPath:(id)arg2;
- (NSInteger)allowedDropPositionsForItemsAtIndexPaths:(id)arg1 movedToIndexPath:(id)arg2;
- (void)rearrangingCoordinatorReloadLayout_;
@property(readonly, nonatomic) BOOL isRearranging_;
@property(nonatomic) CGFloat rearrangingPreviewDelay_;
@property(nonatomic) BOOL rearrangingContinuouslyUpdateInsideCells_;
@property(nonatomic) NSInteger rearrangingInitiationMode_;
@property(nonatomic) BOOL rearrangingExternalDropEnabled_;
@property(nonatomic) BOOL rearrangingAllowAutoscroll_;
@property(nonatomic) BOOL rearrangingEnabled_;
- (id)_rearrangingCoordinator;
- (void)setContentInset:(NSEdgeInsets)arg1;
- (NSEdgeInsets)contentInset;

@end

