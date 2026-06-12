#import "_UXAccessoryBarContainer.h"
#import "_UXContainerView.h"
#import "_UXNavigationRequest.h"
#import "_UXViewControllerOneToOneTransitionContext.h"
#import "_UXViewControllerTransitionCoordinator.h"
#import "_UXWindowState.h"
#import "NSResponder+UXKit.h"
#import "NSView+UXKit.h"
#import "NSWindow+UXKit.h"
#import "UXBackButton.h"
#import "UXBar+Internal.h"
#import "UXBarButtonItem+Internal.h"
#import "UXIdentityTransitionController.h"
#import "UXKitPrivateUtilites.h"
#import "UXNavigationBar+Internal.h"
#import "UXNavigationController+Internal.h"
#import "UXNavigationItem+Internal.h"
#import "UXParallaxTransitionController.h"
#import "UXSlideTransitionController.h"
#import "UXSubtoolbar.h"
#import "UXToolbar+Internal.h"
#import "UXTransitionController.h"
#import "UXView+Internal.h"
#import "UXViewController+Internal.h"
#import "UXViewControllerTransitionCoordinator.h"
#import "UXViewControllerTransitioning.h"
#import "UXWindowController+Internal.h"
#import "UXZoomingCrossfadeTransitionController.h"

void *UXToolbarItemsObservationContext = &UXToolbarItemsObservationContext;
void *UXSubtoolbarItemsObservationContext = &UXSubtoolbarItemsObservationContext;
void *UXToolbarPositionsObservationContext = &UXToolbarPositionsObservationContext;
void *UXToolbarAppearanceObservationContext = &UXToolbarAppearanceObservationContext;
void *UXAccessoryViewControllerObservationContext = &UXAccessoryViewControllerObservationContext;
void *UXScopeBarItemsObservationContext = &UXScopeBarItemsObservationContext;


@implementation UXNavigationController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _addedConstraints = [NSMutableArray array];
        _navigationRequests = [NSMutableArray array];
        _targetViewControllers = [NSMutableArray array];
        _currentViewControllers = [NSMutableArray array];
        __toolbarPosition = UXBarPositionTop;
        __subtoolbarPosition = UXBarPositionTop;
        _subtoolbarHidden = YES;
        _toolbarHidden = YES;
        _scopeBarHidden = YES;
        __defaultPushTransition = 100;
        __defaultPopTransition = 101;
        _interactivePopGestureRecognizer = [NSGestureRecognizer new];
        _backButtonMenuEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"UXBackButtonMenuEnabled"];
    }

    return self;
}

- (void)setToolbarHidden:(BOOL)toolbarHidden {
    [self setToolbarHidden:toolbarHidden animated:NO];
}


- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    [self setNavigationBarHidden:navigationBarHidden animated:NO];
}


