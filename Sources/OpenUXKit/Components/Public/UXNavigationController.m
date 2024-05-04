#import <OpenUXKit/_UXAccessoryBarContainer-Protocol.h>
#import <OpenUXKit/_UXContainerView.h>
#import <OpenUXKit/_UXNavigationRequest.h>
#import <OpenUXKit/_UXViewControllerOneToOneTransitionContext.h>
#import <OpenUXKit/_UXViewControllerTransitionCoordinator.h>
#import <OpenUXKit/_UXWindowState.h>
#import <OpenUXKit/NSResponder-UXKit.h>
#import <OpenUXKit/NSView-UXKit.h>
#import <OpenUXKit/NSWindow-UXKit.h>
#import <OpenUXKit/UXBackButton.h>
#import <OpenUXKit/UXBar+Internal.h>
#import <OpenUXKit/UXBarButtonItem+Internal.h>
#import <OpenUXKit/UXIdentityTransitionController.h>
#import <OpenUXKit/UXNavigationBar+Internal.h>
#import <OpenUXKit/UXNavigationController+Internal.h>
#import <OpenUXKit/UXNavigationItem.h>
#import <OpenUXKit/UXParallaxTransitionController.h>
#import <OpenUXKit/UXSlideTransitionController.h>
#import <OpenUXKit/UXSubtoolbar.h>
#import <OpenUXKit/UXTransitionController.h>
#import <OpenUXKit/UXView.h>
#import <OpenUXKit/UXViewController+Internal.h>
#import <OpenUXKit/UXViewControllerTransitionCoordinator.h>
#import <OpenUXKit/UXViewControllerTransitioning.h>
#import <OpenUXKit/UXWindowController.h>
#import <OpenUXKit/UXZoomingCrossfadeTransitionController.h>


void *UXToolbarItemsObservationContext = &UXToolbarItemsObservationContext;
void *UXSubtoolbarItemsObservationContext = &UXSubtoolbarItemsObservationContext;
void *UXToolbarPositionsObservationContext = &UXToolbarPositionsObservationContext;
void *UXToolbarAppearanceObservationContext = &UXToolbarAppearanceObservationContext;
void *UXAccessoryViewControllerObservationContext = &UXAccessoryViewControllerObservationContext;



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

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self _setToolbarHidden:hidden subtoolbarHidden:self.subtoolbarHidden animated:animated duration:0.33 animateSubtree:YES];
}

- (void)_setToolbarHidden:(BOOL)toolbarHidden subtoolbarHidden:(BOOL)subtoolbarHidden animated:(BOOL)animated duration:(NSTimeInterval)duration animateSubtree:(BOOL)animateSubtree {
    BOOL currentToolbarHidden = _toolbarHidden;

    if (currentToolbarHidden == toolbarHidden) {
        currentToolbarHidden = toolbarHidden;

        if (_subtoolbarHidden == subtoolbarHidden) {
            if (!self._toolbarNeedsVerticalOffsetUpdate) {
                return;
            }

            currentToolbarHidden = _toolbarHidden;
        }
    }

    BOOL currentSubtoolbarHidden = _subtoolbarHidden;
    _toolbarHidden = toolbarHidden;
    _subtoolbarHidden = subtoolbarHidden;

    auto completion = ^(BOOL finished) {
        self->_toolbar.hidden = self->_toolbarHidden;

        if (self->_subtoolbarHidden) {
            self->_subtoolbar.hidden = YES;
        } else {
            self->_subtoolbar.hidden = self->_toolbarHidden;
        }
    };

    if (self.isViewLoaded) {
        self.toolbarVerticalConstraint.constant = self._toolbarVerticalOffset;

        if (animated) {
            if (currentToolbarHidden && !_toolbarHidden) {
                self.toolbar.hidden = NO;
            }

            if (currentSubtoolbarHidden && !_subtoolbarHidden) {
                self.subtoolbar.hidden = NO;
            }

            [UXView animateWithDuration:duration
                                  delay:0.0
                                options:(0x4000)
                             animations:^{
                if (!currentSubtoolbarHidden) {
                    if (!self->_toolbarHidden) {
                        self->_subtoolbar.hidden = self->_subtoolbarHidden;
                    }
                }

                [self invalidateIntrinsicLayoutInsets];

                if (animateSubtree) {
                    [self.view layoutSubtreeIfNeeded];
                } else {
                    [self->_toolbar layoutSubtreeIfNeeded];
                    [self->_subtoolbar layoutSubtreeIfNeeded];
                }
            }
                             completion:completion];
            return;
        }

        [self invalidateIntrinsicLayoutInsets];
        [self.view layoutSubtreeIfNeeded];
    }

    completion(YES);
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    [self setNavigationBarHidden:navigationBarHidden animated:NO];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    if (_navigationBarHidden != hidden) {
        _navigationBarHidden = hidden;

        if (self.isViewLoaded) {
            self.navigationBarTopConstraint.constant = self._navigationBarVerticalOffset;

            if (animated) {
                [UXView animateWithDuration:0.33
                                 animations:^{
                    [self invalidateIntrinsicLayoutInsets];
                    [self.view layoutSubtreeIfNeeded];
                }
                                 completion:nil];
            } else {
                [self invalidateIntrinsicLayoutInsets];
                [self.view layoutSubtreeIfNeeded];
            }
        }
    }
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

    self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.toolbar];
    _subtoolbar = [[UXSubtoolbar alloc] initWithFrame:CGRectZero];
    _subtoolbar.translatesAutoresizingMaskIntoConstraints = NO;
    _subtoolbar.hidden = _subtoolbarHidden;
    _subtoolbar.delegate = self;
    [self.view addSubview:_subtoolbar positioned:NSWindowBelow relativeTo:self.toolbar];
    _toolbarExtendedBackgroundView = [[UXView alloc] init];
    _toolbarExtendedBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    _toolbarExtendedBackgroundView.hidden = YES;
    _toolbarExtendedBackgroundView.wantsLayer = YES;
    [_toolbarExtendedBackgroundView setBackgroundColor:NSColor.controlBackgroundColor];
    [self.view addSubview:_toolbarExtendedBackgroundView];
}

