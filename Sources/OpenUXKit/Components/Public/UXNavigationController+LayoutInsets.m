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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation UXNavigationController (LayoutInsets)

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

- (void)addChildViewController:(NSViewController *)childViewController {
    [super addChildViewController:childViewController];

    if ([childViewController isKindOfClass:[UXViewController class]]) {
        [self _invalidateIntrinsicLayoutInsetsForViewController:(UXViewController *)childViewController];
    }
}

- (NSEdgeInsets)intrinsicLayoutInsets {
    return [self _intrinsicLayoutInsetsForChildViewController:self.currentTopViewController];
}

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
            BOOL fromHasAccessory = fromViewController.accessoryViewController || fromViewController.accessoryBarItems.count;

            if (fromHasAccessory) {
                UXViewController *toAccessoryViewController = toViewController.accessoryViewController;

                if (!toAccessoryViewController && !toViewController.accessoryBarItems.count) {
                    top = top - self.accessoryBarContainer._accessoryBarHeight;
                }
            }
        }

        if (toViewController == childViewController) {
            BOOL fromHasAccessory = fromViewController.accessoryViewController || fromViewController.accessoryBarItems.count;

            if (fromHasAccessory) {
                BOOL childHasAccessory = childViewController.accessoryViewController || childViewController.accessoryBarItems.count;

                if (!childHasAccessory) {
                    top = top - self.accessoryBarContainer._accessoryBarHeight;
                }
            }
        }
    }

    NSEdgeInsets toolbarInsets = [self _toolbarLayoutInsetsForChildViewController:childViewController];
    top = top + toolbarInsets.top;
    bottom = toolbarInsets.bottom;

    return NSEdgeInsetsMake(top, 0, bottom, 0);
}

- (NSEdgeInsets)_toolbarLayoutInsetsForChildViewController:(UXViewController *)childViewController {
    CGFloat top = 0.0;
    CGFloat bottom = 0.0;

    UXViewController *toolbarViewController = childViewController.toolbarViewController;
    BOOL hasToolbar = toolbarViewController || childViewController.toolbarItems.count;

    if (hasToolbar && !childViewController.hidesBottomBarWhenPushed) {
        CGFloat preferredToolbarHeight = childViewController.preferredToolbarHeight;

        if (preferredToolbarHeight == 0.0) {
            bottom = self.toolbar.height;
        } else {
            bottom = preferredToolbarHeight;
        }

        if (__toolbarPosition == UXBarPositionTop) {
            if (childViewController.edgesForExtendedLayout & UXRectEdgeTop) {
                top = top + bottom;
            }
        }

        if (__toolbarPosition == UXBarPositionBottom) {
            bottom = 0.0;
        }

        if (childViewController.subtoolbarItems.count) {
            UXBarPosition preferredSubtoolbarPosition = childViewController.preferredSubtoolbarPosition;
            CGFloat preferredSubtoolbarHeight = childViewController.preferredSubtoolbarHeight;

            if (!preferredSubtoolbarPosition) {
                preferredSubtoolbarPosition = self._subtoolbarPosition;
            }

            if (preferredSubtoolbarHeight == 0.0) {
                preferredSubtoolbarHeight = self.subtoolbar.height;
            }

            if (preferredSubtoolbarPosition != 10) {
                top = top + preferredSubtoolbarHeight;
            }
        }

        if (childViewController.scopeBarItems.count) {
            CGFloat preferredScopeBarHeight = childViewController.preferredScopeBarHeight;
            if (preferredScopeBarHeight == 0.0) {
                preferredScopeBarHeight = self.scopeBar.height;
            }
            top = top + preferredScopeBarHeight;
        }
    }

    return NSEdgeInsetsMake(top, 0, bottom, 0);
}

- (void)_setLeadingContentInset:(CGFloat)contentInset forViewController:(UXViewController *)viewController {
    if (__leadingContentInset != contentInset) {
        __leadingContentInset = contentInset;
    }

    if (viewController.hidesSourceListWhenPushed) {
        contentInset = 0.0;
    }

    if (_topViewControllerLeftConstraint.constant != contentInset) {
        _topViewControllerLeftConstraint.constant = contentInset;
        id<UXViewControllerTransitionCoordinator> transitionCoordinator = self.transitionCoordinator;

        BOOL shouldUpdateToolbarConstraintImmediately = NO;
        BOOL hasVisibleToolbar = NO;
        UXViewController *toolbarViewController = viewController.toolbarViewController;

        if (toolbarViewController) {
            hasVisibleToolbar = !viewController.hidesBottomBarWhenPushed;
        } else if (viewController.toolbarItems.count) {
            hasVisibleToolbar = !viewController.hidesBottomBarWhenPushed;
        }

        if (hasVisibleToolbar) {
            shouldUpdateToolbarConstraintImmediately = YES;
        } else {
            shouldUpdateToolbarConstraintImmediately = viewController.subtoolbarItems.count != 0;

            if (transitionCoordinator && !viewController.subtoolbarItems.count) {
                [transitionCoordinator animateAlongsideTransition:nil
                                                       completion:^(id<UXViewControllerTransitionCoordinatorContext> context) {
                    self.toolbarLeadingConstraint.constant = contentInset;
                }];
                return;
            }
        }

        self.toolbarLeadingConstraint.constant = contentInset;

        if (self.isToolbarHidden && self.isSubtoolbarHidden && shouldUpdateToolbarConstraintImmediately) {
            [self.view layoutSubtreeIfNeeded];
        }
    }
}

- (CGFloat)_leftContentInset {
    if (NSApp.userInterfaceLayoutDirection != NSUserInterfaceLayoutDirectionRightToLeft) {
        return __leadingContentInset;
    } else {
        return 0.0;
    }
}

- (void)_setupLayoutGuidesForViewController:(UXViewController *)viewController {
    _UXLayoutSpacer *topLayoutGuide = (_UXLayoutSpacer *)viewController.topLayoutGuide;

    [topLayoutGuide _setUpDimensionConstraintWithLength:self.navigationBar.height + self.topLayoutGuide.length];
}

- (void)_setFullScreenMode:(BOOL)_fullScreenMode {
    __fullScreenMode = _fullScreenMode;
    self.accessoryBar.bordered = _fullScreenMode;
    [self.view setNeedsUpdateConstraints:YES];
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

@end

#pragma clang diagnostic pop
