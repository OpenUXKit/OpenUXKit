#import <OpenUXKit/_UXSourceSplitItemView.h>
#import <OpenUXKit/_UXSourceSplitView.h>
#import <OpenUXKit/_UXViewControllerOneToOneTransitionContext.h>
#import <OpenUXKit/_UXViewControllerTransitionCoordinator.h>
#import <OpenUXKit/NSResponder+UXKit.h>
#import <OpenUXKit/NSWindow+UXKit.h>
#import <OpenUXKit/UXKitPrivateUtilites.h>
#import <OpenUXKit/UXNavigationBar+Internal.h>
#import <OpenUXKit/UXNavigationController+Internal.h>
#import <OpenUXKit/UXSourceController.h>
#import <OpenUXKit/UXSourceList.h>
#import <OpenUXKit/UXTabBarItem.h>
#import <OpenUXKit/UXViewController+Internal.h>
#import <OpenUXKit/UXViewControllerTransitionCoordinator.h>

@interface UXSourceController () <_UXSourceSplitViewDelegate> {
    NSView *_tabBarView;
    _UXSourceSplitView *_splitView;
    NSLayoutConstraint *_popUpWidthContraint;
    BOOL _needsToSetInitialSourceListWidth;
    double _preferredSourceListWidthFraction;
    BOOL _isTransitioning;
    _UXViewControllerOneToOneTransitionContext *_transitionCtx;
    UXTransitionController *_transitionController;
    NSMapTable<UXViewController *, UXNavigationController *> *_navigationControllerByRootViewController;
    NSMapTable *_transitionControllerClassByToViewControllerClass;
    NSOperationQueue *_viewControllerOperations;
    UXNavigationController *_targetNavigationController;
    id <UXNavigationDestination> _targetNavigationDestination;
    BOOL _navigatingToDestination;
    id <UXNavigationControllerDelegate> _currentNavigationDelegate;
    id _localEdgeHoverEventMonitor;
    id _globalEdgeHoverEventMonitor;
    id _windowResizeObserver;
    id _windowDeactivateObserver;
    UXView *_transientlyUncollapsedView;
    BOOL _hasItemToRevealOnEdgeHover;
    BOOL _wantsDetachedNavigationBars;
    NSInteger _preferredStyle;
    NSInteger _style;
    UXViewController<UXSourceList> *_sourceListViewController;
    CGFloat _minimumWidthForInlineSourceList;
    NSString *_sourceListAutosaveName;
    NSArray *_rootViewControllers;
    UXViewController *_selectedViewController;
    NSSegmentedControl *_segmentedControl;
    NSPopUpButton *_popUpButton;
    __weak NSWindow *_observedWindow;
    NSSearchToolbarItem *_searchToolbarItem;
}
@end

@implementation UXSourceController

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _style = -1;
        _needsToSetInitialSourceListWidth = YES;
        _preferredSourceListWidthFraction = 0.15;
        _segmentedControl = [NSSegmentedControl new];
        _segmentedControl.segmentStyle = NSSegmentStyleTexturedSquare;
        _segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        _segmentedControl.target = self;
        _segmentedControl.action = @selector(segmentChanged:);
        _popUpButton = [NSPopUpButton new];
        _popUpButton.bezelStyle = NSBezelStyleToolbar;
        _popUpButton.translatesAutoresizingMaskIntoConstraints = NO;
        _popUpButton.menu.autoenablesItems = NO;
        _popUpButton.target = self;
        _popUpButton.action = @selector(popUpChanged:);
        _popUpWidthContraint = [_popUpButton.widthAnchor constraintGreaterThanOrEqualToConstant:120.0];
        _popUpWidthContraint.priority = 260.0;
        _popUpWidthContraint.active = YES;
        _navigationControllerByRootViewController = [NSMapTable weakToStrongObjectsMapTable];
        _transitionControllerClassByToViewControllerClass = [NSMapTable weakToWeakObjectsMapTable];
        _viewControllerOperations = [NSOperationQueue new];
        _viewControllerOperations.maxConcurrentOperationCount = 1;
        _viewControllerOperations.qualityOfService = NSQualityOfServiceUserInitiated;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _splitView = [[_UXSourceSplitView alloc] initWithFrame:self.view.bounds];
    _splitView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    _splitView.accessibilityIdentifier = @"UXSourceControllerSplitView";
    _splitView.minimumWidthForInlineSourceList = self.minimumWidthForInlineSourceList;
    _splitView.revealsOnEdgeHoverInFullscreen = YES;
    _splitView.springLoaded = YES;
    _splitView.delegate = self;
    [self.view addSubview:_splitView];
    self.style = 0;
    self.selectedIndex = 0;
}