NSString * UXLocalizedString(NSString *key) {
    NSBundle *currentBundle = [NSBundle bundleForClass:[UXNavigationController class]];

    return [currentBundle localizedStringForKey:key value:nil table:nil];
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

- (UXBarPosition)positionForBar:(id<UXBarPositioning>)bar {
    if (self.toolbar == bar) {
        return self._toolbarPosition;
    }

    if (self.subtoolbar == bar) {
        return self._subtoolbarPosition;
    }

    return UXBarPositionTop;
}

- (void)detachNavigationBar {
    if (!self.isNavigationBarDetached) {
        NSArray *navigationBarConstraints = self.navigationBarConstraints;

        if (navigationBarConstraints) {
            [self.view removeConstraints:self.navigationBarConstraints];
            self.navigationBarConstraints = nil;
            self.navigationBarTopConstraint = nil;
        }

        id secondItem = self.toolbarVerticalConstraint.secondItem;

        if (secondItem == self.navigationBar) {
            [self.view removeConstraint:self.toolbarVerticalConstraint];
            NSMutableArray *addedConstraints = [self addedConstraints];
            [addedConstraints removeObject:self.toolbarVerticalConstraint];
            self.toolbarVerticalConstraint = nil;
        }

        [self.navigationBar removeFromSuperview];

        self.navigationBarDetached = YES;

        if (!self.toolbarVerticalConstraint) {
            self.toolbarVerticalConstraint = self._verticalToolbarLayoutConstraint;
            NSMutableArray *addedConstraints = [self addedConstraints];
            [addedConstraints addObject:self.toolbarVerticalConstraint];
            [self.view addConstraint:self.toolbarVerticalConstraint];
        }

        self.navigationBar.centerYOffset = 0.0;
        self.navigationBar.detached = YES;
        self.navigationBar.edgeInsets = NSEdgeInsetsMake(0.0, 1.0, 0.0, 1.0);
        self.navigationBar.blurEnabled = NO;
        [self.navigationBar setBackgroundColor:NSColor.clearColor];
    }
}

- (NSLayoutConstraint *)_verticalToolbarLayoutConstraint {
    CGFloat toolbarVerticalOffset = self._toolbarVerticalOffset;

    if (__toolbarPosition != UXBarPositionTop) {
        return [NSLayoutConstraint constraintWithItem:_toolbar attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:self.bottomLayoutGuide attribute:(NSLayoutAttributeTop) multiplier:1.0 constant:toolbarVerticalOffset];
    }

    if (self.isNavigationBarDetached) {
        return [NSLayoutConstraint constraintWithItem:_toolbar attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self.topLayoutGuide attribute:(NSLayoutAttributeTop) multiplier:1.0 constant:toolbarVerticalOffset];
    }

    return [NSLayoutConstraint constraintWithItem:_toolbar attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self.navigationBar attribute:(NSLayoutAttributeBottom) multiplier:1.0 constant:toolbarVerticalOffset];
}

- (CGFloat)_toolbarVerticalOffset {
    if (_toolbarHidden) {
        return self._hiddenToolbarOffset;
    } else {
        return self._visibleToolbarOffset;
    }
}

- (CGFloat)_hiddenToolbarOffset {
    CGFloat visibleToolbarOffset = self._visibleToolbarOffset;
    CGFloat multiplier = 0.0;

    if (__toolbarPosition == UXBarPositionTop) {
        multiplier = -1.0;
    } else {
        multiplier = 1.0;
    }

    CGFloat offset = visibleToolbarOffset + multiplier * self.toolbar.height;

    if (!self.subtoolbar.isHidden) {
        offset = offset + multiplier * self.subtoolbar.height;
    }

    return offset;
}

- (CGFloat)_visibleToolbarOffset {
    CGFloat offset = 0.0;

    if (__toolbarPosition == UXBarPositionTop) {
        NSWindow *window = self.viewIfLoaded.window;

        if (!self.isNavigationBarDetached) {
            return offset;
        }

        if (!window) {
            return offset;
        }

        offset = CGRectGetHeight(window.contentViewController.view.bounds) - CGRectGetHeight(window.contentLayoutRect);
        _UXViewControllerOneToOneTransitionContext *context = self.currentTransitionContext;

        if (!context) {
            return offset;
        }

        UXViewController *fromViewController = [self.currentTransitionContext viewControllerForKey:@"UXTransitionContextFromViewController"];
        UXViewController *toViewController = [self.currentTransitionContext viewControllerForKey:@"UXTransitionContextToViewController"];

        if (self.currentTransitionContext.isCurrentlyInteractive) {
            return offset;
        }

        UXViewController *fromAccessoryViewController = fromViewController.accessoryViewController;

        if (!fromAccessoryViewController) {
            if (!fromViewController.accessoryBarItems.count) {
                return offset;
            }
        }

        UXViewController *toAccessoryViewController = toViewController.accessoryViewController;

        if (!toAccessoryViewController) {
            if (toViewController.accessoryBarItems.count) {
                return offset;
            }

            offset = offset - self.accessoryBarContainer._accessoryBarHeight;
        }
    }

    return offset;
}

- (void)invalidateIntrinsicLayoutInsets {
    [self _loadViewIfNotLoaded];
    _UXViewControllerOneToOneTransitionContext *context = self.currentTransitionContext;

    if (context) {
        UXViewController *viewController = [self.currentTransitionContext viewControllerForKey:@"UXTransitionContextToViewController"];
        [self _invalidateIntrinsicLayoutInsetsForViewController:viewController];
    } else {
        [self _invalidateIntrinsicLayoutInsetsForViewController:self.currentTopViewController];
    }
}

- (UXViewController *)currentTopViewController {
    return _currentViewControllers.lastObject;
}

- (void)_invalidateIntrinsicLayoutInsetsForViewController:(UXViewController *)viewController {
    if (viewController) {
        NSEdgeInsets intrinsicLayoutInsets = [self _intrinsicLayoutInsetsForChildViewController:viewController];

        if (self.edgesForExtendedLayout & UXRectEdgeTop) {
            viewController.topLayoutGuide.length = intrinsicLayoutInsets.top + self.topLayoutGuide.length;
        }

        if (self.edgesForExtendedLayout & UXRectEdgeBottom) {
            viewController.bottomLayoutGuide.length = intrinsicLayoutInsets.bottom + self.bottomLayoutGuide.length;
        }
    }
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

    self.topConstraint = [NSLayoutConstraint constraintWithItem:_containerView attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self.uxView attribute:(NSLayoutAttributeTop) multiplier:1.0 constant:0.0];
    [self.addedConstraints addObject:self.topConstraint];
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:_containerView attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:self.uxView attribute:(NSLayoutAttributeBottom) multiplier:1.0 constant:0.0];
    [self.addedConstraints addObject:self.bottomConstraint];


    NSDictionary *views = @{
            @"topGuide": self.topLayoutGuide,
            @"navigationBar": self.navigationBar,
            @"containerView": _containerView,
            @"toolbar": self.toolbar,
            @"bottomGuide": self.bottomLayoutGuide,
    };

    if (self.isNavigationBarDetached) {
        self.navigationBarTopConstraint = nil;
        self.navigationBarConstraints = nil;
    } else {
        self.navigationBarTopConstraint = [_navigationBar.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor constant:4];
        [self.addedConstraints addObject:self.navigationBarTopConstraint];
        NSArray *layoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[navigationBar]|" options:(NSLayoutFormatDirectionLeadingToTrailing) metrics:nil views:views];
        [self.addedConstraints addObjectsFromArray:layoutConstraints];
        self.navigationBarConstraints = [layoutConstraints arrayByAddingObject:self.navigationBarTopConstraint];
    }

    self.toolbarVerticalConstraint = [self _verticalToolbarLayoutConstraint];
    [self.addedConstraints addObject:self.toolbarVerticalConstraint];
    self.toolbarLeadingConstraint = [_toolbar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:__leadingContentInset];
    [self.addedConstraints addObject:self.toolbarLeadingConstraint];
    [self.addedConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[containerView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
    [self.addedConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[toolbar]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
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
    ]];
    [self.view addConstraints:self.addedConstraints];
    [super updateViewConstraints];
}

- (void)viewWillLayout {
    [super viewWillLayout];

    if (self.isNavigationBarDetached) {
        BOOL inFullScreen = self.view.window.ux_inFullScreen;

        if (inFullScreen == self._isFullScreenMode) {
            goto LABEL7;
        }

        self._fullScreenMode = inFullScreen;
        [self.view updateConstraintsForSubtreeIfNeeded];
    }

    if (self._isFullScreenMode) {
        self._fullScreenMode = NO;
        [self.view updateConstraintsForSubtreeIfNeeded];
    }

 LABEL7:

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

- (BOOL)_toolbarNeedsVerticalOffsetUpdate {
    return self._toolbarVerticalOffset != self.toolbarVerticalConstraint.constant;
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
        _delegateFlags.willShowViewController = NO;
        _delegateFlags.willShowViewController = [self.delegate respondsToSelector:@selector(navigationController:willShowViewController:)];
        _delegateFlags.didShowViewController = NO;
        _delegateFlags.didShowViewController = [self.delegate respondsToSelector:@selector(navigationController:didShowViewController:)];
        _delegateFlags.interactionControllerForAnimationController = NO;
        _delegateFlags.interactionControllerForAnimationController = [self.delegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)];
        _delegateFlags.animationControllerForOperation = NO;
        _delegateFlags.animationControllerForOperation = [self.delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)];
        _delegateFlags.shouldBeginInteractivePopFromViewControllerToViewController = NO;
        _delegateFlags.shouldBeginInteractivePopFromViewControllerToViewController = [self.delegate respondsToSelector:@selector(navigationController:shouldBeginInteractivePopFromViewController:toViewController:)];
        _delegateFlags.shouldPopFromViewControllerToViewController = NO;
        _delegateFlags.shouldPopFromViewControllerToViewController = [self.delegate respondsToSelector:@selector(navigationController:shouldPopFromViewController:toViewController:)];
        _delegate = delegate;
    }
}

- (CGFloat)_navigationBarVerticalOffset {
    if (!_navigationBarHidden) {
        return 0.0;
    } else {
        return -self.navigationBar.height;
    }
}

- (void)addChildViewController:(NSViewController *)childViewController {
    [super addChildViewController:childViewController];

    if ([childViewController isKindOfClass:[UXViewController class]]) {
        [self _invalidateIntrinsicLayoutInsetsForViewController:(UXViewController *)childViewController];
    }
}

- (NSEdgeInsets)intrinsicLayoutInsets {
    return [self _intrinsicLayoutInsetsForChildViewController:self.currentTopViewController];
}

// FIXME: - Need Implementation
- (NSEdgeInsets)_intrinsicLayoutInsetsForChildViewController:(UXViewController *)childViewController {
    NSWindow *window = self.viewIfLoaded.window;
    CGFloat top = 0.0;
    CGFloat bottom = 0;

    if (self.isNavigationBarDetached && window) {
        CGFloat windowHeight = CGRectGetHeight(window.frame);
        top = windowHeight - CGRectGetMaxY(window.contentLayoutRect);
    } else {
        top = 0.0;

        if (self.edgesForExtendedLayout & UXRectEdgeTop && !_navigationBarHidden) {
            top = self.navigationBar.height;
        }
    }

    id<UXViewControllerContextTransitioning> currentTransitionContext = self.currentTransitionContext;

    if (currentTransitionContext) {
        UXViewController *fromViewController = [self.currentTransitionContext viewControllerForKey:@"UXTransitionContextFromViewController"];
        UXViewController *toViewController = [self.currentTransitionContext viewControllerForKey:@"UXTransitionContextToViewController"];

        if (fromViewController == childViewController) {
            UXViewController *accessoryViewController = childViewController.accessoryViewController;

            if (accessoryViewController) {
            }

            if (childViewController.accessoryBarItems.count) {
                UXViewController *toAccessoryViewController = toViewController.accessoryViewController;

                if (toAccessoryViewController) {
                    top = top - self.accessoryBarContainer._accessoryBarHeight;
                }
            }
        }

 LABEL_13:
        {
            if (toViewController != childViewController) {
                goto LABEL_28;
            }

            UXViewController *accessoryViewController = fromViewController.accessoryViewController;

            if (!accessoryViewController) {
                if (!fromViewController.accessoryBarItems.count) {
                    goto LABEL_28;
                }
            }

            UXViewController *childAccessoryViewController = childViewController.accessoryViewController;

            if (childAccessoryViewController) {
                goto LABEL_28;
            }

            if (childViewController.accessoryBarItems.count) {
                goto LABEL_28;
            }
        }



 LABEL_25:
        {
            top = top - self.accessoryBarContainer._accessoryBarHeight;
            goto LABEL_28;
        }
    }

 LABEL_28:
    {
        UXViewController *toolbarViewController = childViewController.toolbarViewController;

        if (!toolbarViewController) {
            if (!childViewController.toolbarItems.count) {
                bottom = 0.0;
                goto LABEL_43;
            }
        }

        bottom = 0.0;

        if (childViewController.hidesBottomBarWhenPushed == NO) {
            CGFloat preferredToolbarHeight = childViewController.preferredToolbarHeight;

            if (preferredToolbarHeight == 0.0) {
                bottom = self.toolbar.height;
            } else {
                bottom = preferredToolbarHeight;
            }

            if (__toolbarPosition == 2) {
                CGFloat edge = -0.0;

                if (childViewController.edgesForExtendedLayout & UXRectEdgeTop) {
                    edge = bottom;
                }

                top = top + edge;
            }

            if (__toolbarPosition == 1) {
                bottom = 0.0;
            }
        }
    }

 LABEL_43:
    {
        if (childViewController.subtoolbarItems.count) {
            UXBarPosition preferredSubtoolbarPosition = childViewController.preferredSubtoolbarPosition;
            CGFloat preferredSubtoolbarHeight = childViewController.preferredSubtoolbarHeight;

            if (!childViewController.preferredSubtoolbarPosition) {
                preferredSubtoolbarPosition = self._subtoolbarPosition;
            }

            if (preferredSubtoolbarHeight == 0.0) {
                preferredSubtoolbarHeight = self.subtoolbar.height;
            }

            CGFloat offset = -0.0;

            if (preferredSubtoolbarPosition != 10) {
                offset = preferredSubtoolbarHeight;
            }

            top = top + offset;
        }
    }

    return NSEdgeInsetsMake(top, 0, bottom, 0);
}

- (instancetype)initWithRootViewController:(UXViewController *)rootViewController {
    NSParameterAssert([rootViewController isKindOfClass:[UXViewController class]]);
    if (self = [self initWithNibName:nil bundle:nil]) {
        [self pushViewController:rootViewController animated:NO];
    }

    return self;
}

- (void)pushViewController:(UXViewController *)viewController animated:(BOOL)animated {
    _UXNavigationRequest *request = [_UXNavigationRequest pushRequestWithViewController:viewController animated:animated];

    [self _performOrEnqueueNavigationRequest:request];
}

