#import <objc/runtime.h>
#import <OpenUXKit/NSResponder+UXKit.h>
#import <OpenUXKit/NSView+UXKit.h>
#import <OpenUXKit/UXLayoutSupport.h>
#import <OpenUXKit/UXNavigationController+Internal.h>
#import <OpenUXKit/UXNavigationController.h>
#import <OpenUXKit/UXNavigationDestination.h>
#import <OpenUXKit/UXNavigationItem.h>
#import <OpenUXKit/UXPopoverController.h>
#import <OpenUXKit/UXSourceController.h>
#import <OpenUXKit/UXTabBarController.h>
#import <OpenUXKit/UXTabBarItem.h>
#import <OpenUXKit/UXTabBarItem.h>
#import <OpenUXKit/UXTabBarItemSegment.h>
#import <OpenUXKit/UXView+Internal.h>
#import <OpenUXKit/UXViewController+Internal.h>
#import <OpenUXKit/UXViewControllerTransitionCoordinator.h>
#import <OpenUXKit/UXWindowController.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenUXKit/UXKitPrivateUtilites.h>

@implementation UXViewController

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (nibNameOrNil == nil) {
        NSString *nibClassName = NSStringFromClass([self class]);
        NSString *nibPath = [[NSBundle mainBundle] pathForResource:nibClassName ofType:@"nib"];
        nibNameOrNil = nibPath ? nibClassName : nil;
    }

    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self _commonInit];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self _commonInit];
    }

    return self;
}

- (void)_commonInit {
    _edgesForExtendedLayout = UXRectEdgeAll;
    _isEditing = NO;
    _automaticallyAdjustsScrollViewInsets = YES;
    _preferredSubtoolbarPosition = 2;
}

- (void)loadView {
    if (self.nibName) {
        [super loadView];
    } else {
        UXView *view = [[[[self class] viewClass] alloc] initWithFrame:[self _defaultInitialFrame]];
        view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [view setBackgroundColor:NSColor.clearColor];
        self.view = view;
    }
}

+ (Class)viewClass {
    return [UXView class];
}

- (CGRect)_defaultInitialFrame {
    return CGRectMake(0, 0, 500, 500);
}

- (void)setView:(NSView *)view {
    if (view) {
        if (![view isKindOfClass:[UXView class]]) {
            NSAssert([view isKindOfClass:[UXView class]], @"%s, the view is not of class UXView.", __FUNCTION__);
        }
    }

    UXView *uxView = (UXView *)view;

    if ([view isKindOfClass:[UXView class]]) {
        uxView.viewControllerProxy = self;
    }

    if (uxView) {
        [self _setupLayoutGuidesForView:uxView];
    }

    [super setView:uxView];

    if (CGSizeEqualToSize(_ux_preferredContentSize, CGSizeZero)) {
        if (uxView) {
            self.preferredContentSize = uxView.bounds.size;
        } else {
            self.preferredContentSize = CGSizeZero;
        }
    }
}

- (void)_setupLayoutGuidesForView:(UXView *)view {
    _UXLayoutSpacer *topLayoutGuide = cast(_UXLayoutSpacer *, self.topLayoutGuide);
    _UXLayoutSpacer *bottomLayoutGuide = cast(_UXLayoutSpacer *, self.bottomLayoutGuide);

    [view addLayoutGuide:topLayoutGuide];
    [view addLayoutGuide:bottomLayoutGuide];
    [topLayoutGuide _activate];
    [bottomLayoutGuide _activate];
    [view.topAnchor constraintEqualToAnchor:topLayoutGuide.topAnchor].active = YES;
    [view.bottomAnchor constraintEqualToAnchor:bottomLayoutGuide.bottomAnchor].active = YES;
}

- (id<UXLayoutSupport>)topLayoutGuide {
    if (_topLayoutGuide == nil) {
        _topLayoutGuide = [_UXLayoutSpacer _verticalLayoutSpacer];
        __weak typeof(self) weakSelf = self;
        [_topLayoutGuide setLengthUpdateBlock:^{
            [weakSelf didUpdateLayoutGuides];
        }];
    }

    return _topLayoutGuide;
}