- (void)setStyle:(NSInteger)style {
    [self _setStyle:style animated:NO completion:nil];
}

- (void)_setStyle:(NSInteger)style animated:(BOOL)animated completion:(UXParameterCompletionHandler)completion {
    if (_style == style) {
        if (completion) {
            completion(NO);
        }
    } else if (animated) {
        [UXView animateWithDuration:0.3
                              delay:0.0
                            options:0
                         animations:^{
            [self _setStyle:style];
        }
                         completion:^(BOOL finished) {
            [self _didChangeCollapsed];

            if (completion) {
                completion(finished);
            }
        }];
    } else {
        [self _setStyle:style];
        [self _didChangeCollapsed];

        if (completion) {
            completion(YES);
        }
    }
}

- (void)_setStyle:(NSInteger)style {
    if (_style != style) {
        _style = style;
        [self _setWantsSourceListCollapsed:style == 0];

        for (UXNavigationController *navigationController in _navigationControllerByRootViewController.objectEnumerator) {
            UXViewController *firstViewController = navigationController.viewControllers.firstObject;

            if (firstViewController != _selectedViewController) {
                navigationController.navigationBar.alternateTitleEnabled = self.alternateTitleEnabled;
            }
        }

        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *_Nonnull context) {
            context.allowsImplicitAnimation = NO;
            self.selectedNavigationController.navigationBar.alternateTitleEnabled = self.alternateTitleEnabled;
            [self.selectedNavigationController.navigationBar layoutSubtreeIfNeeded];
        }
                            completionHandler:nil];
        _tabBarView.hidden = style == 0;
    }
}

- (void)_setWantsSourceListCollapsed:(BOOL)collapsed {
    if (_splitView.wantsCollapsed != collapsed) {
        _splitView.wantsCollapsed = collapsed;
        [self _setLeadingContentInset:_splitView.leadingContentInset];
        [self _setHasItemToRevealOnEdgeHover:_splitView.collapsed];
        _sourceListViewController.sourceListCollapsed = _splitView.collapsed;
    }
}

- (void)_setLeadingContentInset:(CGFloat)contentInset {
    for (UXNavigationController *navigationController in _navigationControllerByRootViewController.objectEnumerator) {
        [navigationController _setLeadingContentInset:contentInset forViewController:navigationController.topViewController];
    }
}

- (void)_setHasItemToRevealOnEdgeHover:(BOOL)hasItemToRevealOnEdgeHover {
    if (_hasItemToRevealOnEdgeHover != hasItemToRevealOnEdgeHover) {
        _hasItemToRevealOnEdgeHover = hasItemToRevealOnEdgeHover;
        NSWindow *window = self.viewIfLoaded.window;

        if (window) {
            if (hasItemToRevealOnEdgeHover) {
                if (window.ux_inFullScreen) {
                    [self _startObservingEdgeHover];
                }

                [self _startObservingFullscreenForWindow:window];
            } else {
                [self _stopObservingEdgeHover];
                [self _stopObservingFullscreenForWindow:window];
            }
        }
    }
}

- (UXNavigationController *)selectedNavigationController {
    return [_navigationControllerByRootViewController objectForKey:_selectedViewController];
}

- (BOOL)alternateTitleEnabled {
    return _style == 0;
}

