#import <OpenUXKit/UXSourceController.h>
#import <OpenUXKit/UXSourceList.h>
#import <OpenUXKit/UXNavigationDestination.h>
#import <OpenUXKit/UXNavigationController+Internal.h>
#import <OpenUXKit/UXNavigationBar+Internal.h>
#import <OpenUXKit/UXNavigationItem+Internal.h>
#import <OpenUXKit/UXViewController+Internal.h>
#import <OpenUXKit/UXView+Internal.h>
#import <OpenUXKit/UXWindowController.h>
#import <OpenUXKit/UXTransitionController.h>
#import <OpenUXKit/UXTabBarItem.h>
#import <OpenUXKit/NSResponder+UXKit.h>
#import <OpenUXKit/NSWindow+UXKit.h>
#import <OpenUXKit/UXKitPrivateUtilites.h>
#import <OpenUXKit/UXViewControllerTransitionCoordinator.h>
#import <OpenUXKit/_UXViewControllerOneToOneTransitionContext.h>
#import <OpenUXKit/_UXViewControllerTransitionContext.h>
#import <OpenUXKit/_UXViewControllerTransitionCoordinator.h>
#import <OpenUXKit/_UXDetailViewController.h>
#import <OpenUXKit/_UXInspectorViewController.h>

static void *kFirstResponderObserverContext = &kFirstResponderObserverContext;
static void *kCollapsedObserverContext = &kCollapsedObserverContext;
static void *kInspectorViewControllerObserverContext = &kInspectorViewControllerObserverContext;

UXKIT_EXTERN Class _transitionControllerClassForTransition(NSUInteger transition);

@implementation UXSourceController

@synthesize observedWindow = _observedWindow;
@synthesize observedNavigationController = _observedNavigationController;
@synthesize selectedViewController = _selectedViewController;
@synthesize selectedNavigationTopViewController = _selectedNavigationTopViewController;
@synthesize selectedNavigationViewConstraints = _selectedNavigationViewConstraints;
@synthesize detailViewController = _detailViewController;
@synthesize inspectorViewController = _inspectorViewController;
@synthesize sidebarSplitViewItem = _sidebarSplitViewItem;
@synthesize detailSplitViewItem = _detailSplitViewItem;
@synthesize inspectorSplitViewItem = _inspectorSplitViewItem;
@synthesize detailSplitViewItemTopAccessoryViewController = _detailSplitViewItemTopAccessoryViewController;
@synthesize wantsDetachedNavigationBars = _wantsDetachedNavigationBars;
@synthesize wantsDetachedToolbars = _wantsDetachedToolbars;
@synthesize wantsSourceListHidden = _wantsSourceListHidden;
@synthesize sourceListViewController = _sourceListViewController;
@synthesize sourceListAutosaveName = _sourceListAutosaveName;
@synthesize rootViewControllers = _rootViewControllers;
@synthesize searchToolbarItem = _searchToolbarItem;

#pragma mark - Initialization

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _needsToSetInitialSourceListWidth = YES;
        _wantsSourceListCollapsed = NO;

        // Create detail view controller and its split view item
        _detailViewController = [_UXDetailViewController new];
        _detailSplitViewItem = [NSSplitViewItem contentListWithViewController:_detailViewController];

        // Create top accessory view controller
        _detailSplitViewItemTopAccessoryViewController = [NSSplitViewItemAccessoryViewController new];
        _detailSplitViewItemTopAccessoryViewController.automaticallyAppliesContentInsets = NO;
        _detailSplitViewItemTopAccessoryViewController.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 500, 32)];

        _detailSplitViewItem.automaticallyAdjustsSafeAreaInsets = YES;
        _detailSplitViewItem.minimumThickness = 550.0;
        [self addSplitViewItem:_detailSplitViewItem];

        // Create inspector view controller and its split view item
        _inspectorViewController = [_UXInspectorViewController new];
        _inspectorSplitViewItem = [NSSplitViewItem inspectorWithViewController:_inspectorViewController];
        _inspectorSplitViewItem.canCollapse = NO;
        _inspectorSplitViewItem.collapsed = YES;
        [self addSplitViewItem:_inspectorSplitViewItem];

        // Create map tables and operation queue
        _navigationControllerByRootViewController = [NSMapTable weakToStrongObjectsMapTable];
        _transitionControllerClassByToViewControllerClass = [NSMapTable weakToWeakObjectsMapTable];
        _viewControllerOperations = [NSOperationQueue new];
        _viewControllerOperations.maxConcurrentOperationCount = 1;
        _viewControllerOperations.qualityOfService = NSQualityOfServiceUserInitiated;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.splitView.accessibilityIdentifier = @"UXSourceControllerSplitView";
}

- (void)viewWillAppear {
    [super viewWillAppear];
    if (_needsToSetInitialSourceListWidth) {
        NSSplitViewItem *firstItem = self.splitViewItems.firstObject;
        if (firstItem == _sidebarSplitViewItem) {
            _needsToSetInitialSourceListWidth = NO;
            CGFloat preferredWidth = [self _preferredSourceListWidth];
            [self.splitView setPosition:preferredWidth ofDividerAtIndex:0];
            [self _updateSplitViewAutosaveName];
            [_inspectorSplitViewItem setCollapsed:YES];
        }
    }
}