- (id<UXLayoutSupport>)bottomLayoutGuide {
    if (_bottomLayoutGuide == nil) {
        _bottomLayoutGuide = [_UXLayoutSpacer _verticalLayoutSpacer];
        __weak typeof(self) weakSelf = self;
        [_bottomLayoutGuide setLengthUpdateBlock:^{
            [weakSelf didUpdateLayoutGuides];
        }];
    }

    return _bottomLayoutGuide;
}

- (void)setPreferredContentSize:(NSSize)preferredContentSize {
    if (_ux_preferredContentSize.width != preferredContentSize.width || _ux_preferredContentSize.height != preferredContentSize.height) {
        _ux_preferredContentSize = preferredContentSize;
    }
}

- (NSView *)viewIfLoaded {
    if (self.isViewLoaded) {
        return self.view;
    } else {
        return nil;
    }
}

- (void)_loadViewIfNotLoaded {
    if (!self.isViewLoaded) {
        [self view];
    }
}

- (UXView *)uxView {
    NSView *view = self.view;

    if ([view isKindOfClass:[UXView class]]) {
        return (UXView *)view;
    } else {
        return nil;
    }
}

- (void)updateViewConstraints {
    [self.uxView updateConstraints];
}

- (void)viewWillLayoutSubviews {
}

- (void)viewDidLayoutSubviews {
}

- (void)viewUpdateLayer {
}

- (void)viewDidLiveResize {
}

- (void)viewWillLiveResize {
}

- (void)viewWillAppear {
    [self viewWillAppear:NO];
    [super viewWillAppear];
    [self _startObservingFullScreenNotifications];
}

- (void)viewDidAppear {
    [self viewDidAppear:NO];
    [super viewDidAppear];
}

- (void)viewWillDisappear {
    [self viewWillDisappear:NO];
    [super viewWillDisappear];
    [self _stopObservingFullScreenNotifications];
}

- (void)viewDidDisappear {
    [self viewDidDisappear:NO];
    [super viewDidDisappear];
}

- (void)windowWillRecalculateKeyViewLoop {
    for (NSViewController *childViewController in self.childViewControllers) {
        if ([childViewController isKindOfClass:[UXViewController class]]) {
            [((UXViewController *)childViewController) windowWillRecalculateKeyViewLoop];
        }
    }
}

- (void)windowDidRecalculateKeyViewLoop {
    for (NSViewController *childViewController in self.childViewControllers) {
        if ([childViewController isKindOfClass:[UXViewController class]]) {
            [((UXViewController *)childViewController) windowDidRecalculateKeyViewLoop];
        }
    }
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    [_navigationItem setTitle:title];
    [_tabBarItem setTitle:title];
}

- (void)addChildViewController:(NSViewController *)childViewController {
    if (childViewController) {
        [super addChildViewController:childViewController];

        if ([childViewController isKindOfClass:[UXViewController class]]) {
            UXViewController *uxChildViewController = (UXViewController *)childViewController;
            NSArray<NSViewController *> *presentedViewControllers = [self presentedViewControllers];

            if (![presentedViewControllers containsObject:childViewController]) {
                NSEdgeInsets intrinsicLayoutInsets = [self intrinsicLayoutInsets];
                uxChildViewController.topLayoutGuide.length = intrinsicLayoutInsets.top + self.topLayoutGuide.length;
                uxChildViewController.bottomLayoutGuide.length = intrinsicLayoutInsets.bottom + self.bottomLayoutGuide.length;
            }
        }
    }
}

- (void)willMoveToParentViewController:(UXViewController *)parent {
}

- (void)didUpdateLayoutGuides {
    [self invalidateIntrinsicLayoutInsets];
}