- (void)_didChangeCollapsed {
    [_splitView didChangeCollapsed];

    if (_splitView.collapsed) {
        BOOL isInResponderChain = [_splitView.masterView isInResponderChainOf:self.view.window.firstResponder];

        if (isInResponderChain) {
            [self.view.window makeFirstResponder:[self preferredFirstResponder]];
        }
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    NSBlockOperation *blockOperation = [NSBlockOperation new];

    @weakify(blockOperation);
    [blockOperation addExecutionBlock:^{
        @strongify(blockOperation);

        if (!blockOperation.isCancelled) {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

            dispatch_async(dispatch_get_main_queue(), ^{
                               [self _setSelectedIndex:selectedIndex
                                              animated:animated
                                                sender:nil];

                               if (self.transitionCoordinator) {
                                   [self.transitionCoordinator animateAlongsideTransition:nil
                                                                               completion:^(id<UXViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                        dispatch_semaphore_signal(semaphore);
                    }];
                               } else {
                                   dispatch_semaphore_signal(semaphore);
                               }
                           });
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    }];
    blockOperation.name = NSStringFromSelector(_cmd);

    for (NSOperation *operation in _viewControllerOperations.operations) {
        if ([operation.name isEqualToString:blockOperation.name]) {
            [operation cancel];
        }
    }

    [_viewControllerOperations addOperation:blockOperation];
}

- (void)registerTransitionControllerClass:(Class)transitionControllerClass forViewControllerClass:(Class)viewControllerClass {
    if (transitionControllerClass && viewControllerClass) {
        [_transitionControllerClassByToViewControllerClass setObject:transitionControllerClass forKey:viewControllerClass];
    }
}

- (void)setSourceListViewController:(UXViewController<UXSourceList> *)sourceListViewController {
    if (_sourceListViewController) {
        [_sourceListViewController willMoveToParentViewController:nil];
        [_sourceListViewController.view removeFromSuperview];
        [_sourceListViewController removeFromParentViewController];
    }

    _sourceListViewController = sourceListViewController;

    if (_sourceListViewController) {
        NSParameterAssert([_sourceListViewController conformsToProtocol:@protocol(UXSourceList)]);
        [self addChildViewController:_sourceListViewController];
        _splitView.minimumMasterWidth = _sourceListViewController.minSourceListWidth;
        _splitView.maximumMasterWidth = _sourceListViewController.maxSourceListWidth;
        _splitView.masterWidth = self._preferredSourceListWidth;
        _splitView.masterView.contentView = _sourceListViewController.view;
        [_sourceListViewController didMoveToParentViewController:self];
    }
}

- (id<UXNavigationDestination>)currentNavigationDestination {
    NSMutableArray *array = [NSMutableArray array];

    for (UXViewController *viewController in self.selectedNavigationController.viewControllers.reverseObjectEnumerator) {
        id<UXNavigationDestination> navigationDestination = viewController.navigationDestination;

        if (navigationDestination) {
            for (UXViewController *innerViewController in array.reverseObjectEnumerator) {
                [innerViewController willEncodeNavigationDestination:navigationDestination];
            }

            return navigationDestination;
        }

        [array addObject:viewController];
    }

    return nil;
}

- (CGFloat)_preferredSourceListWidth {
    CGFloat result = _splitView.masterWidth;

    if (_sourceListAutosaveName.length) {
        float autosaveWidth = [[NSUserDefaults standardUserDefaults] floatForKey:[[self class] _widthDefaultsKeyForAutosaveName:_sourceListAutosaveName]];
        CGFloat width = autosaveWidth;

        if (autosaveWidth == 0.0 && self.isViewLoaded) {
            width = round(self.preferredSourceListWidthFraction * CGRectGetWidth(self.view.bounds));
        }

        result = _sourceListViewController.minSourceListWidth;
        CGFloat maxSourceListWidth = _sourceListViewController.maxSourceListWidth;

        if (width < maxSourceListWidth) {
            maxSourceListWidth = width;
        }

        if (result < maxSourceListWidth) {
            return maxSourceListWidth;
        }
    }

    return result;
}

- (void)setSourceListAutosaveName:(NSString *)sourceListAutosaveName {
    if (![_sourceListAutosaveName isEqualToString:sourceListAutosaveName]) {
        _sourceListAutosaveName = sourceListAutosaveName.copy;
        _splitView.masterWidth = self._preferredSourceListWidth;
    }
}

+ (NSString *)_widthDefaultsKeyForAutosaveName:(NSString *)autosaveName {
    return [NSString stringWithFormat:@"%@.UXSourceListWidth", autosaveName];
}

- (void)setMinimumWidthForInlineSourceList:(CGFloat)minimumWidthForInlineSourceList {
    if (_minimumWidthForInlineSourceList != minimumWidthForInlineSourceList) {
        _minimumWidthForInlineSourceList = minimumWidthForInlineSourceList;

        if (_splitView) {
            _splitView.minimumWidthForInlineSourceList = minimumWidthForInlineSourceList;
        }
    }
}

- (void)setPreferredStyle:(NSInteger)preferredStyle {
    [self _setPreferredStyle:preferredStyle animated:NO completion:nil];
}

- (void)_setPreferredStyle:(NSInteger)style animated:(BOOL)animated completion:(nullable UXParameterCompletionHandler)completion {
    NSBlockOperation *blockOperation = [NSBlockOperation new];

    @weakify(blockOperation);
    [blockOperation addExecutionBlock:^{
        @strongify(blockOperation);

        if (!blockOperation.isCancelled) {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

            dispatch_async(dispatch_get_main_queue(), ^{
                               __auto_type performCompletion = ^(BOOL finished) {
                    dispatch_semaphore_signal(semaphore);
                    completion(finished);
                };

                               if (self->_preferredStyle == style) {
                                   performCompletion(NO);
                               } else {
                                   self->_preferredStyle = style;
                                   NSInteger effectiveStyle = [self _effectiveStyleForViewController:self.selectedNavigationController.currentTopViewController];

                                   if (self->_preferredStyle == effectiveStyle) {
                                       performCompletion(NO);
                                   } else {
                                       [self _setStyle:effectiveStyle
                                              animated:animated
                                            completion:performCompletion];
                                   }
                               }
                           });
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    }];
    blockOperation.name = NSStringFromSelector(_cmd);

    for (NSOperation *operation in _viewControllerOperations.operations) {
        if ([operation.name isEqualToString:blockOperation.name]) {
            [operation cancel];
        }
    }

    [_viewControllerOperations addOperation:blockOperation];
}

- (void)setRootViewControllers:(NSArray<UXViewController *> *)rootViewControllers destination:(id)destination completion:(UXCompletionHandler)completion {
    UXCompletionHandler innerCompletion = ^{};

    if (completion) {
        innerCompletion = completion;
    }

    [_viewControllerOperations addOperationWithBlock:^{
        dispatch_block_t block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
                                                           innerCompletion();
                                                       });
        dispatch_async(dispatch_get_main_queue(), ^{
                           [self _setRootViewControllers:rootViewControllers
                                             destination:destination
                                              completion:block];
                       });
        dispatch_block_wait(block, DISPATCH_TIME_FOREVER);
    }];
}

- (void)viewWillAppear {
    [super viewWillAppear];

    if (_needsToSetInitialSourceListWidth) {
        _needsToSetInitialSourceListWidth = NO;
        _splitView.masterWidth = [self _preferredSourceListWidth];
    }
}

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

- (void)_setSelectedIndex:(NSInteger)index animated:(BOOL)animated sender:(id)sender {
    if (_segmentedControl.segmentCount) {
        NSInteger clampedIndex = 0;
        NSInteger selectedIndex = 0;

        if (index > 0) {
            clampedIndex = index;
        }

        if (index != NSNotFound) {
            selectedIndex = clampedIndex;
        }

        NSInteger segmentCount = _segmentedControl.segmentCount;

        if (selectedIndex >= segmentCount - 1) {
            selectedIndex = segmentCount - 1;
        }

        if (_segmentedControl != sender) {
            _segmentedControl.selectedSegment = selectedIndex;
        }

        if (_popUpButton != sender) {
            [_popUpButton selectItemAtIndex:selectedIndex];
        }

        if (self.isViewLoaded) {
            [self _setSelectedViewController:_rootViewControllers[selectedIndex] animated:animated sender:sender];
        }
    }
}

- (id<UXViewControllerTransitionCoordinator>)transitionCoordinator {
    if (_isTransitioning) {
        return _transitionCtx._transitionCoordinator;
    } else {
        return [super transitionCoordinator];
    }
}

- (void)viewDidAppear {
    [super viewDidAppear];

    NSWindow *window = self.view.window;

    if (window) {
        if (self._hasItemToRevealOnEdgeHover) {
            [self _startObservingFullscreenForWindow:window];

            if (window.ux_inFullScreen) {
                [self _startObservingEdgeHover];
            }
        }
    }

    self.observedWindow = window;
}

- (void)_startObservingFullscreenForWindow:(NSWindow *)window {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didEnterFullscreen:) name:NSWindowDidEnterFullScreenNotification object:window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didExitFullscreen:) name:NSWindowDidExitFullScreenNotification object:window];
}