- (void)viewDidAppear {
    [super viewDidAppear];
    NSWindow *window = self.view.window;
    self.observedWindow = window;
    _sidebarSplitViewItem.canCollapseFromWindowResize = YES;
}

#pragma mark - UXViewController Protocol

- (NSResponder *)preferredFirstResponder {
    NSResponder *preferredFirstResponder = self.selectedNavigationController.preferredFirstResponder;
    if (!preferredFirstResponder) {
        preferredFirstResponder = self;
    }
    return preferredFirstResponder;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (id<UXLayoutSupport>)topLayoutGuide {
    return _topLayoutGuide;
}

- (id<UXLayoutSupport>)bottomLayoutGuide {
    return _bottomLayoutGuide;
}

- (BOOL)isWindowInFullScreen {
    return NO;
}

- (BOOL)isWindowConsideredInFullScreen {
    return NO;
}

- (NSViewController *)contentRepresentingViewController {
    return nil;
}

- (id<UXViewControllerTransitionCoordinator>)transitionCoordinator {
    if (_isTransitioning) {
        return _transitionCtx._transitionCoordinator;
    } else {
        return nil;
    }
}

- (void)willMoveToParentViewController:(id)parent {}
- (void)didMoveToParentViewController:(id)parent {}
- (void)windowDidRecalculateKeyViewLoop {}
- (void)windowWillRecalculateKeyViewLoop {}
- (void)contentRepresentingViewControllerDidChange {}

- (void)invalidateIntrinsicLayoutInsets {}

- (void)didUpdateLayoutGuides {
    [self invalidateIntrinsicLayoutInsets];
}

- (void)presentViewController:(UXViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    viewController.transitory = YES;
    UXNavigationController *navigationController = self.selectedNavigationController;
    [navigationController pushViewController:viewController animated:animated];

    if (completion) {
        id<UXViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
        if (coordinator) {
            [coordinator animateAlongsideTransition:nil completion:^(id<UXViewControllerTransitionCoordinatorContext> context) {
                completion();
            }];
        } else {
            completion();
        }
    }
}

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    UXNavigationController *navigationController = self.selectedNavigationController;
    [navigationController _popTransitoryViewControllersAnimated:animated];

    if (completion) {
        id<UXViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
        if (coordinator) {
            [coordinator animateAlongsideTransition:nil completion:^(id<UXViewControllerTransitionCoordinatorContext> context) {
                completion();
            }];
        } else {
            completion();
        }
    }
}

#pragma mark - Source List

- (void)setSourceListViewController:(UXViewController<UXSourceList> *)sourceListViewController {
    if (_sourceListViewController == sourceListViewController) {
        return;
    }

    if (_sourceListViewController) {
        NSParameterAssert(_sidebarSplitViewItem.viewController == _sourceListViewController);
        [_sourceListViewController willMoveToParentViewController:nil];
        [_sidebarSplitViewItem removeObserver:self forKeyPath:@"collapsed" context:kCollapsedObserverContext];
        [self removeSplitViewItem:_sidebarSplitViewItem];
    }

    _sourceListViewController = sourceListViewController;

    if (_sourceListViewController) {
        NSParameterAssert([_sourceListViewController conformsToProtocol:@protocol(UXSourceList)]);

        _sidebarSplitViewItem = [NSSplitViewItem sidebarWithViewController:_sourceListViewController];
        _sidebarSplitViewItem.preferredThicknessFraction = _sourceListViewController.sourceListPreferredWidthFraction;
        _sidebarSplitViewItem.minimumThickness = _sourceListViewController.sourceListMinimumWidth;
        _sidebarSplitViewItem.maximumThickness = _sourceListViewController.sourceListMaximumWidth;

        [self insertSplitViewItem:_sidebarSplitViewItem atIndex:0];
        [_sourceListViewController didMoveToParentViewController:self];

        [_sidebarSplitViewItem addObserver:self forKeyPath:@"collapsed" options:0 context:kCollapsedObserverContext];

        // Set preferred width
        NSView *sourceListView = _sourceListViewController.view;
        CGRect frame = sourceListView.frame;
        CGFloat preferredWidth = [self _preferredSourceListWidth];
        frame.size.width = preferredWidth;
        sourceListView.frame = frame;
    }
}

- (void)setSourceListAutosaveName:(NSString *)sourceListAutosaveName {
    if (![_sourceListAutosaveName isEqualToString:sourceListAutosaveName]) {
        _sourceListAutosaveName = sourceListAutosaveName.copy;
        if (!_needsToSetInitialSourceListWidth) {
            [self _updateSplitViewAutosaveName];
        }
    }
}

- (CGFloat)_preferredSourceListWidth {
    CGFloat thicknessFraction = _sidebarSplitViewItem.preferredThicknessFraction;
    if (thicknessFraction > 0.0) {
        CGFloat width = 0.0;
        if (self.isViewLoaded) {
            width = round(thicknessFraction * CGRectGetWidth(self.view.bounds));
        }
        CGFloat minimumWidth = _sourceListViewController.sourceListMinimumWidth;
        CGFloat maximumWidth = _sourceListViewController.sourceListMaximumWidth;
        if (width < minimumWidth) {
            return minimumWidth;
        }
        if (width > maximumWidth) {
            return maximumWidth;
        }
        return width;
    }
    return thicknessFraction;
}