- (UXNavigationBar *)navigationBar {
    if (_navigationBar == nil) {
        Class navigationBarClass = self.navigationBarClass;

        if (navigationBarClass == nil) {
            navigationBarClass = [UXNavigationBar class];
        }

        _navigationBar = [navigationBarClass new];
        _navigationBar.interitemSpacing = 8.0;
        _navigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    }

    return _navigationBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.containerView = [[_UXContainerView alloc] initWithFrame:self.view.bounds];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.containerView];

    if (!self.isNavigationBarDetached) {
        [self.view addSubview:self.navigationBar];
    }

    UXToolbar *toolbar = self.toolbar;
    UXToolbar *subtoolbar = self.subtoolbar;
    UXToolbar *scopeBar = self.scopeBar;

    if (self.areToolbarsDetached) {
        NSView *detachedBarsContainer = self.detachedBarsContainer;
        [detachedBarsContainer addSubview:toolbar];
        [detachedBarsContainer addSubview:subtoolbar positioned:NSWindowBelow relativeTo:toolbar];
        [detachedBarsContainer addSubview:scopeBar positioned:NSWindowBelow relativeTo:toolbar];

        self.detachedSubtoolbarTopConstraint = [subtoolbar.topAnchor constraintEqualToAnchor:detachedBarsContainer.topAnchor];
        self.detachedScopeBarTopConstraint = [scopeBar.topAnchor constraintEqualToAnchor:detachedBarsContainer.topAnchor];
        self.detachedBarsContainerHeightConstraint = [detachedBarsContainer.heightAnchor constraintEqualToConstant:0.0];

        [NSLayoutConstraint activateConstraints:@[
            [toolbar.topAnchor constraintEqualToAnchor:detachedBarsContainer.topAnchor],
            [toolbar.leadingAnchor constraintEqualToAnchor:detachedBarsContainer.leadingAnchor],
            [toolbar.trailingAnchor constraintEqualToAnchor:detachedBarsContainer.trailingAnchor],
            self.detachedSubtoolbarTopConstraint,
            [subtoolbar.leadingAnchor constraintEqualToAnchor:detachedBarsContainer.leadingAnchor],
            [subtoolbar.trailingAnchor constraintEqualToAnchor:detachedBarsContainer.trailingAnchor],
            self.detachedScopeBarTopConstraint,
            [scopeBar.leadingAnchor constraintEqualToAnchor:detachedBarsContainer.leadingAnchor],
            [scopeBar.trailingAnchor constraintEqualToAnchor:detachedBarsContainer.trailingAnchor],
            self.detachedBarsContainerHeightConstraint,
        ]];
    } else {
        [self.view addSubview:toolbar];
        [self.view addSubview:subtoolbar positioned:NSWindowBelow relativeTo:toolbar];
        [self.view addSubview:scopeBar positioned:NSWindowBelow relativeTo:toolbar];
        _toolbarExtendedBackgroundView = [[UXView alloc] init];
        _toolbarExtendedBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        _toolbarExtendedBackgroundView.hidden = YES;
        _toolbarExtendedBackgroundView.wantsLayer = YES;
        [_toolbarExtendedBackgroundView setBackgroundColor:NSColor.controlBackgroundColor];
        [self.view addSubview:_toolbarExtendedBackgroundView];
    }
}

- (UXToolbar *)toolbar {
    if (_toolbar == nil) {
        Class toolbarClass = self.toolbarClass;

        if (toolbarClass == nil) {
            toolbarClass = [UXToolbar class];
        }

        _toolbar = [toolbarClass new];
        _toolbar.delegate = self;
        _toolbar.hidden = _toolbarHidden;
        _toolbar.accessibilityIdentifier = @"UXNavigationControllerToolbar";
        _toolbar.accessibilityRoleDescription = UXLocalizedString(@"UXNavigationControllerToolbarAXRoleDescription");
        _toolbar.accessibilityLabel = UXLocalizedString(@"UXNavigationControllerToolbarAXLabel");
    }

    return _toolbar;
}

- (UXToolbar *)subtoolbar {
    if (_subtoolbar == nil) {
        _subtoolbar = [[UXSubtoolbar alloc] initWithFrame:CGRectZero];
        _subtoolbar.delegate = self;
        _subtoolbar.hidden = _subtoolbarHidden;
        _subtoolbar.accessibilityIdentifier = @"UXNavigationControllerSubtoolbar";
        _subtoolbar.accessibilityRoleDescription = UXLocalizedString(@"UXNavigationControllerToolbarAXRoleDescription");
        _subtoolbar.accessibilityLabel = UXLocalizedString(@"UXNavigationControllerToolbarAXLabel");
        _subtoolbar.translatesAutoresizingMaskIntoConstraints = NO;
    }

    return _subtoolbar;
}


- (UXViewController *)currentTopViewController {
    return _currentViewControllers.lastObject;
}


- (UXToolbar *)accessoryBar {
    if (_accessoryBar == nil) {
        _accessoryBar = [UXToolbar new];
        _accessoryBar.delegate = self;
        _accessoryBar.blurEnabled = NO;
        _accessoryBar.accessibilityIdentifier = @"UXNavigationControllerAccessoryBar";
        _accessoryBar.accessibilityRoleDescription = UXLocalizedString(@"UXNavigationControllerToolbarAXRoleDescription");
        _accessoryBar.accessibilityLabel = UXLocalizedString(@"UXNavigationControllerAuxiliaryAXLabel");
    }

    return _accessoryBar;
}

