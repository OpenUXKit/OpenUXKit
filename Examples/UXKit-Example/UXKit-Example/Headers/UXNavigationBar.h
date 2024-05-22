/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import "UXBar.h"

@protocol UXNavigationBarDelegate;
@class NSView, NSArray, NSImage, NSMutableArray, _UXNavigationItemContainerView, UXNavigationItem;

@interface UXNavigationBar : UXBar {

	BOOL _needsRecalculateWindowKeyViewLoop;
	BOOL _recalculatingKeyViewLoop;
	BOOL _translucent;
	BOOL _recalculatingWindowKeyViewLoop;
	BOOL _alternateTitleEnabled;
	BOOL _detached;
	id<UXNavigationBarDelegate> _delegate;
	NSView* _titleCenteringTrackedView;
	NSArray* _items;
	NSImage* _backIndicatorImage;
//	NSView* _globalTrailingView;
//	double _globalTrailingViewWidthMultiplier;
	NSMutableArray* _internalItems;
	_UXNavigationItemContainerView* _topItemContainer;
	long long _currentOperation;
	UXNavigationItem* _transitioningItem;
	NSView* _alternateTitleView;
	NSView* _alternateCondensedTitleView;
	double _leftInteritemSpacing;
	double _rightInteritemSpacing;
	double _centerYOffset;
	NSEdgeInsets _edgeInsets;

}

