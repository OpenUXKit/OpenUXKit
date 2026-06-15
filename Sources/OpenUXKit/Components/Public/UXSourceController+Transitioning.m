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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation UXSourceController (Transitioning)

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

- (_UXViewControllerOneToOneTransitionContext *)_contextForTransitionOperation:(NSInteger)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController transition:(UXNavigationControllerTransition)transition {
    UXNavigationControllerTransition effectiveTransition = transition;

    if (fromViewController && toViewController) {
        if (fromViewController.view == toViewController.view) {
            effectiveTransition = UXNavigationControllerTransitionNone;
        }
    }

    _transitionController = [_transitionControllerClassForTransition(effectiveTransition) new];
    _transitionController.operation = operation;
    [self.view layoutSubtreeIfNeeded];

    NSSplitView *splitView = self.splitView;
    UXView *detailView = self.detailViewController.uxView;
    _UXViewControllerOneToOneTransitionContext *transitionContext = [_UXViewControllerOneToOneTransitionContext new];
    transitionContext.containerView = detailView;
    transitionContext.animated = transition != UXNavigationControllerTransitionNone;
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

- (id<UXViewControllerTransitionCoordinator>)transitionCoordinator {
    if (_isTransitioning) {
        return _transitionCtx._transitionCoordinator;
    }

    return nil;
}

- (NSViewController *)contentRepresentingViewController {
    return self.selectedNavigationController.topViewController.contentRepresentingViewController;
}

- (UXNavigationController *)navigationController {
    return self.selectedNavigationController;
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

@end

#pragma clang diagnostic pop