- (BOOL)isAccessoryBarHidden {
    BOOL isAccessoryBarHidden = NO;
    UXViewController *accessoryViewController = self.currentTopViewController.accessoryViewController;

    if (accessoryViewController) {
        isAccessoryBarHidden = NO;
    } else {
        isAccessoryBarHidden = self.currentTopViewController.accessoryBarItems.count == 0;
    }

    return isAccessoryBarHidden;
}

- (id)preferredFirstResponder {
    return self.currentTopViewController.preferredFirstResponder;
}

- (void)updateViewConstraints {
    [self.view removeConstraints:self.addedConstraints];
    [self.addedConstraints removeAllObjects];

    NSDictionary *views = @{
            @"topGuide": self.topLayoutGuide,
            @"navigationBar": self.navigationBar,
            @"containerView": _containerView,
            @"toolbar": self.toolbar,
            @"bottomGuide": self.bottomLayoutGuide,
    };

    self.topConstraint = [NSLayoutConstraint constraintWithItem:_containerView attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self.uxView attribute:(NSLayoutAttributeTop) multiplier:1.0 constant:0.0];
    [self.addedConstraints addObject:self.topConstraint];
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:_containerView attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:self.uxView attribute:(NSLayoutAttributeBottom) multiplier:1.0 constant:0.0];
    [self.addedConstraints addObject:self.bottomConstraint];

    if (self.isNavigationBarDetached) {
        self.navigationBarTopConstraint = nil;
        self.navigationBarConstraints = nil;
    } else {
        self.navigationBarTopConstraint = [_navigationBar.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor constant:self._navigationBarVerticalOffset];
        [self.addedConstraints addObject:self.navigationBarTopConstraint];
        NSArray *layoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[navigationBar]|" options:(NSLayoutFormatDirectionLeadingToTrailing) metrics:nil views:views];
        [self.addedConstraints addObjectsFromArray:layoutConstraints];
        self.navigationBarConstraints = [layoutConstraints arrayByAddingObject:self.navigationBarTopConstraint];
    }

    [self.addedConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[containerView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];

    if (!self.areToolbarsDetached) {
        self.toolbarVerticalConstraint = [self _verticalToolbarLayoutConstraint];
        [self.addedConstraints addObject:self.toolbarVerticalConstraint];
        self.toolbarLeadingConstraint = [_toolbar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:__leadingContentInset];
        [self.addedConstraints addObject:self.toolbarLeadingConstraint];
        [self.addedConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[toolbar]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
        self.scopeBarVerticalConstraint = [self.scopeBar.topAnchor constraintEqualToAnchor:self.toolbar.topAnchor constant:self._scopeBarVerticalOffset];
        [self.addedConstraints addObject:self.scopeBarVerticalConstraint];
        NSLayoutConstraint *layoutConstraint = nil;

        if (__fullScreenMode) {
            layoutConstraint = [self.toolbarExtendedBackgroundView.bottomAnchor constraintEqualToAnchor:self.toolbar.topAnchor];
        } else {
            layoutConstraint = [self.toolbarExtendedBackgroundView.heightAnchor constraintEqualToConstant:self.navigationBar.height];
        }

        [self.addedConstraints addObjectsFromArray:@[
             [self.toolbarExtendedBackgroundView.leftAnchor constraintEqualToAnchor:self.toolbar.leftAnchor],
             [self.toolbarExtendedBackgroundView.rightAnchor constraintEqualToAnchor:self.toolbar.rightAnchor],
             [self.toolbarExtendedBackgroundView.topAnchor constraintLessThanOrEqualToAnchor:_containerView.topAnchor],
             layoutConstraint,
             [self.toolbar.bottomAnchor constraintEqualToAnchor:self.subtoolbar.topAnchor],
             [self.toolbar.leftAnchor constraintEqualToAnchor:self.subtoolbar.leftAnchor],
             [self.toolbar.rightAnchor constraintEqualToAnchor:self.subtoolbar.rightAnchor],
             [self.toolbar.leftAnchor constraintEqualToAnchor:self.scopeBar.leftAnchor],
             [self.toolbar.rightAnchor constraintEqualToAnchor:self.scopeBar.rightAnchor],
        ]];
    }
    [self.view addConstraints:self.addedConstraints];
    [super updateViewConstraints];
}

- (void)viewWillLayout {
    [super viewWillLayout];

    if (self.isNavigationBarDetached) {
        BOOL inFullScreen = self.view.window.ux_inFullScreen;

        if (inFullScreen != self._isFullScreenMode) {
            self._fullScreenMode = inFullScreen;
            [self.view updateConstraintsForSubtreeIfNeeded];
        }
    } else if (self._isFullScreenMode) {
        self._fullScreenMode = NO;
        [self.view updateConstraintsForSubtreeIfNeeded];
    }

    if (self._toolbarNeedsVerticalOffsetUpdate && (!self.currentTransitionCoordinator || self.currentTransitionCoordinator.isInteractive)) {
        self.toolbarVerticalConstraint.constant = self._toolbarVerticalOffset;
    }
}

- (id<UXViewControllerTransitionCoordinator>)currentTransitionCoordinator {
    if (self.currentTransitionContext) {
        return [self.currentTransitionContext _transitionCoordinator];
    } else {
        return nil;
    }
}


- (void)viewDidLayout {
    [super viewDidLayout];

    if (!self.currentTransitionCoordinator && _navigationRequests.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _dequeueNavigationRequest];
        });
    }
}

