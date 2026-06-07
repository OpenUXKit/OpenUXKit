#import "UXSourceController.h"
#import "UXSourceController+Internal.h"
#import "_UXDetailViewController.h"
#import "_UXInspectorViewController.h"
#import "_UXViewControllerOneToOneTransitionContext.h"
#import "_UXViewControllerTransitionContext.h"
#import "_UXViewControllerTransitionCoordinator.h"
#import "_UXLayoutSpacer.h"
#import "NSResponder+UXKit.h"
#import "NSWindow+UXKit.h"
#import "UXKitPrivateUtilites.h"
#import "UXNavigationBar+Internal.h"
#import "UXNavigationController+Internal.h"
#import "UXNavigationItem+Internal.h"
#import "UXSourceList.h"
#import "UXTransitionController.h"
#import "UXView.h"
#import "UXViewController+Internal.h"
#import "UXViewControllerTransitionCoordinator.h"
#import "UXViewControllerTransitioning.h"
#import "UXWindowController+Internal.h"
#import "UXView+Internal.h"
#import "UXNavigationDestination.h"
#import "UXDestinationAuxiliaryStore.h"
#import "EXTScope.h"
#import <objc/message.h>

static void *kFirstResponderObserverContext = &kFirstResponderObserverContext;
static void *kInspectorViewControllerObserverContext = &kInspectorViewControllerObserverContext;
static void *kCollapsedObserverContext = &kCollapsedObserverContext;

static BOOL UXSourceControllerShouldForceSelectionForNavigationDestination(id<UXNavigationDestination> destination) {
    id value = [destination.destinationAuxiliaryStore valueForKey:@"UXSourceControllerForceSelection" inNamespace:nil];

    if ([value isKindOfClass:[NSNumber class]]) {
        return [value boolValue];
    }

    return NO;
}

@interface UXSourceController () <NSSplitViewDelegate> {
    BOOL _needsToSetInitialSourceListWidth;
    BOOL _wantsSourceListCollapsed;
    BOOL _isTogglingSidebar;
    BOOL _hasAddedInspector;
    BOOL _isTransitioning;
    _UXViewControllerOneToOneTransitionContext *_transitionCtx;
    UXTransitionController *_transitionController;
    NSMapTable<UXViewController *, UXNavigationController *> *_navigationControllerByRootViewController;
    NSMapTable *_transitionControllerClassByToViewControllerClass;
    NSOperationQueue *_viewControllerOperations;
    BOOL _navigatingToDestination;
    id<UXNavigationControllerDelegate> _currentNavigationDelegate;
    id<UXLayoutSupport> _topLayoutGuide;
    id<UXLayoutSupport> _bottomLayoutGuide;
}

@property (nonatomic, strong, readwrite) NSSplitViewItem *sidebarSplitViewItem;
@property (nonatomic, strong, readwrite) NSSplitViewItem *detailSplitViewItem;
@property (nonatomic, strong, readwrite) NSSplitViewItem *inspectorSplitViewItem;
@property (nonatomic, strong, readwrite) NSTitlebarAccessoryViewController *detailSplitViewItemTopAccessoryViewController;
@property (nonatomic, strong, readwrite) NSSearchToolbarItem *searchToolbarItem;
@property (nonatomic, readwrite) BOOL wantsSourceListHidden;
@property (nonatomic, copy, readwrite) NSArray *rootViewControllers;
@end

@implementation UXSourceController

@synthesize selectedViewController = _selectedViewController;

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _rootViewControllers = @[];
        _selectedNavigationViewConstraints = @[];
        _wantsSourceListCollapsed = NO;
        _needsToSetInitialSourceListWidth = YES;

        _detailViewController = [_UXDetailViewController new];
        _detailSplitViewItem = [NSSplitViewItem splitViewItemWithViewController:_detailViewController];
        _detailSplitViewItemTopAccessoryViewController = [NSTitlebarAccessoryViewController new];
        // macOS 26 visual APIs accessed dynamically for SDK compatibility:
        //   -[NSTitlebarAccessoryViewController setAutomaticallyAppliesContentInsets:]
        //   -[NSTitlebarAccessoryViewController setPreferredScrollEdgeEffectStyle:[NSScrollEdgeEffectStyle softStyle]]
        SEL setAutomaticallyAppliesContentInsetsSelector = NSSelectorFromString(@"setAutomaticallyAppliesContentInsets:");
        if ([_detailSplitViewItemTopAccessoryViewController respondsToSelector:setAutomaticallyAppliesContentInsetsSelector]) {
            ((void (*)(id, SEL, BOOL))objc_msgSend)(_detailSplitViewItemTopAccessoryViewController, setAutomaticallyAppliesContentInsetsSelector, NO);
        }
        Class scrollEdgeEffectStyleClass = NSClassFromString(@"NSScrollEdgeEffectStyle");
        SEL setPreferredScrollEdgeEffectStyleSelector = NSSelectorFromString(@"setPreferredScrollEdgeEffectStyle:");
        if (scrollEdgeEffectStyleClass && [_detailSplitViewItemTopAccessoryViewController respondsToSelector:setPreferredScrollEdgeEffectStyleSelector]) {
            id softStyle = ((id (*)(id, SEL))objc_msgSend)(scrollEdgeEffectStyleClass, NSSelectorFromString(@"softStyle"));
            ((void (*)(id, SEL, id))objc_msgSend)(_detailSplitViewItemTopAccessoryViewController, setPreferredScrollEdgeEffectStyleSelector, softStyle);
        }
        _detailSplitViewItemTopAccessoryViewController.view = [[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 500.0, 32.0)];
        if (@available(macOS 26.0, *)) {
            _detailSplitViewItem.automaticallyAdjustsSafeAreaInsets = YES;
        }
        _detailSplitViewItem.minimumThickness = 550.0;
        [self addSplitViewItem:_detailSplitViewItem];

        _inspectorViewController = [_UXInspectorViewController new];
        _inspectorSplitViewItem = [NSSplitViewItem inspectorWithViewController:_inspectorViewController];
        _inspectorSplitViewItem.canCollapse = NO;
        _inspectorSplitViewItem.collapsed = YES;
        [self addSplitViewItem:_inspectorSplitViewItem];

        _navigationControllerByRootViewController = [NSMapTable weakToStrongObjectsMapTable];
        _transitionControllerClassByToViewControllerClass = [NSMapTable weakToWeakObjectsMapTable];
        _viewControllerOperations = [NSOperationQueue new];
        _viewControllerOperations.maxConcurrentOperationCount = 1;
        _viewControllerOperations.qualityOfService = NSQualityOfServiceUserInitiated;
    }

    return self;
}

