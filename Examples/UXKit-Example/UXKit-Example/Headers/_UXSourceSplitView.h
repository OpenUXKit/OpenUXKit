/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import "UXView.h"
#import <Cocoa/Cocoa.h>
#import "_UXSourceSplitViewCursorProvider.h"

@protocol _UXSourceSplitViewDelegate;
@class NSObject, NSLayoutConstraint, NSArray, _UXSourceSplitItemView, NSBox, _UXSourceSplitViewSpringLoadingView, _UXSourceSplitViewShadowView, NSWindow, NSGestureRecognizer, NSCursor, UXView, NSString;

@interface _UXSourceSplitView : UXView <NSGestureRecognizerDelegate, _UXSourceSplitViewCursorProvider, NSAccessibilityGroup> {

	NSLayoutConstraint* _dividerTrailingConstraint;
	NSArray* _dividerVerticalConstraints;
	NSLayoutConstraint* _masterViewWidthConstraint;
	BOOL _resizing;
	BOOL _currentlySpringLoading;
	BOOL _needsSidebarProviderUpdate;
	BOOL _hasProvidedSidebarToWindow;
	BOOL _transientlyUncollapsed;
	BOOL _collapsed;
	BOOL _revealsOnEdgeHoverInFullscreen;
	BOOL _springLoaded;
	BOOL _wantsCollapsed;
	BOOL _autoCollapsed;
	_UXSourceSplitItemView* _masterView;
	_UXSourceSplitItemView* _detailView;
	double _minimumMasterWidth;
	double _maximumMasterWidth;
	double _minimumWidthForInlineSourceList;
	id<_UXSourceSplitViewDelegate> _delegate;
	NSBox* _divider;
	_UXSourceSplitViewSpringLoadingView* _leadingSpringLoadingView;
	_UXSourceSplitViewShadowView* _leadingOverlayShadowView;
	NSWindow* _transientOverlayWindow;
	NSGestureRecognizer* _resizeRecognizer;

}