- (void)_updateSplitViewAutosaveName {
    self.splitView.autosaveName = self.sourceListAutosaveName;
}

#pragma mark - Source List Collapsed State

- (BOOL)isSourceListCollapsed {
    return _sidebarSplitViewItem.isCollapsed;
}

- (BOOL)isSourceListAutoCollapsed {
    if (self.isSourceListCollapsed) {
        return !self.wantsSourceListCollapsed;
    }
    return NO;
}

- (BOOL)wantsSourceListCollapsed {
    return _wantsSourceListCollapsed;
}

- (BOOL)wantsInspectorCollapsed {
    return _inspectorSplitViewItem.isCollapsed;
}

- (CGFloat)sourceListWidth {
    NSView *sourceListView = _sourceListViewController.viewIfLoaded;
    return CGRectGetWidth(sourceListView.bounds);
}

- (void)_setWantsSourceListCollapsed:(BOOL)collapsed {
    if (_sidebarSplitViewItem.isCollapsed != collapsed) {
        _sidebarSplitViewItem.collapsed = collapsed;
    }
    if (_wantsSourceListCollapsed != collapsed) {
        _wantsSourceListCollapsed = collapsed;
        CGFloat leadingContentInset = [self _leadingContentInsetForWantsCollapsed:collapsed];
        [self _setLeadingContentInset:leadingContentInset];
    }
}

- (void)_setWantsInspectorCollapsed:(BOOL)collapsed {
    if (_inspectorSplitViewItem.isCollapsed != collapsed) {
        _inspectorSplitViewItem.collapsed = collapsed;
    }
}

- (void)_setWantsSourceListCollapsed:(BOOL)sourceListCollapsed wantsInspectorCollapsed:(BOOL)inspectorCollapsed animated:(BOOL)animated completion:(UXCompletionHandler)completion {
    if (animated) {
        [UXView animateWithDuration:0.3
                              delay:0.0
                            options:0
                         animations:^{
            [self _setWantsSourceListCollapsed:sourceListCollapsed];
            [self _setWantsInspectorCollapsed:inspectorCollapsed];
        }
                         completion:^(BOOL finished) {
            [self _didChangeCollapsed];
            if (completion) {
                completion();
            }
        }];
    } else {
        [self _setWantsSourceListCollapsed:sourceListCollapsed];
        [self _setWantsInspectorCollapsed:inspectorCollapsed];
        [self _didChangeCollapsed];
    }
}

- (void)_didChangeCollapsed {
    NSWindow *window = self.view.window;
    if (_sidebarSplitViewItem.isCollapsed) {
        NSViewController *sidebarViewController = _sidebarSplitViewItem.viewController;
        NSResponder *firstResponder = window.firstResponder;
        BOOL isInResponderChain = [sidebarViewController ux_isInResponderChainOf:firstResponder];
        if (isInResponderChain) {
            [window makeFirstResponder:[self preferredFirstResponder]];
        }
    }
}

- (BOOL)_wantsSourceListCollapsedForViewController:(UXViewController *)viewController {
    return viewController.hidesSourceListWhenPushed;
}

- (BOOL)_wantsInspectorCollapsedForViewController:(UXViewController *)viewController {
    return YES;
}

#pragma mark - Leading Content Inset

- (void)_setLeadingContentInset:(CGFloat)contentInset {
    for (UXNavigationController *navigationController in _navigationControllerByRootViewController.objectEnumerator) {
        UXViewController *topViewController = navigationController.topViewController;
        [navigationController _setLeadingContentInset:contentInset forViewController:topViewController];
    }
}

- (CGFloat)_leadingContentInsetForWantsCollapsed:(BOOL)wantsCollapsed {
    if (wantsCollapsed) {
        return 0.0;
    }
    if (self.isSourceListAutoCollapsed) {
        return 0.0;
    }
    if (self.isSourceListCollapsed) {
        return self.sourceListWidth + 1.0;
    }
    NSView *detailView = _detailViewController.view;
    NSView *selfView = self.view;
    if (selfView.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        NSPoint detailOrigin = [selfView convertPoint:detailView.frame.origin fromView:nil];
        CGFloat selfWidth = CGRectGetWidth(selfView.frame);
        return selfWidth - detailOrigin.x;
    } else {
        NSPoint convertedPoint = [selfView convertPoint:NSZeroPoint fromView:detailView];
        return convertedPoint.x;
    }
}

- (void)_detailViewWidthDidChange {
    CGFloat leadingContentInset = [self _leadingContentInsetForWantsCollapsed:self.isSourceListCollapsed];
    [self _setLeadingContentInset:leadingContentInset];
}

#pragma mark - Navigation Controller Management

- (UXNavigationController *)selectedNavigationController {
    return [_navigationControllerByRootViewController objectForKey:_selectedViewController];
}

- (UXNavigationController *)navigationController {
    return self.selectedNavigationController;
}

- (BOOL)isNavigating {
    return _navigatingToDestination;
}

