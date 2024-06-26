/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import <AppKit/NSScrollView.h>

@protocol UXCollectionViewDataSource, UXCollectionViewDelegate, UXCollectionViewAccessibilityDelegate;
@class UXCollectionDocumentView, UXCollectionViewLayout, UXCollectionViewMutableIndexPathsSet, NSHashTable, NSMutableDictionary, NSIndexPath, UXCollectionViewData, UXCollectionViewUpdate, NSMutableArray, NSArray, NSMutableSet, CALayer, UXCollectionViewIndexPathsSet, _UXCollectionViewRearrangingCoordinator, NSObject;

@interface UXCollectionView : NSScrollView {

	UXCollectionDocumentView* _collectionDocumentView;
	UXCollectionViewLayout* _layout;
	UXCollectionViewMutableIndexPathsSet* _indexPathsForSelectedItems;
	NSHashTable* _notifiedDisplayedCells;
	NSMutableDictionary* _cellReuseQueues;
	NSMutableDictionary* _supplementaryViewReuseQueues;
	long long _reloadingSuspendedCount;
	long long _updateAnimationCount;
	NSMutableDictionary* _allVisibleViewsDict;
	NSMutableDictionary* _clonedViewsDict;
	NSIndexPath* _lastSelectionAnchorIndexPath;
	NSIndexPath* _pendingSelectionIndexPath;
	UXCollectionViewMutableIndexPathsSet* _pendingDeselectionIndexPaths;
	UXCollectionViewData* _collectionViewData;
	UXCollectionViewUpdate* _currentUpdate;
	CGRect _visibleBounds;
	CGRect _previousBounds;
	CGPoint _resizeBoundsOffset;
	long long _resizeAnimationCount;
	long long _updateCount;
	NSMutableArray* _insertItems;
	NSMutableArray* _deleteItems;
	NSMutableArray* _reloadItems;
	NSMutableArray* _moveItems;
	NSArray* _originalInsertItems;
	NSArray* _originalDeleteItems;
	/*^block*/id _updateCompletionHandler;
	NSMutableDictionary* _cellClassDict;
	NSMutableDictionary* _cellNibDict;
	NSMutableDictionary* _supplementaryViewClassDict;
	NSMutableDictionary* _supplementaryViewNibDict;
	NSMutableSet* _supplementaryElementKinds;
	BOOL _allowsSelection;
	BOOL _allowsMultipleSelection;
	BOOL _allowsEmptySelection;
	BOOL _allowsContinuousSelection;
	BOOL _allowsPaintingSelection;
	BOOL _allowsLassoSelection;
	BOOL _rightMouseSimulated;
	CGSize _minReusedViewSize;
	BOOL _doneFirstLayout;
	CGPoint _lastContentOffset;
	CGSize _contentSize;
	long long _layoutTransitionAnimationCount;
	BOOL _scrolling;
	BOOL _liveScrolling;
	unsigned long long _extraNumberOfCellsToPreloadWhenScrollingStopped;
	unsigned long long _purgingCellsThreshold;
	BOOL _involvesScrollWheel;
	BOOL _decelerating;
	BOOL _canDetectDeceleration;
	BOOL _scrollingFromExternalControl;
	CGPoint _lastScrollingDistance;
	float _scrollingVelocity;
	double _lastScrollingTime;
	CGRect _lastPreparedOverdrawContentRect;
	CGPoint _normalizedSavedScrollViewPosition;
	BOOL _isPaintingSelectionRunning;
	BOOL _paintingSelectionType;
	CALayer* _lassoSelectionLayer;
	CGPoint _lassoSelectionStartPoint;
	UXCollectionViewIndexPathsSet* _lassoInitiallySelectedItems;
	BOOL _lassoInvertsSelection;
	BOOL _layoutSubviewsOnSetNeedsLayout;
	UXCollectionViewIndexPathsSet* _keyboardRangeSelectionPreviouslySelectedItems;
	NSIndexPath* _keyboardRangeSelectionFirstSelectedItem;
	NSIndexPath* _keyboardRangeSelectionLastSelectedItem;
	NSMutableDictionary* _doubleClickContext;
	_UXCollectionViewRearrangingCoordinator* _rearrangingCoordinator;
	long long _suspendClipViewBoundsDidChange;
	struct {
		unsigned delegateWillBeginScrolling : 1;
		unsigned delegateDidScroll : 1;
		unsigned delegateDidEndScrolling : 1;
		unsigned delegateDidEndScrollingAnimation : 1;
		unsigned delegateWillBeginDeceleratingTargetContentOffset : 1;
		unsigned delegateDidEndDecelerating : 1;
		unsigned delegateShouldSelectItemAtIndexPath : 1;
		unsigned delegateShouldDeselectItemAtIndexPath : 1;
		unsigned delegateDidSelectItemAtIndexPath : 1;
		unsigned delegateDidDeselectItemAtIndexPath : 1;
		unsigned delegateSelectionWillAddAndRemove : 1;
		unsigned delegateSelectionDidAddAndRemove : 1;
		unsigned delegateSectionsForSelectAllAction : 1;
		unsigned delegateMouseDownWithEvent : 1;
		unsigned delegateItemWasDoubleClickedAtIndexPathWithEvent : 1;
		unsigned delegateItemWasRightClickedAtIndexPathWithEvent : 1;
		unsigned delegateWillDisplayCell : 1;
		unsigned delegateDidEndDisplayingCellForItemAtIndexPath : 1;
		unsigned delegateDidEndDisplayingSupplementaryViewForElementOfKindAtIndexPath : 1;
		unsigned delegateDidPrepareForOverdraw : 1;
		unsigned delegateTargetContentOffsetForProposedContentOffset : 1;
		unsigned delegateTargetContentOffsetOnResizeForProposedContentOffset : 1;
		unsigned delegateAllowedDropPositionsForItemsAtIndexPathsMovedToIndexPath : 1;
		unsigned delegateDragOperationForItemsAtIndexPathsMovedOntoItemAtIndexPath : 1;
		unsigned dataSourceNumberOfSections : 1;
		unsigned dataSourceViewForSupplementaryElement : 1;
		unsigned reloadSkippedDuringSuspension : 1;
		unsigned scheduledUpdateVisibleCells : 1;
		unsigned scheduledUpdateVisibleCellLayoutAttributes : 1;
		unsigned allowsSelection : 1;
		unsigned allowsMultipleSelection : 1;
		unsigned fadeCellsForBoundsChange : 1;
		unsigned updatingLayout : 1;
		unsigned needsReload : 1;
		unsigned reloading : 1;
		unsigned skipLayoutDuringSnapshotting : 1;
		unsigned skipCellsUpdateDuringResizing : 1;
		unsigned layoutInvalidatedSinceLastCellUpdate : 1;
		unsigned doneFirstLayout : 1;
		unsigned loadingOffscreenViews : 1;
		unsigned updating : 1;
		unsigned accessibilityDelegateShouldPrepareAccessibilitySection : 1;
		unsigned accessibilityDelegateAXRoleDescription : 1;
		unsigned viewIsPrepared : 1;
		unsigned performingHitTest : 1;
	}  _collectionViewFlags;
	CGPoint _lastLayoutOffset;
	NSObject<UXCollectionViewDataSource>* _dataSource;
	NSObject<UXCollectionViewDelegate>* _delegate;
	NSObject<UXCollectionViewAccessibilityDelegate>* _accessibilityDelegate;
	NSIndexPath* _lastRightClickedIndexPath;
	/*^block*/id _scrollingRequest;

}

