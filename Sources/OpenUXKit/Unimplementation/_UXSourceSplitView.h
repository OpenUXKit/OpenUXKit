

#import <AppKit/AppKit.h>
#import <OpenUXKit/_UXSourceSplitViewCursorProvider-Protocol.h>

@class NSArray, NSBox, NSCursor, NSGestureRecognizer, NSLayoutConstraint, NSString, NSWindow, UXView, _UXContainerView, _UXSourceSplitViewShadowView, _UXSourceSplitViewSpringLoadingView;
@protocol _UXSourceSplitViewDelegate;

@interface _UXSourceSplitView <NSGestureRecognizerDelegate, _UXSourceSplitViewCursorProvider, NSAccessibilityGroup>
{
    NSLayoutConstraint *_separatorTrailingConstraint;	// 112 = 0x70
    NSArray *_separatorVerticalConstraints;	// 120 = 0x78
    NSLayoutConstraint *_masterViewWidthConstraint;	// 128 = 0x80
    BOOL _resizing;	// 136 = 0x88
    BOOL _currentlySpringLoading;	// 137 = 0x89
    BOOL _transientlyUncollapsed;	// 138 = 0x8a
    BOOL _collapsed;	// 139 = 0x8b
    BOOL _revealsOnEdgeHoverInFullscreen;	// 140 = 0x8c
    BOOL _springLoaded;	// 141 = 0x8d
    BOOL _wantsCollapsed;	// 142 = 0x8e
    BOOL _autoCollapsed;	// 143 = 0x8f
    _UXContainerView *_masterView;	// 144 = 0x90
    _UXContainerView *_detailView;	// 152 = 0x98
    CGFloat _minimumMasterWidth;	// 160 = 0xa0
    CGFloat _maximumMasterWidth;	// 168 = 0xa8
    CGFloat _minimumWidthForInlineSourceList;	// 176 = 0xb0
    id <_UXSourceSplitViewDelegate> _delegate;	// 184 = 0xb8
    NSBox *_separator;	// 192 = 0xc0
    _UXSourceSplitViewSpringLoadingView *_leadingSpringLoadingView;	// 200 = 0xc8
    _UXSourceSplitViewShadowView *_leadingOverlayShadowView;	// 208 = 0xd0
    NSWindow *_transientOverlayWindow;	// 216 = 0xd8
    NSGestureRecognizer *_resizeRecognizer;	// 224 = 0xe0
}


@property(strong, nonatomic) NSGestureRecognizer *resizeRecognizer; // @synthesize resizeRecognizer=_resizeRecognizer;
@property(strong, nonatomic) NSWindow *transientOverlayWindow; // @synthesize transientOverlayWindow=_transientOverlayWindow;
@property(readonly, nonatomic) BOOL autoCollapsed; // @synthesize autoCollapsed=_autoCollapsed;
@property(readonly, nonatomic) _UXSourceSplitViewShadowView *leadingOverlayShadowView; // @synthesize leadingOverlayShadowView=_leadingOverlayShadowView;
@property(readonly, nonatomic) _UXSourceSplitViewSpringLoadingView *leadingSpringLoadingView; // @synthesize leadingSpringLoadingView=_leadingSpringLoadingView;
@property(readonly, nonatomic) NSBox *separator; // @synthesize separator=_separator;
@property(nonatomic) __weak id <_UXSourceSplitViewDelegate> delegate; // @synthesize delegate=_delegate;
@property(nonatomic) BOOL wantsCollapsed; // @synthesize wantsCollapsed=_wantsCollapsed;
@property(nonatomic) BOOL springLoaded; // @synthesize springLoaded=_springLoaded;
@property(nonatomic) BOOL revealsOnEdgeHoverInFullscreen; // @synthesize revealsOnEdgeHoverInFullscreen=_revealsOnEdgeHoverInFullscreen;
@property(nonatomic) CGFloat minimumWidthForInlineSourceList; // @synthesize minimumWidthForInlineSourceList=_minimumWidthForInlineSourceList;
@property(nonatomic) CGFloat maximumMasterWidth; // @synthesize maximumMasterWidth=_maximumMasterWidth;
@property(nonatomic) CGFloat minimumMasterWidth; // @synthesize minimumMasterWidth=_minimumMasterWidth;
@property(readonly, nonatomic) BOOL collapsed; // @synthesize collapsed=_collapsed;
@property(readonly, nonatomic) BOOL transientlyUncollapsed; // @synthesize transientlyUncollapsed=_transientlyUncollapsed;
@property(readonly, nonatomic) _UXContainerView *detailView; // @synthesize detailView=_detailView;
@property(readonly, nonatomic) _UXContainerView *masterView; // @synthesize masterView=_masterView;
- (id)accessibilityRole;
- (id)accessibilityChildren;
- (id)accessibilitySplitters;
- (void)cursorUpdate:(id)arg1;
- (void)_performResizeWithGestureRecognizer:(id)arg1;
- (void)handlePanGestureRecognizer:(id)arg1;
- (BOOL)gestureRecognizerShouldBegin:(id)arg1;
- (BOOL)gestureRecognizer:(id)arg1 shouldAttemptToRecognizeWithEvent:(id)arg2;
- (void)resetCursorRects;
- (id)hitTest:(CGPoint)arg1;
- (void)layout;
- (BOOL)_canSpringLoad;
- (BOOL)_springLoading:(BOOL)arg1;
- (void)_setCollapsed:(BOOL)arg1 shouldLayoutSubtree:(BOOL)arg2;
- (void)_didChangeTransientlyUncollapsed;
- (BOOL)_shouldBeCollapsed;
- (void)_endSeparatorLiveResize;
- (void)_startSeparatorLiveResize;
- (void)_resizeToWidth:(CGFloat)arg1;
@property(readonly, nonatomic) NSCursor *separatorCursor;
@property(readonly, nonatomic) UXView *subviewToReveal;
- (void)setTransientlyUncollapsed:(BOOL)arg1 animated:(BOOL)arg2;
- (void)_tearDownTransientOverlayWindow;
- (void)_setupTransientOverlayWindow;
- (void)_moveMasterAndSeparatorToView:(id)arg1;
- (void)didChangeCollapsed;
@property(readonly, nonatomic) CGFloat leadingContentInset;
- (CGFloat)leadingContentInsetForWantsCollapsed:(BOOL)arg1;
@property(nonatomic) CGFloat masterWidth;
- (void)updateConstraintsForSeparatorAndMain;
- (id)initWithFrame:(CGRect)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) NSUInteger hash;
@property(readonly) Class superclass;

@end