- (id<UXNavigationDestination>)currentNavigationDestination {
    NSMutableArray *viewControllersWithoutDestination = [NSMutableArray array];
    for (UXViewController *viewController in self.selectedNavigationController.viewControllers.reverseObjectEnumerator) {
        id<UXNavigationDestination> navigationDestination = viewController.navigationDestination;
        if (navigationDestination) {
            for (UXViewController *innerViewController in viewControllersWithoutDestination.reverseObjectEnumerator) {
                [innerViewController willEncodeNavigationDestination:navigationDestination];
            }
            return navigationDestination;
        }
        [viewControllersWithoutDestination addObject:viewController];
    }
    return nil;
}

- (CGSize)contentSizeForWantsSourceListCollapsed:(BOOL)collapsed {
    return self.splitView.bounds.size;
}

#pragma mark - Root View Controllers

- (void)_addRootViewController:(UXViewController *)rootViewController {
    NSParameterAssert(rootViewController);

    UXNavigationController *navigationController = [[UXNavigationController alloc] initWithRootViewController:rootViewController];
    [self _configureManagedNavigationController:navigationController];
    if (self.wantsDetachedNavigationBars) {
        [navigationController detachNavigationBar];
    }
    if (self.wantsDetachedToolbars) {
        [navigationController detachToolbars];
    }
    navigationController.delegate = self;
    navigationController._locked = YES;
    [self willAddNavigationController:navigationController];

    _rootViewControllers = [_rootViewControllers arrayByAddingObject:rootViewController];
    [_navigationControllerByRootViewController setObject:navigationController forKey:rootViewController];
}

- (void)_removeRootViewController:(UXViewController *)rootViewController {
    NSParameterAssert(rootViewController);

    NSUInteger index = [_rootViewControllers indexOfObjectIdenticalTo:rootViewController];
    if (index != NSNotFound) {
        NSMutableArray *mutableControllers = [_rootViewControllers mutableCopy];
        [mutableControllers removeObjectAtIndex:index];
        _rootViewControllers = [mutableControllers copy];
        [_navigationControllerByRootViewController removeObjectForKey:rootViewController];
    }
}

- (void)_prepareTransitionToRootViewController:(UXViewController *)rootViewController {
    UXNavigationController *selectedNavigationController = self.selectedNavigationController;
    UXNavigationController *targetNavigationController = [_navigationControllerByRootViewController objectForKey:rootViewController];

    if (targetNavigationController && selectedNavigationController != targetNavigationController) {
        [_detailViewController addChildViewController:targetNavigationController];
        NSView *targetView = targetNavigationController.view;
        targetView.frame = self.splitView.bounds;
    }
}

- (void)_configureManagedNavigationController:(UXNavigationController *)navigationController {
}

- (void)willAddNavigationController:(UXNavigationController *)navigationController {
}

- (void)willSelectViewController:(UXViewController *)viewController {
}

- (void)willChangeTopViewController:(UXViewController *)viewController {
}

- (void)didChangeSelectedViewController {
}

- (void)didChangeTopViewControllerForNavigationController:(UXNavigationController *)navigationController {
}

- (void)willUpdateToolbarForNavigationController:(UXNavigationController *)navigationController {
}

- (void)_didChangeToolbarVisibilityForNavigationController:(UXNavigationController *)navigationController {
}

- (void)windowDidUpdateFirstResponder {
}

#pragma mark - Selection

- (void)setSelectedViewController:(UXViewController *)selectedViewController {
    [self setSelectedViewController:selectedViewController animated:NO];
}

- (void)setSelectedViewController:(UXViewController *)selectedViewController animated:(BOOL)animated {
    [self _setSelectedViewController:selectedViewController animated:animated sender:nil];
}

- (void)_setSelectedViewController:(UXViewController *)selectedViewController animated:(BOOL)animated sender:(id)sender {
    if (_isTransitioning) {
        NSLog(@"%s - Nested transitions are not allowed.", __PRETTY_FUNCTION__);
        return;
    }

    [self willSelectViewController:selectedViewController];
    UXNavigationController *fromNavigationController = self.selectedNavigationController;

    if (selectedViewController) {
        if (_selectedViewController != selectedViewController) {
            _selectedViewController = selectedViewController;
            UXNavigationController *toNavigationController = self.selectedNavigationController;
            NSUInteger transition = animated ? 103 : 102;
            _transitionCtx = [self _contextForTransitionOperation:1
                                              fromViewController:fromNavigationController
                                                toViewController:toNavigationController
                                                      transition:transition];
            [self setObservedNavigationController:toNavigationController];
            [self _updateInspectorViewController];
            [self _beginTransitionWithContext:_transitionCtx operation:1];

            [_transitionCtx._transitionCoordinator animateAlongsideTransition:nil completion:^(id<UXViewControllerTransitionCoordinatorContext> context) {
                [self _popTransitoryViewControllersInNavigationController:fromNavigationController animated:NO];
                [self _didChangeSelectedViewControllerFromSender:sender];
                [self.view.window recalculateKeyViewLoop];
            }];
            return;
        }
    } else if (_selectedViewController) {
        _selectedViewController = nil;
        [self setObservedNavigationController:nil];
        [self _updateInspectorViewController];
        [fromNavigationController willMoveToParentViewController:nil];
        [fromNavigationController.view removeFromSuperview];
        [fromNavigationController removeFromParentViewController];
        [self _didChangeSelectedViewControllerFromSender:sender];
        [self.view.window recalculateKeyViewLoop];
        return;
    }

    // Same VC selected, just pop or dismiss
    BOOL hidesBackButton = fromNavigationController.navigationBar.topItem.hidesBackButton;
    if (hidesBackButton) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [fromNavigationController popToRootViewControllerAnimated:sender != self];
    }
}

