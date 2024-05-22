#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXView.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class _UXSourceSplitView, _UXContainerView, _UXSourceSplitViewShadowView, _UXSourceSplitViewSpringLoadingView, _UXSourceSplitItemView;
@protocol _UXSourceSplitViewDelegate;

NS_SWIFT_UI_ACTOR
@protocol _UXSourceSplitViewCursorProvider <NSObject>

- (NSCursor *)dividerCursor;

@end

NS_SWIFT_UI_ACTOR
@protocol _UXSourceSplitViewDelegate <NSObject>

- (BOOL)sourceSplitView:(_UXSourceSplitView *)sourceSplitView canSpringLoadRevealSubview:(UXView *)subview;
- (void)sourceSplitView:(_UXSourceSplitView *)sourceSplitView didChangeAutoCollapsedValue:(BOOL)autoCollapsedValue;
- (void)sourceSplitView:(_UXSourceSplitView *)sourceSplitView didResizeMasterWidth:(CGFloat)masterWidth;

@end


UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXSourceSplitView : UXView <NSGestureRecognizerDelegate, _UXSourceSplitViewCursorProvider, NSAccessibilityGroup>

@property (nonatomic, strong) NSGestureRecognizer *resizeRecognizer;
@property (nonatomic, strong, nullable) NSWindow *transientOverlayWindow;
@property (nonatomic, readonly) BOOL autoCollapsed;
@property (nonatomic, readonly) _UXSourceSplitViewShadowView *leadingOverlayShadowView;
@property (nonatomic, readonly) _UXSourceSplitViewSpringLoadingView *leadingSpringLoadingView;
@property (nonatomic, readonly) NSBox *divider;
@property (nonatomic, readonly) NSCursor *dividerCursor;
@property (nonatomic) CGFloat dividerPosition;
@property (nonatomic, weak, nullable) id <_UXSourceSplitViewDelegate> delegate;
@property (nonatomic) BOOL wantsCollapsed;
@property (nonatomic) BOOL springLoaded;
@property (nonatomic) BOOL revealsOnEdgeHoverInFullscreen;
@property (nonatomic) CGFloat minimumWidthForInlineSourceList;
@property (nonatomic) CGFloat maximumMasterWidth;
@property (nonatomic) CGFloat minimumMasterWidth;
@property (nonatomic, readonly, getter = isCollapsed) BOOL collapsed;
@property (nonatomic, readonly) BOOL transientlyUncollapsed;
@property (nonatomic, readonly) _UXSourceSplitItemView *detailView;
@property (nonatomic, readonly) _UXSourceSplitItemView *masterView;
@property (nonatomic, readonly) NSCursor *separatorCursor;
@property (nonatomic, readonly) UXView *subviewToReveal;
@property (nonatomic, readonly) CGFloat leadingContentInset;
@property (nonatomic) CGFloat masterWidth;
@property (readonly) CGFloat sidebarDividerPosition;
@property (readonly) NSInteger depthOfView;
@property (readonly) NSObject *representedView;
@property (readonly) BOOL isValidConfiguration;
@property (readonly) CGFloat minimumDividerPosition;
@property (readonly) CGFloat maximumDividerPosition;
@property (readonly, getter = isOverlaidAsSidebar) BOOL overlaidAsSidebar;
@property (readonly) CGFloat dividerWidth;
@property (readonly) CGRect dividerCursorRect;
@property (nonatomic) NSEdgeInsets sidebarAdditionalSafeAreaInsets;

- (BOOL)_canSpringLoad;
- (BOOL)_shouldBeCollapsed;
- (BOOL)_springLoading:(BOOL)springLoading;
- (CGFloat)leadingContentInsetForWantsCollapsed:(BOOL)wantsCollapsed;
- (void)_didChangeTransientlyUncollapsed;
- (void)_endDividerLiveResize;
- (void)_moveMasterAndSeparatorToView:(NSView *)view;
- (void)_noteNeedsSidebarProviderUpdate;
- (void)_performResizeWithGestureRecognizer:(NSGestureRecognizer *)gestureRecognizer;
- (void)_registerSplitViewItemTrackingIfApplicable;
- (void)_removeWindowSidebarTrackingIfApplicable;
- (void)_resizeToWidth:(CGFloat)width;
- (void)_setCollapsed:(BOOL)collapsed shouldLayoutSubtree:(BOOL)shouldLayoutSubtree;
- (void)_setupTransientOverlayWindow;
- (void)_startDividerLiveResize;
- (void)_tearDownTransientOverlayWindow;
- (void)_unregisterSplitViewItemTrackingIfApplicable;
- (void)_updateWindowSidebarTrackingIfApplicable;
- (void)didChangeCollapsed;
- (void)handlePanGestureRecognizer:(NSPanGestureRecognizer *)panGestureRecognizer;
- (void)setTransientlyUncollapsed:(BOOL)transientlyUncollapsed animated:(BOOL)animated;
- (void)toggleSidebar:(id)sender;
- (void)updateConstraintsForDividerAndMain;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
