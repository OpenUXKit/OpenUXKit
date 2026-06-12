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

@implementation UXSourceController (Sidebar)

- (CGFloat)_preferredSourceListWidth {
    CGFloat preferredThicknessFraction = self.sidebarSplitViewItem.preferredThicknessFraction;

    if (preferredThicknessFraction > 0.0) {
        CGFloat width = preferredThicknessFraction;

        if (self.isViewLoaded) {
            width = round(preferredThicknessFraction * CGRectGetWidth(self.view.bounds));
        }

        CGFloat minimumWidth = _sourceListViewController.sourceListMinimumWidth;
        CGFloat maximumWidth = _sourceListViewController.sourceListMaximumWidth;

        if (width < minimumWidth) {
            width = minimumWidth;
        }

        if (width > maximumWidth) {
            width = maximumWidth;
        }

        return width;
    }

    return preferredThicknessFraction;
}

- (void)_updateSplitViewAutosaveName {
    self.splitView.autosaveName = self.sourceListAutosaveName;
}

- (void)_setWantsSourceListCollapsed:(BOOL)wantsSourceListCollapsed {
    if (self.sidebarSplitViewItem.isCollapsed != wantsSourceListCollapsed) {
        self.sidebarSplitViewItem.collapsed = wantsSourceListCollapsed;
    }

    if (_wantsSourceListCollapsed != wantsSourceListCollapsed) {
        _wantsSourceListCollapsed = wantsSourceListCollapsed;
        [self _setLeadingContentInset:[self _leadingContentInsetForWantsCollapsed:wantsSourceListCollapsed]];
    }
}

- (void)_setWantsInspectorCollapsed:(BOOL)wantsInspectorCollapsed {
    if (self.inspectorSplitViewItem.isCollapsed != wantsInspectorCollapsed) {
        self.inspectorSplitViewItem.collapsed = wantsInspectorCollapsed;
    }
}

- (void)_setWantsSourceListCollapsed:(BOOL)wantsSourceListCollapsed wantsInspectorCollapsed:(BOOL)wantsInspectorCollapsed animated:(BOOL)animated completion:(UXCompletionHandler)completion {
    if (animated) {
        [UXView animateWithDuration:0.3
                              delay:0.0
                            options:0
                         animations:^{
            [self _setWantsSourceListCollapsed:wantsSourceListCollapsed];
            [self _setWantsInspectorCollapsed:wantsInspectorCollapsed];
        }
                         completion:^(BOOL finished) {
            [self _didChangeCollapsed];

            if (completion) {
                completion();
            }
        }];
    } else {
        [self _setWantsSourceListCollapsed:wantsSourceListCollapsed];
        [self _setWantsInspectorCollapsed:wantsInspectorCollapsed];
        [self _didChangeCollapsed];
    }
}

- (void)_didChangeCollapsed {
    NSWindow *window = self.view.window;

    if (self.sidebarSplitViewItem.isCollapsed) {
        BOOL inResponderChain = [self.sidebarSplitViewItem.viewController isInResponderChainOf:window.firstResponder];

        if (inResponderChain) {
            [window makeFirstResponder:self.preferredFirstResponder];
        }
    }
}

- (void)viewController:(UXViewController *)viewController changedSourceListCollapsed:(BOOL)changedSourceListCollapsed {
    if (viewController == self.selectedViewController && (changedSourceListCollapsed || self.sidebarSplitViewItem.isCollapsed)) {
        [self _setWantsSourceListCollapsed:changedSourceListCollapsed];
    }
}

- (BOOL)_wantsSourceListCollapsedForViewController:(UXViewController *)viewController {
    if (self.wantsSourceListHidden) {
        return YES;
    }

    return viewController.hidesSourceListWhenPushed;
}

- (BOOL)_wantsInspectorCollapsedForViewController:(UXViewController *)viewController {
    return viewController.hidesInspectorWhenPushed;
}

- (CGFloat)_leadingContentInsetForWantsCollapsed:(BOOL)wantsCollapsed {
    if (wantsCollapsed || UXSourceControllerSolariumEnabled() || self.isSourceListAutoCollapsed) {
        return 0.0;
    }

    if (self.isSourceListCollapsed) {
        return self.sourceListWidth + 1.0;
    }

    NSView *detailView = self.detailViewController.view;
    NSView *view = self.view;

    if (view.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        CGRect detailFrame = detailView.frame;
        CGPoint converted = [view convertPoint:CGPointMake(CGRectGetMaxX(detailFrame), 0.0) fromView:detailView];
        return CGRectGetWidth(view.frame) - converted.x;
    } else {
        CGPoint converted = [view convertPoint:CGPointZero fromView:detailView];
        return converted.x;
    }
}

- (void)_setLeadingContentInset:(CGFloat)leadingContentInset {
    for (UXNavigationController *navigationController in _navigationControllerByRootViewController.objectEnumerator) {
        [navigationController _setLeadingContentInset:leadingContentInset forViewController:navigationController.topViewController];
    }
}

- (CGSize)contentSizeForWantsSourceListCollapsed:(BOOL)wantsSourceListCollapsed {
    CGFloat leadingContentInset = [self _leadingContentInsetForWantsCollapsed:wantsSourceListCollapsed];
    return CGSizeMake(CGRectGetWidth(self.splitView.bounds) - leadingContentInset, 0.0);
}

