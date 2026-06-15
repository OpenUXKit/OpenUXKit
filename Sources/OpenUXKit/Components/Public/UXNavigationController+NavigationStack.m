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

@implementation UXNavigationController (NavigationStack)

- (void)pushViewController:(UXViewController *)viewController animated:(BOOL)animated {
    _UXNavigationRequest *request = [_UXNavigationRequest pushRequestWithViewController:viewController animated:animated];

    [self _performOrEnqueueNavigationRequest:request];
}

- (NSArray<__kindof UXViewController *> *)_performOrEnqueueNavigationRequest:(_UXNavigationRequest *)navigationRequest {
    [self willChangeValueForKey:NSStringFromSelector(@selector(topViewController))];
    UXNavigationControllerOperation operation = navigationRequest.operation;
    BOOL hasPendingPopOperation = NO;
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
        hasPendingPopOperation = NO;
    } else {
        if (operation == UXNavigationControllerOperationPush) {
            hasPendingPopOperation = hasOperation(UXNavigationControllerOperationPop);
            [self _checkinPushNavigationRequest:navigationRequest];
        } else {
            if (!operation) {
                [self _checkinSetNavigationRequest:navigationRequest];
            }

            hasPendingPopOperation = NO;
        }

        result = nil;
    }

    [self didChangeValueForKey:NSStringFromSelector(@selector(topViewController))];

    id<UXViewControllerTransitionCoordinator> currentTransitionCoordinator = self.currentTransitionCoordinator;

    if (!currentTransitionCoordinator && !hasPendingPopOperation) {
        [navigationRequest setupContainmentIfNeededInParentViewController:self];
    }

    if (_navigationRequests.count == 1) {
        if (currentTransitionCoordinator) {
            [currentTransitionCoordinator animateAlongsideTransition:nil
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
                UXNavigationControllerTransition defaultPopTransition = UXNavigationControllerTransitionNone;

                if (navigationRequest.animated) {
                    defaultPopTransition = __defaultPopTransition;
                } else {
                    defaultPopTransition = UXNavigationControllerTransitionNone;
                }

                result = [self _popToViewController:navigationRequest.viewController transition:defaultPopTransition];
            }
            break;

            case UXNavigationControllerOperationPush: {
                UXNavigationControllerTransition defaultPushTransition = UXNavigationControllerTransitionNone;

                if (navigationRequest.animated) {
                    defaultPushTransition = __defaultPushTransition;
                } else {
                    defaultPushTransition = UXNavigationControllerTransitionNone;
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

- (void)_pushViewController:(UXViewController *)viewController transition:(UXNavigationControllerTransition)transition {
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

    _UXViewControllerOneToOneTransitionContext *context = [self _contextForTransitionOperation:(UXNavigationControllerOperationPush) fromViewController:currentTopViewController toViewController:viewController transition:transition];
    self.currentTransitionContext = context;

    if (self.currentTransitionContext) {
        [self _beginTransitionWithContext:self.currentTransitionContext operation:(UXNavigationControllerOperationPush)];
        [self _invalidateIntrinsicLayoutInsetsForViewController:viewController];
    }
}

- (BOOL)_hasNoNavigationRequests {
    return _navigationRequests.count == 0;
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

- (void)_handleInteractiveUpdateWithEvent:(NSEvent *)event {
    CGFloat scrollingDeltaX = fabs(event.scrollingDeltaX);
    CGFloat scrollingDeltaY = fabs(event.scrollingDeltaY);

    if (scrollingDeltaX > scrollingDeltaY) {
        if (_interactivePopGestureRecognizer.isEnabled) {
            if (self.isTransitioning || !self.transitionCoordinator) {
                if (event.phase == NSEventPhaseBegan || event.phase == NSEventPhaseChanged) {
                    __block BOOL hasBegunInteractivePop = NO;
                    [event trackSwipeEventWithOptions:7
                             dampenAmountThresholdMin:-1.0
                                                  max:1.0
                                         usingHandler:^(CGFloat gestureAmount, NSEventPhase phase, BOOL isComplete, BOOL *_Nonnull stop) {
                        if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
                            gestureAmount = -gestureAmount;
                        }

                        if (!hasBegunInteractivePop) {
                            if (gestureAmount > 0.0) {
                                hasBegunInteractivePop = YES;
                                NSArray<UXViewController *> *currentViewControllers = self->_currentViewControllers;

                                if (currentViewControllers.count < 2 || self.isTransitioning) {
                                    *stop = YES;
                                } else if (self->_delegateFlags.shouldBeginInteractivePopFromViewControllerToViewController) {
                                    BOOL shouldBeginInteractivePop = [self.delegate navigationController:self
                                                             shouldBeginInteractivePopFromViewController:self.topViewController
                                                                                        toViewController:currentViewControllers[[currentViewControllers indexOfObject:self.topViewController] - 1]];

                                    if (!shouldBeginInteractivePop) {
                                        *stop = YES;
                                    } else {
                                        self->_isInteractive = YES;
                                        [self popViewControllerAnimated:YES];
                                    }
                                } else if (self->_delegateFlags.animationControllerForOperation) {
                                    *stop = YES;
                                } else {
                                    self->_isInteractive = YES;
                                    [self popViewControllerAnimated:YES];
                                }
                            }
                        } else {
                            BOOL transitionIsInFlight = self.currentTransitionContext.transitionIsInFlight;

                            if (transitionIsInFlight && self.currentTransitionContext && self.isTransitioning && self.isInteractive) {
                                [self.defaultTransitionController updateInteractiveTransition:gestureAmount
                                                                                    inContext:self.currentTransitionContext];
                            } else if (transitionIsInFlight) {
                                *stop = YES;
                            }
                        }

                        if (hasBegunInteractivePop && isComplete) {
                            CGFloat percentComplete = [self.defaultTransitionController percentComplete];

                            if (percentComplete > 0.3) {
                                [self.currentTransitionContext finishInteractiveTransition];
                            } else {
                                [self.currentTransitionContext cancelInteractiveTransition];
                            }

                            self->_isInteractive = NO;
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
            UXNavigationControllerTransition defaultPopTransition = UXNavigationControllerTransitionNone;

            if (animated) {
                defaultPopTransition = __defaultPopTransition;
            } else {
                defaultPopTransition = UXNavigationControllerTransitionNone;
            }

            [self _popToViewController:lastViewController transition:defaultPopTransition];
        } else {
            UXNavigationControllerTransition defaultPushTransition = UXNavigationControllerTransitionNone;

            if (animated) {
                defaultPushTransition = __defaultPushTransition;
            } else {
                defaultPushTransition = UXNavigationControllerTransitionNone;
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

- (NSArray<__kindof UXViewController *> *)_popToViewController:(UXViewController *)viewController transition:(UXNavigationControllerTransition)transition {
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

- (UXViewController *)popViewControllerAnimated:(BOOL)animated {
    NSUInteger targetViewControllersCount = _targetViewControllers.count;

    if (targetViewControllersCount < 2) {
        NSLog(@"WARNING YOU ARE ATTEMPTING TO POP FROM A NAVIGATION STACK CONTAINING ONLY 1 VIEWCONTROLLER %s", __PRETTY_FUNCTION__);
        return nil;
    } else {
        UXViewController *toViewController = _targetViewControllers[targetViewControllersCount - 2];
        UXViewController *fromViewController = self.currentTopViewController;

        if (_delegateFlags.shouldPopFromViewControllerToViewController && self.delegate && fromViewController && toViewController && ![self.delegate navigationController:self shouldPopFromViewController:fromViewController toViewController:toViewController]) {
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

- (void)moveToBeginningOfDocument:(id)sender {
    if (!self.transitionCoordinator && !self.navigationBar.topItem.hidesBackButton && self.viewControllers.count >= 2) {
        [self popViewControllerAnimated:YES];
        return;
    }

    if ([self.superclass instancesRespondToSelector:_cmd]) {
        [super moveToBeginningOfDocument:sender];
    }
}

- (void)keyDown:(NSEvent *)event {
    BOOL isUpArrowKey = NO;
    auto charactersIgnoringModifiers = event.charactersIgnoringModifiers;

    if (charactersIgnoringModifiers.length) {
        isUpArrowKey = [charactersIgnoringModifiers characterAtIndex:0] == NSUpArrowFunctionKey;
    }

    NSEventModifierFlags modifierMask = NSEventModifierFlagShift | NSEventModifierFlagControl | NSEventModifierFlagOption | NSEventModifierFlagCommand;

    if (!event.isARepeat
        && (event.modifierFlags & modifierMask) == NSEventModifierFlagCommand
        && isUpArrowKey
        && !self.transitionCoordinator
        && !self.navigationBar.topItem.hidesBackButton
        && self.viewControllers.count >= 2) {
        [self popViewControllerAnimated:YES];
        return;
    }

    [super keyDown:event];
}

- (void)scrollWheel:(NSEvent *)event {
    [self _handleInteractiveUpdateWithEvent:event];
}

- (BOOL)wantsForwardedScrollEventsForAxis:(NSEventGestureAxis)axis {
    return axis == NSEventGestureAxisHorizontal;
}

- (void)_popTransitoryViewControllersAnimated:(BOOL)animated {
    UXViewController *previousViewController = nil;

    for (UXViewController *viewController in self.viewControllers) {
        if (previousViewController && viewController.isTransitory) {
            [self popToViewController:previousViewController animated:animated];
            return;
        }

        previousViewController = viewController;
    }
}

@end

#pragma clang diagnostic pop
