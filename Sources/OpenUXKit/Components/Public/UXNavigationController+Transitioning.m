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

@implementation UXNavigationController (Transitioning)

- (_UXViewControllerOneToOneTransitionContext *)_contextForTransitionOperation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController transition:(NSUInteger)transition {
    id<UXViewControllerInteractiveTransitioning> interactor = nil;
    id<UXViewControllerAnimatedTransitioning> animator = [self _customAnimationControllerForOperation:operation fromViewController:fromViewController toViewController:toViewController transition:transition];

    if (!animator) return nil;

    UXTransitionController *defaultTransitionController = self.defaultTransitionController;

    if (animator != defaultTransitionController) {
        interactor = [self _customInteractionControllerForAnimationController:animator transition:transition];
    } else {
        if (self.isInteractive) {
            interactor = self.defaultTransitionController;
        } else {
            interactor = [self _customInteractionControllerForAnimationController:animator transition:transition];
        }
    }

    [self _loadViewIfNotLoaded];
    [self.view layoutSubtreeIfNeeded];

    _UXViewControllerOneToOneTransitionContext *oneToOneTransitionContext = [_UXViewControllerOneToOneTransitionContext new];
    oneToOneTransitionContext.containerView = self.containerView;
    oneToOneTransitionContext.animated = transition != 102;
    oneToOneTransitionContext.animator = animator;
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
    _scopeBar.userInteractionEnabled = NO;
    _isTransitioning = YES;
    
    UXViewController *fromViewController = [context viewControllerForKey:UXTransitionContextFromViewControllerKey];
    UXViewController *toViewController = [context viewControllerForKey:UXTransitionContextToViewControllerKey];
    BOOL selfViewIsInResponderChainOfWindowFirstResponder = [self.view isInResponderChainOf:self.view.window.firstResponder];
    __weak typeof(self) weakSelf = self;
    __weak typeof(context) weakContext = context;
    auto setupContext = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        weakContext.duration = [weakContext.animator transitionDuration:weakContext];
        weakContext.completionHandler = ^(_UXViewControllerTransitionContext *innerContext, BOOL isEnded) {
            UXViewController *innerFromViewController = [innerContext viewControllerForKey:UXTransitionContextFromViewControllerKey];
            UXViewController *innerToViewController = [innerContext viewControllerForKey:UXTransitionContextToViewControllerKey];
            id<UXViewControllerAnimatedTransitioning> animator = innerContext.animator;

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
                CGRect finalFrame = [innerContext finalFrameForViewController:innerToViewController];
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
                    [strongSelf _addConstraintsForContainedView:innerFromViewController.uxView leftInset:[innerContext initialFrameForViewController:innerFromViewController].origin.x];
                    [innerToViewController removeFromParentViewController];
                    [strongSelf->_targetViewControllers removeLastObject];
                    [strongSelf->_currentViewControllers removeLastObject];
                } else {
                    removeFromSuperview(innerToViewController.view);
                    CGRect initialFrame = [innerContext initialFrameForViewController:innerFromViewController];
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
        [weakContext._transitionCoordinator animateAlongsideTransition:^(id<UXViewControllerTransitionCoordinatorContext>  _Nonnull innerContext) {
            BOOL isCancelled = innerContext.isCancelled;
            NSTimeInterval transitionDuration = innerContext.transitionDuration;

            if (innerContext.initiallyInteractive) {
                [weakSelf.navigationBar _completeInteractiveTransition:!isCancelled
                                                              duration:transitionDuration];
                [weakSelf.accessoryBar _completeInteractiveTransition:!isCancelled
                                                             duration:transitionDuration];
                [weakSelf.toolbar _completeInteractiveTransition:!isCancelled
                                                        duration:transitionDuration];

                if (isCancelled) {
                    BOOL fromHasAccessory = fromViewController.accessoryViewController || fromViewController.accessoryBarItems.count;

                    if (fromHasAccessory) {
                        BOOL toHasAccessory = toViewController.accessoryViewController || toViewController.accessoryBarItems.count;

                        if (!toHasAccessory) {
                            [weakSelf.accessoryBarContainer _setAccessoryBarHidden:YES];
                        }
                    }
                }

                [weakSelf _updateToolbarsPositionsUsingTopViewController:toViewController];
                [weakSelf _updateToolbarVisibilityUsingTopViewController:toViewController
                                                                animated:YES
                                                                duration:transitionDuration
                                                          animateSubtree:NO];
                [weakSelf _updateToolbarAppearanceUsingTopViewController:toViewController
                                                                animated:YES
                                                                duration:transitionDuration];
            } else {
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
            }

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
        context.interactiveUpdateHandler = ^(BOOL interactionIsOver, BOOL transitionCompleted, _UXViewControllerTransitionContext *innerContext, CGFloat percentComplete) {
            if (interactionIsOver) {
                setupContext();
                return;
            }

            CGFloat transition = fmax(percentComplete, 0.0);

            [weakSelf.navigationBar _updateInteractiveTransition:transition];
            [weakSelf.accessoryBar _updateInteractiveTransition:transition];
            [weakSelf.toolbar _updateInteractiveTransition:transition];
            UXViewController *toViewController = [innerContext viewControllerForKey:UXTransitionContextToViewControllerKey];
            UXViewController *toolbarViewController = toViewController.toolbarViewController;
            BOOL shouldHideToolbar = NO;

            if (toolbarViewController) {
                shouldHideToolbar = toViewController.hidesBottomBarWhenPushed;
            } else if (toViewController.toolbarItems.count) {
                shouldHideToolbar = toViewController.hidesBottomBarWhenPushed;
            }

            if (shouldHideToolbar) {
                if (!weakSelf.isToolbarHidden) {
                    weakSelf.toolbarVerticalConstraint.constant = weakSelf._hiddenToolbarOffset + (weakSelf._visibleToolbarOffset - weakSelf._hiddenToolbarOffset) * transition;
                }
            } else {
                if (weakSelf.isToolbarHidden) {
                    weakSelf.toolbarVerticalConstraint.constant = weakSelf._visibleToolbarOffset + (weakSelf._hiddenToolbarOffset - weakSelf._visibleToolbarOffset) * transition;
                }
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

- (id<UXViewControllerTransitionCoordinator>)transitionCoordinator {
    if (self.currentTransitionCoordinator) {
        return self.currentTransitionCoordinator;
    } else {
        return [super transitionCoordinator];
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

- (void)_prepareViewController:(UXViewController *)viewController forAnimationInContext:(_UXViewControllerOneToOneTransitionContext *)context completion:(void (^)(void))completion {
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
                [NSValue valueWithPointer:UXScopeBarItemsObservationContext]: @[
                    @"scopeBarItems",
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
            [self _invalidateScopeBarItems];
            [self _invalidateToolbarsPositions];
            [self _invalidateToolbarsAppearance];
        }];
    }
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

#pragma clang diagnostic pop