- (NSArray<__kindof UXViewController *> *)_performOrEnqueueNavigationRequest:(_UXNavigationRequest *)navigationRequest {
    [self willChangeValueForKey:NSStringFromSelector(@selector(topViewController))];
    UXNavigationControllerOperation operation = navigationRequest.operation;
    BOOL v7 = NO;
    NSArray<__kindof UXViewController *> *result = nil;
    auto hasOperation = ^BOOL (UXNavigationControllerOperation operation) {
        for (_UXNavigationRequest *request in self->_navigationRequests) {
            if (request.operation == operation) {
                return YES;
            }
        }

        return NO;
    };

    if (operation == UXNavigationControllerOperationPop) {
        result = [self _checkinPopNavigationRequest:navigationRequest];
        v7 = NO;
    } else {
        if (operation == UXNavigationControllerOperationPush) {
            v7 = hasOperation(UXNavigationControllerOperationPop);
            [self _checkinPushNavigationRequest:navigationRequest];
        } else {
            if (!operation) {
                [self _checkinSetNavigationRequest:navigationRequest];
            }

            v7 = NO;
        }

        result = nil;
    }

    [self didChangeValueForKey:NSStringFromSelector(@selector(topViewController))];

    id<UXViewControllerTransitionCoordinator> currentTransitionCoordinator = self.currentTransitionCoordinator;

    if (!currentTransitionCoordinator && !v7) {
        [navigationRequest setupContainmentIfNeededInParentViewController:self];
    }

    if (_navigationRequests.count == 1) {
        if (currentTransitionCoordinator) {
            // objc_msgSend(v9, "animateAlongsideTransition:completion:", 0LL, v12);
            // v12 is transition or completion ? IDA Pro display this is a completion.
            [currentTransitionCoordinator animateAlongsideTransition:^(id<UXViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            }
                                                          completion:^(id<UXViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                [self _dequeueNavigationRequest];
            }];
        } else if (self.isViewLoaded) {
            result = [self _dequeueNavigationRequest];
        }
    }

    return result;
}

- (void)_checkinPushNavigationRequest:(_UXNavigationRequest *)navigationRequest {
    UXViewController *viewController = navigationRequest.viewController;

    if (viewController) {
        if ([_targetViewControllers containsObject:viewController]) {
            NSLog(@"Pushing the same view controller instance more than once is not supported (%@)", viewController);
        } else {
            if ([viewController isKindOfClass:[UXNavigationController class]]) {
                NSLog(@"Pushing a navigation controller is not supported");
            } else {
                [_navigationRequests addObject:navigationRequest];
                [_targetViewControllers addObject:viewController];
            }
        }
    } else {
        NSLog(@"Application tried to push a nil view controller on target %@.", self);
    }
}