- (void)_didChangeSelectedViewControllerFromSender:(id)sender {
    if (sender) {
        [self didChangeSelectedViewController];
    }
}

- (id)_popTransitoryViewControllersInNavigationController:(UXNavigationController *)navigationController animated:(BOOL)animated {
    return [navigationController _popTransitoryViewControllersAnimated:animated];
}

#pragma mark - Inspector

- (void)_updateInspectorViewController {
    UXNavigationController *selectedNavigationController = self.selectedNavigationController;
    UXViewController *inspectorContentViewController = selectedNavigationController.inspectorViewController;
    [_inspectorViewController setContentViewController:inspectorContentViewController];
}

- (void)_updateDetailSplitViewItemAccessories {
    UXNavigationController *selectedNavigationController = self.selectedNavigationController;
    BOOL allHidden = selectedNavigationController.isToolbarHidden &&
                     selectedNavigationController.isSubtoolbarHidden &&
                     selectedNavigationController.isScopeBarHidden;

    NSViewController *accessoryParent = _detailSplitViewItemTopAccessoryViewController.parentViewController;

    if (accessoryParent && !allHidden) {
        // Remove accessory if bars are visible
        [_detailSplitViewItemTopAccessoryViewController removeFromParentViewController];
    } else if (!accessoryParent && allHidden) {
        // Add accessory if all bars are hidden
        [_detailSplitViewItem addTopAlignedAccessoryViewController:_detailSplitViewItemTopAccessoryViewController];
    }

    _detailSplitViewItemTopAccessoryViewController.view = selectedNavigationController.detachedBarsContainer;
}

#pragma mark - Observed Navigation Controller (KVO for inspector)

- (void)setObservedNavigationController:(UXNavigationController *)observedNavigationController {
    if (_observedNavigationController != observedNavigationController) {
        [_observedNavigationController removeObserver:self forKeyPath:@"inspectorViewController" context:kInspectorViewControllerObserverContext];
        _observedNavigationController = observedNavigationController;
        [observedNavigationController addObserver:self forKeyPath:@"inspectorViewController" options:0 context:kInspectorViewControllerObserverContext];
    }
}

#pragma mark - Observed Window (KVO for firstResponder)