- (void)invalidateIntrinsicLayoutInsets {
    for (NSViewController *childViewController in self.childViewControllers) {
        if ([childViewController isKindOfClass:[UXViewController class]]) {
            UXViewController *uxChildViewController = (UXViewController *)childViewController;

            if (uxChildViewController.edgesForExtendedLayout & UXRectEdgeTop) {
                NSEdgeInsets intrinsicLayoutInsets = self.intrinsicLayoutInsets;
                uxChildViewController.topLayoutGuide.length = intrinsicLayoutInsets.top + self.topLayoutGuide.length;
            }

            if (uxChildViewController.edgesForExtendedLayout & UXRectEdgeBottom) {
                NSEdgeInsets intrinsicLayoutInsets = self.intrinsicLayoutInsets;
                uxChildViewController.bottomLayoutGuide.length = intrinsicLayoutInsets.bottom + self.bottomLayoutGuide.length;
            }
        }
    }
}

- (UXRectEdge)edgesForExtendedLayout {
    return _edgesForExtendedLayout;
}

- (NSEdgeInsets)intrinsicLayoutInsets {
    return NSEdgeInsetsMake(0, 0, 0, 0);
}

- (id)_ancestorViewControllerOfClass:(Class)class {
    NSViewController *parentViewController = self.parentViewController;

    if ([parentViewController isKindOfClass:class]) {
        return parentViewController;
    } else {
        return [((UXViewController *)parentViewController) _ancestorViewControllerOfClass:class];
    }
}

- (void)didMoveToParentViewController:(UXViewController *)parent {
}

- (id<UXViewControllerTransitionCoordinator>)transitionCoordinator {
    _ignoreViewController = YES;
    UXViewController *parentViewController = (UXViewController *)self.parentViewController;

    if (parentViewController && !parentViewController->_ignoreViewController) {
        return [parentViewController transitionCoordinator];
    } else {
        return nil;
    }
}

+ (CGFloat)defaultToolbarHeight {
    return 32.0;
}

- (BOOL)_requiresWindowForTransitionPreparation {
    return NO;
}

+ (NSArray<NSString *> *)toolbarPropertyNames {
    static dispatch_once_t onceToken;
    static NSArray<NSString *> *toolbarPropertyNames = nil;

    dispatch_once(&onceToken, ^{
        toolbarPropertyNames = @[
            @"toolbarItems",
            @"preferredToolbarHeight",
            @"preferredToolbarBaselineOffsetFromBottom",
            @"preferredToolbarStyle",
            @"preferredToolbarDecorationInsets",
            @"subtoolbarItems",
            @"preferredSubtoolbarHeight",
            @"preferredSubtoolbarBaselineOffsetFromBottom",
            @"preferredSubtoolbarPosition",
        ];
    });
    return toolbarPropertyNames;
}

- (NSResponder *)preferredFirstResponder {
    if (self.acceptsFirstResponder) {
        if (@available(macOS 14.0, *)) {
            return self.viewIfLoaded;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)contentRepresentingViewControllerDidChange {
    UXViewController *ancestorViewController = [self _ancestorViewControllerOfClass:[UXViewController class]];

    [ancestorViewController contentRepresentingViewControllerDidChange];
}

- (void)_prepareForAnimationInContext:(id)context completion:(void (^)(void))completion {
    [self prepareForTransitionWithContext:context completion:completion];
}

- (UXBarPosition)preferredToolbarPosition {
    return UXBarPositionTop;
}

- (UXViewController *)contentRepresentingViewController {
    return self;
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    if ([self.parentViewController respondsToSelector:@selector(menuForEvent:)]) {
        return [self.parentViewController performSelector:@selector(menuForEvent:) withObject:event];
    } else {
        return nil;
    }
}

- (CGSize)preferredContentSizeCappedToSize:(CGSize)size {
    CGSize preferredContentSize = self.preferredContentSize;

    if (preferredContentSize.height >= size.height) {
        preferredContentSize.height = size.height;
    }

    if (preferredContentSize.width >= size.width) {
        preferredContentSize.width = size.width;
    }

    return preferredContentSize;
}

- (NSSize)preferredContentSize {
    CGSize result = _ux_preferredContentSize;

    if (CGSizeEqualToSize(_ux_preferredContentSize, CGSizeZero)) {
        CGRect bounds = self.view.bounds;
        result.width = bounds.size.width;
        result.height = bounds.size.height;
    }

    return result;
}

- (void)_animateView:(UXView *)view fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"frameOrigin"];

    NSValue *fromValue = [NSValue valueWithPoint:NSMakePoint(fromFrame.origin.x, fromFrame.origin.y)];
    NSValue *toValue = [NSValue valueWithPoint:NSMakePoint(toFrame.origin.x, toFrame.origin.y)];

    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.removedOnCompletion = YES;
    view.animations = @{
            @"frameOrigin": animation
    };

    view.frame = toFrame;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [self setEditing:editing];
}

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {}