@property (nonatomic) BOOL rearrangingEnabled_; 
@property (nonatomic) BOOL rearrangingAllowAutoscroll_; 
@property (nonatomic) BOOL rearrangingExternalDropEnabled_; 
@property (nonatomic) long long rearrangingInitiationMode_; 
@property (nonatomic) BOOL rearrangingContinuouslyUpdateInsideCells_; 
@property (nonatomic) double rearrangingPreviewDelay_; 
@property (nonatomic, readonly) BOOL isRearranging_; 
@property (nonatomic) CGSize contentSize; 
@property (nonatomic, copy) id scrollingRequest;                                                                 //@synthesize scrollingRequest=_scrollingRequest - In the implementation block
@property (nonatomic, strong) NSIndexPath *lastRightClickedIndexPath;                                            //@synthesize lastRightClickedIndexPath=_lastRightClickedIndexPath - In the implementation block
@property (getter=isScrolling, nonatomic, readonly) BOOL scrolling;                                              //@synthesize scrolling=_scrolling - In the implementation block
@property (getter=isDecelerating, nonatomic, readonly) BOOL decelerating;                                        //@synthesize decelerating=_decelerating - In the implementation block
@property (nonatomic, strong) UXCollectionViewLayout *collectionViewLayout;                                      //@synthesize layout=_layout - In the implementation block
@property (nonatomic, weak) NSObject<UXCollectionViewDataSource> *dataSource;                                    //@synthesize dataSource=_dataSource - In the implementation block
@property (nonatomic, weak) NSObject<UXCollectionViewDelegate> *delegate;                                        //@synthesize delegate=_delegate - In the implementation block
@property (nonatomic) BOOL allowsSelection;                                                                      //@synthesize allowsSelection=_allowsSelection - In the implementation block
@property (nonatomic) BOOL allowsMultipleSelection;                                                              //@synthesize allowsMultipleSelection=_allowsMultipleSelection - In the implementation block
@property (nonatomic) BOOL allowsEmptySelection;                                                                 //@synthesize allowsEmptySelection=_allowsEmptySelection - In the implementation block
@property (nonatomic) BOOL allowsContinuousSelection;                                                            //@synthesize allowsContinuousSelection=_allowsContinuousSelection - In the implementation block
@property (nonatomic) BOOL allowsLassoSelection;                                                                 //@synthesize allowsLassoSelection=_allowsLassoSelection - In the implementation block
@property (nonatomic) BOOL allowsPaintingSelection;                                                              //@synthesize allowsPaintingSelection=_allowsPaintingSelection - In the implementation block
@property (nonatomic) unsigned long long extraNumberOfCellsToPreloadWhenScrollingStopped;                        //@synthesize extraNumberOfCellsToPreloadWhenScrollingStopped=_extraNumberOfCellsToPreloadWhenScrollingStopped - In the implementation block
@property (nonatomic) unsigned long long purgingCellsThreshold;                                                  //@synthesize purgingCellsThreshold=_purgingCellsThreshold - In the implementation block
@property (nonatomic, weak) NSObject<UXCollectionViewAccessibilityDelegate> *accessibilityDelegate;              //@synthesize accessibilityDelegate=_accessibilityDelegate - In the implementation block
+ (void)initialize;
+ (id)_reuseKeyForSupplementaryViewOfKind:(id)arg1 withReuseIdentifier:(id)arg2;
+ (BOOL)isCompatibleWithResponsiveScrolling;
+ (Class)documentClass;
- (void)dealloc;
- (id)description;
- (id)delegate;
- (id)initWithCoder:(id)arg1;
- (void)setDelegate:(id)arg1;
- (void)layout;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void*)arg4;
- (id)_viewAnimationsForCurrentUpdate;
- (void)draggingExited:(id)arg1;
- (void)insertSections:(id)arg1;
- (void)rightMouseDown:(id)arg1;
- (void)setContentSize:(CGSize)arg1;
- (void)_suspendReloads;
- (BOOL)allowsSelection;
- (void)deleteSections:(id)arg1;
- (void)performBatchUpdates:(/*^block*/id)arg1 completion:(/*^block*/id)arg2;
- (void)reloadSections:(id)arg1;
- (id)_arrayForUpdateAction:(long long)arg1;
- (void)_beginUpdates;
- (id)_collectionViewData;
- (CGPoint)_contentOffsetForNewFrame:(CGRect)arg1 oldFrame:(CGRect)arg2 newContentSize:(CGSize)arg3 andOldContentSize:(CGSize)arg4;
- (id)_createPreparedCellForItemAtIndexPath:(id)arg1 withLayoutAttributes:(id)arg2 applyAttributes:(BOOL)arg3;
- (id)_createPreparedSupplementaryViewForElementOfKind:(id)arg1 atIndexPath:(id)arg2 withLayoutAttributes:(id)arg3 applyAttributes:(BOOL)arg4;
- (id)_currentUpdate;
- (BOOL)_dataSourceImplementsNumberOfSections;
- (id)_dequeueReusableViewOfKind:(id)arg1 withIdentifier:(id)arg2 forIndexPath:(id)arg3 viewCategory:(unsigned long long)arg4;
- (BOOL)_deselectItemsAtIndexPaths:(id)arg1 animated:(BOOL)arg2 notifyDelegate:(BOOL)arg3;
- (id)_doubleSidedAnimationsForView:(id)arg1 withStartingLayoutAttributes:(id)arg2 startingLayout:(id)arg3 endingLayoutAttributes:(id)arg4 endingLayout:(id)arg5 withAnimationSetup:(/*^block*/id)arg6 animationCompletion:(/*^block*/id)arg7 enableCustomAnimations:(BOOL)arg8 customAnimationsType:(unsigned long long)arg9;
- (void)_endUpdates;
- (BOOL)_hasAnyItems;
- (BOOL)_highlightColorDependsOnWindowState;
- (id)_indexPathsForVisibleSupplementaryViewsOfKind:(id)arg1;
- (void)_invalidateLayoutWithContext:(id)arg1;
- (id)_layoutAttributesForItemsInRect:(CGRect)arg1;
- (void)_prepareLayoutForUpdates;
- (void)_reloadDataIfNeeded;
- (void)_resumeReloads;
- (void)_reuseCell:(id)arg1;
- (void)_reuseSupplementaryView:(id)arg1;
- (void)_scrollToEnd:(BOOL)arg1;
- (void)_setCollectionViewLayout:(id)arg1 animated:(BOOL)arg2 isInteractive:(BOOL)arg3 completion:(/*^block*/id)arg4;
- (void)_setNeedsVisibleCellsUpdate:(BOOL)arg1 withLayoutAttributes:(BOOL)arg2;
- (void)_setupCellAnimations;
- (void)_updateAnimationDidStop:(id)arg1 finished:(id)arg2 context:(id)arg3;
- (void)_updateFirstResponderView;
- (void)_updateRowsAtIndexPaths:(id)arg1 updateAction:(long long)arg2;
- (void)_updateSections:(id)arg1 updateAction:(long long)arg2;
- (void)_updateVisibleCellsNow:(BOOL)arg1;
- (id)_validateHitTest:(id)arg1;
- (BOOL)_visible;
- (CGRect)_visibleBounds;
- (id)_visibleDecorationViewOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)_visibleSupplementaryViewOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)_visibleSupplementaryViewOfKind:(id)arg1 atIndexPath:(id)arg2 isDecorationView:(BOOL)arg3;
- (id)_visibleSupplementaryViewsOfKind:(id)arg1;
- (BOOL)acceptsFirstMouse:(id)arg1;
- (id)accessibilityChildren;
- (id)accessibilityContents;
- (id)accessibilityDelegate;
- (id)accessibilityHitTest:(CGPoint)arg1;
- (void)accessibilitySelectItemsAtIndexPaths:(id)arg1;
- (BOOL)allowsEmptySelection;
- (BOOL)allowsMultipleSelection;
- (id)collectionViewLayout;
- (void)concludeDragOperation:(id)arg1;
- (NSEdgeInsets)contentInset;
- (CGPoint)contentOffset;
- (id)dataSource;
- (void)deleteItemsAtIndexPaths:(id)arg1;
- (id)dequeueReusableSupplementaryViewOfKind:(id)arg1 withReuseIdentifier:(id)arg2 forIndexPath:(id)arg3;
- (void)deselectAll:(id)arg1;
- (void)draggingEnded:(id)arg1;
- (unsigned long long)draggingEntered:(id)arg1;
- (void)draggingSession:(id)arg1 endedAtPoint:(CGPoint)arg2 operation:(unsigned long long)arg3;
- (void)draggingSession:(id)arg1 movedToPoint:(CGPoint)arg2;
- (unsigned long long)draggingSession:(id)arg1 sourceOperationMaskForDraggingContext:(long long)arg2;
- (void)draggingSession:(id)arg1 willBeginAtPoint:(CGPoint)arg2;
- (unsigned long long)draggingUpdated:(id)arg1;
- (id)hitTest:(CGPoint)arg1;
- (id)indexPathForItemAtPoint:(CGPoint)arg1;
- (id)indexPathsForSelectedItems;
- (id)indexPathsForVisibleItems;
- (id)indexPathsForVisibleSupplementaryElementsOfKind:(id)arg1;
- (id)initWithFrame:(CGRect)arg1;
- (void)insertItemsAtIndexPaths:(id)arg1;
- (BOOL)isBusy;
- (BOOL)isOpaque;
- (void)keyDown:(id)arg1;
- (id)layoutAttributesForItemAtIndexPath:(id)arg1;
- (id)layoutAttributesForSupplementaryElementOfKind:(id)arg1 atIndexPath:(id)arg2;
- (id)menuForEvent:(id)arg1;
- (void)mouseDown:(id)arg1;
- (void)mouseDragged:(id)arg1;
- (void)mouseUp:(id)arg1;
- (void)moveItemAtIndexPath:(id)arg1 toIndexPath:(id)arg2;
- (void)moveSection:(long long)arg1 toSection:(long long)arg2;
- (long long)numberOfItemsInSection:(long long)arg1;
- (long long)numberOfSections;
- (BOOL)performDragOperation:(id)arg1;
- (BOOL)prepareForDragOperation:(id)arg1;
- (void)registerClass:(Class)arg1 forCellWithReuseIdentifier:(id)arg2;
- (void)registerClass:(Class)arg1 forSupplementaryViewOfKind:(id)arg2 withReuseIdentifier:(id)arg3;
- (void)registerNib:(id)arg1 forCellWithReuseIdentifier:(id)arg2;
- (void)registerNib:(id)arg1 forSupplementaryViewOfKind:(id)arg2 withReuseIdentifier:(id)arg3;
- (void)reloadData;
- (void)reloadItemsAtIndexPaths:(id)arg1;
- (void)scrollToItemAtIndexPath:(id)arg1 atScrollPosition:(unsigned long long)arg2 animated:(BOOL)arg3;
- (void)scrollWheel:(id)arg1;
- (void)selectAll:(id)arg1;
- (void)setAccessibilityDelegate:(id)arg1;
- (void)setAllowsEmptySelection:(BOOL)arg1;
- (void)setAllowsMultipleSelection:(BOOL)arg1;
- (void)setAllowsSelection:(BOOL)arg1;
- (void)setBounds:(CGRect)arg1;
- (void)setCollectionViewLayout:(id)arg1;
- (void)setCollectionViewLayout:(id)arg1 animated:(BOOL)arg2;
- (void)setCollectionViewLayout:(id)arg1 animated:(BOOL)arg2 completion:(/*^block*/id)arg3;
- (void)setContentInset:(NSEdgeInsets)arg1;
- (void)setContentInsets:(NSEdgeInsets)arg1;
- (void)setContentOffset:(CGPoint)arg1;
- (void)setDataSource:(id)arg1;
- (void)setFrame:(CGRect)arg1;
- (void)setNeedsLayout;
- (void)setScrollerStyle:(long long)arg1;
- (BOOL)shouldDelayWindowOrderingForEvent:(id)arg1;
- (void)touchesBeganWithEvent:(id)arg1;
- (void)touchesEndedWithEvent:(id)arg1;
- (void)updateDraggingItemsForDrag:(id)arg1;
- (void)updateLayout;
- (BOOL)validateUserInterfaceItem:(id)arg1;
- (void)viewDidMoveToWindow;
- (void)viewWillMoveToSuperview:(id)arg1;
- (void)viewWillMoveToWindow:(id)arg1;
- (id)visibleSupplementaryViews;
- (id)visibleSupplementaryViewsOfKind:(id)arg1;
- (BOOL)wantsPeriodicDraggingUpdates;
- (BOOL)wantsUpdateLayer;
- (void)windowDidBecomeKey:(id)arg1;
- (void)windowDidChangeBackingProperties:(id)arg1;
- (void)windowDidResignKey:(id)arg1;
- (BOOL)isScrolling;
- (CGSize)documentSize;
- (void)layoutSubviews;
- (CGSize)frameSizeForContentSize:(CGSize)arg1;
- (unsigned long long)numberOfSelectedItems;
- (id)cellForItemAtIndexPath:(id)arg1;
- (id)dequeueReusableCellWithReuseIdentifier:(id)arg1 forIndexPath:(id)arg2;
- (void)_addEntriesFromDictionary:(id)arg1 inDictionary:(id)arg2;
- (void)_addEntriesFromDictionary:(id)arg1 inDictionary:(id)arg2 andSet:(id)arg3;
- (void)_deselectAllAnimated:(BOOL)arg1 notifyDelegate:(BOOL)arg2;
- (id)_indexPathForView:(id)arg1 ofType:(unsigned long long)arg2;
- (id)_keysForObject:(id)arg1 inDictionary:(id)arg2;
- (void)_notifyDidEndDisplayingCellIfNeeded:(id)arg1 forIndexPath:(id)arg2;
- (void)_notifyWillDisplayCellIfNeeded:(id)arg1 forIndexPath:(id)arg2;
- (id)_objectInDictionary:(id)arg1 forKind:(id)arg2 indexPath:(id)arg3;
- (id)_selectableIndexPathForItemContainingHitView:(id)arg1;
- (void)_setObject:(id)arg1 inDictionary:(id)arg2 forKind:(id)arg3 indexPath:(id)arg4;
- (void)deselectItemAtIndexPath:(id)arg1 animated:(BOOL)arg2;
- (CGRect)documentBounds;
- (id)indexPathForCell:(id)arg1;
- (id)indexPathForSupplementaryView:(id)arg1;
- (id)initWithFrame:(CGRect)arg1 collectionViewLayout:(id)arg2;
- (BOOL)isDecelerating;
- (void)selectItemAtIndexPath:(id)arg1 animated:(BOOL)arg2 scrollPosition:(unsigned long long)arg3;
- (void)setContentOffset:(CGPoint)arg1 animated:(BOOL)arg2;
- (void)setDocumentBounds:(CGRect)arg1;
- (id)visibleCells;
- (id)viewForSupplementaryElementOfKind:(id)arg1 atIndexPath:(id)arg2;
- (unsigned long long)numberOfVisibleCells;
- (BOOL)rearrangingExternalDropEnabled_;
- (void)setRearrangingAllowAutoscroll_:(BOOL)arg1;
- (void)_selectAllItems:(BOOL)arg1 notifyDelegate:(BOOL)arg2;
- (BOOL)_toggleSelectionStateOfItemAtIndexPath:(id)arg1 animated:(BOOL)arg2 notifyDelegate:(BOOL)arg3;
- (void)selectAllItems:(BOOL)arg1;
- (void)_addControlled:(BOOL)arg1 subview:(id)arg2 atZIndex:(long long)arg3;
- (id)_cellsIncludingOverdrawArea:(BOOL)arg1;
- (id)_dictionaryOfIndexPathsAndContentCells;
- (void)_didEndScrolling:(id)arg1;
- (void)_didEndScrollingAnimation;
- (void)_endItemAnimations;
- (void)_enumerateSupplementaryViewsIncludingOverdrawArea:(BOOL)arg1 identifier:(id)arg2 usingBlock:(/*^block*/id)arg3;
- (id)_firstSelectableItemIndexPath;
- (id)_indexPathForSupplementaryElementOfKind:(id)arg1 hitByEvent:(id)arg2;
- (id)_indexPathOfSelectableItemHitByEvent:(id)arg1;
- (id)_indexPathsForItemsInSections:(id)arg1 includingOverdrawArea:(BOOL)arg2;
- (void)_invalidateLayoutIfNecessary;
- (id)_keyItemIndexPathForItemIndexPaths:(id)arg1;
- (id)_keyItemIndexPathForItemIndexPathsSet:(id)arg1;
- (long long)_maxNumberOfReusedViews;
- (void)_notifyAccessibilityDelegateToPrepareSection:(id)arg1;
- (long long)_numberOfReusedViewsForIdentifier:(id)arg1;
- (BOOL)_performItemSelectionForKey:(unsigned short)arg1 withModifiers:(unsigned long long)arg2;
- (void)_performItemSelectionForMouseEvent:(id)arg1 onCell:(id)arg2 atIndexPath:(id)arg3;
- (BOOL)_performScrollingForKey:(unsigned short)arg1;
- (void)_prepareCellsForOverdraw:(CGRect)arg1;
- (id)_rearrangingCoordinator;
- (void)_respondToDoubleClick;
- (id)_retrieveAccessibiltyRoleDescriptionFromAXDelegate;
- (CGPoint)_scrollAmountForMovingRect:(CGRect)arg1 toScrollPosition:(unsigned long long)arg2 inDestinationRect:(CGRect)arg3;
- (void)_scrollPage:(BOOL)arg1;
- (void)_scrollRect:(CGRect)arg1 toScrollPosition:(unsigned long long)arg2 withInsets:(NSEdgeInsets)arg3 animated:(BOOL)arg4 userInteractivelyScrolling:(BOOL)arg5;
- (BOOL)_selectItemsInIndexPathsSet:(id)arg1 byExtendingSelection:(BOOL)arg2 animated:(BOOL)arg3 scrollingKeyItem:(id)arg4 toPosition:(unsigned long long)arg5 notifyDelegate:(BOOL)arg6;
- (BOOL)_selectRangeOfItemsFromIndexPath:(id)arg1 toIndexPath:(id)arg2 byExtendingSelection:(BOOL)arg3 animated:(BOOL)arg4 scroll:(BOOL)arg5 toPosition:(unsigned long long)arg6 notifyDelegate:(BOOL)arg7 candidateLastSelectedItemIndexPath:(id*)arg8;
- (BOOL)_selectionBorderShouldUsePrimaryColor;
- (void)_setVisibleBounds:(CGRect)arg1;
- (void)_submitScrollingRequest:(/*^block*/id)arg1;
- (id)_supplementaryViewsIncludingOverdrawArea:(BOOL)arg1 identifier:(id)arg2;
- (void)_updateCellsInRect:(CGRect)arg1 createIfNecessary:(BOOL)arg2;
- (void)_updateWithItems:(id)arg1;
- (void)_viewCleanup;
- (void)_viewPrepare;
- (id)_visibleViewsDict;
- (void)_willStartScrolling:(id)arg1;
- (id)accessibilityContentSiblingCellFromIndexPath:(id)arg1 direction:(id)arg2;
- (BOOL)accessibilityPerformPressWithItemAtIndexPath:(id)arg1;
- (void)accessibilitySelected:(BOOL)arg1 itemAtIndexPath:(id)arg2;
- (long long)allowedDropPositionsForItemsAtIndexPaths:(id)arg1 movedToIndexPath:(id)arg2;
- (BOOL)allowsContinuousSelection;
- (BOOL)allowsLassoSelection;
- (BOOL)allowsPaintingSelection;
- (void)clipViewBoundsDidChange:(id)arg1;
- (CGPoint)collectionViewPointForLayoutPoint:(CGPoint)arg1;
- (id)contentCells;
- (CGSize)contentSizeForFrameSize:(CGSize)arg1;
- (id)contentSupplementaryViews;
- (void)deselectAllItems:(BOOL)arg1;
- (void)deselectItemsAtIndexPaths:(id)arg1 animated:(BOOL)arg2;
- (void)didEndScrollingFromExternalControl;
- (CGRect)documentContentRect;
- (unsigned long long)dragOperationForItemsAtIndexPaths:(id)arg1 movedOntoItemAtIndexPath:(id)arg2;
- (unsigned long long)extraNumberOfCellsToPreloadWhenScrollingStopped;
- (id)indexPathForItemHitByEvent:(id)arg1;
- (id)indexPathForSupplementaryElementOfKind:(id)arg1 atPoint:(CGPoint)arg2;
- (id)indexPathForSupplementaryElementOfKind:(id)arg1 hitByEvent:(id)arg2;
- (id)indexPathsForContentItems;
- (id)indexPathsForContentItemsInSections:(id)arg1;
- (id)indexPathsForVisibleItemsInSections:(id)arg1;
- (BOOL)isLassoSelectionInProgress;
- (BOOL)isRearranging_;
- (BOOL)lassoInvertsSelection;
- (id)lastRightClickedIndexPath;
- (CGPoint)layoutPointForCollectionViewPoint:(CGPoint)arg1;
- (BOOL)layoutSubviewsOnSetNeedsLayout;
- (id)nextIndexPath:(id)arg1;
- (unsigned long long)numberOfContentCells;
- (id)previousIndexPath:(id)arg1;
- (unsigned long long)purgingCellsThreshold;
- (BOOL)rearrangingAllowAutoscroll_;
- (BOOL)rearrangingContinuouslyUpdateInsideCells_;
- (void)rearrangingCoordinatorReloadLayout_;
- (BOOL)rearrangingEnabled_;
- (long long)rearrangingInitiationMode_;
- (double)rearrangingPreviewDelay_;
- (Class)registeredClassForCellWithReuseIdentifier:(id)arg1;
- (Class)registeredClassForSupplementaryViewOfKind:(id)arg1 withReuseIdentifier:(id)arg2;
- (void)resetScrollingOverdraw;
- (void)scrollRect:(CGRect)arg1 toScrollPosition:(unsigned long long)arg2 withInsets:(NSEdgeInsets)arg3 animated:(BOOL)arg4;
- (void)scrollToItemAtIndexPath:(id)arg1 atScrollPosition:(unsigned long long)arg2 animated:(BOOL)arg3 userInteractivelyScrolling:(BOOL)arg4;
- (void)scrollViewDidEndLiveScrollNotification:(id)arg1;
- (void)scrollViewWillStartLiveScrollNotification:(id)arg1;
- (id)scrollingRequest;
- (void)selectItemsAtIndexPaths:(id)arg1 byExtendingSelection:(BOOL)arg2 animated:(BOOL)arg3;
- (void)selectItemsAtIndexPaths:(id)arg1 byExtendingSelection:(BOOL)arg2 animated:(BOOL)arg3 scrollItemAtIndex:(id)arg4 toPosition:(unsigned long long)arg5;
- (BOOL)selectableItemAtIndexPath:(id)arg1;
- (BOOL)selectedItemAtIndexPath:(id)arg1;
- (void)setAllowsContinuousSelection:(BOOL)arg1;
- (void)setAllowsLassoSelection:(BOOL)arg1;
- (void)setAllowsPaintingSelection:(BOOL)arg1;
- (void)setExtraNumberOfCellsToPreloadWhenScrollingStopped:(unsigned long long)arg1;
- (void)setLassoInvertsSelection:(BOOL)arg1;
- (void)setLastRightClickedIndexPath:(id)arg1;
- (void)setLayoutSubviewsOnSetNeedsLayout:(BOOL)arg1;
- (void)setPurgingCellsThreshold:(unsigned long long)arg1;
- (void)setRearrangingContinuouslyUpdateInsideCells_:(BOOL)arg1;
- (void)setRearrangingEnabled_:(BOOL)arg1;
- (void)setRearrangingExternalDropEnabled_:(BOOL)arg1;
- (void)setRearrangingInitiationMode_:(long long)arg1;
- (void)setRearrangingPreviewDelay_:(double)arg1;
- (void)setScrollingRequest:(id)arg1;
- (void)willEndScrollingFromExternalControl;
- (void)willStartScrollingFromExternalControl;
@end