- (void)setObservedWindow:(NSWindow *)observedWindow {
    NSWindow *currentObservedWindow = _observedWindow;
    if (currentObservedWindow != observedWindow) {
        [currentObservedWindow removeObserver:self forKeyPath:NSStringFromSelector(@selector(firstResponder)) context:kFirstResponderObserverContext];
        _observedWindow = observedWindow;
        [observedWindow addObserver:self forKeyPath:NSStringFromSelector(@selector(firstResponder)) options:0 context:kFirstResponderObserverContext];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == kFirstResponderObserverContext) {
        [self windowDidUpdateFirstResponder];
    } else if (context == kInspectorViewControllerObserverContext) {
        [self _updateInspectorViewController];
    } else if (context == kCollapsedObserverContext) {
        NSSplitViewItem *sidebarItem = self.sidebarSplitViewItem;
        BOOL wantsCollapsed = self.wantsSourceListCollapsed;
        NSUInteger pressedButtons = [NSEvent pressedMouseButtons];
        BOOL isCollapsed = sidebarItem.isCollapsed;

        if (!wantsCollapsed && isCollapsed && pressedButtons != 1) {
            // The sidebar was auto-collapsed (e.g., by window resize), uncollapse it on next run loop
            [NSRunLoop.currentRunLoop performBlock:^{
                if (sidebarItem.isCollapsed && !self.wantsSourceListCollapsed) {
                    [self _setWantsSourceListCollapsed:YES];
                }
            }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)viewController:(UXViewController *)viewController changedSourceListCollapsed:(BOOL)collapsed {
    UXViewController *currentSelectedViewController = self.selectedViewController;
    if (viewController == currentSelectedViewController) {
        if (collapsed || _sidebarSplitViewItem.isCollapsed) {
            [self _setWantsSourceListCollapsed:collapsed];
        }
    }
}

#pragma mark - Transition System

- (id)_contextForTransitionOperation:(NSInteger)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController transition:(NSUInteger)transition {
    if (fromViewController && toViewController) {
        NSView *fromView = fromViewController.view;
        NSView *toView = toViewController.view;
        if (fromView == toView) {
            transition = 102;
        }
    }

    UXTransitionController *transitionController = [_transitionControllerClassForTransition(transition) new];
    _transitionController = transitionController;
    _transitionController.operation = operation;

    [self.view layoutSubtreeIfNeeded];

    NSSplitView *splitView = self.splitView;
    UXView *containerView = _detailViewController.uxView;

    _UXViewControllerOneToOneTransitionContext *transitionContext = [_UXViewControllerOneToOneTransitionContext new];
    transitionContext.containerView = containerView;
    transitionContext.animated = transition != 102;
    transitionContext.animator = _transitionController;
    transitionContext.interactor = nil;
    transitionContext.initiallyInteractive = NO;
    transitionContext.fromViewController = fromViewController;
    transitionContext.toViewController = toViewController;
    transitionContext.fromStartFrame = fromViewController.view.frame;
    transitionContext.fromEndFrame = CGRectZero;
    transitionContext.toStartFrame = CGRectZero;
    transitionContext.toEndFrame = [containerView convertRect:splitView.bounds fromView:splitView];
    return transitionContext;
}

- (void)_beginTransitionWithContext:(_UXViewControllerOneToOneTransitionContext *)context operation:(NSInteger)operation {
    _isTransitioning = YES;

    NSWindow *window = self.view.window;
    NSWindowController *windowController = window.windowController;
    UXWindowController *uxWindowController = nil;
    if ([windowController isKindOfClass:[UXWindowController class]]) {
        uxWindowController = (UXWindowController *)windowController;
    }

    UXNavigationController *fromViewController = (UXNavigationController *)[context viewControllerForKey:UXTransitionContextFromViewControllerKey];
    [fromViewController.navigationBar _snapshot];

    UXNavigationController *toViewController = (UXNavigationController *)[context viewControllerForKey:UXTransitionContextToViewControllerKey];
    NSResponder *sourceListVC = (NSResponder *)_sourceListViewController;
    BOOL sourceListInResponderChain = [sourceListVC ux_isInResponderChainOf:window.firstResponder];

    fromViewController.uxView.userInteractionEnabled = NO;
    fromViewController.uxView.wantsSafeAreaInsetsFrozen = YES;
    toViewController.uxView.translatesAutoresizingMaskIntoConstraints = YES;

    CGRect finalFrame = [context finalFrameForViewController:toViewController];
    toViewController.uxView.frame = finalFrame;

    NSWindowStyleMask styleMask = window.styleMask;
    window.styleMask = styleMask & ~(NSWindowStyleMaskClosable | NSWindowStyleMaskResizable);
    NSWindowCollectionBehavior collectionBehavior = window.collectionBehavior;
    if (!(styleMask & NSWindowStyleMaskFullScreen)) {
        window.collectionBehavior = collectionBehavior & ~NSWindowCollectionBehaviorFullScreenPrimary;
    }
    if (styleMask & NSWindowStyleMaskMiniaturizable) {
        [window ux_forceEnableStandardWindowButton:NSWindowMiniaturizeButton];
    }
    if ((styleMask & NSWindowStyleMaskResizable) || (collectionBehavior & NSWindowCollectionBehaviorFullScreenPrimary)) {
        [window ux_forceEnableStandardWindowButton:NSWindowZoomButton];
    }

    auto animator = context.animator;
    context.duration = [animator transitionDuration:context];

    @weakify(self);
    context.completionHandler = ^(_UXViewControllerTransitionContext *transitionContext, BOOL isEnded) {
        @strongify(self);
        toViewController.uxView.userInteractionEnabled = YES;
        fromViewController.uxView.wantsSafeAreaInsetsFrozen = NO;

        window.styleMask = styleMask;
        if (!(styleMask & NSWindowStyleMaskFullScreen)) {
            window.collectionBehavior = collectionBehavior;
        }

        if (!sourceListInResponderChain) {
            NSResponder *preferredResponder = [self preferredFirstResponder];
            [window makeFirstResponder:preferredResponder];
        }

        self->_isTransitioning = NO;
        self->_transitionCtx = nil;
    };

    auto prepareCompletion = ^{
        [toViewController view]; // Ensure view is loaded
        [animator animateTransition:(id)context];
    };

    [self _prepareViewController:fromViewController forAnimationInContext:context completion:prepareCompletion];
}

- (void)_prepareViewController:(UXViewController *)viewController forAnimationInContext:(id)context completion:(UXCompletionHandler)completion {
    if (viewController) {
        [viewController _prepareForAnimationInContext:context completion:completion];
    } else if (completion) {
        completion();
    }
}

+ (Class)_defaultTransitionControllerClass {
    return nil;
}

#pragma mark - UXNavigationControllerDelegate

- (id<UXViewControllerAnimatedTransitioning>)navigationController:(UXNavigationController *)navigationController animationControllerForOperation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController {
    if (!_currentNavigationDelegate) {
        [self _setupDelegateForNavigationController:navigationController operation:operation fromViewController:fromViewController toViewController:toViewController];
    }
    id<UXViewControllerAnimatedTransitioning> animationController = nil;
    if ([_currentNavigationDelegate respondsToSelector:_cmd]) {
        animationController = [_currentNavigationDelegate navigationController:navigationController animationControllerForOperation:operation fromViewController:fromViewController toViewController:toViewController];
    }
    if (!animationController) {
        animationController = [[[self class] _defaultTransitionControllerClass] new];
    }
    return animationController;
}

- (id<UXViewControllerInteractiveTransitioning>)navigationController:(UXNavigationController *)navigationController interactionControllerForAnimationController:(id<UXViewControllerAnimatedTransitioning>)animationController {
    if ([_currentNavigationDelegate respondsToSelector:_cmd]) {
        return [_currentNavigationDelegate navigationController:navigationController interactionControllerForAnimationController:animationController];
    }
    return nil;
}

- (void)_setupDelegateForNavigationController:(UXNavigationController *)navigationController operation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController {
    UXViewController *pushTarget = nil;
    UXViewController *popTarget = nil;
    if (operation == UXNavigationControllerOperationPush) {
        pushTarget = toViewController;
        popTarget = fromViewController;
    } else {
        pushTarget = fromViewController;
        popTarget = toViewController;
    }

    Class transitionControllerClass = [_transitionControllerClassByToViewControllerClass objectForKey:[pushTarget class]];
    if (!transitionControllerClass) {
        transitionControllerClass = [_transitionControllerClassByToViewControllerClass objectForKey:[popTarget class]];
    }

    if (transitionControllerClass) {
        if (transitionControllerClass == [pushTarget class]) {
            _currentNavigationDelegate = (id<UXNavigationControllerDelegate>)pushTarget;
        } else if (transitionControllerClass == [popTarget class]) {
            _currentNavigationDelegate = (id<UXNavigationControllerDelegate>)popTarget;
        } else {
            _currentNavigationDelegate = [transitionControllerClass new];
        }
        return;
    }

    Class defaultTransitionControllerClass = [[self class] _defaultTransitionControllerClass];
    if (defaultTransitionControllerClass) {
        _currentNavigationDelegate = [defaultTransitionControllerClass new];
        if ([_currentNavigationDelegate isKindOfClass:[UXTransitionController class]]) {
            ((UXTransitionController *)_currentNavigationDelegate).operation = operation;
        }
    }
}

- (void)navigationController:(UXNavigationController *)navigationController willShowViewController:(UXViewController *)viewController {
    NSWindow *window = navigationController.view.window;
    if (window) {
        [self willChangeTopViewController:viewController];
    }

    BOOL isEqualSelectedNavigationController = self.selectedNavigationController == navigationController;
    BOOL wantsCollapsed = [self _wantsSourceListCollapsedForViewController:viewController];
    BOOL wantsInspectorCollapsed = [self _wantsInspectorCollapsedForViewController:viewController];
    CGFloat leadingContentInset = [self _leadingContentInsetForWantsCollapsed:wantsCollapsed];
    [navigationController _setLeadingContentInset:leadingContentInset forViewController:viewController];

    [navigationController.transitionCoordinator animateAlongsideTransition:^(id<UXViewControllerTransitionCoordinatorContext> context) {
        if (isEqualSelectedNavigationController) {
            [self _setWantsSourceListCollapsed:wantsCollapsed wantsInspectorCollapsed:wantsInspectorCollapsed animated:context.isAnimated completion:nil];
        }
    } completion:^(id<UXViewControllerTransitionCoordinatorContext> context) {
        self->_currentNavigationDelegate = nil;
        if (!self->_navigatingToDestination) {
            id<UXNavigationDestination> currentNavigationDestination = self.currentNavigationDestination;
            if (isEqualSelectedNavigationController && currentNavigationDestination) {
                [self.sourceListViewController selectNavigationDestination:currentNavigationDestination];
            }
        }
    }];
}

- (BOOL)navigationController:(UXNavigationController *)navigationController shouldBeginInteractivePopFromViewController:(UXViewController *)viewController toViewController:(UXViewController *)toViewController {
    return YES;
}

- (void)navigationController:(UXNavigationController *)navigationController didShowViewController:(UXViewController *)viewController {
    if (navigationController.view.window) {
        [self didChangeTopViewControllerForNavigationController:navigationController];
    }
}

#pragma mark - Transition Controller Registration

- (void)registerTransitionControllerClass:(Class)transitionControllerClass forViewControllerClass:(Class)viewControllerClass {
    if (transitionControllerClass && viewControllerClass) {
        [_transitionControllerClassByToViewControllerClass setObject:transitionControllerClass forKey:viewControllerClass];
    }
}

- (void)registerTranistionControllerClass:(Class)tranistionControllerClass forViewControllerClass:(Class)viewControllerClass {
    [self registerTransitionControllerClass:tranistionControllerClass forViewControllerClass:viewControllerClass];
}

- (void)unregisterTransitionControllerForTransitionToViewControllerClass:(Class)viewControllerClass {
    if (viewControllerClass) {
        [_transitionControllerClassByToViewControllerClass removeObjectForKey:viewControllerClass];
    }
}

#pragma mark - Navigation

- (id)fallbackNavigationDestination {
    return nil;
}

- (id)makeRootViewControllerForDestination:(id<UXNavigationDestination>)destination {
    return nil;
}

- (void)navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(UXCompletionHandler)completion {
    [self navigateToDestination:destination animated:animated useFallbackDestinationIfNeeded:NO completion:completion];
}

- (void)navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated useFallbackDestinationIfNeeded:(BOOL)useFallbackDestinationIfNeeded completion:(UXCompletionHandler)completion {
    UXCompletionHandler innerCompletion = completion ?: ^{};

    [_viewControllerOperations addOperationWithBlock:^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _navigateToDestination:destination animated:animated completion:^(BOOL finished) {
                if (finished) {
                    innerCompletion();
                    dispatch_semaphore_signal(semaphore);
                } else if (useFallbackDestinationIfNeeded) {
                    id fallback = [self fallbackNavigationDestination];
                    if (fallback) {
                        [self _navigateToDestination:fallback animated:animated completion:^(BOOL innerFinished) {
                            innerCompletion();
                            dispatch_semaphore_signal(semaphore);
                        }];
                    } else {
                        innerCompletion();
                        dispatch_semaphore_signal(semaphore);
                    }
                } else {
                    innerCompletion();
                    dispatch_semaphore_signal(semaphore);
                }
            }];
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }];
}

- (void)_navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(UXParameterCompletionHandler)completion {
    UXViewController *rootViewController = [self _rootViewControllerForNavigationDestination:destination];

    if (!rootViewController) {
        rootViewController = [self makeRootViewControllerForDestination:destination];
        if (rootViewController && ![_rootViewControllers containsObject:rootViewController]) {
            [self _addRootViewController:rootViewController];
        }
    }

    if (rootViewController) {
        __block BOOL completionCalled = NO;
        [rootViewController requestViewControllersForNavigationDestination:destination completion:^(BOOL success, NSArray<UXViewController *> *viewControllers) {
            if (completionCalled) return;
            completionCalled = YES;

            if (success && viewControllers.count > 0) {
                _navigatingToDestination = YES;

                NSUInteger rootIndex = [self->_rootViewControllers indexOfObject:rootViewController];
                if (rootIndex != NSNotFound && self->_selectedViewController != rootViewController) {
                    [self _setSelectedViewController:rootViewController animated:animated sender:self];
                }

                UXNavigationController *navigationController = [self->_navigationControllerByRootViewController objectForKey:rootViewController];
                NSMutableArray *newViewControllers = [NSMutableArray arrayWithObject:rootViewController];
                [newViewControllers addObjectsFromArray:viewControllers];
                [navigationController setViewControllers:newViewControllers animated:animated];

                auto finishNavigation = ^{
                    self->_navigatingToDestination = NO;
                    if (completion) {
                        completion(YES);
                    }
                };

                if (self.transitionCoordinator) {
                    [self.transitionCoordinator animateAlongsideTransition:nil completion:^(id<UXViewControllerTransitionCoordinatorContext> context) {
                        finishNavigation();
                    }];
                } else {
                    finishNavigation();
                }
            } else {
                if (completion) {
                    completion(NO);
                }
            }
        }];
    } else if (completion) {
        completion(NO);
    }
}

- (id)_rootViewControllerForNavigationDestination:(id<UXNavigationDestination>)destination {
    for (UXViewController *rootViewController in self.rootViewControllers) {
        if ([rootViewController canProvideViewControllersForNavigationDestination:destination]) {
            return rootViewController;
        }
    }
    return nil;
}

- (void)removeDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(UXCompletionHandler)completion {
    [_viewControllerOperations addOperationWithBlock:^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _removeDestination:destination animated:animated completion:^{
                if (completion) {
                    completion();
                }
                dispatch_semaphore_signal(semaphore);
            }];
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }];
}