- (void)presentViewController:(UXViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {}

- (UXViewController *)ux_presentingViewController {
    NSViewController *presentingViewController = [super presentingViewController];

    if ([presentingViewController isKindOfClass:[UXViewController class]]) {
        return (UXViewController *)presentingViewController;
    } else {
        return nil;
    }
}

- (UXViewController *)ux_parentViewController {
    NSViewController *presentingViewController = [super parentViewController];

    if ([presentingViewController isKindOfClass:[UXViewController class]]) {
        return (UXViewController *)presentingViewController;
    } else {
        return nil;
    }
}

- (UXViewController *)presentedViewController {
    NSArray<__kindof NSViewController *> *presentedViewControllers = self.presentedViewControllers;

    return presentedViewControllers.lastObject;
}

- (void)removeChildViewControllerAtIndex:(NSInteger)index {
    if (self.childViewControllers.count > index) {
        [super removeChildViewControllerAtIndex:index];
    }
}

- (void)windowDidExitFullScreen {
}

- (void)windowDidEnterFullScreen {
}

- (void)windowWillExitFullScreen {
}

- (void)windowWillEnterFullScreen {
}

- (BOOL)isWindowConsideredInFullScreen {
    if (_transitioningIntoFullScreen) {
        return YES;
    }

    if (_transitioningOutOfFullScreen) {
        return NO;
    }

    return self.isWindowInFullScreen;
}

- (BOOL)isWindowInFullScreen {
    NSWindow *window = self.viewIfLoaded.window;
    NSWindow *targetWindow = nil;

    if (window) {
        targetWindow = window;
    } else {
        NSWindow *parentWindow = self.parentViewController.view.window;

        if (parentWindow) {
            targetWindow = parentWindow;
        } else {
            targetWindow = self.transitionCoordinator.containerView.window;
        }
    }

    return targetWindow.styleMask & NSWindowStyleMaskFullScreen;
}

- (void)_stopObservingFullScreenNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center removeObserver:self name:NSWindowWillEnterFullScreenNotification object:nil];
    [center removeObserver:self name:NSWindowDidEnterFullScreenNotification object:nil];
    [center removeObserver:self name:NSWindowWillExitFullScreenNotification object:nil];
    [center removeObserver:self name:NSWindowDidExitFullScreenNotification object:nil];
}

- (void)_startObservingFullScreenNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self selector:@selector(_willEnterFullScreenNotification:) name:NSWindowWillEnterFullScreenNotification object:nil];
    [center addObserver:self selector:@selector(_didEnterFullScreenNotification:) name:NSWindowDidEnterFullScreenNotification object:nil];
    [center addObserver:self selector:@selector(_willExitFullScreenNotification:) name:NSWindowWillExitFullScreenNotification object:nil];
    [center addObserver:self selector:@selector(_didExitFullScreenNotification:) name:NSWindowDidExitFullScreenNotification object:nil];
}

- (void)_didExitFullScreenNotification:(NSNotification *)notification {
    if (self.viewIfLoaded.window == notification.object) {
        _transitioningIntoFullScreen = NO;
        _transitioningOutOfFullScreen = NO;
        [self windowDidExitFullScreen];
    }
}

- (void)_willExitFullScreenNotification:(NSNotification *)notification {
    if (self.viewIfLoaded.window == notification.object) {
        _transitioningIntoFullScreen = NO;
        _transitioningOutOfFullScreen = YES;
        [self windowWillExitFullScreen];
    }
}