- (void)_detailViewWidthDidChange {
    [self _setLeadingContentInset:[self _leadingContentInsetForWantsCollapsed:self.isSourceListCollapsed]];
}

- (void)_updateInspectorViewController {
    self.inspectorViewController.contentViewController = self.selectedNavigationController.inspectorViewController;
}

- (void)_updateDetailSplitViewItemAccessories {
    UXNavigationController *selectedNavigationController = self.selectedNavigationController;
    BOOL barsHidden = selectedNavigationController.isToolbarHidden && selectedNavigationController.isSubtoolbarHidden && selectedNavigationController.isScopeBarHidden;
    BOOL hasParent = self.detailSplitViewItemTopAccessoryViewController.parentViewController != nil;

    if (hasParent && barsHidden) {
        [self.detailSplitViewItemTopAccessoryViewController removeFromParentViewController];
    } else if (!barsHidden && !hasParent) {
        if (@available(macOS 26.0, *)) {
            [self.detailSplitViewItem addTopAlignedAccessoryViewController:(NSSplitViewItemAccessoryViewController *)self.detailSplitViewItemTopAccessoryViewController];
        }
    }

    self.detailSplitViewItemTopAccessoryViewController.view = selectedNavigationController.detachedBarsContainer;
}

- (void)_didChangeToolbarVisibilityForNavigationController:(UXNavigationController *)navigationController {
    if (self.selectedNavigationController == navigationController) {
        [self _updateDetailSplitViewItemAccessories];
    }
}

- (id<UXLayoutSupport>)topLayoutGuide {
    if (!_topLayoutGuide) {
        _UXLayoutSpacer *layoutSpacer = [_UXLayoutSpacer _verticalLayoutSpacer];
        @weakify(self);
        layoutSpacer.lengthUpdateBlock = ^{
            @strongify(self);
            [self didUpdateLayoutGuides];
        };
        _topLayoutGuide = layoutSpacer;
    }

    return _topLayoutGuide;
}

- (id<UXLayoutSupport>)bottomLayoutGuide {
    if (!_bottomLayoutGuide) {
        _UXLayoutSpacer *layoutSpacer = [_UXLayoutSpacer _verticalLayoutSpacer];
        @weakify(self);
        layoutSpacer.lengthUpdateBlock = ^{
            @strongify(self);
            [self didUpdateLayoutGuides];
        };
        _bottomLayoutGuide = layoutSpacer;
    }

    return _bottomLayoutGuide;
}

- (void)invalidateIntrinsicLayoutInsets {
    for (UXViewController *childViewController in self.childViewControllers) {
        if ([childViewController isKindOfClass:[UXViewController class]]) {
            if (childViewController.edgesForExtendedLayout & UXRectEdgeTop) {
                childViewController.topLayoutGuide.length = self.topLayoutGuide.length;
            }

            if (childViewController.edgesForExtendedLayout & UXRectEdgeBottom) {
                childViewController.bottomLayoutGuide.length = self.bottomLayoutGuide.length;
            }
        }
    }
}

- (NSResponder *)preferredFirstResponder {
    NSResponder *preferredFirstResponder = self.selectedNavigationController.preferredFirstResponder;

    if (!preferredFirstResponder) {
        preferredFirstResponder = self;
    }

    return preferredFirstResponder;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)toggleSidebar:(id)sender {
    _isTogglingSidebar = YES;
    [super toggleSidebar:sender];
    _isTogglingSidebar = NO;
    _wantsSourceListCollapsed = self.sidebarSplitViewItem.isCollapsed;
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item {
    BOOL valid = [super validateUserInterfaceItem:item];

    if (valid && item.action == @selector(toggleSidebar:)) {
        if (self.isSourceListCollapsed) {
            return !self.selectedNavigationController.topViewController.hidesSourceListWhenPushed;
        }

        return YES;
    }

    return valid;
}

- (CGRect)splitView:(NSSplitView *)splitView effectiveRect:(CGRect)proposedEffectiveRect forDrawnRect:(CGRect)drawnRect ofDividerAtIndex:(NSInteger)dividerIndex {
    CGRect effectiveRect = [super splitView:splitView effectiveRect:proposedEffectiveRect forDrawnRect:drawnRect ofDividerAtIndex:dividerIndex];

    if (dividerIndex == 1) {
        return CGRectZero;
    }

    return effectiveRect;
}

- (void)windowDidUpdateFirstResponder {
}

- (void)windowWillEnterFullScreen {
}

- (void)windowWillExitFullScreen {
}

- (void)windowDidRecalculateKeyViewLoop {
}

- (BOOL)isWindowInFullScreen {
    return self.detailViewController.isWindowInFullScreen;
}

- (BOOL)isWindowConsideredInFullScreen {
    return self.detailViewController.isWindowConsideredInFullScreen;
}

- (void)willMoveToParentViewController:(UXViewController *)parent {
}

- (void)didMoveToParentViewController:(UXViewController *)parent {
}

- (void)contentRepresentingViewControllerDidChange {
}

- (void)windowWillRecalculateKeyViewLoop {
}

- (void)didUpdateLayoutGuides {
}

@end

#pragma clang diagnostic pop
