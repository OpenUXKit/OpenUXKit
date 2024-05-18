#import <OpenUXKit/_UXSourceSplitView.h>
#import <OpenUXKit/_UXSourceSplitItemView.h>
#import <OpenUXKit/UXKitPrivateUtilites.h>
#import <OpenUXKit/_UXSourceSplitViewSpringLoadingView.h>
#import <OpenUXKit/_UXSourceSplitViewShadowView.h>
#import <OpenUXKit/NSWindow-UXKit.h>
#import <OpenUXKit/_UXSourceSplitViewFullScreenOverlayContentView.h>
#import <OpenUXKit/NSView+PrivateSPI.h>
#import <OpenUXKit/NSWindow+PrivateSPI.h>


@interface _UXSourceSplitView () {
    NSArray* _dividerVerticalConstraints;
    NSLayoutConstraint* _dividerTrailingConstraint;
    NSLayoutConstraint* _masterViewWidthConstraint;
    BOOL _resizing;
    BOOL _hasProvidedSidebarToWindow;
    BOOL _needsSidebarProviderUpdate;
    BOOL _currentlySpringLoading;
}
@end

@implementation _UXSourceSplitView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _minimumMasterWidth = 200.0;
        _maximumMasterWidth = 400.0;
        _detailView = [_UXSourceSplitItemView new];
        _detailView.frame = self.bounds;
        _detailView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [self addSubview:_detailView];
        _masterView = [_UXSourceSplitItemView new];
        _masterView.translatesAutoresizingMaskIntoConstraints = NO;
        _masterView.wantsMaterialBackground = YES;
        _masterView._semanticContext = 7;
        _divider = [[NSBox alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 10.0)];
        _divider.boxType = NSBoxSeparator;
        _divider.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_divider];
        _masterViewWidthConstraint = [_masterView.widthAnchor constraintEqualToConstant:240.0];
        _masterViewWidthConstraint.active = YES;
        _resizeRecognizer = [[NSPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
        _resizeRecognizer.delaysPrimaryMouseButtonEvents = NO;
        _resizeRecognizer.delegate = self;
        [self addGestureRecognizer:_resizeRecognizer];
        [self updateConstraintsForDividerAndMain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:self.window];
    }
    return self;
}