static void *kFirstResponderObserverContext = &kFirstResponderObserverContext;

- (void)setObservedWindow:(NSWindow *)observedWindow {
    if (_observedWindow != observedWindow) {
        [_observedWindow removeObserver:self forKeyPath:NSStringFromSelectorLiteral(firstResponder) context:kFirstResponderObserverContext];
        [observedWindow addObserver:self forKeyPath:NSStringFromSelectorLiteral(firstResponder) options:0 context:kFirstResponderObserverContext];
    }
}

- (NSInteger)_effectiveStyleForViewController:(UXViewController *)viewController {
    if (_preferredStyle == 1) {
        return viewController.hidesSourceListWhenPushed ^ 1;
    } else {
        return 0;
    }
}

- (void)_stopObservingEdgeHover {
    if (_localEdgeHoverEventMonitor) {
        [NSEvent removeMonitor:_localEdgeHoverEventMonitor];
        _localEdgeHoverEventMonitor = nil;
    }

    if (_globalEdgeHoverEventMonitor) {
        [NSEvent removeMonitor:_globalEdgeHoverEventMonitor];
        _globalEdgeHoverEventMonitor = nil;
    }
}

- (void)_stopObservingFullscreenForWindow:(NSWindow *)window {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidEnterFullScreenNotification object:window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidExitFullScreenNotification object:window];
}

