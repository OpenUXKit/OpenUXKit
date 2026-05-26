#import <OpenUXKit/UXTabBarController.h>
#import <OpenUXKit/UXTabBarItem.h>
#import <OpenUXKit/UXTabBarItemSegment.h>
#import <OpenUXKit/UXNavigationController+Internal.h>
#import <OpenUXKit/UXNavigationItem+Internal.h>
#import <OpenUXKit/UXViewController+Internal.h>
#import <OpenUXKit/UXViewControllerTransitionCoordinator.h>
#import <OpenUXKit/UXViewControllerTransitioning.h>
#import <OpenUXKit/UXTransitionController.h>
#import <OpenUXKit/UXView.h>
#import <OpenUXKit/UXKitPrivateUtilites.h>
#import <OpenUXKit/_UXViewControllerOneToOneTransitionContext.h>
#import <OpenUXKit/_UXViewControllerTransitionContext.h>
#import <OpenUXKit/_UXViewControllerTransitionCoordinator.h>
#import <OpenUXKit/EXTScope.h>

static void *kTabBarItemObservationContext = &kTabBarItemObservationContext;
static void *kItemSegmentEnabledObservationContext = &kItemSegmentEnabledObservationContext;
static void *kLeftBarButtonItemsObservationContext = &kLeftBarButtonItemsObservationContext;
static void *kRightBarButtonItemsObservationContext = &kRightBarButtonItemsObservationContext;
static void *kProgressBarButtonItemObservationContext = &kProgressBarButtonItemObservationContext;
static void *kNavigationItemTitlesObservationContext = &kNavigationItemTitlesObservationContext;
static void *kToolbarPropertiesObservationContext = &kToolbarPropertiesObservationContext;

@interface UXTabBarController () <NSMenuItemValidation> {
    _UXViewControllerOneToOneTransitionContext *_transitionCtx;
    UXTransitionController *_transitionController;
    UXViewController *_installedViewController;
    BOOL _needsTransition;
    BOOL _tabBarHidden;
    __weak UXViewController *_selectedViewController;
}

@property (nonatomic, strong, readwrite) NSSegmentedControl *segmentedControl;
@property (nonatomic, strong, readwrite) NSPopUpButton *popUpButton;
@property (nonatomic, strong, readwrite) NSLayoutConstraint *popUpButtonWidthConstraint;
@property (nonatomic, strong, readwrite) NSToolbarItemGroup *toolbarItemGroup;
@property (nonatomic, strong, readwrite) NSMapTable *transitionControllerClassByToViewControllerClass;
@end

@implementation UXTabBarController

@synthesize selectedViewController = _selectedViewController;

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _segmentedControl = [NSSegmentedControl new];
        _segmentedControl.segmentStyle = NSSegmentStyleTexturedSquare;
        _segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        _segmentedControl.target = self;
        _segmentedControl.action = @selector(segmentChanged:);
        _segmentedControl.cell.controlSize = NSControlSizeLarge;

        _popUpButton = [NSPopUpButton new];
        _popUpButton.bezelStyle = NSBezelStyleToolbar;
        _popUpButton.translatesAutoresizingMaskIntoConstraints = NO;
        _popUpButton.menu.autoenablesItems = NO;
        _popUpButton.target = self;
        _popUpButton.action = @selector(popUpChanged:);
        _popUpButton.cell.controlSize = NSControlSizeLarge;

        _popUpButtonWidthConstraint = [_popUpButton.widthAnchor constraintGreaterThanOrEqualToConstant:120.0];
        _popUpButtonWidthConstraint.priority = 260.0;
        _popUpButtonWidthConstraint.active = YES;

        _toolbarItemGroup = [NSToolbarItemGroup groupWithItemIdentifier:@"UXWindowToolbarCenteredItem"
                                                                 titles:@[]
                                                          selectionMode:NSToolbarItemGroupSelectionModeSelectOne
                                                                 labels:@[]
                                                                 target:self
                                                                 action:@selector(toolbarItemGroupSelectionDidChange:)];
        _toolbarItemGroup.visibilityPriority = NSToolbarItemVisibilityPriorityHigh;
        NSString *centeredItemLabel = UXLocalizedString(@"UXWindowToolbarCenteredItemLabel");
        _toolbarItemGroup.paletteLabel = centeredItemLabel;
        _toolbarItemGroup.label = centeredItemLabel;

        _centerToolbarItemGroupTitles = @[];
        _transitionControllerClassByToViewControllerClass = [NSMapTable weakToWeakObjectsMapTable];
    }

    return self;
}