- (void)_didEnterFullScreenNotification:(NSNotification *)notification {
    if (self.viewIfLoaded.window == notification.object) {
        _transitioningIntoFullScreen = NO;
        _transitioningOutOfFullScreen = NO;
        [self windowDidEnterFullScreen];
    }
}

- (void)_willEnterFullScreenNotification:(NSNotification *)notification {
    if (self.viewIfLoaded.window == notification.object) {
        _transitioningIntoFullScreen = YES;
        _transitioningOutOfFullScreen = NO;
        [self windowWillEnterFullScreen];
    }
}

- (BOOL)delegatesSidebarAndToolbarFullscreenVisibilityManagement {
    return YES;
}

- (BOOL)prefersSidebarAndToolbarHiddenInFullscreenWindowMode {
    return NO;
}

- (void)updateFirstResponderIfNeeded {
    NSResponder *firstResponder = self.view.window.firstResponder;

    if ([self isInResponderChainOf:firstResponder] && ![self.preferredFirstResponder isInResponderChainOf:firstResponder]) {
        [self.view.window makeFirstResponder:self.preferredFirstResponder];
    }
}

- (void)performActionForSelectingCurrentTabBarItemSegment {
}

- (void)prepareForTransitionToSelectedTabBarItemSegmentWithCompletion:(void (^)(void))completion {
    if (completion) {
        completion();
    }
}

@end

@implementation UXViewController (UXNavigationControllerItem)

- (void)setHidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed {
    _hidesBottomBarWhenPushed = hidesBottomBarWhenPushed;
}

- (BOOL)hidesBottomBarWhenPushed {
    return _hidesBottomBarWhenPushed;
}

- (void)setToolbarViewController:(UXViewController *)toolbarViewController {
    _toolbarViewController = toolbarViewController;
}

- (UXViewController *)toolbarViewController {
    return _toolbarViewController;
}

- (void)setToolbarItems:(NSArray *)toolbarItems {
    if (toolbarItems.count) {
        CGFloat preferredToolbarHeight = self.preferredToolbarHeight;

        if (preferredToolbarHeight == 0.0) {
            self.preferredToolbarHeight = [self class].defaultToolbarHeight;
        }

        CGFloat preferredToolbarBaselineOffsetFromBottom = self.preferredToolbarBaselineOffsetFromBottom;

        if (preferredToolbarBaselineOffsetFromBottom == 0.0) {
            self.preferredToolbarBaselineOffsetFromBottom = 10.0;
        }

        if (!self.preferredToolbarStyle) {
            self.preferredToolbarStyle = 1;
        }
    }

    _toolbarItems = toolbarItems;
}

- (void)setToolbarItems:(NSArray *)toolbarItems animated:(BOOL)animated {
    [self performToolbarsChanges:^{
        if (animated) {
            [self setShouldAnimateToolbarsChanges];
        }

        [self setToolbarItems:toolbarItems];
    }];
}

- (NSArray *)toolbarItems {
    return _toolbarItems;
}

- (void)setSubtoolbarItems:(NSArray *)subtoolbarItems {
    _subtoolbarItems = subtoolbarItems;
}

- (NSArray *)subtoolbarItems {
    return _subtoolbarItems;
}

- (UXNavigationItem *)navigationItem {
    if (_navigationItem == nil) {
        _navigationItem = [[UXNavigationItem alloc] initWithTitle:self.title];
        NSUserInterfaceItemIdentifier identifier = self.identifier;

        if (identifier) {
            _navigationItem.identifier = identifier;
        } else {
            _navigationItem.identifier = NSStringFromClass([self class]);
        }
    }

    return _navigationItem;
}

- (UXNavigationController *)navigationController {
    return [self _ancestorViewControllerOfClass:[UXNavigationController class]];
}

- (void)setAccessoryViewController:(UXViewController *)accessoryViewController {
    _accessoryViewController = accessoryViewController;
}

- (UXViewController *)accessoryViewController {
    return _accessoryViewController;
}

- (void)setAccessoryBarItems:(NSArray *)accessoryBarItems {
    _accessoryBarItems = accessoryBarItems;
}

- (NSArray *)accessoryBarItems {
    return _accessoryBarItems;
}

@end