- (void)dealloc {
    self.observedWindow = nil;
    self.observedNavigationController = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.splitView.accessibilityIdentifier = @"UXSourceControllerSplitView";
}

- (void)viewWillAppear {
    [super viewWillAppear];

    if (_needsToSetInitialSourceListWidth) {
        if (self.splitViewItems.firstObject == self.sidebarSplitViewItem) {
            _needsToSetInitialSourceListWidth = NO;
            [self.splitView setPosition:[self _preferredSourceListWidth] ofDividerAtIndex:0];
            [self _updateSplitViewAutosaveName];
            self.inspectorSplitViewItem.collapsed = YES;
        }
    }
}

- (void)viewDidAppear {
    [super viewDidAppear];
    self.observedWindow = self.view.window;
    self.sidebarSplitViewItem.canCollapseFromWindowResize = YES;
}

- (void)viewWillDisappear {
    [super viewWillDisappear];
    self.observedWindow = nil;
}

#pragma mark - Source List

- (void)setSourceListViewController:(UXViewController<UXSourceList> *)sourceListViewController {
    if (_sourceListViewController != sourceListViewController) {
        if (_sourceListViewController) {
            NSAssert(self.sidebarSplitViewItem.viewController == _sourceListViewController, @"_sidebarSplitViewItem.viewController == _sourceListViewController");
            [_sourceListViewController willMoveToParentViewController:nil];
            [self.sidebarSplitViewItem removeObserver:self forKeyPath:@"collapsed" context:kCollapsedObserverContext];
            [self removeSplitViewItem:self.sidebarSplitViewItem];
        }

        _sourceListViewController = sourceListViewController;

        if (_sourceListViewController) {
            NSParameterAssert([_sourceListViewController conformsToProtocol:@protocol(UXSourceList)]);
            self.sidebarSplitViewItem = [NSSplitViewItem sidebarWithViewController:_sourceListViewController];
            self.sidebarSplitViewItem.preferredThicknessFraction = _sourceListViewController.sourceListPreferredWidthFraction;
            self.sidebarSplitViewItem.minimumThickness = _sourceListViewController.sourceListMinimumWidth;
            self.sidebarSplitViewItem.maximumThickness = _sourceListViewController.sourceListMaximumWidth;
            [self insertSplitViewItem:self.sidebarSplitViewItem atIndex:0];
            [_sourceListViewController didMoveToParentViewController:(UXViewController *)self];
            [self.sidebarSplitViewItem addObserver:self forKeyPath:@"collapsed" options:0 context:kCollapsedObserverContext];
            NSView *sourceListView = _sourceListViewController.view;
            CGRect frame = sourceListView.frame;
            frame.size.width = [self _preferredSourceListWidth];
            sourceListView.frame = frame;
        }
    }
}

- (CGFloat)_preferredSourceListWidth {
    CGFloat preferredThicknessFraction = self.sidebarSplitViewItem.preferredThicknessFraction;

    if (preferredThicknessFraction > 0.0) {
        CGFloat width = preferredThicknessFraction;

        if (self.isViewLoaded) {
            width = round(preferredThicknessFraction * CGRectGetWidth(self.view.bounds));
        }

        CGFloat minimumWidth = _sourceListViewController.sourceListMinimumWidth;
        CGFloat maximumWidth = _sourceListViewController.sourceListMaximumWidth;

        if (width < minimumWidth) {
            width = minimumWidth;
        }

        if (width > maximumWidth) {
            width = maximumWidth;
        }

        return width;
    }

    return preferredThicknessFraction;
}

- (CGFloat)sourceListWidth {
    return CGRectGetWidth(_sourceListViewController.viewIfLoaded.bounds);
}

- (void)setSourceListAutosaveName:(NSString *)sourceListAutosaveName {
    if (![_sourceListAutosaveName isEqualToString:sourceListAutosaveName]) {
        _sourceListAutosaveName = sourceListAutosaveName.copy;
        [self _updateSplitViewAutosaveName];
    }
}

- (void)_updateSplitViewAutosaveName {
    self.splitView.autosaveName = self.sourceListAutosaveName;
}

#pragma mark - Collapse

- (BOOL)isSourceListCollapsed {
    return self.sidebarSplitViewItem.isCollapsed;
}

- (BOOL)isSourceListAutoCollapsed {
    return self.isSourceListCollapsed && !self.wantsSourceListCollapsed;
}

- (BOOL)wantsSourceListCollapsed {
    return _wantsSourceListCollapsed;
}

- (BOOL)wantsInspectorCollapsed {
    return self.inspectorSplitViewItem.isCollapsed;
}

- (void)_setWantsSourceListCollapsed:(BOOL)wantsSourceListCollapsed {
    if (self.sidebarSplitViewItem.isCollapsed != wantsSourceListCollapsed) {
        self.sidebarSplitViewItem.collapsed = wantsSourceListCollapsed;
    }

    if (_wantsSourceListCollapsed != wantsSourceListCollapsed) {
        _wantsSourceListCollapsed = wantsSourceListCollapsed;
        [self _setLeadingContentInset:[self _leadingContentInsetForWantsCollapsed:wantsSourceListCollapsed]];
    }
}