- (void)setSpringLoaded:(BOOL)springLoaded {
    if (_springLoaded != springLoaded) {
        _springLoaded = springLoaded;
        _leadingSpringLoadingView = [_UXSourceSplitViewSpringLoadingView new];
        @weakify(self);
        _leadingSpringLoadingView.springLoadingHandler = ^(BOOL springLoaded){
            @strongify(self);
            self->_springLoaded = springLoaded;
        };
        _leadingSpringLoadingView.canSpringLoadHandler = ^BOOL{
            @strongify(self);
            return [self _canSpringLoad];
        };
        _leadingSpringLoadingView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_leadingSpringLoadingView];
        [_leadingSpringLoadingView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [_leadingSpringLoadingView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [_leadingSpringLoadingView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    } else {
        _leadingSpringLoadingView.springLoadingHandler = nil;
        _leadingSpringLoadingView.canSpringLoadHandler = nil;
    }
}

- (void)setWantsCollapsed:(BOOL)wantsCollapsed {
    if (_wantsCollapsed != wantsCollapsed) {
        _wantsCollapsed = wantsCollapsed;
        BOOL autoCollapsed = NO;
        if (self._shouldBeCollapsed) {
            autoCollapsed = !_wantsCollapsed;
        }
        _autoCollapsed = autoCollapsed;
        BOOL collapsed = _wantsCollapsed | autoCollapsed;
        if (_transientlyUncollapsed && !_wantsCollapsed && !autoCollapsed) {
            _transientlyUncollapsed = NO;
            [self _didChangeTransientlyUncollapsed];
        }
        [self _setCollapsed:collapsed shouldLayoutSubtree:YES];
    }
}

- (BOOL)_shouldBeCollapsed {
    CGFloat width = CGRectGetWidth(self.bounds);
    return width < self.minimumWidthForInlineSourceList;
}

- (void)_setCollapsed:(BOOL)collapsed shouldLayoutSubtree:(BOOL)shouldLayoutSubtree {
    if (_collapsed != collapsed) {
        _collapsed = collapsed;
        if (!collapsed) {
            _masterViewWidthConstraint.constant = 0.0;
        }
        self.dividerPosition = 0.0;
        if (shouldLayoutSubtree) {
            [self.divider.superview layoutSubtreeIfNeeded];
        }
    }
}

- (void)layout {
    if (!_wantsCollapsed) {
        BOOL autoCollapsed = NO;
        BOOL shouldBeCollapsed = self._shouldBeCollapsed;
        BOOL oldAutoCollapsed = _autoCollapsed;
        BOOL collapsed = !_autoCollapsed && shouldBeCollapsed;
        if (collapsed) {
            autoCollapsed = YES;
        } else {
            if (autoCollapsed == NO || shouldBeCollapsed) {
                [super layout];
                [self _updateWindowSidebarTrackingIfApplicable];
                [self _registerSplitViewItemTrackingIfApplicable];
                return;
            }
            autoCollapsed = NO;
        }
        _autoCollapsed = autoCollapsed;
        if (autoCollapsed != oldAutoCollapsed) {
            [self _setCollapsed:collapsed shouldLayoutSubtree:NO];
            [self.delegate sourceSplitView:self didChangeAutoCollapsedValue:_autoCollapsed];
        }
    }
    [super layout];
    [self _updateWindowSidebarTrackingIfApplicable];
    [self _registerSplitViewItemTrackingIfApplicable];
}

- (CGFloat)leadingContentInset {
    if (self.collapsed) {
        return 0.0;
    } else {
        return self.masterWidth;
    }
}

- (void)didChangeCollapsed {
    [self.window invalidateCursorRectsForView:self];
    NSAccessibilityPostNotification(self, NSAccessibilityLayoutChangedNotification);
}

- (CGFloat)masterWidth {
    return _masterViewWidthConstraint.constant;
}

- (void)setMasterWidth:(CGFloat)masterWidth {
    _masterViewWidthConstraint.constant = masterWidth;
    if (!_collapsed) {
        self.dividerPosition = masterWidth;
    }
}

- (CGFloat)leadingContentInsetForWantsCollapsed:(BOOL)wantsCollapsed {
    if (wantsCollapsed || self._shouldBeCollapsed) {
        return 0.0;
    } else {
        return self.masterWidth;
    }
}

- (void)resetCursorRects {
    if (self.collapsed || _resizing) {
        [super resetCursorRects];
    } else {
        CGRect dividerFrame = _divider.frame;
        [self addCursorRect:dividerFrame cursor:self.dividerCursor];
    }
}

- (NSAccessibilityRole)accessibilityRole {
    return NSAccessibilitySplitGroupRole;
}

- (NSArray *)accessibilityChildren {
    if (self.collapsed) {
        return NSAccessibilityUnignoredChildren(@[self.detailView]);
    } else {
        return NSAccessibilityUnignoredChildren(@[self.detailView, self.masterView]);
    }
}

- (NSArray *)accessibilitySplitters {
    return nil;
}

- (void)toggleSidebar:(id)sender {
    self.wantsCollapsed = self.wantsCollapsed ^ 1;
}

- (NSEdgeInsets)sidebarAdditionalSafeAreaInsets {
    return self.masterView.additionalSafeAreaInsets;
}

- (void)setSidebarAdditionalSafeAreaInsets:(NSEdgeInsets)sidebarAdditionalSafeAreaInsets {
    self.masterView.additionalSafeAreaInsets = sidebarAdditionalSafeAreaInsets;
}

- (CGFloat)dividerWidth {
    return 0.0;
}

- (BOOL)isOverlaidAsSidebar {
    return self.transientlyUncollapsed;
}

- (CGFloat)maximumDividerPosition {
    return self.maximumMasterWidth;
}

- (CGFloat)minimumDividerPosition {
    return self.minimumMasterWidth;
}

- (NSObject *)representedView {
    return self.masterView;
}

- (NSInteger)depthOfView {
    return 0;
}

- (CGFloat)sidebarDividerPosition {
    CGFloat dividerPosition = self.dividerPosition;
    if (self.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        dividerPosition = self.window.contentView.frame.size.width - dividerPosition;
    }
    return dividerPosition;
}

- (void)_performResizeWithGestureRecognizer:(NSGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self];
    CGFloat locationX = location.x;
    CGRect frame = self.frame;
    
    CGFloat rightWidth = CGRectGetMinX(frame) + CGRectGetWidth(frame) - locationX;
    CGFloat leftWidth = locationX - CGRectGetMinX(frame);
    if (self.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        leftWidth = rightWidth;
    }
    [self _resizeToWidth:leftWidth];
    NSAccessibilityPostNotification(self, NSAccessibilityLayoutChangedNotification);
}

- (void)handlePanGestureRecognizer:(NSPanGestureRecognizer *)panGestureRecognizer {
    NSView *view = panGestureRecognizer.view;
    NSWindow *window = view.window;
    switch (panGestureRecognizer.state) {
        case NSGestureRecognizerStatePossible:
            break;
        case NSGestureRecognizerStateBegan:
            _resizing = YES;
            [self _startDividerLiveResize];
            [window invalidateCursorRectsForView:view];
            break;
        case NSGestureRecognizerStateChanged:
            [self _performResizeWithGestureRecognizer:panGestureRecognizer];
            break;
        default:
            [window invalidateCursorRectsForView:view];
            [self _endDividerLiveResize];
            _resizing = NO;
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(NSGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.divider];
    return [self.divider mouse:location inRect:self.bounds];
}

- (BOOL)gestureRecognizer:(NSGestureRecognizer *)gestureRecognizer shouldAttemptToRecognizeWithEvent:(NSEvent *)event {
    return !self.collapsed;
}

- (void)cursorUpdate:(NSEvent *)event {
    if (self.collapsed || !_resizing) {
        [super cursorUpdate:event];
    } else {
        [self.dividerCursor set];
    }
}

- (NSView *)hitTest:(NSPoint)point {
    if (self.collapsed || ![self mouse:point inRect:_divider.frame]) {
        return [super hitTest:point];
    } else {
        return self;
    }
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    if (self.window) {
        [self _noteNeedsSidebarProviderUpdate];
        [self _registerSplitViewItemTrackingIfApplicable];
    }
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [self _removeWindowSidebarTrackingIfApplicable];
    [self _unregisterSplitViewItemTrackingIfApplicable];
    [super viewWillMoveToWindow:newWindow];
}

- (void)_unregisterSplitViewItemTrackingIfApplicable {
    NSWindow *window = self.window;
    if (self.masterView.isRegisteredWithTitlebar) {
        [window unregisterSplitViewItemSeparatorTrackingAdapter:self.masterView];
        self.masterView.isRegisteredWithTitlebar = NO;
    }
    if (self.detailView.isRegisteredWithTitlebar) {
        [window unregisterSplitViewItemSeparatorTrackingAdapter:self.detailView];
        self.detailView.isRegisteredWithTitlebar = NO;
    }
}

- (void)_registerSplitViewItemTrackingIfApplicable {
    NSWindow *window = self.window;
    CGFloat dividerPosition = self.dividerPosition;
    if (dividerPosition > 0.0) {
        if (!self.masterView.isRegisteredWithTitlebar) {
            [window registerSplitViewItemSeparatorTrackingAdapter:self.masterView];
            self.masterView.isRegisteredWithTitlebar = YES;
        }
        if (!self.detailView.isRegisteredWithTitlebar) {
            [window registerSplitViewItemSeparatorTrackingAdapter:self.detailView];
            self.detailView.isRegisteredWithTitlebar = YES;
        }
    }
}

- (void)_removeWindowSidebarTrackingIfApplicable {
    if (_hasProvidedSidebarToWindow) {
        [self.window _sidebarProviderWillRemoveFromWindow:self];
        _hasProvidedSidebarToWindow = NO;
    }
}

- (void)_updateWindowSidebarTrackingIfApplicable {
    if (_needsSidebarProviderUpdate && self.window) {
        _needsSidebarProviderUpdate = NO;
        if (self.masterView) {
            [self.window _sidebarAdapterWasAddedToWindow:self];
            _needsSidebarProviderUpdate = YES;
        }
    }
}

- (void)_noteNeedsSidebarProviderUpdate {
    if (_hasProvidedSidebarToWindow) {
        _needsSidebarProviderUpdate = YES;
    }
}

- (BOOL)_canSpringLoad {
    BOOL collapsed = self.collapsed;
    if (collapsed) {
        collapsed = [self.delegate sourceSplitView:self canSpringLoadRevealSubview:_masterView];
    }
    return collapsed;
}


- (BOOL)_springLoading:(BOOL)springLoading {
    BOOL result = NO;
    if (springLoading) {
        if (self.collapsed && [self.delegate sourceSplitView:self canSpringLoadRevealSubview:self.subviewToReveal]) {
            result = YES;
            _currentlySpringLoading = YES;
            [self setTransientlyUncollapsed:YES animated:YES];
        }
    } else {
        result = YES;
        [self setTransientlyUncollapsed:NO animated:YES];
        _currentlySpringLoading = NO;
    }
    return result;
}

- (void)_didChangeTransientlyUncollapsed {
    if (!_transientlyUncollapsed) {
        [_leadingOverlayShadowView removeFromSuperview];
        _leadingOverlayShadowView = nil;
        _divider.hidden = NO;
        [self _tearDownTransientOverlayWindow];
    }
}

- (void)_endDividerLiveResize {
    if ([NSView instancesRespondToSelector:@selector(_endLiveResize)]) {
        [_masterView _endLiveResize];
        [_detailView _endLiveResize];
    }
}

- (void)_startDividerLiveResize {
    if ([NSView instancesRespondToSelector:@selector(_startLiveResize)]) {
        [_masterView _startLiveResize];
        [_detailView _startLiveResize];
    }
}

- (void)_resizeToWidth:(CGFloat)width {
    width = round(width);
    if (width < self.minimumMasterWidth) {
        width = self.minimumMasterWidth;
    }
    if (width >= self.maximumMasterWidth) {
        width = self.maximumMasterWidth;
    }
    self.masterWidth = width;
    [self.delegate sourceSplitView:self didResizeMasterWidth:width];
    [self.divider.window invalidateCursorRectsForView:self.divider.superview];
}

- (NSCursor *)dividerCursor {
    if (self.masterWidth > self.minimumMasterWidth) {
        if (self.masterWidth < self.maximumMasterWidth) {
            return [NSCursor resizeLeftRightCursor];
        }
        if (self.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
            return [NSCursor resizeRightCursor];
        }
        return [NSCursor resizeLeftCursor];
    }
    if (self.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        return [NSCursor resizeLeftCursor];
    }
    return [NSCursor resizeRightCursor];
}

- (UXView *)subviewToReveal {
    return self.masterView;
}

- (void)setTransientlyUncollapsed:(BOOL)transientlyUncollapsed animated:(BOOL)animated {
    if (_transientlyUncollapsed != transientlyUncollapsed) {
        _transientlyUncollapsed = transientlyUncollapsed;
        if (transientlyUncollapsed) {
            [self _setupTransientOverlayWindow];
            _divider.hidden = YES;
            _leadingOverlayShadowView = [_UXSourceSplitViewShadowView new];
            _leadingOverlayShadowView.translatesAutoresizingMaskIntoConstraints = NO;
            _leadingOverlayShadowView.shadowEdge = 2 * (self.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft);
            [_divider.superview addSubview:_leadingOverlayShadowView];
            [_leadingOverlayShadowView.leadingAnchor constraintEqualToAnchor:_divider.trailingAnchor constant:-0.5].active = YES;
            [_leadingOverlayShadowView.topAnchor constraintEqualToAnchor:_divider.topAnchor].active = YES;
            [_leadingOverlayShadowView.bottomAnchor constraintEqualToAnchor:_divider.bottomAnchor].active = YES;
            [_divider.superview layoutSubtreeIfNeeded];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        CGFloat duration = animated ? 0.3 : 0.0;
        [UXView animateWithDuration:duration delay:0.0 options:(UXViewAnimationOptionTransitionNone) animations:^{
            [self _setCollapsed:transientlyUncollapsed == NO shouldLayoutSubtree:YES];
        } completion:^(BOOL finished) {
            [self _didChangeTransientlyUncollapsed];
        }];
    }
}

- (void)_tearDownTransientOverlayWindow {
    [self addSubview:_masterView];
    [self _moveMasterAndSeparatorToView:self];
    [self.transientOverlayWindow orderOut:nil];
    self.transientOverlayWindow = nil;
}

- (void)_setupTransientOverlayWindow {
    NSWindow *window = self.window;
    NSWindowStyleMask styleMask = self.window.styleMask;
    NSWindowStyleMask newStyleMask = styleMask;
    if (!window.ux_toolbarHiddenInFullScreen) {
        newStyleMask = newStyleMask ^ NSWindowStyleMaskFullScreen;
    }
    CGRect contentRect = [window contentRectForFrameRect:window.frame styleMask:newStyleMask];
    NSWindow *newWindow = [[NSWindow alloc] initWithContentRect:contentRect styleMask:(styleMask >> 14) & NSWindowStyleMaskFullSizeContentView backing:(NSBackingStoreBuffered) defer:NO];
    newWindow.titlebarAppearsTransparent = YES;
    
    
    _UXSourceSplitViewFullScreenOverlayContentView *fullScreenOverlayContentView = [[_UXSourceSplitViewFullScreenOverlayContentView alloc] initWithFrame:contentRect];
    
    fullScreenOverlayContentView.cursorProvider = self;
    fullScreenOverlayContentView.dividerView = self.divider;
    fullScreenOverlayContentView.appearance = window.appearance;
    newWindow.contentView = fullScreenOverlayContentView;
    [window addChildWindow:newWindow ordered:(NSWindowAbove)];
    newWindow.backgroundColor = [NSColor clearColor];
    newWindow.opaque = NO;
    [self _moveMasterAndSeparatorToView:fullScreenOverlayContentView];
    [newWindow becomeKeyWindow];
    self.transientOverlayWindow = newWindow;
}

- (void)_moveMasterAndSeparatorToView:(NSView *)view {
    [view addSubview:self.masterView];
    [view addSubview:self.divider];
    [self.resizeRecognizer.view removeGestureRecognizer:self.resizeRecognizer];
    [view addGestureRecognizer:self.resizeRecognizer];
    [self updateConstraintsForDividerAndMain];
}

- (CGFloat)dividerPosition {
    return _dividerTrailingConstraint.constant;
}

- (void)setDividerPosition:(CGFloat)dividerPosition {
    if (_dividerTrailingConstraint.constant != dividerPosition) {
        NSString *key = NSStringFromSelector(@selector(sidebarDividerPosition));
        [self willChangeValueForKey:key];
        _detailView.dividerPosition = dividerPosition;
        _dividerTrailingConstraint.constant = dividerPosition;
        [self didChangeValueForKey:key];
    }
}

- (void)updateConstraintsForDividerAndMain {
    _dividerTrailingConstraint = [_divider.trailingAnchor constraintEqualToAnchor:self.divider.superview.leadingAnchor constant:_dividerTrailingConstraint.constant];
    _dividerTrailingConstraint.active = YES;
    NSDictionary<NSString *, id> *views = @{
        @"divider": self.divider,
        @"masterView": self.masterView,
    };
    NSArray<NSLayoutConstraint *> *hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[masterView]-(-1)-[divider]" options:(NSLayoutFormatDirectionLeadingToTrailing) metrics:nil views:views];
    [NSLayoutConstraint activateConstraints:hConstraints];
    [self.divider.topAnchor constraintEqualToAnchor:self.masterView.topAnchor].active = YES;
    [self.divider.bottomAnchor constraintEqualToAnchor:self.masterView.bottomAnchor].active = YES;
    NSArray<NSLayoutConstraint *> *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[divider]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views];
    _dividerVerticalConstraints = vConstraints;
    [NSLayoutConstraint activateConstraints:vConstraints];
}

- (void)windowDidResize:(NSNotification *)notification {
    if (![notification.name isEqualToString:NSWindowDidResizeNotification]) {
        return;
    }
    if (self.window == notification.object && self.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        NSString *key = NSStringFromSelector(@selector(sidebarDividerPosition));
        [self willChangeValueForKey:key];
        [self didChangeValueForKey:key];
    }
}


@end