- (void)viewWillAppear {
    [super viewWillAppear];

    if (_delegateFlags.willShowViewController) {
        [self.delegate navigationController:self willShowViewController:self.currentTopViewController];
    }
}

- (void)viewDidAppear {
    [super viewDidAppear];

    if (_delegateFlags.didShowViewController) {
        [self.delegate navigationController:self didShowViewController:self.currentTopViewController];
    }
}

- (void)setDelegate:(id<UXNavigationControllerDelegate>)delegate {
    if (__locked) {
        NSLog(@"Warning - Attempting to set the delegate of a UXNavigationController that is being managed by another controller (%@). This is not allowed.\n %@", NSStringFromClass(delegate.class), NSThread.callStackSymbols);
    } else {
        _delegate = delegate;
        _delegateFlags.willShowViewController = [delegate respondsToSelector:@selector(navigationController:willShowViewController:)];
        _delegateFlags.didShowViewController = [delegate respondsToSelector:@selector(navigationController:didShowViewController:)];
        _delegateFlags.interactionControllerForAnimationController = [delegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)];
        _delegateFlags.animationControllerForOperation = [delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)];
        _delegateFlags.shouldBeginInteractivePopFromViewControllerToViewController = [delegate respondsToSelector:@selector(navigationController:shouldBeginInteractivePopFromViewController:toViewController:)];
        _delegateFlags.shouldPopFromViewControllerToViewController = [delegate respondsToSelector:@selector(navigationController:shouldPopFromViewController:toViewController:)];
    }
}


- (instancetype)initWithRootViewController:(UXViewController *)rootViewController {
    NSParameterAssert([rootViewController isKindOfClass:[UXViewController class]]);

    if (self = [self initWithNibName:nil bundle:nil]) {
        [self pushViewController:rootViewController animated:NO];
    }

    return self;
}


NSArray * _toolbarItemsForViewController(UXViewController *viewController) {
    UXViewController *toolbarViewController = viewController.toolbarViewController;

    if (toolbarViewController) {
        UXBarButtonItem *toolbarItem = [[UXBarButtonItem alloc] initWithContentViewController:toolbarViewController];
        return @[toolbarItem];
    } else {
        if (viewController.toolbarItems) {
            return viewController.toolbarItems;
        } else {
            return @[];
        }
    }
}