- (void)_setWantsInspectorCollapsed:(BOOL)wantsInspectorCollapsed {
    if (self.inspectorSplitViewItem.isCollapsed != wantsInspectorCollapsed) {
        self.inspectorSplitViewItem.collapsed = wantsInspectorCollapsed;
    }
}

- (void)_setWantsSourceListCollapsed:(BOOL)wantsSourceListCollapsed wantsInspectorCollapsed:(BOOL)wantsInspectorCollapsed animated:(BOOL)animated completion:(UXCompletionHandler)completion {
    if (animated) {
        [UXView animateWithDuration:0.3
                              delay:0.0
                            options:0
                         animations:^{
            [self _setWantsSourceListCollapsed:wantsSourceListCollapsed];
            [self _setWantsInspectorCollapsed:wantsInspectorCollapsed];
        }
                         completion:^(BOOL finished) {
            [self _didChangeCollapsed];

            if (completion) {
                completion();
            }
        }];
    } else {
        [self _setWantsSourceListCollapsed:wantsSourceListCollapsed];
        [self _setWantsInspectorCollapsed:wantsInspectorCollapsed];
        [self _didChangeCollapsed];
    }
}

- (void)_didChangeCollapsed {
    NSWindow *window = self.view.window;

    if (self.sidebarSplitViewItem.isCollapsed) {
        BOOL inResponderChain = [self.sidebarSplitViewItem.viewController isInResponderChainOf:window.firstResponder];

        if (inResponderChain) {
            [window makeFirstResponder:self.preferredFirstResponder];
        }
    }
}

- (void)viewController:(UXViewController *)viewController changedSourceListCollapsed:(BOOL)changedSourceListCollapsed {
    if (viewController == self.selectedViewController && (changedSourceListCollapsed || self.sidebarSplitViewItem.isCollapsed)) {
        [self _setWantsSourceListCollapsed:changedSourceListCollapsed];
    }
}

- (BOOL)_wantsSourceListCollapsedForViewController:(UXViewController *)viewController {
    if (self.wantsSourceListHidden) {
        return YES;
    }

    return viewController.hidesSourceListWhenPushed;
}

- (BOOL)_wantsInspectorCollapsedForViewController:(UXViewController *)viewController {
    return viewController.hidesInspectorWhenPushed;
}

- (CGFloat)_leadingContentInsetForWantsCollapsed:(BOOL)wantsCollapsed {
    if (wantsCollapsed || self.isSourceListAutoCollapsed) {
        return 0.0;
    }

    if (self.isSourceListCollapsed) {
        return self.sourceListWidth + 1.0;
    }

    NSView *detailView = self.detailViewController.view;
    NSView *view = self.view;

    if (view.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        CGRect detailFrame = detailView.frame;
        CGPoint converted = [view convertPoint:CGPointMake(CGRectGetMaxX(detailFrame), 0.0) fromView:detailView];
        return CGRectGetWidth(view.frame) - converted.x;
    } else {
        CGPoint converted = [view convertPoint:CGPointZero fromView:detailView];
        return converted.x;
    }
}

- (void)_setLeadingContentInset:(CGFloat)leadingContentInset {
    for (UXNavigationController *navigationController in _navigationControllerByRootViewController.objectEnumerator) {
        [navigationController _setLeadingContentInset:leadingContentInset forViewController:navigationController.topViewController];
    }
}

- (CGSize)contentSizeForWantsSourceListCollapsed:(BOOL)wantsSourceListCollapsed {
    CGFloat leadingContentInset = [self _leadingContentInsetForWantsCollapsed:wantsSourceListCollapsed];
    return CGSizeMake(CGRectGetWidth(self.splitView.bounds) - leadingContentInset, 0.0);
}

- (void)_detailViewWidthDidChange {
    [self _setLeadingContentInset:[self _leadingContentInsetForWantsCollapsed:self.isSourceListCollapsed]];
}

#pragma mark - Inspector / Detail accessories

- (void)_updateInspectorViewController {
    self.inspectorViewController.contentViewController = self.selectedNavigationController.inspectorViewController;
}

- (void)_updateDetailSplitViewItemAccessories {
    UXNavigationController *selectedNavigationController = self.selectedNavigationController;
    BOOL barsHidden = selectedNavigationController.isToolbarHidden && selectedNavigationController.isSubtoolbarHidden && selectedNavigationController.isScopeBarHidden;
    BOOL hasParent = self.detailSplitViewItemTopAccessoryViewController.parentViewController != nil;

    if (hasParent && barsHidden) {
        [self.detailSplitViewItemTopAccessoryViewController removeFromParentViewController];
    } else if (!barsHidden && !hasParent) {
        if (@available(macOS 26.0, *)) {
            [self.detailSplitViewItem addTopAlignedAccessoryViewController:(NSSplitViewItemAccessoryViewController *)self.detailSplitViewItemTopAccessoryViewController];
        }
    }

    self.detailSplitViewItemTopAccessoryViewController.view = selectedNavigationController.detachedBarsContainer;
}

- (void)_didChangeToolbarVisibilityForNavigationController:(UXNavigationController *)navigationController {
    if (self.selectedNavigationController == navigationController) {
        [self _updateDetailSplitViewItemAccessories];
    }
}

#pragma mark - Observed window / navigation controller

- (void)setObservedWindow:(NSWindow *)observedWindow {
    NSWindow *previousWindow = _observedWindow;

    if (previousWindow != observedWindow) {
        [previousWindow removeObserver:self forKeyPath:NSStringFromSelector(@selector(firstResponder)) context:kFirstResponderObserverContext];
        _observedWindow = observedWindow;
        [observedWindow addObserver:self forKeyPath:NSStringFromSelector(@selector(firstResponder)) options:0 context:kFirstResponderObserverContext];
    }
}