- (void)_removeDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(UXCompletionHandler)completion {
    UXCompletionHandler innerCompletion = completion ?: ^{};

    // Find root VC matching this destination
    for (UXViewController *rootViewController in self.rootViewControllers) {
        id<UXNavigationDestination> navigationDestination = rootViewController.navigationDestination;
        if ([navigationDestination isEqual:destination]) {
            // Found direct match on root VC
            if (self.selectedViewController == rootViewController) {
                // Navigate to fallback first
                id fallback = [self fallbackNavigationDestination];
                if (fallback) {
                    [self _navigateToDestination:fallback animated:animated completion:^(BOOL finished) {
                        [self _removeRootViewController:rootViewController];
                        innerCompletion();
                    }];
                    return;
                }
            }
            [self _removeRootViewController:rootViewController];
            innerCompletion();
            return;
        }

        // Check child VCs in navigation stack
        UXNavigationController *navigationController = [_navigationControllerByRootViewController objectForKey:rootViewController];
        UXViewController *previousViewController = nil;
        for (UXViewController *viewController in navigationController.viewControllers) {
            id<UXNavigationDestination> vcDestination = viewController.navigationDestination;
            if ([vcDestination isEqual:destination]) {
                UXViewController *popTarget = previousViewController ?: viewController;
                BOOL shouldAnimate = animated && navigationController.view.window != nil;
                [navigationController popToViewController:popTarget animated:shouldAnimate];

                id<UXViewControllerTransitionCoordinator> coordinator = navigationController.transitionCoordinator ?: self.transitionCoordinator;
                if (coordinator) {
                    [coordinator animateAlongsideTransition:nil completion:^(id<UXViewControllerTransitionCoordinatorContext> context) {
                        innerCompletion();
                    }];
                } else {
                    innerCompletion();
                }
                return;
            }
            previousViewController = viewController;
        }
    }

    innerCompletion();
}

- (void)windowWillEnterFullScreen {
}

- (void)windowWillExitFullScreen {
}

@end