- (void)performToolbarsChanges:(void (^)(void))changesBlock {
    BOOL isPerformingToolbarsChanges = _isPerformingToolbarsChanges;

    _isPerformingToolbarsChanges = YES;

    if (changesBlock) {
        changesBlock();
    }

    _isPerformingToolbarsChanges = isPerformingToolbarsChanges;

    if (!isPerformingToolbarsChanges) {
        [self _updateToolbarsIfNeeded];
    }
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

- (void)_updateToolbarsIfNeeded {
    if (self._toolbarsNeedUpdate) {
        UXViewController *currentTopViewController = self.currentTopViewController;
        BOOL shouldAnimateToolbarUpdates = self.shouldAnimateToolbarUpdates;
        self.shouldAnimateToolbarUpdates = NO;

        if (_toolbarsNeedUpdateFlags.appearance) {
            _toolbarsNeedUpdateFlags.appearance = NO;
            [self _updateToolbarAppearanceUsingTopViewController:currentTopViewController animated:shouldAnimateToolbarUpdates duration:0.33];
        }

        if (_toolbarsNeedUpdateFlags.toolbarItems) {
            _toolbarsNeedUpdateFlags.toolbarItems = NO;
            [self.toolbar setItems:_toolbarItemsForViewController(currentTopViewController) animated:shouldAnimateToolbarUpdates];
        }

        if (_toolbarsNeedUpdateFlags.subtoolbarItems) {
            _toolbarsNeedUpdateFlags.subtoolbarItems = NO;
            [self.subtoolbar setItems:_subtoolbarItemsForViewController(currentTopViewController) animated:shouldAnimateToolbarUpdates];
        }

        if (_toolbarsNeedUpdateFlags.positions) {
            _toolbarsNeedUpdateFlags.positions = NO;
            [self _updateToolbarsPositionsUsingTopViewController:currentTopViewController];
        }

        if (_toolbarsNeedUpdateFlags.visibility) {
            _toolbarsNeedUpdateFlags.visibility = NO;
            [self _updateToolbarVisibilityUsingTopViewController:currentTopViewController animated:shouldAnimateToolbarUpdates duration:0.33 animateSubtree:YES];
        }

        if (self._toolbarsNeedUpdate) {
            NSAssert(false, @"toolbars still need update after update pass");
        }
    }
}

- (BOOL)_toolbarsNeedUpdate {
    return _toolbarsNeedUpdateFlags.toolbarItems
           || _toolbarsNeedUpdateFlags.subtoolbarItems
           || _toolbarsNeedUpdateFlags.positions
           || _toolbarsNeedUpdateFlags.visibility
           || _toolbarsNeedUpdateFlags.appearance;
}

- (void)setViewControllers:(NSArray<UXViewController *> *)viewControllers animated:(BOOL)animated {
    _UXNavigationRequest *request = [_UXNavigationRequest setRequestWithViewControllers:viewControllers animated:animated];

    [self _performOrEnqueueNavigationRequest:request];
}

- (void)_checkinSetNavigationRequest:(_UXNavigationRequest *)navigationRequest {
    NSArray<UXViewController *> *viewControllers = navigationRequest.viewControllers;

    if (![_targetViewControllers isEqualToArray:viewControllers]) {
        for (_UXNavigationRequest *request in _navigationRequests) {
            [request tearDownContainmentIfNeeded];
        }

        [_navigationRequests setArray:@[navigationRequest]];
        [_targetViewControllers setArray:viewControllers];
    }
}

- (NSArray<__kindof UXViewController *> *)_dequeueNavigationRequest {
    _UXNavigationRequest *firstRequest = _navigationRequests.firstObject;
    NSArray<__kindof UXViewController *> *result = nil;

    if (firstRequest) {
        [_navigationRequests removeObject:firstRequest];
        [firstRequest setupContainmentIfNeededInParentViewController:self];
        result = [self _performNavigationRequest:firstRequest];
        id<UXViewControllerTransitionCoordinator> currentTransitionCoordinator = self.currentTransitionCoordinator;

        if (currentTransitionCoordinator) {
            [currentTransitionCoordinator animateAlongsideTransition:^(id<UXViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            }
                                                          completion:^(id<UXViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                [self _dequeueNavigationRequest];
            }];
        } else {
            [self _removeAllNavigationRequests];
        }
    }

    return result;
}

- (NSArray<__kindof UXViewController *> *)_performNavigationRequest:(_UXNavigationRequest *)navigationRequest {
    UXNavigationControllerOperation operation = navigationRequest.operation;
    NSArray<__kindof UXViewController *> *result = nil;

    if (operation) {
        switch (operation) {
            case UXNavigationControllerOperationPop: {
                NSUInteger defaultPopTransition = 0;

                if (navigationRequest.animated) {
                    defaultPopTransition = __defaultPopTransition;
                } else {
                    defaultPopTransition = 102;
                }

                result = [self _popToViewController:navigationRequest.viewController transition:defaultPopTransition];
            }
            break;

            case UXNavigationControllerOperationPush: {
                NSUInteger defaultPushTransition = 0;

                if (navigationRequest.animated) {
                    defaultPushTransition = __defaultPushTransition;
                } else {
                    defaultPushTransition = 102;
                }

                [self _pushViewController:navigationRequest.viewController transition:defaultPushTransition];
            }
            break;

            default:
                break;
        }
    } else {
        [self _setViewControllers:navigationRequest.viewControllers animated:navigationRequest.animated];
    }

    return result;
}

- (void)_pushViewController:(UXViewController *)viewController transition:(NSUInteger)transition {
    UXViewController *currentTopViewController = self.currentTopViewController;
    UXNavigationItem *navigationItem = self.provisionalPreviousViewController.navigationItem;
    UXNavigationItem *targetNavigationItem = nil;

    if (navigationItem) {
        targetNavigationItem = viewController.navigationItem;
        [self _addBackBarItemFromNavigationItem:navigationItem toNavigationItem:targetNavigationItem];
    } else {
        if (currentTopViewController) {
            targetNavigationItem = currentTopViewController.navigationItem;
            [self _addBackBarItemFromNavigationItem:targetNavigationItem toNavigationItem:viewController.navigationItem];
        }
    }

    id<UXViewControllerContextTransitioning> context = [self _contextForTransitionOperation:(UXNavigationControllerOperationPush) fromViewController:currentTopViewController toViewController:viewController transition:transition];
    self.currentTransitionContext = context;

    if (self.currentTransitionContext) {
        [self _beginTransitionWithContext:self.currentTransitionContext operation:(UXNavigationControllerOperationPush)];
        [self _invalidateIntrinsicLayoutInsetsForViewController:viewController];
    }
}

- (_UXViewControllerOneToOneTransitionContext *)_contextForTransitionOperation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController transition:(NSUInteger)transition {
    UXTransitionController *interactor = nil;
    UXTransitionController *transitionController = [self _customAnimationControllerForOperation:operation fromViewController:fromViewController toViewController:toViewController transition:transition];

    if (!transitionController) {
        return nil;
    }

    UXTransitionController *defaultTransitionController = self.defaultTransitionController;

    if (transitionController != defaultTransitionController) {
        interactor = [self _customInteractionControllerForAnimationController:transitionController transition:transition];
    } else {
        if (self.isInteractive) {
            interactor = self.defaultTransitionController;
        } else {
            interactor = [self _customInteractionControllerForAnimationController:transitionController transition:transition];
        }
    }

    [self _loadViewIfNotLoaded];
    [self.view layoutSubtreeIfNeeded];

    _UXViewControllerOneToOneTransitionContext *oneToOneTransitionContext = [_UXViewControllerOneToOneTransitionContext new];
    oneToOneTransitionContext.containerView = self.containerView;
    oneToOneTransitionContext.animated = transition != 102;
    oneToOneTransitionContext.animator = transitionController;
    oneToOneTransitionContext.interactor = interactor;
    oneToOneTransitionContext.initiallyInteractive = interactor != nil;
    oneToOneTransitionContext.fromViewController = fromViewController;
    oneToOneTransitionContext.toViewController = toViewController;
    __weak typeof(self) weakSelf = self;
    oneToOneTransitionContext.arbitraryTransitionCompletionHandler = ^{
        [weakSelf testing_notifyTransitionAnimationDidComplete];
    };
    oneToOneTransitionContext.fromStartFrame = fromViewController.view.frame;
    oneToOneTransitionContext.fromEndFrame = CGRectZero;
    oneToOneTransitionContext.toStartFrame = CGRectZero;
    oneToOneTransitionContext.toEndFrame = self.containerView.bounds;
    return oneToOneTransitionContext;
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

- (id<UXViewControllerAnimatedTransitioning>)_customAnimationControllerForOperation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController transition:(NSUInteger)transition {
    id<UXViewControllerAnimatedTransitioning> animationController = nil;

    if ([self.delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        animationController = [self.delegate navigationController:self animationControllerForOperation:operation fromViewController:fromViewController toViewController:toViewController];
    }

    if (!animationController) {
        NSUInteger _transition = 102;

        if (fromViewController && toViewController) {
            if (fromViewController.view == toViewController.view) {
                _transition = 102;
            } else {
                _transition = transition;
            }
        }

        Class transitionControllerClass = _transitionControllerClassForTransition(_transition);
        self.defaultTransitionController = [transitionControllerClass new];
        self.defaultTransitionController.operation = operation;
        animationController = self.defaultTransitionController;
    }

    if (!_defaultTransitionController) {
        if ([animationController isKindOfClass:[UXTransitionController class]]) {
            _defaultTransitionController = (UXTransitionController *)animationController;
        }
    }

    return animationController;
}

- (id)_customInteractionControllerForAnimationController:(id<UXViewControllerAnimatedTransitioning>)animationController transition:(NSUInteger)transition {
    if (_delegateFlags.interactionControllerForAnimationController) {
        return [self.delegate navigationController:self interactionControllerForAnimationController:animationController];
    } else {
        return nil;
    }
}

- (void)_beginTransitionWithContext:(_UXViewControllerOneToOneTransitionContext *)context operation:(UXNavigationControllerOperation)operation {
    _navigationBar.userInteractionEnabled = NO;
    _toolbar.userInteractionEnabled = NO;
    _subtoolbar.userInteractionEnabled = NO;
    _isTransitioning = YES;
    UXViewController *fromViewController = [context viewControllerForKey:@"UXTransitionContextFromViewController"];
    UXViewController *toViewController = [context viewControllerForKey:@"UXTransitionContextToViewController"];
    BOOL selfViewIsInResponderChainOfWindowFirstResponder = [self.view isInResponderChainOf:self.view.window.firstResponder];
    __weak typeof(self) weakSelf = self;
    __weak typeof(context) weakContext = context;
    auto setupContext = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        weakContext.duration = [weakContext.animator transitionDuration:weakContext];
        weakContext.completionHandler = ^(_UXViewControllerTransitionContext *context, BOOL isEnded) {
            UXViewController *innerFromViewController = [context viewControllerForKey:@"UXTransitionContextFromViewController"];
            UXViewController *innerToViewController = [context viewControllerForKey:@"UXTransitionContextToViewController"];
            id<UXViewControllerAnimatedTransitioning> animator = context.animator;

            if ([animator respondsToSelector:@selector(animationEnded:)]) {
                [animator animationEnded:isEnded];
            }

            innerFromViewController.uxView.userInteractionEnabled = YES;
            strongSelf.navigationBar.userInteractionEnabled = YES;
            strongSelf.toolbar.userInteractionEnabled = YES;
            strongSelf.subtoolbar.userInteractionEnabled = YES;
            innerToViewController.uxView.userInteractionEnabled = YES;
            BOOL fromViewIsNotEqualToView = innerFromViewController.view != innerToViewController.view;
            auto removeFromSuperview = ^(NSView *view) {
                if (fromViewIsNotEqualToView) {
                    [view removeFromSuperview];
                }
            };

            if (isEnded) {
                CGRect finalFrame = [context finalFrameForViewController:innerToViewController];
                CGFloat leftInset = finalFrame.origin.x;
                CGFloat width = finalFrame.size.width;

                if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
                    leftInset = strongSelf.view.frame.origin.x - width;
                }

                if (operation == UXNavigationControllerOperationPush) {
                    removeFromSuperview(innerFromViewController.view);
                    [strongSelf _addConstraintsForContainedView:innerToViewController.uxView leftInset:leftInset];
                    [innerToViewController didMoveToParentViewController:strongSelf];
                } else {
                    [innerFromViewController willMoveToParentViewController:nil];
                    removeFromSuperview(innerFromViewController.view);
                    [strongSelf _addConstraintsForContainedView:innerToViewController.uxView leftInset:leftInset];
                    [innerFromViewController removeFromParentViewController];
                }

                [strongSelf _beginObservingCurrentTopViewController];

                if (selfViewIsInResponderChainOfWindowFirstResponder) {
                    [strongSelf.view.window makeFirstResponder:innerToViewController.preferredFirstResponder];
                }

                if (strongSelf && strongSelf->_delegateFlags.didShowViewController) {
                    [strongSelf.delegate navigationController:strongSelf didShowViewController:innerToViewController];
                }

                [strongSelf contentRepresentingViewControllerDidChange];
            } else {
                [strongSelf willChangeValueForKey:NSStringFromSelector(@selector(currentTopViewController))];
                [strongSelf _endObservingCurrentTopViewController];

                if (operation == UXNavigationControllerOperationPush) {
                    [innerToViewController willMoveToParentViewController:nil];
                    removeFromSuperview(innerToViewController.view);
                    [strongSelf _addConstraintsForContainedView:innerFromViewController.uxView leftInset:[context initialFrameForViewController:innerFromViewController.uxView].origin.x];
                    [innerToViewController removeFromParentViewController];
                    [strongSelf->_targetViewControllers removeLastObject];
                    [strongSelf->_currentViewControllers removeLastObject];
                } else {
                    removeFromSuperview(innerToViewController.view);
                    CGRect initialFrame = [context initialFrameForViewController:innerFromViewController];
                    [strongSelf _addConstraintsForContainedView:innerFromViewController.uxView leftInset:initialFrame.origin.x];
                    [strongSelf->_targetViewControllers addObject:innerFromViewController];
                    [strongSelf->_currentViewControllers addObject:innerFromViewController];
                }

                if (selfViewIsInResponderChainOfWindowFirstResponder) {
                    [strongSelf.view.window makeFirstResponder:[innerFromViewController preferredFirstResponder]];
                }

                [strongSelf _beginObservingCurrentTopViewController];
                [strongSelf didChangeValueForKey:NSStringFromSelector(@selector(currentTopViewController))];
            }

            self.currentTransitionContext = nil;
            self.defaultTransitionController = nil;
            self->_isTransitioning = NO;

            if (isEnded) {
                NSWindow *window = strongSelf.view.window;

                if (window) {
                    UXViewController *fromAccessoryViewController = fromViewController.accessoryViewController;

                    if (fromAccessoryViewController || fromViewController.accessoryBarItems.count) {
                        UXViewController *toAccessoryViewController = toViewController.accessoryViewController;

                        if (!toAccessoryViewController && !toViewController.accessoryBarItems.count) {
                            [strongSelf _setAccessoryBarHidden:YES];
                        }
                    }
                }
            }

            [strongSelf.view.window recalculateKeyViewLoop];
        };
        [strongSelf _invalidateIntrinsicLayoutInsetsForViewController:toViewController];
        [weakContext.animator animateTransition:weakContext];
        [weakContext __runAlongsideAnimations];
        weakContext.transitionIsInFlight = YES;
    };
    _UXWindowState *currentWindowState = nil;
    NSWindow *currentWindow = self.view.window;

    if (self.windowState || !self._hasNoNavigationRequests) {
        currentWindowState = nil;
    } else {
        if (self.currentTransitionCoordinator == [super transitionCoordinator]) {
            _UXWindowState *windowState = [_UXWindowState windowStateWithStyleMask:currentWindow.styleMask collectionBehavior:currentWindow.collectionBehavior];
            self.windowState = windowState;
            currentWindowState = windowState;
        }
    }

    auto prepareTransition = ^(void (^toCompletion)(void)) {
        if (currentWindowState) {
            currentWindow.styleMask = currentWindowState.styleMask ^ NSWindowStyleMaskMiniaturizable ^ NSWindowStyleMaskResizable;

            if (currentWindowState.styleMask & NSWindowStyleMaskFullScreen) {
                currentWindow.collectionBehavior = currentWindowState.collectionBehavior ^ NSWindowCollectionBehaviorFullScreenPrimary;
            }

            if (currentWindowState.styleMask & NSWindowStyleMaskMiniaturizable) {
                [currentWindow ux_forceEnableStandardWindowButton:(NSWindowMiniaturizeButton)];
            }

            if (currentWindowState.styleMask & NSWindowStyleMaskResizable || currentWindow.collectionBehavior & NSWindowCollectionBehaviorFullScreenPrimary) {
                [currentWindow ux_forceEnableStandardWindowButton:NSWindowZoomButton];
            }
        }

        auto fromCompletion = ^{
            if (selfViewIsInResponderChainOfWindowFirstResponder) {
                [self.view.window makeFirstResponder:self.uxView];
            }

            if (toViewController._requiresWindowForTransitionPreparation) {
                toViewController.view.alphaValue = 0.0;
                UXView *containerView = context.containerView;

                if (operation == UXNavigationControllerOperationPush) {
                    [containerView addSubview:toViewController.view];
                } else {
                    [containerView addSubview:toViewController.view positioned:NSWindowBelow relativeTo:fromViewController.view];
                }
            }

            [self _prepareViewController:toViewController
                   forAnimationInContext:context
                              completion:^{
                if (!NSThread.isMainThread) {
                    NSAssert(false, @"completion block must be called on the main thread");
                }
                if (toCompletion) {
                    toCompletion();
                } else {
                    NSLog(@"Do not call the completion block passed to prepareForTransitionWithContext:completion: more than once! %@", [NSThread callStackSymbols]);
                }
            }];
        };
        [self _removeConstraintsForContainedView:fromViewController.uxView];
        [self.navigationBar _prepareForNavigationItemTransition];
        [self _prepareViewController:fromViewController
               forAnimationInContext:context
                          completion:^{
            if (!NSThread.isMainThread) {
                NSAssert(false, @"completion block must be called on the main thread");
            }

            if (fromCompletion) {
                fromCompletion();
            } else {
                NSLog(@"Do not call the completion block passed to prepareForTransitionWithContext:completion: more than once! %@", [NSThread callStackSymbols]);
            }
        }];
    };
    auto animateAlongsideTransition = ^{
        [weakContext._transitionCoordinator animateAlongsideTransition:^(id<UXViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            BOOL isCancelled = context.isCancelled;
            NSTimeInterval transitionDuration = context.transitionDuration;

            if (context.initiallyInteractive) {
                [weakSelf.navigationBar _completeInteractiveTransition:!isCancelled
                                                              duration:transitionDuration];
                [weakSelf.accessoryBar _completeInteractiveTransition:!isCancelled
                                                             duration:transitionDuration];
                [weakSelf.toolbar _completeInteractiveTransition:!isCancelled
                                                        duration:transitionDuration];

                if (!isCancelled) {
 LABEL13:
                    [weakSelf _updateToolbarsPositionsUsingTopViewController:toViewController];
                    [weakSelf _updateToolbarVisibilityUsingTopViewController:toViewController
                                                                    animated:YES
                                                                    duration:transitionDuration
                                                              animateSubtree:NO];
                    [weakSelf _updateToolbarAppearanceUsingTopViewController:toViewController
                                                                    animated:YES
                                                                    duration:transitionDuration];
                    goto LABEL14;
                }

                UXViewController *fromAccessoryViewController = fromViewController.accessoryViewController;

                if (fromAccessoryViewController) {
                } else {
                    if (!fromViewController.accessoryBarItems.count) {
                        UXViewController *toAccessoryViewController = toViewController.accessoryViewController;

                        if (toAccessoryViewController) {
                        } else {
                            if (!toViewController.accessoryBarItems.count) {
                                goto LABEL13;
                            }
                        }

                        [weakSelf.accessoryBarContainer _setAccessoryBarHidden:YES];
                        goto LABEL12;
                    }
                }

 LABEL12:
                goto LABEL13;
            }

            if (operation == UXNavigationControllerOperationPop) {
                [weakSelf.navigationBar _popNavigationItemAnimated:YES
                                                          duration:transitionDuration];
            } else {
                [weakSelf.navigationBar _pushNavigationItem:toViewController.navigationItem
                                                   animated:YES
                                                   duration:transitionDuration];
            }

            [weakSelf _updateToolbarsPositionsUsingTopViewController:toViewController];
            [weakSelf _updateToolbarVisibilityUsingTopViewController:toViewController
                                                            animated:YES
                                                            duration:transitionDuration
                                                      animateSubtree:NO];
            [weakSelf _updateToolbarAppearanceUsingTopViewController:toViewController
                                                            animated:YES
                                                            duration:transitionDuration];
            [weakSelf.toolbar _setItems:_toolbarItemsForViewController(toViewController)
                               animated:YES
                               duration:transitionDuration];
            [weakSelf.subtoolbar _setItems:_subtoolbarItemsForViewController(toViewController)
                                  animated:YES
                                  duration:transitionDuration];
            [weakSelf.accessoryBar _setItems:_accessoryBarItemsForViewController(toViewController)
                                    animated:YES
                                    duration:transitionDuration];
 LABEL14:

            if (!isCancelled && UXNavigationController.useIndividualNSToolbarItems) {
                [[weakSelf windowController] _updateToolbarItems];
            }
        }
                                                            completion:^(id<UXViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            if (weakSelf._hasNoNavigationRequests) {
                if (weakSelf.windowState) {
                    [weakSelf.windowState applyToWindow:currentWindow];
                    weakSelf.windowState = nil;
                }
            }
        }];
    };
    auto modifyCurrentViewControllers = ^{
        if (operation == UXNavigationControllerOperationPush) {
            [self->_currentViewControllers addObject:toViewController];
            [self _endObservingCurrentTopViewController];
        } else {
            [self->_currentViewControllers removeObject:fromViewController];
        }
    };

    if (_delegateFlags.willShowViewController) {
        [self.delegate navigationController:self willShowViewController:toViewController];
    }

    CGRect toEndFrame = context.toEndFrame;
    CGFloat leftContentInset = self._leftContentInset;
    CGFloat leadingContentInset = self._leadingContentInset;
    context.toEndFrame = CGRectMake(toEndFrame.origin.x + leftContentInset, toEndFrame.origin.y, toEndFrame.size.width - leadingContentInset, toEndFrame.size.height);
    CGRect finalFrame = [context finalFrameForViewController:toViewController];
    toViewController.uxView.frame = finalFrame;
    toViewController.uxView.userInteractionEnabled = NO;
    UXViewController *fromAccessoryViewController = fromViewController.accessoryViewController;

    if (!fromAccessoryViewController && !fromViewController.accessoryBarItems.count) {
        if (toViewController.accessoryViewController || toViewController.accessoryBarItems.count) {
            [self _setAccessoryBarHidden:NO];
        }
    }

    if (context.initiallyInteractive) {
        context.interactiveUpdateHandler = ^(BOOL a2, BOOL a3, _UXViewControllerTransitionContext *context, CGFloat a5) {
            if (a2 && a3) {
                setupContext();
                return;
            }

            if (a2) {
                setupContext();
                return;
            }

            CGFloat transition = fmax(a5, 0.0);

            [weakSelf.navigationBar _updateInteractiveTransition:transition];
            [weakSelf.accessoryBar _updateInteractiveTransition:transition];
            [weakSelf.toolbar _updateInteractiveTransition:transition];
            UXViewController *toViewController = [context viewControllerForKey:@"UXTransitionContextToViewController"];
            UXViewController *toolbarViewController = toViewController.toolbarViewController;

            if (toolbarViewController) {
            } else {
                if (!toViewController.toolbarItems.count) {
                    goto LABEL14;
                }
            }

            BOOL hidesBottomBarWhenPushed = toViewController.hidesBottomBarWhenPushed;

            if (!hidesBottomBarWhenPushed && weakSelf.isToolbarHidden) {
                weakSelf.toolbarVerticalConstraint.constant = weakSelf._visibleToolbarOffset + (weakSelf._hiddenToolbarOffset - weakSelf._visibleToolbarOffset) * transition;
                return;
            }

 LABEL14:

            if (toolbarViewController) {
                if (!toViewController.hidesBottomBarWhenPushed) {
                    return;
                }
            } else {
                if (toViewController.toolbarItems.count) {
                    if (!toViewController.hidesBottomBarWhenPushed) {
                        return;
                    }
                } else {
                }
            }

            if (!weakSelf.isToolbarHidden) {
                weakSelf.toolbarVerticalConstraint.constant = weakSelf._hiddenToolbarOffset + (weakSelf._visibleToolbarOffset - weakSelf._hiddenToolbarOffset) * transition;
            }
        };

        prepareTransition(^{
            toViewController.view.alphaValue = 1.0;
            [context.interactor startInteractiveTransition:context];
            animateAlongsideTransition();
            context.transitionIsInFlight = YES;

            if (operation == UXNavigationControllerOperationPop) {
                [self.navigationBar beginInteractivePop];
            } else {
                [self.navigationBar beginInteractivePushToItem:toViewController.navigationItem];
            }

            [self.accessoryBar _beginInteractiveTransitionForItems:_accessoryBarItemsForViewController(toViewController)];
            [self.toolbar _beginInteractiveTransitionForItems:_toolbarItemsForViewController(toViewController)];
            [self.subtoolbar _beginInteractiveTransitionForItems:_subtoolbarItemsForViewController(toViewController)];
        });
    } else {
        fromViewController.uxView.userInteractionEnabled = NO;
        prepareTransition(^{
            modifyCurrentViewControllers();
            animateAlongsideTransition();
            toViewController.view.alphaValue = 1.0;
            setupContext();
        });
    }
}

- (BOOL)_hasNoNavigationRequests {
    return _navigationRequests.count == 0;
}

- (void)_setLeadingContentInset:(CGFloat)contentInset forViewController:(UXViewController *)viewController {
    if (__leadingContentInset != contentInset) {
        __leadingContentInset = contentInset;
    }

    if (viewController.hidesSourceListWhenPushed) {
        contentInset = 0.0;
    }

    BOOL v16 = NO;

    if (_topViewControllerLeftConstraint.constant != contentInset) {
        _topViewControllerLeftConstraint.constant = contentInset;
        id<UXViewControllerTransitionCoordinator> transitionCoordinator = self.transitionCoordinator;
        UXViewController *toolbarViewController = viewController.toolbarViewController;

        if (toolbarViewController) {
            if (viewController.hidesBottomBarWhenPushed) {
                goto LABEL13;
            } else {
                v16 = YES;
                goto LABEL16;
            }
        }

        if (viewController.toolbarItems.count) {
            if (!viewController.hidesBottomBarWhenPushed) {
                v16 = YES;
                goto LABEL16;
            }
        }

 LABEL13:
        v16 = viewController.subtoolbarItems.count != 0;

        if (transitionCoordinator && !viewController.subtoolbarItems.count) {
            [transitionCoordinator animateAlongsideTransition:nil
                                                   completion:^(id <UXViewControllerTransitionCoordinatorContext> context) {
                self.toolbarLeadingConstraint.constant = contentInset;
            }];
            return;
        }

 LABEL16:
        self.toolbarLeadingConstraint.constant = contentInset;

        if (self.isToolbarHidden && self.isSubtoolbarHidden && v16) {
            [self.view layoutSubtreeIfNeeded];
        }
    }
}

- (id<UXViewControllerTransitionCoordinator>)transitionCoordinator {
    if (self.currentTransitionCoordinator) {
        return self.currentTransitionCoordinator;
    } else {
        return [super transitionCoordinator];
    }
}

- (CGFloat)_leftContentInset {
    if (NSApp.userInterfaceLayoutDirection != NSUserInterfaceLayoutDirectionRightToLeft) {
        return __leadingContentInset;
    } else {
        return 0.0;
    }
}

- (void)_removeConstraintsForContainedView:(UXView *)containedView {
    CGRect frame = containedView.frame;

    if (_topViewControllerLeftConstraint) {
        [self.containerView removeConstraint:_topViewControllerLeftConstraint];
    }

    if (_topViewControllerOtherConstraints) {
        [self.containerView removeConstraints:_topViewControllerOtherConstraints];
        _topViewControllerOtherConstraints = nil;
    }

    containedView.translatesAutoresizingMaskIntoConstraints = YES;
    containedView.frame = frame;
}

- (void)_prepareViewController:(UXViewController *)viewController forAnimationInContext:(id)context completion:(void (^)(void))completion {
    if (viewController) {
        [viewController _prepareForAnimationInContext:context completion:completion];
    } else {
        completion();
    }
}

- (void)_endObservingCurrentTopViewController {
    [[[self class] topViewControllerObservationKeyPathsByContext] enumerateKeysAndObjectsUsingBlock:^(NSValue *_Nonnull context, NSArray<NSString *> *_Nonnull keyPaths, BOOL *_Nonnull stop) {
        for (NSString *keyPath in keyPaths) {
            [_observedViewController removeObserver:self
                                         forKeyPath:keyPath
                                            context:[context pointerValue]];
        }
    }];
    _observedViewController = nil;
}

+ (NSDictionary<NSValue *, NSArray<NSString *> *> *)topViewControllerObservationKeyPathsByContext {
    static dispatch_once_t onceToken;
    static NSDictionary<NSValue *, NSArray<NSString *> *> *propertyNamesByContext;

    dispatch_once(&onceToken, ^{
        propertyNamesByContext = @{
                [NSValue valueWithPointer:UXToolbarItemsObservationContext]: @[
                    @"toolbarItems",
                    @"toolbarViewController",
                ],
                [NSValue valueWithPointer:UXSubtoolbarItemsObservationContext]: @[
                    @"subtoolbarItems",
                ],
                [NSValue valueWithPointer:UXToolbarPositionsObservationContext]: @[
                    @"preferredSubtoolbarPosition",
                ],
                [NSValue valueWithPointer:UXToolbarAppearanceObservationContext]: @[
                    @"preferredToolbarHeight",
                    @"preferredToolbarBaselineOffsetFromBottom",
                    @"preferredToolbarStyle",
                    @"preferredToolbarDecorationInsets",
                    @"preferredSubtoolbarHeight",
                    @"preferredSubtoolbarBaselineOffsetFromBottom",
                ],
                [NSValue valueWithPointer:UXAccessoryViewControllerObservationContext]: @[
                    @"accessoryViewController",
                ],
        };
        NSMutableSet *set = [NSMutableSet set];
        [propertyNamesByContext enumerateKeysAndObjectsUsingBlock:^(NSValue *_Nonnull key, NSArray<NSString *> *_Nonnull obj, BOOL *_Nonnull stop) {
            [set addObjectsFromArray:obj];
        }];

        if (![[NSSet setWithArray:UXViewController.toolbarPropertyNames] isSubsetOfSet:set]) {
            NSAssert(false, @"topViewControllerObservationKeyPathsByContext don't include all UXViewController.toolbarPropertyNames");
        }
    });
    return propertyNamesByContext;
}

- (void)_updateToolbarsPositionsUsingTopViewController:(UXViewController *)topViewController {
    UXBarPosition toolbarPosition = topViewController.preferredToolbarPosition;
    UXBarPosition subtoolbarPosition = topViewController.preferredSubtoolbarPosition;

    if (!toolbarPosition) {
        toolbarPosition = self._toolbarPosition;
    }

    if (!subtoolbarPosition) {
        subtoolbarPosition = self._subtoolbarPosition;
    }

    [self _setToolbarPosition:toolbarPosition subtoolbarPosition:subtoolbarPosition];
}

- (void)_setToolbarPosition:(UXBarPosition)toolbarPosition subtoolbarPosition:(UXBarPosition)subtoolbarPosition {
    if (__toolbarPosition != toolbarPosition || __subtoolbarPosition != subtoolbarPosition) {
        __toolbarPosition = toolbarPosition;
        __subtoolbarPosition = subtoolbarPosition;
        [self invalidateIntrinsicLayoutInsets];
        [_toolbar _updateDecorationLine];
        [_subtoolbar _updateDecorationLine];
    }
}

- (void)_updateToolbarVisibilityUsingTopViewController:(UXViewController *)topViewController animated:(BOOL)animated duration:(NSTimeInterval)duration animateSubtree:(BOOL)animateSubtree {
    UXViewController *toolbarViewController = topViewController.toolbarViewController;
    BOOL hidesBottomBarWhenPushed = NO;

    if (toolbarViewController) {
        hidesBottomBarWhenPushed = !topViewController.hidesBottomBarWhenPushed;
    } else {
        if (topViewController.toolbarItems.count) {
            hidesBottomBarWhenPushed = !topViewController.hidesBottomBarWhenPushed;
        } else {
            hidesBottomBarWhenPushed = NO;
        }
    }

    [self _setToolbarHidden:!hidesBottomBarWhenPushed subtoolbarHidden:topViewController.subtoolbarItems.count == 0 animated:animated duration:duration animateSubtree:animateSubtree];
}

- (void)_updateToolbarAppearanceUsingTopViewController:(UXViewController *)topViewController animated:(BOOL)animated duration:(NSTimeInterval)duration {
    CGFloat preferredToolbarHeight = topViewController.preferredToolbarHeight;
    CGFloat toolbarHeight = self.toolbar.height;
    BOOL invalidPreferredToolbarHeight = NO;

    if (preferredToolbarHeight <= 0.0 || preferredToolbarHeight == toolbarHeight) {
        invalidPreferredToolbarHeight = YES;
    } else {
        invalidPreferredToolbarHeight = NO;
        self.toolbar.height = preferredToolbarHeight;
    }

    if (topViewController.preferredToolbarBaselineOffsetFromBottom > 0.0) {
        self.toolbar.baselineOffsetFromBottom = topViewController.preferredToolbarBaselineOffsetFromBottom;
    }

    if (topViewController.preferredSubtoolbarHeight > 0.0) {
        self.subtoolbar.height = topViewController.preferredSubtoolbarHeight;
    }

    if (topViewController.preferredSubtoolbarBaselineOffsetFromBottom > 0.0) {
        self.subtoolbar.baselineOffsetFromBottom = topViewController.preferredSubtoolbarBaselineOffsetFromBottom;
    }

    NSEdgeInsets layoutMargins = topViewController.navigationItem.layoutMargins;
    self.toolbar.layoutMargins = layoutMargins;
    self.subtoolbar.layoutMargins = layoutMargins;
    NSInteger preferredToolbarStyle = topViewController.preferredToolbarStyle;
    NSColor *backgroundColor = nil;
    NSColor *toolbarBorderColor = nil;
    NSColor *subtoolbarBorderColor = nil;
    BOOL subtoolbarBlurEnabled = NO;

    if (preferredToolbarStyle) {
        NSEdgeInsets preferredToolbarDecorationInsets = topViewController.preferredToolbarDecorationInsets;

        if (preferredToolbarStyle == 1) {
            [self.toolbarVisualEffectsView removeFromSuperview];
            [self.subtoolbarVisualEffectsView removeFromSuperview];
            self.toolbar.blurEnabled = YES;
            self.toolbar.blurMaterial = NSVisualEffectMaterialHeaderView;
            toolbarBorderColor = [NSColor colorWithSRGBRed:0.0 green:0.0 blue:0.0 alpha:0.15];
            backgroundColor = [NSColor clearColor];
            subtoolbarBlurEnabled = YES;
        } else {
            if (preferredToolbarStyle == 2) {
                if (!self.toolbarVisualEffectsView.superview) {
                    CGRect toolbarBounds = self.toolbar.bounds;
                    self.toolbarVisualEffectsView.frame = toolbarBounds;
                    [self.toolbar addSubview:self.toolbarVisualEffectsView positioned:NSWindowBelow relativeTo:nil];
                }

                if (!self.subtoolbarVisualEffectsView.superview) {
                    self.subtoolbarVisualEffectsView.frame = self.subtoolbar.bounds;
                    [self.subtoolbar addSubview:self.subtoolbarVisualEffectsView positioned:NSWindowBelow relativeTo:nil];
                }

                backgroundColor = NSColor.clearColor;
                subtoolbarBorderColor = NSColor.quaternaryLabelColor;
            }

            self.toolbar.blurEnabled = NO;
            subtoolbarBlurEnabled = NO;
        }

        [self.toolbar setBackgroundColor:backgroundColor];
        self.toolbar.borderColor = toolbarBorderColor;
        self.toolbar.bordered = toolbarBorderColor != nil;
        self.toolbar.decorationInsets = preferredToolbarDecorationInsets;
        self.subtoolbar.blurEnabled = subtoolbarBlurEnabled;
        [self.subtoolbar setBackgroundColor:backgroundColor];
        self.subtoolbar.borderColor = subtoolbarBorderColor;
        self.subtoolbar.bordered = subtoolbarBorderColor != nil;
        self.subtoolbar.decorationInsets = preferredToolbarDecorationInsets;
        self.toolbarExtendedBackgroundView.hidden = subtoolbarBlurEnabled;
    } else {
        self.toolbarExtendedBackgroundView.hidden = YES;
        [self.toolbarVisualEffectsView removeFromSuperview];
        [self.subtoolbarVisualEffectsView removeFromSuperview];
    }

    if (!(invalidPreferredToolbarHeight || !animated)) {
        [UXView animateWithDuration:duration
                         animations:^{
            [self.toolbar layoutSubtreeIfNeeded];
            [self.subtoolbar layoutSubtreeIfNeeded];
        }];
    }
}

- (void)_addConstraintsForContainedView:(UXView *)containedView leftInset:(CGFloat)leftInset {
    containedView.translatesAutoresizingMaskIntoConstraints = NO;

    _topViewControllerLeftConstraint = [NSLayoutConstraint constraintWithItem:containedView attribute:(NSLayoutAttributeLeading) relatedBy:(NSLayoutRelationEqual) toItem:self.containerView attribute:(NSLayoutAttributeLeading) multiplier:1.0 constant:leftInset];
    [self.containerView addConstraint:_topViewControllerLeftConstraint];

    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                             options:(NSLayoutFormatDirectionLeadingToTrailing)
                                                                             metrics:nil
                                                                               views:@{
                                          @"view": containedView,
    }]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:containedView attribute:(NSLayoutAttributeTrailing) relatedBy:(NSLayoutRelationEqual) toItem:self.containerView attribute:(NSLayoutAttributeTrailing) multiplier:1.0 constant:0.0]];
    [self.containerView addConstraints:constraints];
    _topViewControllerOtherConstraints = constraints;
}