- (void)setObservedNavigationController:(UXNavigationController *)observedNavigationController {
    if (_observedNavigationController != observedNavigationController) {
        [_observedNavigationController removeObserver:self forKeyPath:NSStringFromSelector(@selector(inspectorViewController)) context:kInspectorViewControllerObserverContext];
        _observedNavigationController = observedNavigationController;
        [observedNavigationController addObserver:self forKeyPath:NSStringFromSelector(@selector(inspectorViewController)) options:0 context:kInspectorViewControllerObserverContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == kFirstResponderObserverContext) {
        [self windowDidUpdateFirstResponder];
    } else if (context == kInspectorViewControllerObserverContext) {
        [self _updateInspectorViewController];
    } else if (context == kCollapsedObserverContext) {
        NSSplitViewItem *sidebarSplitViewItem = self.sidebarSplitViewItem;
        BOOL wantsSourceListCollapsed = self.wantsSourceListCollapsed;
        NSUInteger pressedMouseButtons = NSEvent.pressedMouseButtons;

        if (!wantsSourceListCollapsed && sidebarSplitViewItem.isCollapsed && pressedMouseButtons != 1) {
            [NSRunLoop.currentRunLoop performBlock:^{
                [sidebarSplitViewItem setCollapsed:NO];
            }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Selection

- (UXViewController *)selectedViewController {
    return _selectedViewController;
}

- (void)setSelectedViewController:(UXViewController *)selectedViewController {
    [self setSelectedViewController:selectedViewController animated:NO];
}

- (void)setSelectedViewController:(UXViewController *)selectedViewController animated:(BOOL)animated {
    NSParameterAssert([self.rootViewControllers containsObject:selectedViewController]);
    [self _prepareTransitionToRootViewController:selectedViewController];
    [self _setSelectedViewController:selectedViewController animated:animated sender:nil];
}

- (UXNavigationController *)selectedNavigationController {
    return [_navigationControllerByRootViewController objectForKey:_selectedViewController];
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
            _transitionCtx = [self _contextForTransitionOperation:1 fromViewController:fromNavigationController toViewController:toNavigationController transition:transition];
            [self setObservedNavigationController:toNavigationController];
            [self _updateInspectorViewController];
            [self _beginTransitionWithContext:_transitionCtx operation:1];
            [_transitionCtx._transitionCoordinator animateAlongsideTransition:nil completion:^(id<UXViewControllerTransitionCoordinatorContext> transitionContext) {
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
        return;
    }

    BOOL hidesBackButton = fromNavigationController.navigationBar.topItem.hidesBackButton;

    if (hidesBackButton) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (sender) {
        [fromNavigationController popToRootViewControllerAnimated:sender != self];
    }
}

- (void)_didChangeSelectedViewControllerFromSender:(id)sender {
    if (sender) {
        [self didChangeSelectedViewController];
    }
}

#pragma mark - Root view controllers

- (void)addRootViewController:(UXViewController *)rootViewController {
    [self _addRootViewController:rootViewController];
}

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
    self.rootViewControllers = [_rootViewControllers arrayByAddingObject:rootViewController];
    [_navigationControllerByRootViewController setObject:navigationController forKey:rootViewController];
}

- (void)_removeRootViewController:(UXViewController *)rootViewController {
    NSParameterAssert(rootViewController);
    NSUInteger index = [_rootViewControllers indexOfObjectIdenticalTo:rootViewController];

    if (index != NSNotFound) {
        NSMutableArray *mutableRootViewControllers = [_rootViewControllers mutableCopy];
        [mutableRootViewControllers removeObjectAtIndex:index];
        self.rootViewControllers = mutableRootViewControllers.copy;
        [_navigationControllerByRootViewController removeObjectForKey:rootViewController];
    }
}

- (void)_prepareTransitionToRootViewController:(UXViewController *)rootViewController {
    UXNavigationController *selectedNavigationController = self.selectedNavigationController;
    UXNavigationController *navigationController = [_navigationControllerByRootViewController objectForKey:rootViewController];

    if (navigationController && selectedNavigationController != navigationController) {
        [self.detailViewController addChildViewController:navigationController];
        navigationController.view.frame = self.splitView.bounds;
    }
}

- (void)_configureManagedNavigationController:(UXNavigationController *)navigationController {
}

- (void)willAddNavigationController:(UXNavigationController *)navigationController {
}

#pragma mark - Navigation

- (id<UXNavigationDestination>)currentNavigationDestination {
    NSMutableArray<UXViewController *> *encounteredViewControllers = [NSMutableArray array];

    for (UXViewController *viewController in self.selectedNavigationController.viewControllers.reverseObjectEnumerator) {
        id<UXNavigationDestination> navigationDestination = viewController.navigationDestination;

        if (navigationDestination) {
            for (UXViewController *encounteredViewController in encounteredViewControllers.reverseObjectEnumerator) {
                [encounteredViewController willEncodeNavigationDestination:navigationDestination];
            }

            return navigationDestination;
        }

        [encounteredViewControllers addObject:viewController];
    }

    return nil;
}

- (BOOL)isNavigating {
    return _viewControllerOperations.operationCount != 0;
}

- (id<UXNavigationDestination>)fallbackNavigationDestination {
    return nil;
}

- (UXViewController *)makeRootViewControllerForDestination:(id<UXNavigationDestination>)destination {
    return nil;
}

- (UXViewController *)_rootViewControllerForNavigationDestination:(id<UXNavigationDestination>)navigationDestination {
    for (UXViewController *rootViewController in self.rootViewControllers) {
        if ([rootViewController canProvideViewControllersForNavigationDestination:navigationDestination]) {
            return rootViewController;
        }
    }

    return nil;
}

- (void)navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(UXCompletionHandler)completion {
    [_viewControllerOperations addOperationWithBlock:^{
        [self _navigateToDestination:destination animated:animated completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    }];
}

- (void)navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated useFallbackDestinationIfNeeded:(BOOL)useFallbackDestinationIfNeeded completion:(UXCompletionHandler)completion {
    UXCompletionHandler innerCompletion = completion ?: ^{};
    [_viewControllerOperations addOperationWithBlock:^{
        [self _navigateToDestination:destination animated:animated completion:^(BOOL finished) {
            if (!finished && useFallbackDestinationIfNeeded) {
                [self _navigateToDestination:self.fallbackNavigationDestination animated:animated completion:^(BOOL fallbackFinished) {
                    innerCompletion();
                }];
            } else {
                innerCompletion();
            }
        }];
    }];
}

- (void)_navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(UXParameterCompletionHandler)completion {
    UXViewController *rootViewController = [self _rootViewControllerForNavigationDestination:destination];

    if (!rootViewController) {
        UXViewController *madeRootViewController = [self makeRootViewControllerForDestination:destination];

        if (!madeRootViewController) {
            if (completion) {
                completion(NO);
            }

            return;
        }

        rootViewController = madeRootViewController;

        if (![_rootViewControllers containsObject:rootViewController]) {
            [self _addRootViewController:rootViewController];
        }
    }

    __block BOOL completionDidFire = NO;
    [rootViewController requestViewControllersForNavigationDestination:destination completion:^(BOOL finished, NSArray<UXViewController *> *viewControllers) {
        NSAssert(!completionDidFire, @"API misuse. The completion block of -[UXViewController requestViewControllersForNavigationDestination:completion:] was called multiple times");
        completionDidFire = YES;
        NSAssert(viewControllers.count > 0, @"Error: Attempting to push an empty navigation stack.\n%@", NSThread.callStackSymbols);
        NSAssert([self.rootViewControllers containsObject:viewControllers.firstObject], @"Error attempting to push a view controller stack without an existing root view controller\n%@", NSThread.callStackSymbols);

        UXNavigationController *selectedNavigationController = self.selectedNavigationController;
        UXViewController *originalTopViewController = selectedNavigationController.topViewController;
        UXViewController *lastViewController = viewControllers.lastObject;
        self->_navigatingToDestination = YES;
        [self _prepareTransitionToRootViewController:rootViewController];
        UXNavigationController *navigationController = [self->_navigationControllerByRootViewController objectForKey:rootViewController];
        [navigationController setViewControllers:viewControllers animated:animated];

        UXCompletionHandler afterSetViewControllers = ^{
            if (rootViewController.navigationController == selectedNavigationController) {
                if (originalTopViewController == lastViewController && UXSourceControllerShouldForceSelectionForNavigationDestination(destination)) {
                    [lastViewController updateForEqualNavigationDestination:destination];
                }
            } else {
                [self _setSelectedViewController:rootViewController animated:animated sender:self];
            }

            [self.sourceListViewController selectNavigationDestination:destination];

            UXCompletionHandler afterSelection = ^{
                self->_navigatingToDestination = NO;
                if (completion) {
                    completion(YES);
                }
            };

            id<UXViewControllerTransitionCoordinator> postSelectionCoordinator = selectedNavigationController.transitionCoordinator ?: self.transitionCoordinator;

            if (postSelectionCoordinator) {
                [postSelectionCoordinator animateAlongsideTransition:nil completion:^(id<UXViewControllerTransitionCoordinatorContext> transitionContext) {
                    afterSelection();
                }];
            } else {
                afterSelection();
            }
        };

        id<UXViewControllerTransitionCoordinator> coordinator = navigationController.transitionCoordinator;
        if (coordinator) {
            [coordinator animateAlongsideTransition:nil completion:^(id<UXViewControllerTransitionCoordinatorContext> transitionContext) {
                afterSetViewControllers();
            }];
        } else {
            afterSetViewControllers();
        }
    }];
}

- (void)removeDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(UXCompletionHandler)completion {
    [_viewControllerOperations addOperationWithBlock:^{
        [self _removeDestination:destination animated:animated completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    }];
}

- (void)_removeDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(UXParameterCompletionHandler)completion {
    UXParameterCompletionHandler innerCompletion = completion ?: ^(BOOL finished) {};

    for (UXViewController *rootViewController in self.rootViewControllers) {
        if ([rootViewController.navigationDestination isEqual:destination]) {
            id skipValue = [[destination.destinationAuxiliaryStore valueForKey:@"UXSourceControllerSkipDestinationRemovalKey" inNamespace:nil] boolValue] ? @YES : nil;

            if (skipValue) {
                innerCompletion(NO);
                return;
            }

            if (self.selectedViewController == rootViewController) {
                id<UXNavigationDestination> fallbackDestination = self.fallbackNavigationDestination;

                if (fallbackDestination) {
                    [self _navigateToDestination:fallbackDestination animated:animated completion:^(BOOL finished) {
                        [self _removeRootViewController:rootViewController];
                        innerCompletion(finished);
                    }];
                    return;
                }
            }

            [self _removeRootViewController:rootViewController];
            innerCompletion(YES);
            return;
        }

        UXNavigationController *navigationController = [_navigationControllerByRootViewController objectForKey:rootViewController];
        UXViewController *previousViewController = nil;

        for (UXViewController *viewController in navigationController.viewControllers) {
            if ([viewController.navigationDestination isEqual:destination]) {
                UXViewController *targetViewController = previousViewController ?: viewController;
                BOOL hasWindow = animated ? targetViewController.navigationController.view.window != nil : NO;
                [targetViewController.navigationController popToViewController:targetViewController animated:hasWindow];
                id<UXViewControllerTransitionCoordinator> transitionCoordinator = targetViewController.navigationController.transitionCoordinator ?: self.transitionCoordinator;

                if (transitionCoordinator) {
                    [transitionCoordinator animateAlongsideTransition:nil completion:^(id<UXViewControllerTransitionCoordinatorContext> transitionContext) {
                        innerCompletion(YES);
                    }];
                } else {
                    innerCompletion(YES);
                }

                return;
            }

            previousViewController = viewController;
        }
    }

    innerCompletion(NO);
}

#pragma mark - Present / Dismiss

- (void)presentViewController:(UXViewController *)viewController animated:(BOOL)animated completion:(UXCompletionHandler)completion {
    viewController.transitory = YES;
    [self.selectedNavigationController pushViewController:viewController animated:animated];

    if (completion) {
        if (self.transitionCoordinator) {
            [self.transitionCoordinator animateAlongsideTransition:nil completion:^(id<UXViewControllerTransitionCoordinatorContext> transitionContext) {
                completion();
            }];
        } else {
            completion();
        }
    }
}

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(UXCompletionHandler)completion {
    [self.selectedNavigationController _popTransitoryViewControllersAnimated:animated];

    if (completion) {
        if (self.transitionCoordinator) {
            [self.transitionCoordinator animateAlongsideTransition:nil completion:^(id<UXViewControllerTransitionCoordinatorContext> transitionContext) {
                completion();
            }];
        } else {
            completion();
        }
    }
}

#pragma mark - Transition controllers

+ (Class)_defaultTransitionControllerClass {
    return nil;
}

- (void)registerTransitionControllerClass:(Class)transitionControllerClass forViewControllerClass:(Class)viewControllerClass {
    if (transitionControllerClass && viewControllerClass) {
        [_transitionControllerClassByToViewControllerClass setObject:transitionControllerClass forKey:viewControllerClass];
    }
}

- (void)registerTranistionControllerClass:(Class)transitionControllerClass forViewControllerClass:(Class)viewControllerClass {
    [self registerTransitionControllerClass:transitionControllerClass forViewControllerClass:viewControllerClass];
}

- (void)unregisterTransitionControllerForTransitionToViewControllerClass:(Class)viewControllerClass {
    if (viewControllerClass && [_transitionControllerClassByToViewControllerClass objectForKey:viewControllerClass]) {
        [_transitionControllerClassByToViewControllerClass removeObjectForKey:viewControllerClass];
    }
}

- (void)_setupDelegateForNavigationController:(UXNavigationController *)navigationController operation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController {
    UXViewController *destinationViewController = nil;
    UXViewController *sourceViewController = nil;

    if (operation == UXNavigationControllerOperationPush) {
        sourceViewController = fromViewController;
        destinationViewController = toViewController;
    } else {
        destinationViewController = fromViewController;
        sourceViewController = toViewController;
    }

    Class transitionControllerClass = [_transitionControllerClassByToViewControllerClass objectForKey:[destinationViewController class]];

    if (transitionControllerClass || (transitionControllerClass = [_transitionControllerClassByToViewControllerClass objectForKey:[sourceViewController class]])) {
        if (transitionControllerClass == [destinationViewController class]) {
            _currentNavigationDelegate = (id<UXNavigationControllerDelegate>)destinationViewController;
        } else if (transitionControllerClass == [sourceViewController class]) {
            _currentNavigationDelegate = (id<UXNavigationControllerDelegate>)sourceViewController;
        } else {
            _currentNavigationDelegate = [transitionControllerClass new];
        }
    } else if ([[self class] _defaultTransitionControllerClass]) {
        _currentNavigationDelegate = [[[self class] _defaultTransitionControllerClass] new];

        if ([_currentNavigationDelegate isKindOfClass:[UXTransitionController class]]) {
            cast(UXTransitionController *, _currentNavigationDelegate).operation = operation;
        }
    }
}

- (_UXViewControllerOneToOneTransitionContext *)_contextForTransitionOperation:(NSInteger)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController transition:(NSUInteger)transition {
    NSUInteger effectiveTransition = transition;

    if (fromViewController && toViewController) {
        if (fromViewController.view == toViewController.view) {
            effectiveTransition = 102;
        }
    }

    _transitionController = [_transitionControllerClassForTransition(effectiveTransition) new];
    _transitionController.operation = operation;
    [self.view layoutSubtreeIfNeeded];

    NSSplitView *splitView = self.splitView;
    UXView *detailView = self.detailViewController.uxView;
    _UXViewControllerOneToOneTransitionContext *transitionContext = [_UXViewControllerOneToOneTransitionContext new];
    transitionContext.containerView = detailView;
    transitionContext.animated = transition != 102;
    transitionContext.animator = _transitionController;
    transitionContext.interactor = nil;
    transitionContext.initiallyInteractive = NO;
    transitionContext.fromViewController = fromViewController;
    transitionContext.toViewController = toViewController;
    transitionContext.fromStartFrame = fromViewController.view.frame;
    transitionContext.fromEndFrame = CGRectNull;
    transitionContext.toStartFrame = CGRectNull;
    transitionContext.toEndFrame = [detailView convertRect:splitView.bounds fromView:splitView];
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

    UXNavigationController *fromNavigationController = (UXNavigationController *)[context viewControllerForKey:UXTransitionContextFromViewControllerKey];
    [fromNavigationController.navigationBar _snapshot];
    UXNavigationController *toNavigationController = (UXNavigationController *)[context viewControllerForKey:UXTransitionContextToViewControllerKey];
    BOOL sourceListInResponderChain = [self.sourceListViewController isInResponderChainOf:window.firstResponder];
    fromNavigationController.uxView.userInteractionEnabled = NO;
    fromNavigationController.uxView.wantsSafeAreaInsetsFrozen = YES;
    toNavigationController.uxView.translatesAutoresizingMaskIntoConstraints = YES;
    toNavigationController.uxView.frame = [context finalFrameForViewController:toNavigationController];

    NSWindowStyleMask styleMask = window.styleMask;
    window.styleMask = styleMask & ~(NSWindowStyleMask)0xC;
    NSWindowCollectionBehavior collectionBehavior = window.collectionBehavior;

    if (!(styleMask & 0x4000)) {
        window.collectionBehavior = collectionBehavior & ~(NSWindowCollectionBehavior)0x80;
    }

    if (styleMask & NSWindowStyleMaskMiniaturizable) {
        [window ux_forceEnableStandardWindowButton:NSWindowMiniaturizeButton];
    }

    if ((styleMask & NSWindowStyleMaskResizable) || (collectionBehavior & 0x80)) {
        [window ux_forceEnableStandardWindowButton:NSWindowZoomButton];
    }

    id<UXViewControllerAnimatedTransitioning> animator = context.animator;
    context.duration = [animator transitionDuration:context];

    @weakify(self);
    context.completionHandler = ^(_UXViewControllerTransitionContext *transitionContext, BOOL isCompletion) {
        @strongify(self);
        id<UXViewControllerAnimatedTransitioning> contextAnimator = transitionContext.animator;

        if ([contextAnimator respondsToSelector:@selector(animationEnded:)]) {
            [contextAnimator animationEnded:isCompletion];
        }

        [toNavigationController didMoveToParentViewController:self.detailViewController];
        fromNavigationController.uxView.userInteractionEnabled = YES;
        toNavigationController.uxView.userInteractionEnabled = YES;
        toNavigationController.uxView.translatesAutoresizingMaskIntoConstraints = NO;
        UXView *toView = toNavigationController.uxView;
        NSSplitView *splitView = self.splitView;
        self.selectedNavigationViewConstraints = @[
            [toView.topAnchor constraintEqualToAnchor:splitView.topAnchor],
            [toView.bottomAnchor constraintEqualToAnchor:splitView.bottomAnchor],
            [toView.leadingAnchor constraintEqualToAnchor:splitView.leadingAnchor],
            [toView.trailingAnchor constraintEqualToAnchor:splitView.trailingAnchor],
        ];
        window.styleMask = styleMask;
        window.collectionBehavior = collectionBehavior;
        [fromNavigationController.navigationBar setAlternateTitleView:nil];
        [fromNavigationController willMoveToParentViewController:nil];
        [fromNavigationController.view removeFromSuperview];
        [fromNavigationController removeFromParentViewController];
        fromNavigationController.uxView.wantsSafeAreaInsetsFrozen = NO;
        [uxWindowController _updateToolbarItems];

        if (self.wantsDetachedToolbars) {
            [self _updateDetailSplitViewItemAccessories];
        }

        [toNavigationController.navigationBar _updateItemContainer];

        if (!sourceListInResponderChain) {
            [window makeFirstResponder:toNavigationController.preferredFirstResponder];
        }

        self->_isTransitioning = NO;
        self->_transitionCtx = nil;
        self->_transitionController = nil;
    };

    [self _prepareViewController:fromNavigationController forAnimationInContext:context completion:^{
        @strongify(self);

        if (toNavigationController._requiresWindowForTransitionPreparation) {
            toNavigationController.view.alphaValue = 0.0;
            UXView *containerView = context.containerView;

            if (operation == 1) {
                [containerView addSubview:toNavigationController.view];
            } else {
                [containerView addSubview:toNavigationController.view positioned:NSWindowBelow relativeTo:fromNavigationController.view];
            }
        }

        [uxWindowController _updateAccessoryBar];
        [self _prepareViewController:toNavigationController forAnimationInContext:context completion:^{
            toNavigationController.view.alphaValue = 1.0;
            [context.animator animateTransition:context];
            [context __runAlongsideAnimations];
            context.transitionIsInFlight = YES;
        }];
    }];
}

- (void)_prepareViewController:(UXViewController *)viewController forAnimationInContext:(_UXViewControllerOneToOneTransitionContext *)context completion:(UXCompletionHandler)completion {
    if (viewController) {
        [viewController _prepareForAnimationInContext:context completion:completion];
    } else if (completion) {
        completion();
    }
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

- (BOOL)navigationController:(UXNavigationController *)navigationController shouldBeginInteractivePopFromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController {
    [self _setupDelegateForNavigationController:navigationController operation:UXNavigationControllerOperationPop fromViewController:fromViewController toViewController:toViewController];

    if ([_currentNavigationDelegate respondsToSelector:_cmd]) {
        return [_currentNavigationDelegate navigationController:navigationController shouldBeginInteractivePopFromViewController:fromViewController toViewController:toViewController];
    }

    return _currentNavigationDelegate == nil;
}

- (void)navigationController:(UXNavigationController *)navigationController willShowViewController:(UXViewController *)viewController {
    NSWindow *window = navigationController.view.window;

    if (window) {
        [self willChangeTopViewController:viewController];
    }

    BOOL isSelectedNavigationController = self.selectedNavigationController == navigationController;
    BOOL wantsSourceListCollapsed = [self _wantsSourceListCollapsedForViewController:viewController];
    BOOL wantsInspectorCollapsed = [self _wantsInspectorCollapsedForViewController:viewController];
    CGFloat leadingContentInset = [self _leadingContentInsetForWantsCollapsed:wantsSourceListCollapsed];
    [navigationController _setLeadingContentInset:leadingContentInset forViewController:viewController];
    [navigationController.transitionCoordinator animateAlongsideTransition:^(id<UXViewControllerTransitionCoordinatorContext> transitionContext) {
        if (isSelectedNavigationController) {
            [self _setWantsSourceListCollapsed:wantsSourceListCollapsed wantsInspectorCollapsed:wantsInspectorCollapsed animated:transitionContext.isAnimated completion:nil];
        }
    } completion:^(id<UXViewControllerTransitionCoordinatorContext> transitionContext) {
        self->_currentNavigationDelegate = nil;
        [self _updateDetailSplitViewItemAccessories];

        if (!self->_navigatingToDestination) {
            id<UXNavigationDestination> currentNavigationDestination = self.currentNavigationDestination;

            if (isSelectedNavigationController && currentNavigationDestination) {
                [self.sourceListViewController selectNavigationDestination:currentNavigationDestination];
            }
        }
    }];
}

- (void)navigationController:(UXNavigationController *)navigationController didShowViewController:(UXViewController *)viewController {
    if (navigationController.view.window) {
        [self didChangeTopViewControllerForNavigationController:navigationController];
    }
}

#pragma mark - Layout guides / intrinsic insets

- (id<UXLayoutSupport>)topLayoutGuide {
    if (!_topLayoutGuide) {
        _UXLayoutSpacer *layoutSpacer = [_UXLayoutSpacer _verticalLayoutSpacer];
        @weakify(self);
        layoutSpacer.lengthUpdateBlock = ^{
            @strongify(self);
            [self didUpdateLayoutGuides];
        };
        _topLayoutGuide = layoutSpacer;
    }

    return _topLayoutGuide;
}

- (id<UXLayoutSupport>)bottomLayoutGuide {
    if (!_bottomLayoutGuide) {
        _UXLayoutSpacer *layoutSpacer = [_UXLayoutSpacer _verticalLayoutSpacer];
        @weakify(self);
        layoutSpacer.lengthUpdateBlock = ^{
            @strongify(self);
            [self didUpdateLayoutGuides];
        };
        _bottomLayoutGuide = layoutSpacer;
    }

    return _bottomLayoutGuide;
}

- (void)invalidateIntrinsicLayoutInsets {
    for (UXViewController *childViewController in self.childViewControllers) {
        if ([childViewController isKindOfClass:[UXViewController class]]) {
            if (childViewController.edgesForExtendedLayout & UXRectEdgeTop) {
                childViewController.topLayoutGuide.length = self.topLayoutGuide.length;
            }

            if (childViewController.edgesForExtendedLayout & UXRectEdgeBottom) {
                childViewController.bottomLayoutGuide.length = self.bottomLayoutGuide.length;
            }
        }
    }
}

#pragma mark - Responder / transition coordinator

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

- (id<UXViewControllerTransitionCoordinator>)transitionCoordinator {
    if (_isTransitioning) {
        return _transitionCtx._transitionCoordinator;
    }

    return nil;
}

- (NSViewController *)contentRepresentingViewController {
    return self.selectedNavigationController.topViewController.contentRepresentingViewController;
}

#pragma mark - Sidebar command

- (void)toggleSidebar:(id)sender {
    _isTogglingSidebar = YES;
    [super toggleSidebar:sender];
    _isTogglingSidebar = NO;
    _wantsSourceListCollapsed = self.sidebarSplitViewItem.isCollapsed;
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item {
    BOOL valid = [super validateUserInterfaceItem:item];

    if (valid && item.action == @selector(toggleSidebar:)) {
        if (self.isSourceListCollapsed) {
            return !self.selectedNavigationController.topViewController.hidesSourceListWhenPushed;
        }

        return YES;
    }

    return valid;
}

- (CGRect)splitView:(NSSplitView *)splitView effectiveRect:(CGRect)proposedEffectiveRect forDrawnRect:(CGRect)drawnRect ofDividerAtIndex:(NSInteger)dividerIndex {
    CGRect effectiveRect = [super splitView:splitView effectiveRect:proposedEffectiveRect forDrawnRect:drawnRect ofDividerAtIndex:dividerIndex];

    if (dividerIndex == 1) {
        return CGRectZero;
    }

    return effectiveRect;
}

#pragma mark - Hooks

- (UXNavigationController *)navigationController {
    return nil;
}

- (void)didChangeSelectedViewController {
}

- (void)willSelectViewController:(UXViewController *)viewController {
}

- (void)willChangeTopViewController:(UXViewController *)viewController {
}

- (void)didChangeTopViewControllerForNavigationController:(UXNavigationController *)navigationController {
}

- (void)willUpdateToolbarForNavigationController:(UXNavigationController *)navigationController {
}

- (void)windowDidUpdateFirstResponder {
}

- (void)windowWillEnterFullScreen {
}

- (void)windowWillExitFullScreen {
}

- (void)windowDidRecalculateKeyViewLoop {
}

- (BOOL)isWindowInFullScreen {
    return self.detailViewController.isWindowInFullScreen;
}

- (BOOL)isWindowConsideredInFullScreen {
    return self.detailViewController.isWindowConsideredInFullScreen;
}

- (void)willMoveToParentViewController:(UXViewController *)parent {
}

- (void)didMoveToParentViewController:(UXViewController *)parent {
}

- (void)contentRepresentingViewControllerDidChange {
}

- (void)windowWillRecalculateKeyViewLoop {
}

- (void)didUpdateLayoutGuides {
}

- (void)setSelectedNavigationViewConstraints:(NSArray *)selectedNavigationViewConstraints {
    if (![_selectedNavigationViewConstraints isEqualToArray:selectedNavigationViewConstraints]) {
        [NSLayoutConstraint deactivateConstraints:_selectedNavigationViewConstraints];
        _selectedNavigationViewConstraints = selectedNavigationViewConstraints.copy;
        [NSLayoutConstraint activateConstraints:_selectedNavigationViewConstraints];
    }
}

- (void)setSelectedNavigationTopViewController:(UXViewController *)selectedNavigationTopViewController {
    _selectedNavigationTopViewController = selectedNavigationTopViewController;
}

@end
