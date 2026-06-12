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

@implementation UXSourceController (Navigation)

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
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _navigateToDestination:destination animated:animated completion:^(BOOL finished) {
                if (completion) {
                    completion();
                }

                dispatch_semaphore_signal(semaphore);
            }];
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }];
}

- (void)navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated useFallbackDestinationIfNeeded:(BOOL)useFallbackDestinationIfNeeded completion:(UXCompletionHandler)completion {
    UXCompletionHandler innerCompletion = completion ?: ^{};
    [_viewControllerOperations addOperationWithBlock:^{
        dispatch_block_t completionBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
            innerCompletion();
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _navigateToDestination:destination animated:animated completion:^(BOOL finished) {
                if (!finished && useFallbackDestinationIfNeeded) {
                    [self _navigateToDestination:self.fallbackNavigationDestination animated:animated completion:^(BOOL fallbackFinished) {
                        completionBlock();
                    }];
                } else {
                    completionBlock();
                }
            }];
        });
        dispatch_block_wait(completionBlock, DISPATCH_TIME_FOREVER);
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
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _removeDestination:destination animated:animated completion:^(BOOL finished) {
                if (completion) {
                    completion();
                }

                dispatch_semaphore_signal(semaphore);
            }];
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
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

@end

#pragma clang diagnostic pop