NSArray * _subtoolbarItemsForViewController(UXViewController *viewController) {
    NSArray *subtoolbarItems = viewController.subtoolbarItems;

    if (!subtoolbarItems) {
        subtoolbarItems = @[];
    }

    return subtoolbarItems;
}

NSArray *_scopeBarItemsForViewController(UXViewController *viewController) {
    NSArray *scopeBarItems = viewController.scopeBarItems;
    if (!scopeBarItems) {
        scopeBarItems = @[];
    }
    return scopeBarItems;
}

NSArray * _accessoryBarItemsForViewController(UXViewController *viewController) {
    UXViewController *accessoryViewController = viewController.accessoryViewController;

    if (accessoryViewController) {
        return @[[[UXBarButtonItem alloc] initWithContentViewController:viewController.accessoryViewController]];
    } else {
        NSArray *accessoryBarItems = viewController.accessoryBarItems;

        if (!accessoryBarItems) {
            accessoryBarItems = @[];
        }

        return accessoryBarItems;
    }
}


- (void)setViewControllers:(NSArray<UXViewController *> *)viewControllers animated:(BOOL)animated {
    _UXNavigationRequest *request = [_UXNavigationRequest setRequestWithViewControllers:viewControllers animated:animated];

    [self _performOrEnqueueNavigationRequest:request];
}


Class _transitionControllerClassForTransition(NSUInteger transition) {
    if (transition > 101) {
        if (transition == 102) {
            return [UXIdentityTransitionController class];
        } else if (transition == 103) {
            return [UXZoomingCrossfadeTransitionController class];
        }
    } else if (transition - 1 < 2) {
        return [UXSlideTransitionController class];
    } else {
        if (transition - 100 >= 2) {
            return nil;
        }

        return [UXParallaxTransitionController class];
    }

    return nil;
}


- (id)contentRepresentingViewController {
    return self.topViewController.contentRepresentingViewController;
}

- (UXViewController *)topViewController {
    return _targetViewControllers.lastObject;
}


- (UXViewController *)visibleViewController {
    NSViewController *lastPresentedViewController = self.presentedViewControllers.lastObject;

    if ([lastPresentedViewController isKindOfClass:[UXViewController class]]) {
        return (UXViewController *)lastPresentedViewController;
    } else {
        return self.topViewController;
    }
}


- (NSGestureRecognizer *)interactivePopEventTracker {
    return self.interactivePopGestureRecognizer;
}


- (NSVisualEffectView *)subtoolbarVisualEffectsView {
    if (_subtoolbarVisualEffectsView == nil) {
        _subtoolbarVisualEffectsView = [[NSVisualEffectView alloc] initWithFrame:self.subtoolbar.bounds];
        _subtoolbarVisualEffectsView.blendingMode = NSVisualEffectBlendingModeWithinWindow;
        _subtoolbarVisualEffectsView.material = NSVisualEffectMaterialContentBackground;
        _subtoolbarVisualEffectsView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    }

    return _subtoolbarVisualEffectsView;
}

- (NSVisualEffectView *)toolbarVisualEffectsView {
    if (_toolbarVisualEffectsView == nil) {
        _toolbarVisualEffectsView = [[NSVisualEffectView alloc] initWithFrame:self.toolbar.bounds];
        _toolbarVisualEffectsView.blendingMode = NSVisualEffectBlendingModeWithinWindow;
        _toolbarVisualEffectsView.material = NSVisualEffectMaterialContentBackground;
        _toolbarVisualEffectsView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    }

    return _toolbarVisualEffectsView;
}