@implementation UXViewController (UXNavigationControllerContextualToolbarItems_Private)

- (void)performToolbarsChanges:(void (^)(void))changesBlock {
    UXNavigationController *navigationController = nil;

    if ([self isKindOfClass:[UXNavigationController class]]) {
        navigationController = (UXNavigationController *)self;
    } else {
        navigationController = self.navigationController;
    }

    if (navigationController) {
        [navigationController performToolbarsChanges:changesBlock];
    } else if (changesBlock) {
        changesBlock();
    }
}

- (void)setShouldAnimateToolbarsChanges {
    UXNavigationController *navigationController = nil;

    if ([self isKindOfClass:[UXNavigationController class]]) {
        navigationController = (UXNavigationController *)self;
    } else {
        navigationController = self.navigationController;
    }

    if (navigationController) {
        [navigationController setShouldAnimateToolbarUpdates:YES];
    }
}

@end


@implementation UXViewController (Compatibility)

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (NSInteger)interfaceOrientation {
    return 4;
}

@end

@implementation UXViewController (UXViewControllerTransitioning)

- (void)prepareForTransitionWithContext:(id)context completion:(void (^)(void))completion {
    if (completion) {
        completion();
    }
}

@end

@implementation UXViewController (UXSourceController)
- (UXSourceController *)sourceController {
    return [self _ancestorViewControllerOfClass:[UXSourceController class]];
}

- (BOOL)isTransitory {
    return [objc_getAssociatedObject(self, @selector(setTransitory:)) boolValue];
}

- (void)setTransitory:(BOOL)transitory {
    objc_setAssociatedObject(self, _cmd, [NSNumber numberWithBool:transitory], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setHidesSourceListWhenPushed:(BOOL)hidesSourceListWhenPushed {
    objc_setAssociatedObject(self, _cmd, [NSNumber numberWithBool:hidesSourceListWhenPushed], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hidesSourceListWhenPushed {
    return [objc_getAssociatedObject(self, @selector(setHidesSourceListWhenPushed:)) boolValue];
}

- (BOOL)canProvideViewControllersForNavigationDestination:(id<UXNavigationDestination>)navigationDestination {
    return [self.navigationDestination isEqual:navigationDestination];
}

- (void)updateForEqualNavigationDestination:(id<UXNavigationDestination>)navigationDestination {
}

- (void)requestViewControllersForNavigationDestination:(id<UXNavigationDestination>)navigationDestination completion:(void (^)(BOOL, NSArray<UXViewController *> *_Nonnull))completion {
    completion(NO, @[self]);
}

- (void)willEncodeNavigationDestination:(id<UXNavigationDestination>)navigationDestination {
}

- (id<UXNavigationDestination>)navigationDestination {
    return nil;
}

@end


@implementation UXViewController (UXTabBarController)

- (UXTabBarItem *)tabBarItem {
    if (_tabBarItem == nil) {
        _tabBarItem = [[UXTabBarItem alloc] initWithTitle:self.title];
    }

    return _tabBarItem;
}

- (void)setTabBarItem:(UXTabBarItem *)tabBarItem {
    _tabBarItem = tabBarItem;
}

- (UXTabBarController *)tabBarController {
    if ([self.parentViewController isKindOfClass:[UXTabBarController class]]) {
        return (UXTabBarController *)self.parentViewController;
    } else {
        return nil;
    }
}

@end

@implementation UXViewController (UXWindowController)

- (UXWindowController *)windowController {
    NSWindowController *windowController = self.view.window.windowController;

    if ([windowController isKindOfClass:[UXWindowController class]]) {
        return (UXWindowController *)windowController;
    }

    return nil;
}

@end


@implementation UXViewController (UXTabBarController_Private)

- (UXTabBarItemSegment *)preferredTabBarItemSegmentForNavigationDestination:(id<UXNavigationDestination>)navigationDestination {
    return self.tabBarItem.representedSegments.firstObject;
}

@end

@implementation UXViewController (UXPopoverController)

- (UXPopoverController *)popoverController {
    return [self _ancestorViewControllerOfClass:[UXPopoverController class]];
}

@end