@property (nonatomic, strong) NSMutableArray *internalItems;                                 //@synthesize internalItems=_internalItems - In the implementation block
@property (nonatomic, strong) _UXNavigationItemContainerView *topItemContainer;              //@synthesize topItemContainer=_topItemContainer - In the implementation block
@property (nonatomic) long long currentOperation;                                            //@synthesize currentOperation=_currentOperation - In the implementation block
@property (nonatomic, strong) UXNavigationItem *transitioningItem;                           //@synthesize transitioningItem=_transitioningItem - In the implementation block
@property (nonatomic) BOOL recalculatingWindowKeyViewLoop;                                   //@synthesize recalculatingWindowKeyViewLoop=_recalculatingWindowKeyViewLoop - In the implementation block
@property (nonatomic, strong) NSView *alternateTitleView;                                    //@synthesize alternateTitleView=_alternateTitleView - In the implementation block
@property (nonatomic, strong) NSView *alternateCondensedTitleView;                           //@synthesize alternateCondensedTitleView=_alternateCondensedTitleView - In the implementation block
@property (nonatomic) BOOL alternateTitleEnabled;                                            //@synthesize alternateTitleEnabled=_alternateTitleEnabled - In the implementation block
@property (getter=isDetached, nonatomic) BOOL detached;                                      //@synthesize detached=_detached - In the implementation block
@property (nonatomic) double leftInteritemSpacing;                                           //@synthesize leftInteritemSpacing=_leftInteritemSpacing - In the implementation block
@property (nonatomic) double rightInteritemSpacing;                                          //@synthesize rightInteritemSpacing=_rightInteritemSpacing - In the implementation block
@property (nonatomic) double centerYOffset;                                                  //@synthesize centerYOffset=_centerYOffset - In the implementation block
@property (nonatomic, weak) id<UXNavigationBarDelegate> delegate;                            //@synthesize delegate=_delegate - In the implementation block
@property (getter=isTranslucent, nonatomic) BOOL translucent;                                //@synthesize translucent=_translucent - In the implementation block
@property (nonatomic) NSEdgeInsets edgeInsets;                                               //@synthesize edgeInsets=_edgeInsets - In the implementation block
@property (nonatomic, weak) NSView *titleCenteringTrackedView;                               //@synthesize titleCenteringTrackedView=_titleCenteringTrackedView - In the implementation block
@property (nonatomic, readonly) UXNavigationItem *topItem; 
@property (nonatomic, readonly) UXNavigationItem *backItem; 
@property (nonatomic, copy) NSArray *items;                                                  //@synthesize items=_items - In the implementation block
@property (nonatomic, strong) NSImage *backIndicatorImage;                                   //@synthesize backIndicatorImage=_backIndicatorImage - In the implementation block
@property (nonatomic, strong) NSView *globalTrailingView;                                    //@synthesize globalTrailingView=_globalTrailingView - In the implementation block
@property (nonatomic) double globalTrailingViewWidthMultiplier;                              //@synthesize globalTrailingViewWidthMultiplier=_globalTrailingViewWidthMultiplier - In the implementation block
- (void)dealloc;
- (id<UXNavigationBarDelegate>)delegate;
- (void)setDelegate:(id<UXNavigationBarDelegate>)arg1;
- (void)setEdgeInsets:(NSEdgeInsets)arg1;
- (void)layout;
- (long long)currentOperation;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void*)arg4;
- (NSEdgeInsets)edgeInsets;
- (id)initWithFrame:(CGRect)arg1;
- (BOOL)isDetached;
- (id)items;
- (void)mouseDown:(id)arg1;
- (void)recalculateKeyViewLoop;
- (void)setCurrentOperation:(long long)arg1;
- (void)setItems:(id)arg1;
- (void)updateConstraints;
- (void)_snapshot;
- (id)internalItems;
- (void)setInternalItems:(id)arg1;
- (void)_removeItem:(id)arg1;
- (void)setDetached:(BOOL)arg1;
- (id)backItem;
- (void)setTranslucent:(BOOL)arg1;
- (id)topItem;
- (void)_updateTitleView;
- (id)backIndicatorImage;
- (long long)barPosition;
- (BOOL)isTranslucent;
- (id)popNavigationItemAnimated:(BOOL)arg1;
- (void)pushNavigationItem:(id)arg1 animated:(BOOL)arg2;
- (void)setBackIndicatorImage:(id)arg1;
- (void)setInteritemSpacing:(double)arg1;
- (void)setAlternateCondensedTitleView:(id)arg1;
- (void)_addObserversForItem:(id)arg1;
- (void)_completeInteractiveTransition:(BOOL)arg1 duration:(double)arg2;
- (id)_popNavigationItem;
- (id)_popNavigationItemAnimated:(BOOL)arg1 duration:(double)arg2;
- (void)_prepareForNavigationItemTransition;
- (void)_pushItem:(id)arg1;
- (void)_pushNavigationItem:(id)arg1 animated:(BOOL)arg2 duration:(double)arg3;
- (void)_removeObserversForItem:(id)arg1;
- (void)_updateItemContainer;
- (id)alternateCondensedTitleView;
- (BOOL)alternateTitleEnabled;
- (id)alternateTitleView;
- (void)beginInteractivePop;
- (void)beginInteractivePushToItem:(id)arg1;
- (double)centerYOffset;
- (id)globalTrailingView;
- (double)globalTrailingViewWidthMultiplier;
- (double)leftInteritemSpacing;
- (BOOL)recalculatingWindowKeyViewLoop;
- (double)rightInteritemSpacing;
- (void)setAlternateTitleEnabled:(BOOL)arg1;
- (void)setAlternateTitleView:(id)arg1;
- (void)setCenterYOffset:(double)arg1;
- (void)setGlobalTrailingView:(id)arg1;
- (void)setGlobalTrailingViewWidthMultiplier:(double)arg1;
- (void)setLeftInteritemSpacing:(double)arg1;
- (void)setNeedsRecalcuateWindowKeyViewLoop;
- (void)setRecalculatingWindowKeyViewLoop:(BOOL)arg1;
- (void)setRightInteritemSpacing:(double)arg1;
- (void)setTitleCenteringTrackedView:(id)arg1;
- (void)setTopItemContainer:(id)arg1;
- (void)setTransitioningItem:(id)arg1;
- (id)titleCenteringTrackedView;
- (id)topItemContainer;
- (id)transitioningItem;
@end