- (void)_beginObservingCurrentTopViewController {
    UXViewController *currentTopViewController = self.currentTopViewController;

    if (_observedViewController != currentTopViewController) {
        [self _endObservingCurrentTopViewController];
        _observedViewController = currentTopViewController;
        [[[self class] topViewControllerObservationKeyPathsByContext] enumerateKeysAndObjectsUsingBlock:^(NSValue *_Nonnull context, NSArray<NSString *> *_Nonnull keyPaths, BOOL *_Nonnull stop) {
            for (NSString *keyPath in keyPaths) {
                [currentTopViewController addObserver:self
                                           forKeyPath:keyPath
                                              options:0
                                              context:context.pointerValue];
            }
        }];
        [self performToolbarsChanges:^{
            [self setShouldAnimateToolbarsChanges];
            [self _invalidateToolbarItems];
            [self _invalidateSubtoolbarItems];
            [self _invalidateToolbarsPositions];
            [self _invalidateToolbarsAppearance];
        }];
    }
}

- (void)_invalidateToolbarItems {
    _toolbarsNeedUpdateFlags.toolbarItems = YES;
    [self _invalidateToolbarsVisibility];
    [self _invalidateToolbarsAppearance];
}

- (void)_invalidateToolbarsVisibility {
    _toolbarsNeedUpdateFlags.visibility = YES;
    [self _setToolbarsNeedUpdate];
}