- (void)dealloc {
    self.observedTabBarItems = nil;
    self.observedItemSegments = nil;
    self.observedNavigationItem = nil;
    self.observedViewController = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = self.segmentedControl;
    self.navigationItem.condensedTitleView = self.popUpButton;
    self.navigationItem.centerToolbarItemGroup = self.toolbarItemGroup;

    if (_needsTransition) {
        [self.view setNeedsLayout:YES];
    }
}

- (void)viewDidLayout {
    [super viewDidLayout];
    [[NSRunLoop mainRunLoop] performSelector:@selector(_performTransitionIfNeeded)
                                      target:self
                                    argument:nil
                                       order:1999999
                                       modes:@[NSDefaultRunLoopMode]];
}

- (void)viewWillDisappear {
    [super viewWillDisappear];
    [[NSRunLoop mainRunLoop] cancelPerformSelector:@selector(_performTransitionIfNeeded) target:self argument:nil];
}

#pragma mark - View controllers

- (void)setViewControllers:(NSArray *)viewControllers {
    if (![_viewControllers isEqualToArray:viewControllers]) {
        for (UXViewController *viewController in _viewControllers) {
            if (![viewControllers containsObject:viewController]) {
                [viewController willMoveToParentViewController:nil];
                [viewController removeFromParentViewController];
            }
        }

        _viewControllers = viewControllers.copy;

        for (UXViewController *viewController in viewControllers) {
            if (viewController.parentViewController != self) {
                [self addChildViewController:viewController];
                [viewController didMoveToParentViewController:self];
            }
        }

        [self _updateControls];
    }
}

- (UXViewController *)selectedViewController {
    return _selectedViewController;
}

- (void)setSelectedViewController:(UXViewController *)selectedViewController {
    NSArray *representedSegments = self.representedSegments;
    UXTabBarItemSegment *segment = selectedViewController.tabBarItem.representedSegments.firstObject;
    self.selectedIndex = [representedSegments indexOfObject:segment];
}