- (UXToolbar *)scopeBar {
    if (!_scopeBar) {
        _scopeBar = [[UXSubtoolbar alloc] initWithFrame:CGRectZero];
        _scopeBar.delegate = self;
        _scopeBar.hidden = _scopeBarHidden;
        _scopeBar.accessibilityIdentifier = @"UXNavigationControllerScopeBar";
        _scopeBar.accessibilityRoleDescription = UXLocalizedString(@"UXNavigationControllerToolbarAXRoleDescription");
        _scopeBar.accessibilityLabel = UXLocalizedString(@"UXNavigationControllerScopeAXLabel");
        _scopeBar.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _scopeBar;
}

- (NSVisualEffectView *)scopeBarVisualEffectsView {
    if (_scopeBarVisualEffectsView == nil) {
        _scopeBarVisualEffectsView = [[NSVisualEffectView alloc] initWithFrame:self.scopeBar.bounds];
        _scopeBarVisualEffectsView.blendingMode = NSVisualEffectBlendingModeWithinWindow;
        _scopeBarVisualEffectsView.material = NSVisualEffectMaterialContentBackground;
        _scopeBarVisualEffectsView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    }

    return _scopeBarVisualEffectsView;
}

- (NSView *)detachedBarsContainer {
    if (!_detachedBarsContainer) {
        _detachedBarsContainer = [[NSView alloc] init];
        _detachedBarsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _detachedBarsContainer;
}

- (void)setSubtoolbarHidden:(BOOL)subtoolbarHidden {
    [self _setToolbarHidden:self.isToolbarHidden subtoolbarHidden:subtoolbarHidden scopeBarHidden:self.isScopeBarHidden animated:NO duration:0.33 animateSubtree:YES];
}

- (void)setScopeBarHidden:(BOOL)scopeBarHidden {
    [self _setToolbarHidden:self.isToolbarHidden subtoolbarHidden:self.isSubtoolbarHidden scopeBarHidden:scopeBarHidden animated:NO duration:0.33 animateSubtree:YES];
}


- (void)setViewControllers:(NSArray<UXViewController *> *)viewControllers {
    [self setViewControllers:viewControllers animated:NO];
}

- (NSArray<UXViewController *> *)viewControllers {
    return [_targetViewControllers copy];
}


- (NSSize)preferredContentSize {
    if (self.currentTopViewController) {
        return [self.currentTopViewController preferredContentSize];
    } else {
        return [super preferredContentSize];
    }
}


- (void)dealloc {
    if (self.isNavigationBarDetached) {
        [self.navigationBar removeFromSuperview];
    }

    [self _endObservingCurrentTopViewController];
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    if (self = [self initWithNibName:nil bundle:nil]) {
        self.navigationBarClass = navigationBarClass;
        self.toolbarClass = toolbarClass;
    }

    return self;
}

static BOOL _useNSSearchToolbarItem = NO;
static BOOL _useIndividualNSToolbarItems = NO;
static BOOL _allowToolbarCustomization = NO;

+ (void)setUseIndividualNSToolbarItems:(BOOL)useIndividualNSToolbarItems {
    _useIndividualNSToolbarItems = useIndividualNSToolbarItems;
}

+ (BOOL)useIndividualNSToolbarItems {
    return _useIndividualNSToolbarItems;
}

+ (BOOL)useNSSearchToolbarItem {
    return _useNSSearchToolbarItem;
}

+ (void)setUseNSSearchToolbarItem:(BOOL)useNSSearchToolbarItem {
    _useNSSearchToolbarItem = useNSSearchToolbarItem;
}

+ (BOOL)allowToolbarCustomization {
    return _allowToolbarCustomization;
}

+ (void)setAllowToolbarCustomization:(BOOL)allowToolbarCustomization {
    _allowToolbarCustomization = allowToolbarCustomization;
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingPreferredContentSize {
    return [NSSet setWithObject:@"topViewController"];
}


- (UXViewController *)inspectorViewController {
    return self.topViewController.inspectorViewController;
}


@end
@implementation UXNavigationController (Compatibility)

- (NSArray<__kindof UXViewController *> *)px_popToViewControllerPrecedingViewController:(UXViewController *)viewController animated:(BOOL)animated {
    NSArray<UXViewController *> *viewControllers = self.viewControllers;
    NSUInteger index = [viewControllers indexOfObjectIdenticalTo:viewController];
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    return [self popToViewController:viewControllers[index - 1] animated:animated];
}

@end