- (void)_setToolbarsNeedUpdate {
    if (!_isPerformingToolbarsChanges) {
        NSAssert(false, @"not within a _performToolbarsChanges: block");
    }
}

- (void)_invalidateToolbarsAppearance {
    _toolbarsNeedUpdateFlags.appearance = YES;
    [self _setToolbarsNeedUpdate];
}

- (void)_invalidateSubtoolbarItems {
    _toolbarsNeedUpdateFlags.subtoolbarItems = YES;
    [self _invalidateToolbarsVisibility];
    [self _invalidateToolbarsAppearance];
}

- (void)_invalidateToolbarsPositions {
    _toolbarsNeedUpdateFlags.positions = YES;
    [self _setToolbarsNeedUpdate];
}

- (BOOL)_requiresWindowForTransitionPreparation {
    if (self.currentTopViewController) {
        return [self.currentTopViewController _requiresWindowForTransitionPreparation];
    } else {
        return [super _requiresWindowForTransitionPreparation];
    }
}

- (void)_prepareForAnimationInContext:(id)context completion:(void (^)(void))completion {
    if (self.currentTopViewController) {
        [self.currentTopViewController _prepareForAnimationInContext:context completion:completion];
    } else {
        [super _prepareForAnimationInContext:context completion:completion];
    }
}