- (NSUInteger)selectedIndex {
    return [self.representedSegments indexOfObject:_selectedItemSegment];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex allowsCurrentTabReselectionCallback:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex allowsCurrentTabReselectionCallback:(BOOL)allowsCurrentTabReselectionCallback {
    if (self.selectedIndex == selectedIndex) {
        if (allowsCurrentTabReselectionCallback) {
            [self.selectedViewController performActionForSelectingCurrentTabBarItemSegment];
        }
    } else {
        [self _setSelectedIndex:selectedIndex];
        [self _setNeedsTransition];
    }
}

- (void)_setSelectedIndex:(NSUInteger)selectedIndex {
    NSArray *representedSegments = self.representedSegments;

    if (selectedIndex < representedSegments.count) {
        UXTabBarItemSegment *segment = representedSegments[selectedIndex];
        UXViewController *viewController = [self.representedSegmentsToViewControllers objectForKey:segment];
        _selectedViewController = viewController;
        _selectedItemSegment = segment;
        [self _notifyDelegateWithIndexSelection:selectedIndex];
    }
}

- (void)setSelectedItemSegment:(UXTabBarItemSegment *)selectedItemSegment {
    NSUInteger index = [self.representedSegments indexOfObject:selectedItemSegment];

    if (index == NSNotFound) {
        NSLog(@"%@: only a segment in -representedSegments may be set via -%@.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    } else {
        _selectedItemSegment = selectedItemSegment;
        [self _setSelectedIndex:index];
        [self _updateControlsSelection];
    }
}

- (UXViewController *)_targetViewController {
    if (_transientViewController) {
        return _transientViewController;
    }

    return _selectedViewController;
}

- (void)setTransientViewController:(UXViewController *)transientViewController {
    [self setTransientViewController:transientViewController animated:NO];
}

- (void)setTransientViewController:(UXViewController *)transientViewController animated:(BOOL)animated {
    if (_transientViewController != transientViewController) {
        if (_transientViewController) {
            [_transientViewController.viewIfLoaded removeFromSuperview];
            [_transientViewController willMoveToParentViewController:nil];
            [_transientViewController removeFromParentViewController];
        }

        _transientViewController = transientViewController;

        if (_transientViewController) {
            [self addChildViewController:_transientViewController];
            [_transientViewController didMoveToParentViewController:self];
        }

        [self _setNeedsTransition];
    }
}

- (void)setTabBarHidden:(BOOL)tabBarHidden {
    if (_tabBarHidden != tabBarHidden) {
        _tabBarHidden = tabBarHidden;
    }

    [self _updateControlsSelection];
}

- (BOOL)tabBarHidden {
    return _tabBarHidden;
}

#pragma mark - Controls

- (void)_updateControls {
    NSMutableArray *tabBarItems = [NSMutableArray array];
    NSMutableArray *segments = [NSMutableArray array];
    NSMapTable *segmentsToViewControllers = [NSMapTable weakToWeakObjectsMapTable];

    for (UXViewController *viewController in self.viewControllers) {
        UXTabBarItem *tabBarItem = viewController.tabBarItem;
        [tabBarItems addObject:tabBarItem];

        for (UXTabBarItemSegment *segment in tabBarItem.representedSegments) {
            [segments addObject:segment];
            [segmentsToViewControllers setObject:viewController forKey:segment];
        }
    }

    NSMutableArray<NSToolbarItem *> *toolbarSubitems = [[NSMutableArray alloc] initWithCapacity:segments.count];
    for (UXTabBarItemSegment *segment in segments) {
        NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:[NSUUID UUID].UUIDString];
        NSString *title = segment.title ?: @"";
        toolbarItem.label = title;
        toolbarItem.title = title;
        toolbarItem.autovalidates = NO;
        [toolbarSubitems addObject:toolbarItem];
    }

    if (self.toolbarItemGroup.selectedIndex >= (NSInteger)toolbarSubitems.count) {
        self.toolbarItemGroup.selectedIndex = 0;
    }

    self.toolbarItemGroup.subitems = toolbarSubitems;
    self.segmentedControl.segmentCount = segments.count;
    [self.popUpButton removeAllItems];

    [segments enumerateObjectsUsingBlock:^(UXTabBarItemSegment *segment, NSUInteger index, BOOL *stop) {
        [self.segmentedControl setLabel:segment.title forSegment:index];
        [self.popUpButton.menu addItemWithTitle:(segment.title ?: @"") action:nil keyEquivalent:@""];
    }];

    self.observedTabBarItems = [NSSet setWithArray:tabBarItems];
    self.observedItemSegments = [NSSet setWithArray:segments];
    self.representedSegments = segments.copy;
    self.representedSegmentsToViewControllers = segmentsToViewControllers;

    if ([segments containsObject:_selectedItemSegment]) {
        self.selectedIndex = [self.representedSegments indexOfObject:_selectedItemSegment];
    } else {
        self.selectedIndex = 0;
    }

    [self _updateControlsProperties];
    [self _recalculateSegmentedControlWidth];
}

- (void)_updateControlsProperties {
    [self.representedSegments enumerateObjectsUsingBlock:^(UXTabBarItemSegment *segment, NSUInteger index, BOOL *stop) {
        BOOL enabled = segment.isEnabled;
        [self.segmentedControl setEnabled:enabled forSegment:index];
        [self.popUpButton itemAtIndex:index].enabled = enabled;
        [self.toolbarItemGroup.subitems objectAtIndexedSubscript:index].enabled = enabled;
    }];
}

- (void)_updateControlsSelection {
    NSInteger index = _transientViewController ? -1 : self.selectedIndex;
    BOOL enabled = _transientViewController == nil;
    self.segmentedControl.enabled = enabled;
    self.segmentedControl.selectedSegment = index;
    self.popUpButton.enabled = enabled;
    [self.popUpButton selectItemAtIndex:index];
    self.toolbarItemGroup.enabled = enabled;
    self.toolbarItemGroup.selectedIndex = index;
    self.toolbarItemGroup.hidden = self.tabBarHidden;
}

- (void)_recalculateSegmentedControlWidth {
    NSDictionary<NSAttributedStringKey, id> *attributes = @{ NSFontAttributeName: self.segmentedControl.font };
    __block CGFloat maxWidth = 0.0;

    [self.viewControllers enumerateObjectsUsingBlock:^(UXViewController *viewController, NSUInteger index, BOOL *stop) {
        for (NSString *possibleTitle in viewController.tabBarItem.possibleTitles) {
            CGFloat width = [possibleTitle sizeWithAttributes:attributes].width;

            if (maxWidth < width) {
                maxWidth = width;
            }
        }
    }];

    for (UXTabBarItemSegment *segment in self.representedSegments) {
        CGFloat width = [segment.title sizeWithAttributes:attributes].width;

        if (maxWidth < width) {
            maxWidth = width;
        }
    }

    BOOL useFixedWidth = maxWidth < 80.0 || self.segmentedControl.segmentCount < 5;
    maxWidth = useFixedWidth ? maxWidth + 29.0 : 0.0;

    for (NSInteger i = 0; i < self.segmentedControl.segmentCount; i++) {
        [self.segmentedControl setWidth:maxWidth forSegment:i];
    }
}

- (void)_notifyDelegateWithIndexSelection:(NSUInteger)indexSelection {
    id<UXTabBarControllerDelegate> delegate = self.delegate;

    if (delegate) {
        [delegate tabBarController:self didSelectViewController:self.viewControllers[indexSelection]];
    }
}

#pragma mark - Control actions

- (void)segmentChanged:(id)sender {
    if (self.segmentedControl.selectedSegment >= 0) {
        [self setSelectedIndex:self.segmentedControl.selectedSegment allowsCurrentTabReselectionCallback:YES];
    }
}

- (void)popUpChanged:(id)sender {
    if (self.popUpButton.indexOfSelectedItem >= 0) {
        self.selectedIndex = self.popUpButton.indexOfSelectedItem;
    }
}

- (void)toolbarItemGroupSelectionDidChange:(id)sender {
    NSAssert(UXNavigationController.useIndividualNSToolbarItems, @"UXNavigationController.useIndividualNSToolbarItems");
    NSInteger selectedIndex = self.toolbarItemGroup.selectedIndex;

    if (selectedIndex >= 0) {
        [self setSelectedIndex:selectedIndex allowsCurrentTabReselectionCallback:YES];
    }
}

#pragma mark - Transition

- (void)_setNeedsTransition {
    _needsTransition = YES;

    if (self.isViewLoaded) {
        [self.view setNeedsLayout:YES];
    }
}

- (BOOL)_canPerformTransition {
    if (self.viewControllerTransitionInProgress) {
        return NO;
    }

    return !self.segmentTransitionInProgress;
}

- (void)_performTransitionIfNeeded {
    if (_needsTransition && [self _canPerformTransition]) {
        _needsTransition = NO;
        [self _transitionToTargetViewControllerWithCompletion:^{
        }];
    }
}

- (void)_transitionToTargetViewControllerWithCompletion:(UXCompletionHandler)completion {
    [self _updateControlsSelection];
    [self _transitionToViewController:self._targetViewController animated:NO completion:completion];
}

- (void)_transitionToViewController:(UXViewController *)viewController animated:(BOOL)animated completion:(UXCompletionHandler)completion {
    UXCompletionHandler innerCompletion = [^{
        [self contentRepresentingViewControllerDidChange];

        if (completion) {
            completion();
        }
    } copy];

    if (viewController) {
        if (_installedViewController == viewController) {
            self.segmentTransitionInProgress = YES;
            [_installedViewController prepareForTransitionToSelectedTabBarItemSegmentWithCompletion:^{
                self.segmentTransitionInProgress = NO;
                innerCompletion();
            }];
        } else {
            _transitionCtx = [self _contextForTransitionOperation:1 fromViewController:_installedViewController toViewController:viewController transition:(animated ? 103 : 102)];
            _installedViewController = viewController;
            [self _invalidateIntrinsicLayoutInsetsForViewController:viewController];
            [self _beginTransitionWithContext:_transitionCtx operation:1 completion:innerCompletion];
        }
    } else if (_installedViewController) {
        [_installedViewController willMoveToParentViewController:nil];
        [_installedViewController.view removeFromSuperview];
        [_installedViewController removeFromParentViewController];
        _installedViewController = nil;
        [self.view.window recalculateKeyViewLoop];
        innerCompletion();
    }
}

- (id)_contextForTransitionOperation:(NSInteger)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController transition:(NSUInteger)transition {
    if (fromViewController && toViewController) {
        if (fromViewController.view == toViewController.view) {
            transition = 102;
        }
    }

    Class transitionControllerClass = nil;

    if (fromViewController && self.view.window) {
        transitionControllerClass = [self.transitionControllerClassByToViewControllerClass objectForKey:[toViewController class]];
    }

    if (!transitionControllerClass) {
        transitionControllerClass = _transitionControllerClassForTransition(transition);
    }

    _transitionController = [transitionControllerClass new];
    _transitionController.operation = operation;
    [self loadViewIfNeeded];

    _UXViewControllerOneToOneTransitionContext *transitionContext = [_UXViewControllerOneToOneTransitionContext new];
    transitionContext.containerView = self.uxView;
    transitionContext.animated = transition != 102;
    transitionContext.animator = _transitionController;
    transitionContext.interactor = nil;
    transitionContext.initiallyInteractive = NO;
    transitionContext.fromViewController = fromViewController;
    transitionContext.toViewController = toViewController;
    transitionContext.fromStartFrame = fromViewController.view.frame;
    transitionContext.fromEndFrame = CGRectNull;
    transitionContext.toStartFrame = CGRectNull;
    transitionContext.toEndFrame = self.view.bounds;
    return transitionContext;
}

- (void)_beginTransitionWithContext:(_UXViewControllerOneToOneTransitionContext *)context operation:(NSInteger)operation completion:(UXCompletionHandler)completion {
    UXViewController *fromViewController = (UXViewController *)[context viewControllerForKey:UXTransitionContextFromViewControllerKey];
    UXViewController *toViewController = (UXViewController *)[context viewControllerForKey:UXTransitionContextToViewControllerKey];
    fromViewController.uxView.userInteractionEnabled = NO;
    toViewController.uxView.frame = [context finalFrameForViewController:toViewController];
    context.duration = [context.animator transitionDuration:context];
    BOOL animated = context.duration > 0.0;

    @weakify(self);
    context.completionHandler = ^(_UXViewControllerTransitionContext *transitionContext, BOOL isCompletion) {
        @strongify(self);
        id<UXViewControllerAnimatedTransitioning> animator = transitionContext.animator;

        if ([animator respondsToSelector:@selector(animationEnded:)]) {
            [animator animationEnded:isCompletion];
        }

        fromViewController.uxView.userInteractionEnabled = YES;
        toViewController.uxView.userInteractionEnabled = YES;
        [fromViewController.view removeFromSuperview];
        [transitionContext._transitionCoordinator animateAlongsideTransition:nil completion:^(id<UXViewControllerTransitionCoordinatorContext> coordinatorContext) {
            @strongify(self);
            self.segmentTransitionInProgress = NO;
            self.viewControllerTransitionInProgress = NO;
        }];
        self->_transitionController = nil;
        self->_transitionCtx = nil;

        if (completion) {
            completion();
        }
    };

    [self _setObservedNavigationItem:nil updateBarButtonItems:NO];
    self.observedViewController = nil;
    self.viewControllerTransitionInProgress = YES;

    [self _prepareViewController:fromViewController forTransitionInContext:context completion:^{
        @strongify(self);

        if (toViewController._requiresWindowForTransitionPreparation) {
            toViewController.view.alphaValue = 0.0;
            UXView *containerView = context.containerView;

            if (operation == 1) {
                [containerView addSubview:toViewController.view];
            } else {
                [containerView addSubview:toViewController.view positioned:NSWindowBelow relativeTo:fromViewController.view];
            }
        }

        [self _prepareViewController:toViewController forTransitionInContext:context completion:^{
            toViewController.view.alphaValue = 1.0;
            [context.animator animateTransition:context];
            [context __runAlongsideAnimations];
            context.transitionIsInFlight = YES;
        }];
    }];
}

- (void)_prepareViewController:(UXViewController *)viewController forTransitionInContext:(id)context completion:(UXCompletionHandler)completion {
    if (viewController) {
        [viewController prepareForTransitionWithContext:context completion:completion];
    } else if (completion) {
        completion();
    }
}

- (void)_prepareForAnimationInContext:(id)context completion:(UXCompletionHandler)completion {
    UXViewController *targetViewController = self._targetViewController;

    if (targetViewController) {
        if (_needsTransition && [self _canPerformTransition]) {
            _needsTransition = NO;
            [self _transitionToTargetViewControllerWithCompletion:^{
                [targetViewController _prepareForAnimationInContext:context completion:completion];
            }];
        } else {
            [targetViewController _prepareForAnimationInContext:context completion:completion];
        }
    } else if (completion) {
        completion();
    }
}

- (BOOL)_requiresWindowForTransitionPreparation {
    return [self._targetViewController _requiresWindowForTransitionPreparation];
}

#pragma mark - Transition controllers

- (void)registerTransitionControllerClass:(Class)transitionControllerClass forViewControllerClass:(Class)viewControllerClass {
    if (transitionControllerClass && viewControllerClass) {
        [self.transitionControllerClassByToViewControllerClass setObject:transitionControllerClass forKey:viewControllerClass];
    }
}

- (void)unregisterTransitionControllerForTransitionToViewControllerClass:(Class)viewControllerClass {
    if (viewControllerClass && [self.transitionControllerClassByToViewControllerClass objectForKey:viewControllerClass]) {
        [self.transitionControllerClassByToViewControllerClass removeObjectForKey:viewControllerClass];
    }
}

#pragma mark - Observation

- (void)setObservedItemSegments:(NSSet *)observedItemSegments {
    if (![_observedItemSegments isEqualToSet:observedItemSegments]) {
        for (UXTabBarItemSegment *segment in _observedItemSegments) {
            [segment removeObserver:self forKeyPath:@"enabled" context:kItemSegmentEnabledObservationContext];
            [segment removeObserver:self forKeyPath:@"title" context:kTabBarItemObservationContext];
        }

        _observedItemSegments = observedItemSegments;

        for (UXTabBarItemSegment *segment in _observedItemSegments) {
            [segment addObserver:self forKeyPath:@"enabled" options:0 context:kItemSegmentEnabledObservationContext];
            [segment addObserver:self forKeyPath:@"title" options:0 context:kTabBarItemObservationContext];
        }
    }
}

- (void)setObservedTabBarItems:(NSSet *)observedTabBarItems {
    if (![_observedTabBarItems isEqualToSet:observedTabBarItems]) {
        for (UXTabBarItem *tabBarItem in _observedTabBarItems) {
            [tabBarItem removeObserver:self forKeyPath:@"representedSegments" context:kTabBarItemObservationContext];
        }

        _observedTabBarItems = observedTabBarItems;

        for (UXTabBarItem *tabBarItem in _observedTabBarItems) {
            [tabBarItem addObserver:self forKeyPath:@"representedSegments" options:0 context:kTabBarItemObservationContext];
        }
    }
}

- (void)setObservedViewController:(UXViewController *)observedViewController {
    if (observedViewController != _observedViewController) {
        for (NSString *keyPath in [UXViewController toolbarPropertyNames]) {
            [_observedViewController removeObserver:self forKeyPath:keyPath context:kToolbarPropertiesObservationContext];
        }

        _observedViewController = observedViewController;

        for (NSString *keyPath in [UXViewController toolbarPropertyNames]) {
            [_observedViewController addObserver:self forKeyPath:keyPath options:0 context:kToolbarPropertiesObservationContext];
        }

        [self _updateToolbarProperties];
    }
}

- (void)setObservedNavigationItem:(UXNavigationItem *)observedNavigationItem {
    [self _setObservedNavigationItem:observedNavigationItem updateBarButtonItems:NO];
}

- (void)_setObservedNavigationItem:(UXNavigationItem *)observedNavigationItem updateBarButtonItems:(BOOL)updateBarButtonItems {
    if (observedNavigationItem != _observedNavigationItem) {
        [_observedNavigationItem removeObserver:self forKeyPath:@"leftBarButtonItems" context:kLeftBarButtonItemsObservationContext];
        [_observedNavigationItem removeObserver:self forKeyPath:@"rightBarButtonItems" context:kRightBarButtonItemsObservationContext];
        [_observedNavigationItem removeObserver:self forKeyPath:@"progressButtonItem" context:kProgressBarButtonItemObservationContext];
        [_observedNavigationItem removeObserver:self forKeyPath:@"title" context:kNavigationItemTitlesObservationContext];
        [_observedNavigationItem removeObserver:self forKeyPath:@"subtitle" context:kNavigationItemTitlesObservationContext];
        [_observedNavigationItem removeObserver:self forKeyPath:@"useWindowForTitleOutput" context:kNavigationItemTitlesObservationContext];

        _observedNavigationItem = observedNavigationItem;

        [_observedNavigationItem addObserver:self forKeyPath:@"leftBarButtonItems" options:0 context:kLeftBarButtonItemsObservationContext];
        [_observedNavigationItem addObserver:self forKeyPath:@"rightBarButtonItems" options:0 context:kRightBarButtonItemsObservationContext];
        [_observedNavigationItem addObserver:self forKeyPath:@"progressButtonItem" options:0 context:kProgressBarButtonItemObservationContext];
        [_observedNavigationItem addObserver:self forKeyPath:@"title" options:0 context:kNavigationItemTitlesObservationContext];
        [_observedNavigationItem addObserver:self forKeyPath:@"subtitle" options:0 context:kNavigationItemTitlesObservationContext];
        [_observedNavigationItem addObserver:self forKeyPath:@"useWindowForTitleOutput" options:0 context:kNavigationItemTitlesObservationContext];

        if (updateBarButtonItems) {
            [self _updateLeftBarButtonItems];
            [self _updateRightBarButtonItems];
            [self _updateProgressBarButtonItem];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == kTabBarItemObservationContext) {
        [self _updateControls];
    } else if (context == kItemSegmentEnabledObservationContext) {
        [self _updateControlsProperties];
    } else if (context == kLeftBarButtonItemsObservationContext) {
        [self _updateLeftBarButtonItems];
    } else if (context == kRightBarButtonItemsObservationContext) {
        [self _updateRightBarButtonItems];
    } else if (context == kProgressBarButtonItemObservationContext) {
        [self _updateProgressBarButtonItem];
    } else if (context == kNavigationItemTitlesObservationContext) {
        [self _updateTitleProperties];
    } else if (context == kToolbarPropertiesObservationContext) {
        [self _updateToolbarProperties];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)_updateTitleProperties {
    UXNavigationItem *navigationItem = self.navigationItem;
    UXNavigationItem *observedNavigationItem = self.observedNavigationItem;
    navigationItem.title = observedNavigationItem.title;
    navigationItem.subtitle = observedNavigationItem.subtitle;
    navigationItem.useWindowForTitleOutput = observedNavigationItem.useWindowForTitleOutput;
}

- (void)_updateToolbarProperties {
    UXViewController *observedViewController = self.observedViewController;

    if (observedViewController) {
        [self performToolbarsChanges:^{
            [observedViewController performToolbarsChanges:^{
            }];
        }];
    }
}

- (void)_updateLeftBarButtonItems {
    self.navigationItem.leftBarButtonItems = self.observedNavigationItem.leftBarButtonItems;
}

- (void)_updateRightBarButtonItems {
    self.navigationItem.rightBarButtonItems = self.observedNavigationItem.rightBarButtonItems;
}

- (void)_updateProgressBarButtonItem {
    self.navigationItem.progressButtonItem = self.observedNavigationItem.progressButtonItem;
}

#pragma mark - Navigation destination

- (UXViewController *)_childViewControllerAbleToNavigateToDestination:(id<UXNavigationDestination>)destination {
    for (UXViewController *viewController in self.viewControllers) {
        if ([viewController canProvideViewControllersForNavigationDestination:destination]) {
            return viewController;
        }
    }

    return nil;
}

- (BOOL)canProvideViewControllersForNavigationDestination:(id<UXNavigationDestination>)destination {
    return [self _childViewControllerAbleToNavigateToDestination:destination] != nil;
}

- (void)requestViewControllersForNavigationDestination:(id<UXNavigationDestination>)destination completion:(void (^)(BOOL, NSArray<UXViewController *> *))completion {
    _needsTransition = NO;
    UXViewController *childViewController = [self _childViewControllerAbleToNavigateToDestination:destination];
    NSUInteger (^indexBlock)(UXViewController *) = ^NSUInteger(UXViewController *viewController) {
        return [self _firstItemSegmentIndexForViewController:viewController];
    };

    if (_transientViewController) {
        [self _setSelectedIndex:indexBlock(childViewController)];
        [self _updateControlsSelection];
        [self _transitionToViewController:_transientViewController animated:NO completion:^{
            if (completion) {
                completion(YES, @[]);
            }
        }];
    } else {
        [childViewController requestViewControllersForNavigationDestination:destination completion:^(BOOL finished, NSArray<UXViewController *> *viewControllers) {
            [self _setSelectedIndex:indexBlock(childViewController)];

            if (completion) {
                completion(finished, viewControllers);
            }
        }];
    }
}

- (id<UXNavigationDestination>)navigationDestination {
    return self.selectedViewController.navigationDestination;
}

- (void)updateForEqualNavigationDestination:(id<UXNavigationDestination>)destination {
    [self.selectedViewController updateForEqualNavigationDestination:destination];
}

- (NSUInteger)_firstItemSegmentIndexForViewController:(UXViewController *)viewController {
    return [self.representedSegments indexOfObjectPassingTest:^BOOL(UXTabBarItemSegment *segment, NSUInteger index, BOOL *stop) {
        return [self.representedSegmentsToViewControllers objectForKey:segment] == viewController;
    }];
}

#pragma mark - Layout guides

- (void)invalidateIntrinsicLayoutInsets {
    [self _invalidateIntrinsicLayoutInsetsForViewController:self._targetViewController];
}

- (void)_invalidateIntrinsicLayoutInsetsForViewController:(UXViewController *)viewController {
    if (viewController.edgesForExtendedLayout & UXRectEdgeTop) {
        viewController.topLayoutGuide.length = self.intrinsicLayoutInsets.top + self.topLayoutGuide.length;
    }

    if (viewController.edgesForExtendedLayout & UXRectEdgeBottom) {
        viewController.bottomLayoutGuide.length = self.intrinsicLayoutInsets.bottom + self.bottomLayoutGuide.length;
    }
}

#pragma mark - Responder / content

- (NSResponder *)preferredFirstResponder {
    NSResponder *preferredFirstResponder = [self._targetViewController preferredFirstResponder];

    if (!preferredFirstResponder) {
        preferredFirstResponder = [super preferredFirstResponder];
    }

    return preferredFirstResponder;
}

- (NSViewController *)contentRepresentingViewController {
    return [self._targetViewController contentRepresentingViewController];
}

- (id<UXViewControllerTransitionCoordinator>)transitionCoordinator {
    id<UXViewControllerTransitionCoordinator> transitionCoordinator = _transitionCtx._transitionCoordinator;

    if (!transitionCoordinator) {
        transitionCoordinator = [super transitionCoordinator];
    }

    return transitionCoordinator;
}

#pragma mark - Menu / key

- (void)keyDown:(NSEvent *)event {
    NSInteger characterValue = event.characters.integerValue;
    NSUInteger count = self.viewControllers.count;

    if ((event.modifierFlags & NSEventModifierFlagCommand) && event.characters.length == 1 && characterValue >= 1 && characterValue <= (NSInteger)count) {
        self.selectedIndex = characterValue - 1;
    } else {
        [super keyDown:event];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    id representedObject = menuItem.representedObject;

    if ([representedObject isKindOfClass:[UXTabBarItemSegment class]] && representedObject) {
        return [representedObject isEnabled];
    }

    return YES;
}

- (void)selectSegmentFromMenu:(id)sender {
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        UXTabBarItemSegment *segment = [sender representedObject];

        if (self.representedSegments && segment) {
            NSUInteger index = [self.representedSegments indexOfObject:segment];

            if (index != NSNotFound) {
                [self setSelectedIndex:index allowsCurrentTabReselectionCallback:NO];
                return;
            }
        }

        NSLog(@"Failed to navigate to menu item %@ with represented object %@.", sender, segment);
    }
}

- (void)populateShortcutMenuItemsStartingAtIndex:(NSUInteger)index ofMenu:(NSMenu *)menu useSeparators:(BOOL)useSeparators {
    [self _removePopulatedMenuItems];
    NSMutableArray<NSMenuItem *> *menuItems = [NSMutableArray array];

    if (index && useSeparators) {
        [menuItems addObject:[NSMenuItem separatorItem]];
    }

    [self.representedSegments enumerateObjectsUsingBlock:^(UXTabBarItemSegment *segment, NSUInteger segmentIndex, BOOL *stop) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:(segment.title ?: @"") action:@selector(selectSegmentFromMenu:) keyEquivalent:@""];
        menuItem.target = self;
        menuItem.representedObject = segment;
        [menuItems addObject:menuItem];
    }];

    if (useSeparators && (self.representedSegments.count + index != menu.itemArray.count)) {
        [menuItems addObject:[NSMenuItem separatorItem]];
    }

    [menuItems enumerateObjectsUsingBlock:^(NSMenuItem *menuItem, NSUInteger menuItemIndex, BOOL *stop) {
        [menu insertItem:menuItem atIndex:index + menuItemIndex];
    }];

    self.shortcutMenuItems = menuItems;
}

- (void)_removePopulatedMenuItems {
    for (NSMenuItem *menuItem in self.shortcutMenuItems) {
        [menuItem.menu removeItem:menuItem];
    }
}

@end