- (void)_setRootViewControllers:(NSArray<UXViewController *> *)rootViewControllers destination:(id<UXNavigationDestination>)destination completion:(UXCompletionHandler)completion {
    if (![_rootViewControllers isEqualToArray:rootViewControllers]) {
        dispatch_group_t group = dispatch_group_create();

        for (UXViewController *rootViewController in _rootViewControllers) {
            if (![rootViewControllers containsObject:rootViewController]) {
                [rootViewController removeObserver:self forKeyPath:@keypath(rootViewController.tabBarItem.title) context:nil];
                UXNavigationController *navigationController = [_navigationControllerByRootViewController objectForKey:rootViewController];
                dispatch_group_enter(group);
                auto innerCompletion = ^{
                    [navigationController willMoveToParentViewController:nil];
                    [navigationController.view removeFromSuperview];
                    [navigationController removeFromParentViewController];
                    [self->_navigationControllerByRootViewController removeObjectForKey:rootViewController];
                    dispatch_group_leave(group);
                };

                if (rootViewControllers.count && self.selectedViewController == rootViewController) {
                    innerCompletion();
                } else {
                    [navigationController setViewControllers:@[[UXViewController new]] animated:NO];

                    if (!navigationController.transitionCoordinator) {
                        innerCompletion();
                        continue;
                    }

                    [navigationController.transitionCoordinator animateAlongsideTransition:nil
                                                                                completion:^(id<UXViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                        innerCompletion();
                    }];
                }
            }
        }

        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            for (UXViewController *rootViewController in rootViewControllers) {
                if (![self->_rootViewControllers containsObject:rootViewController]) {
                    [self _addRootViewController:rootViewController];
                }
            }

            self->_rootViewControllers = rootViewControllers.copy;
            [self _updateSelectionControls];
            auto setSelectedIndex = ^(NSInteger index) {
                if (self.selectedIndex != index) {
                    [self _setSelectedIndex:index animated:NO sender:nil];
                }

                if (self.transitionCoordinator) {
                    [self.transitionCoordinator animateAlongsideTransition:nil
                                                                completion:^(id<UXViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                        completion();
                    }];
                } else {
                    completion();
                }
            };

            if (destination) {
                [self _navigateToDestination:destination
                                    animated:NO
                                  completion:^(BOOL finished) {
                    if (finished) {
                        completion();
                    } else {
                        [self _navigateToDestination:self.fallbackNavigationDestination
                                            animated:NO
                                          completion:^(BOOL finished) {
                            if (finished) {
                                completion();
                            } else {
                                setSelectedIndex(0);
                            }
                        }];
                    }
                }];
            } else if (rootViewControllers.count) {
                NSInteger index = [rootViewControllers indexOfObject:self->_selectedViewController];

                if (index == NSNotFound) {
                    index = 0;
                }

                setSelectedIndex(index);
            } else {
                setSelectedIndex(-1);
            }
        });
    } else {
        completion();
    }
}