@property (nonatomic, readonly) NSBox *divider;                                                             //@synthesize divider=_divider - In the implementation block
@property (nonatomic, readonly) NSCursor *dividerCursor; 
@property (nonatomic, readonly) _UXSourceSplitViewSpringLoadingView *leadingSpringLoadingView;              //@synthesize leadingSpringLoadingView=_leadingSpringLoadingView - In the implementation block
@property (nonatomic, readonly) _UXSourceSplitViewShadowView *leadingOverlayShadowView;                     //@synthesize leadingOverlayShadowView=_leadingOverlayShadowView - In the implementation block
@property (nonatomic, readonly) BOOL autoCollapsed;                                                         //@synthesize autoCollapsed=_autoCollapsed - In the implementation block
@property (nonatomic) double dividerPosition; 
@property (nonatomic, strong) NSWindow *transientOverlayWindow;                                             //@synthesize transientOverlayWindow=_transientOverlayWindow - In the implementation block
@property (nonatomic, strong) NSGestureRecognizer *resizeRecognizer;                                        //@synthesize resizeRecognizer=_resizeRecognizer - In the implementation block
@property (nonatomic, readonly) _UXSourceSplitItemView *masterView;                                         //@synthesize masterView=_masterView - In the implementation block
@property (nonatomic, readonly) _UXSourceSplitItemView *detailView;                                         //@synthesize detailView=_detailView - In the implementation block
@property (nonatomic, readonly) double leadingContentInset; 
@property (nonatomic, readonly) UXView *subviewToReveal; 
@property (nonatomic, readonly) BOOL transientlyUncollapsed;                                                //@synthesize transientlyUncollapsed=_transientlyUncollapsed - In the implementation block
@property (nonatomic, readonly) BOOL collapsed;                                                             //@synthesize collapsed=_collapsed - In the implementation block
@property (nonatomic) double minimumMasterWidth;                                                            //@synthesize minimumMasterWidth=_minimumMasterWidth - In the implementation block
@property (nonatomic) double maximumMasterWidth;                                                            //@synthesize maximumMasterWidth=_maximumMasterWidth - In the implementation block
@property (nonatomic) double masterWidth; 
@property (nonatomic) double minimumWidthForInlineSourceList;                                               //@synthesize minimumWidthForInlineSourceList=_minimumWidthForInlineSourceList - In the implementation block
@property (nonatomic) BOOL revealsOnEdgeHoverInFullscreen;                                                  //@synthesize revealsOnEdgeHoverInFullscreen=_revealsOnEdgeHoverInFullscreen - In the implementation block
@property (nonatomic) BOOL springLoaded;                                                                    //@synthesize springLoaded=_springLoaded - In the implementation block
@property (nonatomic) BOOL wantsCollapsed;                                                                  //@synthesize wantsCollapsed=_wantsCollapsed - In the implementation block
@property (nonatomic, weak) id<_UXSourceSplitViewDelegate> delegate;                                        //@synthesize delegate=_delegate - In the implementation block
@property (readonly) unsigned long long hash; 
@property (readonly) Class superclass; 
@property (copy, readonly) NSString *description; 
@property (copy, readonly) NSString *debugDescription; 
@property (readonly) double sidebarDividerPosition; 
@property (readonly) long long depthOfView; 
@property (readonly) NSObject *representedView; 
@property (readonly) BOOL isValidConfiguration; 
@property (readonly) double minimumDividerPosition; 
@property (readonly) double maximumDividerPosition; 
@property (readonly) BOOL isCollapsed; 
@property (getter=isOverlaidAsSidebar, readonly) BOOL overlaidAsSidebar; 
@property (readonly) double dividerWidth; 
@property (readonly) CGRect dividerCursorRect; 
@property  NSEdgeInsets sidebarAdditionalSafeAreaInsets; 
- (BOOL)_canSpringLoad;
- (BOOL)_shouldBeCollapsed;
- (BOOL)_springLoading:(BOOL)arg1;
- (BOOL)autoCollapsed;
- (BOOL)collapsed;
- (BOOL)gestureRecognizer:(id)arg1 shouldAttemptToRecognizeWithEvent:(id)arg2;
- (BOOL)gestureRecognizerShouldBegin:(id)arg1;
- (BOOL)isCollapsed;
- (BOOL)isOverlaidAsSidebar;
- (BOOL)revealsOnEdgeHoverInFullscreen;
- (BOOL)springLoaded;
- (BOOL)transientlyUncollapsed;
- (BOOL)wantsCollapsed;
- (double)dividerPosition;
- (double)dividerWidth;
- (double)leadingContentInset;
- (double)leadingContentInsetForWantsCollapsed:(BOOL)arg1;
- (double)masterWidth;
- (double)maximumDividerPosition;
- (double)maximumMasterWidth;
- (double)minimumDividerPosition;
- (double)minimumMasterWidth;
- (double)minimumWidthForInlineSourceList;
- (double)sidebarDividerPosition;
- (id)accessibilityChildren;
- (id)accessibilityRole;
- (id)accessibilitySplitters;
- (id)detailView;
- (id)divider;
- (id)dividerCursor;
- (id)hitTest:(CGPoint)arg1;
- (id)initWithFrame:(CGRect)arg1;
- (id)leadingOverlayShadowView;
- (id)leadingSpringLoadingView;
- (id)masterView;
- (id)representedView;
- (id)resizeRecognizer;
- (id)subviewToReveal;
- (id)transientOverlayWindow;
- (id<_UXSourceSplitViewDelegate>)delegate;
- (long long)depthOfView;
- (NSEdgeInsets)sidebarAdditionalSafeAreaInsets;
- (void)_didChangeTransientlyUncollapsed;
- (void)_endDividerLiveResize;
- (void)_moveMasterAndDividerToView:(id)arg1;
- (void)_noteNeedsSidebarProviderUpdate;
- (void)_performResizeWithGestureRecognizer:(id)arg1;
- (void)_registerSplitViewItemTrackingIfApplicable;
- (void)_removeWindowSidebarTrackingIfApplicable;
- (void)_resizeToWidth:(double)arg1;
- (void)_setCollapsed:(BOOL)arg1 shouldLayoutSubtree:(BOOL)arg2;
- (void)_setupTransientOverlayWindow;
- (void)_startDividerLiveResize;
- (void)_tearDownTransientOverlayWindow;
- (void)_unregisterSplitViewItemTrackingIfApplicable;
- (void)_updateWindowSidebarTrackingIfApplicable;
- (void)cursorUpdate:(id)arg1;
- (void)didChangeCollapsed;
- (void)handlePanGestureRecognizer:(id)arg1;
- (void)layout;
- (void)resetCursorRects;
- (void)setDelegate:(id<_UXSourceSplitViewDelegate>)arg1;
- (void)setDividerPosition:(double)arg1;
- (void)setMasterWidth:(double)arg1;
- (void)setMaximumMasterWidth:(double)arg1;
- (void)setMinimumMasterWidth:(double)arg1;
- (void)setMinimumWidthForInlineSourceList:(double)arg1;
- (void)setResizeRecognizer:(id)arg1;
- (void)setRevealsOnEdgeHoverInFullscreen:(BOOL)arg1;
- (void)setSidebarAdditionalSafeAreaInsets:(NSEdgeInsets)arg1;
- (void)setSpringLoaded:(BOOL)arg1;
- (void)setTransientlyUncollapsed:(BOOL)arg1 animated:(BOOL)arg2;
- (void)setTransientOverlayWindow:(id)arg1;
- (void)setWantsCollapsed:(BOOL)arg1;
- (void)toggleSidebar:(id)arg1;
- (void)updateConstraintsForDividerAndMain;
- (void)viewDidMoveToWindow;
- (void)viewWillMoveToWindow:(id)arg1;
- (void)windowDidResize:(id)arg1;
@end