- (id)contentRepresentingViewController {
    return self.topViewController.contentRepresentingViewController;
}

- (UXViewController *)topViewController {
    return _targetViewControllers.lastObject;
}

- (void)goBackWithMenuItem:(NSMenuItem *)menuItem {
    UXViewController *viewController = self.viewControllers[menuItem.tag];

    if ([viewController isKindOfClass:[UXViewController class]]) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            [self popToViewController:viewController
                             animated:YES];
        }];
    }
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
    [menu removeAllItems];
    __block UXViewController *currentViewController = nil;
    [self.viewControllers enumerateObjectsWithOptions:(NSEnumerationReverse)
                                           usingBlock:^(UXViewController *_Nonnull viewController, NSUInteger idx, BOOL *_Nonnull stop) {
        if (self.topViewController != viewController) {
            NSString *title = nil;

            if ([currentViewController respondsToSelector:@selector(navigationItem)]) {
                title = currentViewController.navigationItem.backBarButtonItem.title;

                if (title) {
                    //FIXME: - keyEquivalent
                    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:title
                                                                      action:@selector(goBackWithMenuItem:)
                                                               keyEquivalent:@""];
                    menuItem.tag = idx;
                    [menu addItem:menuItem];
                }
            }

            if ([viewController respondsToSelector:@selector(navigationItem)] && ((title = viewController.navigationItem.title) || (title = viewController.title))) {
                if (title) {
                    //FIXME: - keyEquivalent
                    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:title
                                                                      action:@selector(goBackWithMenuItem:)
                                                               keyEquivalent:@""];
                    menuItem.tag = idx;
                    [menu addItem:menuItem];
                }
            }
        }

        currentViewController = viewController;
    }];
}

- (NSResponder *)nextResponderForToolbar:(UXToolbar *)toolbar {
    return self.topViewController;
}

- (UXBarButtonItem *)_backItemWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    UXBarButtonItem *backButtonItem = nil;

    if (self.isViewLoaded && [self.view.tintColor isEqual:NSColor.controlTextColor]) {
        NSString *symbolName = nil;

        if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
            symbolName = @"chevron.right";
        } else {
            symbolName = @"chevron.left";
        }

        UXBackButton *backButton = [UXBackButton new];
        backButton.image = [NSImage imageWithSystemSymbolName:symbolName accessibilityDescription:nil];
        backButton.title = title;
        backButton.target = target;
        backButton.action = action;
        NSControlSize controlSize;

        if (self.isNavigationBarDetached) {
            controlSize = NSControlSizeLarge;
        } else {
            controlSize = NSControlSizeRegular;
        }

        backButton.controlSize = controlSize;
        backButton.hidesTitle = self._hidesBackTitles;

        if (self.isBackButtonMenuEnabled) {
            NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Back"];
            menu.delegate = self;
            [backButton setMenu:menu forSegment:0];
        }

        backButtonItem = [[UXBarButtonItem alloc] initWithCustomView:backButton];
    } else {
        backButtonItem = [[UXBarButtonItem alloc] initWithTitle:title style:0 target:target action:action];
        backButtonItem.image = self.navigationBar.backIndicatorImage;
    }

    backButtonItem._view.accessibilityRoleDescription = UXLocalizedString(@"UXBackButtonAXRoleDescription");
    return backButtonItem;
}

- (void)_addBackBarItemFromNavigationItem:(UXNavigationItem *)fromNavigationItem toNavigationItem:(UXNavigationItem *)toNavigationItem {
    NSString *title = nil;
    NSString *accessibilityLabel = nil;

    if (fromNavigationItem.title && fromNavigationItem.title.length) {
        title = fromNavigationItem.title;
        accessibilityLabel = [NSString stringWithValidatedFormat:UXLocalizedString(@"UXBackButtonAXLabelFormat") validFormatSpecifiers:@"%@" error:nil, fromNavigationItem.title];
    } else {
        title = UXLocalizedString(@"UXBackButtonTitle");
        accessibilityLabel = UXLocalizedString(@"UXBackButtonAXLabel");
    }

    UXBarButtonItem *backButtonItem = [self _backItemWithTitle:title target:self action:@selector(__back:)];
    toNavigationItem.backBarButtonItem = backButtonItem;
    toNavigationItem.backBarButtonItem.accessibilityLabel = accessibilityLabel;
    toNavigationItem.backBarButtonItem.label = UXLocalizedString(@"UXBackButtonTitle");
}

- (void)_setupLayoutGuidesForViewController:(UXViewController *)viewController {
    _UXLayoutSpacer *topLayoutGuide = (_UXLayoutSpacer *)viewController.topLayoutGuide;

    [topLayoutGuide _setUpDimensionConstraintWithLength:self.navigationBar.height + self.topLayoutGuide.length];
}

- (void)_handleInteractiveUpdateWithEvent:(NSEvent *)event {
    CGFloat scrollingDeltaX = fabs(event.scrollingDeltaX);
    CGFloat scrollingDeltaY = fabs(event.scrollingDeltaY);

    if (scrollingDeltaX > scrollingDeltaY) {
        if (_interactivePopGestureRecognizer.isEnabled) {
            if (self.isTransitioning || !self.transitionCoordinator) {
                if (event.phase == NSEventPhaseBegan || event.phase == NSEventPhaseChanged) {
                    __block BOOL v11 = NO;
                    [event trackSwipeEventWithOptions:7
                             dampenAmountThresholdMin:-1.0
                                                  max:1.0
                                         usingHandler:^(CGFloat gestureAmount, NSEventPhase phase, BOOL isComplete, BOOL *_Nonnull stop) {
                        if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
                            gestureAmount = -gestureAmount;
                        }

                        if (!v11) {
                            if (gestureAmount <= 0.0) {
                                goto LABEL_17;
                            }

                            v11 = YES;
                            NSArray<UXViewController *> *currentViewControllers = self->_currentViewControllers;

                            if (currentViewControllers.count < 2 || self.isTransitioning) {
                                *stop = YES;
                                goto LABEL_17;
                            }

                            if (self->_delegateFlags.shouldBeginInteractivePopFromViewControllerToViewController) {
                                BOOL shouldBeginInteractivePop = [self.delegate navigationController:self
                                                         shouldBeginInteractivePopFromViewController:self.topViewController
                                                                                    toViewController:currentViewControllers[[currentViewControllers indexOfObject:self.topViewController] - 1]];

                                if (!shouldBeginInteractivePop) {
                                    *stop = YES;
                                    goto LABEL_17;
                                }
                            } else if (self->_delegateFlags.animationControllerForOperation) {
                                *stop = YES;
                                goto LABEL_17;
                            }

                            self->_isInteractive = YES;
                            [self popViewControllerAnimated:YES];
                            goto LABEL_17;
                        }

                        BOOL transitionIsInFlight = self.currentTransitionContext.transitionIsInFlight;

                        if (!transitionIsInFlight) {
                            goto LABEL_17;
                        }

                        if (self.currentTransitionContext && self.isTransitioning) {
                            if (self.isInteractive) {
                                [self.defaultTransitionController updateInteractiveTransition:gestureAmount
                                                                                    inContext:self.currentTransitionContext];
                                goto LABEL_17;
                            }
                        }

                        *stop = YES;
 LABEL_17:
                        {
                            BOOL v18 = YES;

                            if (v11) {
                                v18 = isComplete == NO;
                            }

                            if (!v18) {
                                CGFloat percentComplete = [self.defaultTransitionController percentComplete];

                                if (percentComplete > 0.3) {
                                    [self.currentTransitionContext finishInteractiveTransition];
                                } else {
                                    [self.currentTransitionContext cancelInteractiveTransition];
                                }

                                self->_isInteractive = NO;
                            }
                        }
                    }];
                }
            }
        }
    }
}