- (void)_updateSelectionControls {
    _segmentedControl.segmentCount = _rootViewControllers.count;
    NSInteger indexOfSelectedItem = _popUpButton.indexOfSelectedItem;
    [_popUpButton removeAllItems];
    NSDictionary<NSAttributedStringKey, id> *attributes = @{
            NSFontAttributeName: _segmentedControl.font
    };

    __block CGFloat maxWidth = 0.0;
    [_rootViewControllers enumerateObjectsUsingBlock:^(UXViewController *_Nonnull rootViewController, NSUInteger index, BOOL *_Nonnull stop) {
        NSString *title = rootViewController.tabBarItem.title;

        if (!title) {
            title = @"";
        }

        [self->_segmentedControl setLabel:title
                               forSegment:index];
        [self->_popUpButton.menu addItemWithTitle:title
                                           action:nil
                                    keyEquivalent:@""];
        NSSet<NSString *> *possibleTitles = rootViewController.tabBarItem.possibleTitles;

        if (!possibleTitles) {
            possibleTitles = [NSSet setWithObject:title];
        }

        for (NSString *possibleTitle in possibleTitles) {
            CGSize size = [possibleTitle sizeWithAttributes:attributes];

            if (maxWidth < size.width) {
                maxWidth = size.width;
            }
        }
    }];

    if (_popUpButton.numberOfItems > indexOfSelectedItem) {
        [_popUpButton selectItemAtIndex:indexOfSelectedItem];
    }

    NSInteger segmentCount = _segmentedControl.segmentCount;
    BOOL v11 = maxWidth < 80.0 || segmentCount < 5;
    CGFloat v12 = maxWidth + 29.0;

    if (!v11) {
        v12 = 0.0;
    }

    maxWidth = v12;

    for (NSInteger i = 0; i < _segmentedControl.segmentCount; i++) {
        [_segmentedControl setWidth:maxWidth forSegment:i];
    }

    [_segmentedControl layoutSubtreeIfNeeded];
}

//- (void)_navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(UXParameterCompletionHandler)completion {
//    UXViewController *rootViewController = [self _rootViewControllerProvidingViewControllersForNavigationDestination:destination];
//    if (rootViewController) {
//        if (![_rootViewControllers containsObject:rootViewController]) {
//            [self _addRootViewController:rootViewController];
//            _rootViewControllers = [_rootViewControllers arrayByAddingObject:rootViewController];
//            [self _updateSelectionControls];
//        }
//
//        [rootViewController requestViewControllersForNavigationDestination:destination completion:^(BOOL, NSArray<UXViewController *> * _Nonnull) {
//
//        }];
//    } else if (completion) {
//        completion(NO);
//    }
//}
//
//- (id)_rootViewControllerProvidingViewControllersForNavigationDestination:(id<UXNavigationDestination>)destination {
//
//}

@end
