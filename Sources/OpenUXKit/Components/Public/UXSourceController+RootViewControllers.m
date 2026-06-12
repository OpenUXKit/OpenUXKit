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

@implementation UXSourceController (RootViewControllers)

- (void)setSelectedViewController:(UXViewController *)selectedViewController animated:(BOOL)animated {
    NSParameterAssert([self.rootViewControllers containsObject:selectedViewController]);
    [self _prepareTransitionToRootViewController:selectedViewController];
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

@end

#pragma clang diagnostic pop