- (void)_setViewControllers:(NSArray<UXViewController *> *)viewControllers animated:(BOOL)animated {
    UXViewController *lastViewController = viewControllers.lastObject;
    auto block = ^{
        NSArray<UXViewController *> *currentViewControllers = [self->_currentViewControllers copy];

        for (UXViewController *viewController in currentViewControllers.reverseObjectEnumerator) {
            if (![viewController isEqual:lastViewController]) {
                UXNavigationItem *navigationItem = viewController.navigationItem;
                navigationItem.backBarButtonItem = nil;

                if ([viewControllers containsObject:viewController]) {
                    [viewController.viewIfLoaded removeFromSuperview];
                } else {
                    [viewController willMoveToParentViewController:nil];
                    [viewController.viewIfLoaded removeFromSuperview];
                    [viewController removeFromParentViewController];
                }

                [self->_currentViewControllers removeObject:viewController];
            }

            [self.navigationBar _popNavigationItem];
        }

        __block UXViewController *currentViewController = nil;

        for (UXViewController *viewController in viewControllers) {
            if ([viewController isEqual:lastViewController]) {
                [self.navigationBar _pushItem:viewController.navigationItem];
            } else {
                if (currentViewController) {
                    [self _addBackBarItemFromNavigationItem:currentViewController.navigationItem toNavigationItem:viewController.navigationItem];
                }

                [self.navigationBar _pushItem:viewController.navigationItem];

                if ([currentViewControllers containsObject:viewController] == NO) {
                    [viewController didMoveToParentViewController:self];
                }

                NSUInteger index = 0;

                if (self->_currentViewControllers.count) {
                    index = self->_currentViewControllers.count - 1;
                }

                [self->_currentViewControllers insertObject:viewController atIndex:index];
                currentViewController = viewController;
            }
        }
    };

    if ([self.currentTopViewController isEqual:lastViewController]) {
        block();
    } else {
        if (viewControllers.count >= 2) {
            UXViewController *provisionalPreviousViewController = [viewControllers objectAtIndex:viewControllers.count - 2];
            self.provisionalPreviousViewController = provisionalPreviousViewController;
        }

        if ([_currentViewControllers containsObject:lastViewController]) {
            NSUInteger defaultPopTransition = 0;

            if (animated) {
                defaultPopTransition = __defaultPopTransition;
            } else {
                defaultPopTransition = 102;
            }

            [self _popToViewController:lastViewController transition:defaultPopTransition];
        } else {
            NSUInteger defaultPushTransition = 0;

            if (animated) {
                defaultPushTransition = __defaultPushTransition;
            } else {
                defaultPushTransition = 102;
            }

            [self _pushViewController:lastViewController transition:defaultPushTransition];
        }

        [self.currentTransitionCoordinator animateAlongsideTransition:nil
                                                           completion:^(id<UXViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            block();
            self.provisionalPreviousViewController = nil;
        }];
    }
}

- (NSArray<__kindof UXViewController *> *)_popToViewController:(UXViewController *)viewController transition:(NSUInteger)transition {
    if (_currentViewControllers.count == 1) {
        NSLog(@"Application tried to pop when there is only one view on the stack");
        return nil;
    }

    NSUInteger indexOfViewController = [_currentViewControllers indexOfObjectIdenticalTo:viewController];

    if (indexOfViewController == NSNotFound) {
        NSLog(@"Application tried to pop to a view controller that isn't on the stack (%@)", viewController);
        return nil;
    }

    UXViewController *currentTopViewController = self.currentTopViewController;

    [self _endObservingCurrentTopViewController];
    NSMutableArray<__kindof UXViewController *> *result = [NSMutableArray array];
    [result addObject:self.currentTopViewController];
    NSUInteger index = _currentViewControllers.count - 2;
    NSUInteger targetIndex = indexOfViewController + 1;

    while (index >= targetIndex) {
        UXViewController *popViewController = _currentViewControllers[index];
        [popViewController willMoveToParentViewController:nil];
        [popViewController.view removeFromSuperview];
        [popViewController removeFromParentViewController];
        [_currentViewControllers removeObject:popViewController];
        [self.navigationBar _removeItem:popViewController.navigationItem];
        [result addObject:popViewController];
        --index;
    }
    self.currentTransitionContext = [self _contextForTransitionOperation:(UXNavigationControllerOperationPop) fromViewController:currentTopViewController toViewController:viewController transition:transition];

    if (self.currentTransitionContext) {
        [self _beginTransitionWithContext:self.currentTransitionContext operation:(UXNavigationControllerOperationPop)];
        [self _invalidateIntrinsicLayoutInsetsForViewController:viewController];
    }

    return result;
}

- (void)_removeAllNavigationRequests {
    [_navigationRequests removeAllObjects];
}

- (NSArray<__kindof UXViewController *> *)_checkinPopNavigationRequest:(_UXNavigationRequest *)navigationRequest {
    NSUInteger index = [_targetViewControllers indexOfObjectIdenticalTo:navigationRequest.viewController];

    if (index == NSNotFound) {
        NSLog(@"Tried to pop to a view controller that doesn't exist.");
        return nil;
    } else {
        NSUInteger location = index + 1;
        NSUInteger length = _targetViewControllers.count - location;
        NSArray<__kindof UXViewController *> *result = [_targetViewControllers subarrayWithRange:NSMakeRange(location, length)];
        [_navigationRequests addObject:navigationRequest];
        [_targetViewControllers removeObjectsInRange:NSMakeRange(location, length)];
        return result;
    }
}

- (UXViewController *)visibleViewController {
    NSViewController *lastPresentedViewController = self.presentedViewControllers.lastObject;

    if ([lastPresentedViewController isKindOfClass:[UXViewController class]]) {
        return (UXViewController *)lastPresentedViewController;
    } else {
        return self.topViewController;
    }
}

- (UXViewController *)popViewControllerAnimated:(BOOL)animated {
    NSUInteger targetViewControllersCount = _targetViewControllers.count;

    if (targetViewControllersCount < 2) {
        return nil;
    } else {
        UXViewController *toViewController = _targetViewControllers[targetViewControllersCount - 2];
        UXViewController *fromViewController = self.currentTopViewController;

        if (_delegateFlags.shouldPopFromViewControllerToViewController && self.delegate && fromViewController && toViewController  && ![self.delegate navigationController:self shouldPopFromViewController:fromViewController toViewController:toViewController]) {
            return nil;
        } else {
            return [self popToViewController:toViewController animated:animated].lastObject;
        }
    }
}

- (NSArray<__kindof UXViewController *> *)popToViewController:(UXViewController *)viewController animated:(BOOL)animated {
    _UXNavigationRequest *request = [_UXNavigationRequest popRequestWithViewController:viewController animated:animated];

    return [self _performOrEnqueueNavigationRequest:request];
}

- (nullable NSArray<__kindof UXViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    if (_targetViewControllers.count < 2) {
        return nil;
    } else {
        return [self popToViewController:_targetViewControllers.firstObject animated:animated];
    }
}

- (void)__back:(id)sender {
    UXViewController *popedViewController = [self popViewControllerAnimated:YES];

    if (!popedViewController) {
        if ([sender isKindOfClass:[NSSegmentedControl class]]) {
            NSSegmentedControl *segmentedControl = sender;
            [segmentedControl setSelected:NO forSegment:segmentedControl.selectedSegment];
        }
    }
}

- (NSGestureRecognizer *)interactivePopEventTracker {
    return self.interactivePopGestureRecognizer;
}

- (void)_setFullScreenMode:(BOOL)_fullScreenMode {
    __fullScreenMode = _fullScreenMode;
    self.accessoryBar.bordered = _fullScreenMode;
    [self.view setNeedsUpdateConstraints:YES];
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

- (void)setSubtoolbarHidden:(BOOL)subtoolbarHidden {
    [self _setToolbarHidden:self.isToolbarHidden subtoolbarHidden:subtoolbarHidden animated:NO duration:0.33 animateSubtree:YES];
}

- (void)_setAccessoryBarHidden:(BOOL)hidden {
    [self.accessoryBarContainer _setAccessoryBarHidden:hidden];
}

- (void)setViewControllers:(NSArray<UXViewController *> *)viewControllers {
    [self setViewControllers:viewControllers animated:NO];
}

- (NSArray<UXViewController *> *)viewControllers {
    return [_targetViewControllers copy];
}

- (void)setEdgesForExtendedLayout:(UXRectEdge)edgesForExtendedLayout {
    [super setEdgesForExtendedLayout:edgesForExtendedLayout];
    [self invalidateIntrinsicLayoutInsets];
    CGFloat top = 0.0;

    if (edgesForExtendedLayout & UXRectEdgeTop) {
        top = [self intrinsicLayoutInsets].top;
    }

    self.topConstraint.constant = top;
}

- (NSSize)preferredContentSize {
    if (self.currentTopViewController) {
        return [self.currentTopViewController preferredContentSize];
    } else {
        return [super preferredContentSize];
    }
}

- (void)moveToBeginningOfDocument:(id)sender {
    if (self.transitionCoordinator) {
        goto CallToSuperIfNeeded;
    }

    if (self.navigationBar.topItem.hidesBackButton) {
        goto CallToSuperIfNeeded;
    }

    if (self.viewControllers.count >= 2) {
        [self popViewControllerAnimated:YES];
        return;
    }

 CallToSuperIfNeeded:

    if ([self.superclass instancesRespondToSelector:_cmd]) {
        [super moveToBeginningOfDocument:sender];
    }
}

- (void)keyDown:(NSEvent *)event {
    BOOL v7 = 0;
    auto charactersIgnoringModifiers = event.charactersIgnoringModifiers;

    if (event.charactersIgnoringModifiers.length) {
        v7 = [charactersIgnoringModifiers characterAtIndex:0] == 63232;
    }

    if (event.isARepeat || ((event.modifierFlags & (NSEventModifierFlagShift | NSEventModifierFlagControl | NSEventModifierFlagOption)) != NSEventModifierFlagCommand) || !v7) {
        goto CallToSuperIfNeeded;
    }

    if (self.transitionCoordinator) {
        goto CallToSuperIfNeeded;
    }

    if (self.navigationBar.topItem.hidesBackButton) {
        goto CallToSuperIfNeeded;
    }

    if (self.viewControllers.count >= 2) {
        [self popViewControllerAnimated:YES];
        return;
    }

 CallToSuperIfNeeded:
    [super keyDown:event];
}

- (void)scrollWheel:(NSEvent *)event {
    [self _handleInteractiveUpdateWithEvent:event];
}

- (BOOL)wantsForwardedScrollEventsForAxis:(NSEventGestureAxis)axis {
    return axis == NSEventGestureAxisHorizontal;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if (context == UXToolbarItemsObservationContext) {
        [self performToolbarsChanges:^{
            [self _invalidateToolbarItems];
        }];
        return;
    }

    if (context == UXSubtoolbarItemsObservationContext) {
        [self performToolbarsChanges:^{
            [self _invalidateSubtoolbarItems];
        }];
        return;
    }

    if (context == UXToolbarPositionsObservationContext) {
        [self performToolbarsChanges:^{
            [self _invalidateToolbarsPositions];
        }];
        return;
    }

    if (context == UXToolbarAppearanceObservationContext) {
        [self performToolbarsChanges:^{
            [self _invalidateToolbarsAppearance];
        }];
        return;
    }

    if (context == UXAccessoryViewControllerObservationContext) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(accessoryViewController))];
        [self didChangeValueForKey:NSStringFromSelector(@selector(accessoryViewController))];
        return;
    }

    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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

- (void)testing_notifyTransitionAnimationDidComplete {
    auto testingTransitionAnimationCompletionHandler = self.testingTransitionAnimationCompletionHandler;

    if (testingTransitionAnimationCompletionHandler) {
        self.testingTransitionAnimationCompletionHandler = nil;
        testingTransitionAnimationCompletionHandler();
    }
}

- (void)testing_installTransitionAnimationCompletionHandler:(void (^)(void))handler {
    self.testingTransitionAnimationCompletionHandler = handler;
}

@end
