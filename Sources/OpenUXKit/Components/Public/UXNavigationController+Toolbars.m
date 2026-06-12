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

@implementation UXNavigationController (Toolbars)

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self _setToolbarHidden:hidden subtoolbarHidden:self.isSubtoolbarHidden scopeBarHidden:self.isScopeBarHidden animated:animated duration:0.33 animateSubtree:YES];
}

- (void)_setToolbarHidden:(BOOL)toolbarHidden subtoolbarHidden:(BOOL)subtoolbarHidden scopeBarHidden:(BOOL)scopeBarHidden animated:(BOOL)animated duration:(NSTimeInterval)duration animateSubtree:(BOOL)animateSubtree {
    BOOL currentToolbarHidden = _toolbarHidden;

    if (currentToolbarHidden == toolbarHidden) {
        currentToolbarHidden = toolbarHidden;

        if (_subtoolbarHidden == subtoolbarHidden && self->_scopeBarHidden == scopeBarHidden) {
            if (!self._toolbarNeedsVerticalOffsetUpdate) {
                return;
            }

            currentToolbarHidden = _toolbarHidden;
        }
    }

    BOOL previousSubtoolbarHidden = _subtoolbarHidden;
    BOOL previousScopeBarHidden = _scopeBarHidden;
    _toolbarHidden = toolbarHidden;
    _subtoolbarHidden = subtoolbarHidden;
    _scopeBarHidden = scopeBarHidden;

    auto completion = ^(BOOL finished) {
        self->_toolbar.hidden = self->_toolbarHidden;

        if (self->_subtoolbarHidden) {
            self->_subtoolbar.hidden = YES;
        } else {
            self->_subtoolbar.hidden = self->_toolbarHidden;
        }

        self->_scopeBar.hidden = self->_scopeBarHidden;
    };

    if (self.isViewLoaded) {
        self.toolbarVerticalConstraint.constant = self._toolbarVerticalOffset;
        self.scopeBarVerticalConstraint.constant = self._scopeBarVerticalOffset;

        if (animated) {
            if (currentToolbarHidden && !_toolbarHidden) {
                self.toolbar.hidden = NO;
            }

            if (previousSubtoolbarHidden && !_subtoolbarHidden) {
                self.subtoolbar.hidden = NO;
            }

            if (previousScopeBarHidden && !_scopeBarHidden) {
                UXToolbar *scopeBar = self.scopeBar;
                scopeBar.hidden = NO;
            }

            [UXView animateWithDuration:duration
                                  delay:0.0
                                options:(0x4000)
                             animations:^{
                if (!previousSubtoolbarHidden) {
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

- (void)detachToolbars {
    NSAssert(!self.isViewLoaded, @"detachToolbars must be called before the view is loaded");
    self.toolbarsDetached = YES;
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

- (NSLayoutConstraint *)_verticalLayoutConstraintForToolbar:(UXToolbar *)toolbar {
    CGFloat toolbarVerticalOffset = self._toolbarVerticalOffset;
    if (self._toolbarPosition == UXBarPositionTop) {
        NSLayoutAnchor *topAnchor = [toolbar topAnchor];
        NSLayoutAnchor *bottomAnchor;
        if (self.isNavigationBarDetached) {
            bottomAnchor = [self.topLayoutGuide bottomAnchor];
        } else {
            bottomAnchor = [self.navigationBar bottomAnchor];
        }
        return [topAnchor constraintEqualToAnchor:bottomAnchor constant:toolbarVerticalOffset];
    } else {
        NSLayoutAnchor *bottomAnchor = [toolbar bottomAnchor];
        NSLayoutAnchor *topAnchor = [self.bottomLayoutGuide topAnchor];
        return [bottomAnchor constraintEqualToAnchor:topAnchor constant:toolbarVerticalOffset];
    }
}

- (CGFloat)_toolbarVerticalOffset {
    if (_toolbarHidden) {
        return self._hiddenToolbarOffset;
    } else {
        return self._visibleToolbarOffset;
    }
}

- (CGFloat)_scopeBarVerticalOffset {
    CGFloat offset = 0.0;
    if (!_toolbarHidden) {
        offset += self.toolbar.height;
    }
    if (!_subtoolbarHidden) {
        offset += self.subtoolbar.height;
    }
    return offset;
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

    UXToolbar *scopeBar = self.scopeBar;
    if (!scopeBar.isHidden) {
        offset += multiplier * scopeBar.height;
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

- (BOOL)_toolbarNeedsVerticalOffsetUpdate {
    return self._toolbarVerticalOffset != self.toolbarVerticalConstraint.constant;
}

- (CGFloat)_navigationBarVerticalOffset {
    if (!_navigationBarHidden) {
        return 0.0;
    } else {
        return -self.navigationBar.height;
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

        if (_toolbarsNeedUpdateFlags.scopeBarItems) {
            _toolbarsNeedUpdateFlags.scopeBarItems = NO;
            [self.scopeBar setItems:_scopeBarItemsForViewController(currentTopViewController) animated:shouldAnimateToolbarUpdates];
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
           || _toolbarsNeedUpdateFlags.scopeBarItems
           || _toolbarsNeedUpdateFlags.positions
           || _toolbarsNeedUpdateFlags.visibility
           || _toolbarsNeedUpdateFlags.appearance;
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

    [self _setToolbarHidden:!hidesBottomBarWhenPushed subtoolbarHidden:topViewController.subtoolbarItems.count == 0 scopeBarHidden:topViewController.scopeBarItems.count == 0 animated:animated duration:duration animateSubtree:animateSubtree];
}

- (void)_updateToolbarAppearanceUsingTopViewController:(UXViewController *)topViewController animated:(BOOL)animated duration:(NSTimeInterval)duration {
    UXToolbar *toolbar = self.toolbar;
    UXToolbar *subtoolbar = self.subtoolbar;
    UXToolbar *scopeBar = self.scopeBar;

    BOOL toolbarHeightChanged = NO;
    CGFloat preferredToolbarHeight = topViewController.preferredToolbarHeight;

    if (preferredToolbarHeight > 0.0 && preferredToolbarHeight != toolbar.height) {
        toolbar.height = preferredToolbarHeight;
        toolbarHeightChanged = YES;
    }

    if (topViewController.preferredToolbarBaselineOffsetFromBottom > 0.0) {
        toolbar.baselineOffsetFromBottom = topViewController.preferredToolbarBaselineOffsetFromBottom;
    }

    CGFloat preferredSubtoolbarHeight = topViewController.preferredSubtoolbarHeight;

    if (preferredSubtoolbarHeight > 0.0 && preferredSubtoolbarHeight != subtoolbar.height) {
        subtoolbar.height = preferredSubtoolbarHeight;
    }

    if (topViewController.preferredSubtoolbarBaselineOffsetFromBottom > 0.0) {
        subtoolbar.baselineOffsetFromBottom = topViewController.preferredSubtoolbarBaselineOffsetFromBottom;
    }

    if (topViewController.preferredScopeBarHeight > 0.0) {
        scopeBar.height = topViewController.preferredScopeBarHeight;
    }

    if (topViewController.preferredScopeBarBaselineOffsetFromBottom > 0.0) {
        scopeBar.baselineOffsetFromBottom = topViewController.preferredScopeBarBaselineOffsetFromBottom;
    }

    NSEdgeInsets layoutMargins = topViewController.navigationItem.layoutMargins;
    toolbar.layoutMargins = layoutMargins;
    subtoolbar.layoutMargins = layoutMargins;
    scopeBar.layoutMargins = layoutMargins;

    // macOS 26 (Solarium / liquid glass) toolbar appearance: the bars are rendered with a
    // header-view blur material instead of a drawn border. The unified blur path is shared by
    // toolbar style 1 and the detached-bars layout; style 2 installs per-bar visual effect views.
    NSEdgeInsets decorationInsets = NSEdgeInsetsZero;
    NSColor *backgroundColor = nil;
    BOOL barsBlurEnabled = NO;
    BOOL skipColorUpdate = NO;
    BOOL toolbarsDetached = self.areToolbarsDetached;

    if (toolbarsDetached) {
        decorationInsets = topViewController.preferredToolbarDecorationInsets;
        backgroundColor = NSColor.clearColor;
        [self.toolbarVisualEffectsView removeFromSuperview];
        [self.subtoolbarVisualEffectsView removeFromSuperview];
        [self.scopeBarVisualEffectsView removeFromSuperview];
        toolbar.blurEnabled = NO;
        barsBlurEnabled = NO;
    } else {
        NSInteger preferredToolbarStyle = topViewController.preferredToolbarStyle;

        if (preferredToolbarStyle == 0) {
            self.toolbarExtendedBackgroundView.hidden = YES;
            [self.toolbarVisualEffectsView removeFromSuperview];
            [self.subtoolbarVisualEffectsView removeFromSuperview];
            [self.scopeBarVisualEffectsView removeFromSuperview];
            skipColorUpdate = YES;
        } else {
            decorationInsets = topViewController.preferredToolbarDecorationInsets;

            if (preferredToolbarStyle != 1) {
                if (preferredToolbarStyle == 2) {
                    if (!self.toolbarVisualEffectsView.superview) {
                        self.toolbarVisualEffectsView.frame = toolbar.bounds;
                        [toolbar addSubview:self.toolbarVisualEffectsView positioned:NSWindowBelow relativeTo:nil];
                    }

                    if (!self.subtoolbarVisualEffectsView.superview) {
                        self.subtoolbarVisualEffectsView.frame = subtoolbar.bounds;
                        [subtoolbar addSubview:self.subtoolbarVisualEffectsView positioned:NSWindowBelow relativeTo:nil];
                    }

                    if (!self.scopeBarVisualEffectsView.superview) {
                        self.scopeBarVisualEffectsView.frame = scopeBar.bounds;
                        [scopeBar addSubview:self.scopeBarVisualEffectsView positioned:NSWindowBelow relativeTo:nil];
                    }

                    backgroundColor = NSColor.clearColor;
                } else {
                    backgroundColor = nil;
                }

                toolbar.blurEnabled = NO;
                barsBlurEnabled = NO;
            } else {
                backgroundColor = NSColor.clearColor;
                [self.toolbarVisualEffectsView removeFromSuperview];
                [self.subtoolbarVisualEffectsView removeFromSuperview];
                [self.scopeBarVisualEffectsView removeFromSuperview];
                toolbar.blurEnabled = YES;
                toolbar.blurMaterial = NSVisualEffectMaterialHeaderView;
                subtoolbar.blurMaterial = NSVisualEffectMaterialHeaderView;
                scopeBar.blurMaterial = NSVisualEffectMaterialHeaderView;
                barsBlurEnabled = YES;
            }
        }
    }

    if (!skipColorUpdate) {
        [toolbar setBackgroundColor:backgroundColor];
        toolbar.borderColor = nil;
        toolbar.bordered = NO;
        toolbar.decorationInsets = decorationInsets;
        subtoolbar.blurEnabled = barsBlurEnabled;
        [subtoolbar setBackgroundColor:backgroundColor];
        subtoolbar.borderColor = nil;
        subtoolbar.bordered = NO;
        subtoolbar.decorationInsets = decorationInsets;
        scopeBar.blurEnabled = barsBlurEnabled;
        [scopeBar setBackgroundColor:backgroundColor];
        scopeBar.borderColor = nil;
        scopeBar.bordered = NO;
        scopeBar.decorationInsets = decorationInsets;
        self.toolbarExtendedBackgroundView.hidden = barsBlurEnabled;
    }

    if (animated && toolbarHeightChanged) {
        [UXView animateWithDuration:duration
                         animations:^{
            [toolbar layoutSubtreeIfNeeded];
            [subtoolbar layoutSubtreeIfNeeded];
            [scopeBar layoutSubtreeIfNeeded];
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

- (void)_invalidateScopeBarItems {
    _toolbarsNeedUpdateFlags.scopeBarItems = YES;
    [self _invalidateToolbarsVisibility];
    [self _invalidateToolbarsAppearance];
}

- (void)_invalidateToolbarsPositions {
    _toolbarsNeedUpdateFlags.positions = YES;
    [self _setToolbarsNeedUpdate];
}

- (NSResponder *)nextResponderForToolbar:(UXToolbar *)toolbar {
    return self.topViewController;
}

- (void)_setAccessoryBarHidden:(BOOL)hidden {
    [self.accessoryBarContainer _setAccessoryBarHidden:hidden];
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

    if (context == UXScopeBarItemsObservationContext) {
        [self performToolbarsChanges:^{
            [self _invalidateScopeBarItems];
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

- (void)_updateToolbarContainerConstraints {
    UXToolbar *toolbar = self.toolbar;
    UXToolbar *subtoolbar = self.subtoolbar;
    UXToolbar *scopeBar = self.scopeBar;
    self.detachedSubtoolbarTopConstraint.constant = toolbar.visibleHeight;
    self.detachedScopeBarTopConstraint.constant = toolbar.visibleHeight + subtoolbar.visibleHeight;
    self.detachedBarsContainerHeightConstraint.constant = toolbar.visibleHeight + subtoolbar.visibleHeight + scopeBar.visibleHeight;
}

@end

#pragma clang diagnostic pop
