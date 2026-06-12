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

static void *kFirstResponderObserverContext = &kFirstResponderObserverContext;
static void *kInspectorViewControllerObserverContext = &kInspectorViewControllerObserverContext;
static void *kCollapsedObserverContext = &kCollapsedObserverContext;

// Mirrors UXKit 26.4's _UXSolariumEnabled() == os_feature_enabled(SwiftUI, Solarium).
// When the macOS 26 Solarium ("liquid glass") appearance is active, the source list floats
// over the detail content, so the leading content inset collapses to zero.
extern bool _os_feature_enabled_impl(const char *domain, const char *feature);

BOOL UXSourceControllerSolariumEnabled(void) {
    static BOOL solariumEnabled = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        solariumEnabled = _os_feature_enabled_impl("SwiftUI", "Solarium");
    });
    return solariumEnabled;
}

BOOL UXSourceControllerShouldForceSelectionForNavigationDestination(id<UXNavigationDestination> destination) {
    id value = [destination.destinationAuxiliaryStore valueForKey:@"UXSourceControllerForceSelection" inNamespace:nil];

    if ([value isKindOfClass:[NSNumber class]]) {
        return [value boolValue];
    }

    return NO;
}

@implementation UXSourceController

@synthesize selectedViewController = _selectedViewController;

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _rootViewControllers = @[];
        _selectedNavigationViewConstraints = @[];
        _wantsSourceListCollapsed = NO;
        _needsToSetInitialSourceListWidth = YES;

        _detailViewController = [_UXDetailViewController new];
        _detailSplitViewItem = [NSSplitViewItem splitViewItemWithViewController:_detailViewController];
        _detailSplitViewItemTopAccessoryViewController = [NSTitlebarAccessoryViewController new];
        // macOS 26 visual APIs accessed dynamically for SDK compatibility:
        //   -[NSTitlebarAccessoryViewController setAutomaticallyAppliesContentInsets:]
        //   -[NSTitlebarAccessoryViewController setPreferredScrollEdgeEffectStyle:[NSScrollEdgeEffectStyle softStyle]]
        SEL setAutomaticallyAppliesContentInsetsSelector = NSSelectorFromString(@"setAutomaticallyAppliesContentInsets:");
        if ([_detailSplitViewItemTopAccessoryViewController respondsToSelector:setAutomaticallyAppliesContentInsetsSelector]) {
            ((void (*)(id, SEL, BOOL))objc_msgSend)(_detailSplitViewItemTopAccessoryViewController, setAutomaticallyAppliesContentInsetsSelector, NO);
        }
        Class scrollEdgeEffectStyleClass = NSClassFromString(@"NSScrollEdgeEffectStyle");
        SEL setPreferredScrollEdgeEffectStyleSelector = NSSelectorFromString(@"setPreferredScrollEdgeEffectStyle:");
        if (scrollEdgeEffectStyleClass && [_detailSplitViewItemTopAccessoryViewController respondsToSelector:setPreferredScrollEdgeEffectStyleSelector]) {
            id softStyle = ((id (*)(id, SEL))objc_msgSend)(scrollEdgeEffectStyleClass, NSSelectorFromString(@"softStyle"));
            ((void (*)(id, SEL, id))objc_msgSend)(_detailSplitViewItemTopAccessoryViewController, setPreferredScrollEdgeEffectStyleSelector, softStyle);
        }
        _detailSplitViewItemTopAccessoryViewController.view = [[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 500.0, 32.0)];
        if (@available(macOS 26.0, *)) {
            _detailSplitViewItem.automaticallyAdjustsSafeAreaInsets = YES;
        }
        _detailSplitViewItem.minimumThickness = 550.0;
        [self addSplitViewItem:_detailSplitViewItem];

        _inspectorViewController = [_UXInspectorViewController new];
        _inspectorSplitViewItem = [NSSplitViewItem inspectorWithViewController:_inspectorViewController];
        _inspectorSplitViewItem.canCollapse = NO;
        _inspectorSplitViewItem.collapsed = YES;
        [self addSplitViewItem:_inspectorSplitViewItem];

        _navigationControllerByRootViewController = [NSMapTable weakToStrongObjectsMapTable];
        _transitionControllerClassByToViewControllerClass = [NSMapTable weakToWeakObjectsMapTable];
        _viewControllerOperations = [NSOperationQueue new];
        _viewControllerOperations.maxConcurrentOperationCount = 1;
        _viewControllerOperations.qualityOfService = NSQualityOfServiceUserInitiated;
    }

    return self;
}

- (void)dealloc {
    self.observedWindow = nil;
    self.observedNavigationController = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.splitView.accessibilityIdentifier = @"UXSourceControllerSplitView";
}

- (void)viewWillAppear {
    [super viewWillAppear];

    if (_needsToSetInitialSourceListWidth) {
        if (self.splitViewItems.firstObject == self.sidebarSplitViewItem) {
            _needsToSetInitialSourceListWidth = NO;
            [self.splitView setPosition:[self _preferredSourceListWidth] ofDividerAtIndex:0];
            [self _updateSplitViewAutosaveName];
            self.inspectorSplitViewItem.collapsed = YES;
        }
    }
}

- (void)viewDidAppear {
    [super viewDidAppear];
    self.observedWindow = self.view.window;
    self.sidebarSplitViewItem.canCollapseFromWindowResize = YES;
}

- (void)viewWillDisappear {
    [super viewWillDisappear];
    self.observedWindow = nil;
}

#pragma mark - Source List

- (void)setSourceListViewController:(UXViewController<UXSourceList> *)sourceListViewController {
    if (_sourceListViewController != sourceListViewController) {
        if (_sourceListViewController) {
            NSAssert(self.sidebarSplitViewItem.viewController == _sourceListViewController, @"_sidebarSplitViewItem.viewController == _sourceListViewController");
            [_sourceListViewController willMoveToParentViewController:nil];
            [self.sidebarSplitViewItem removeObserver:self forKeyPath:@"collapsed" context:kCollapsedObserverContext];
            [self removeSplitViewItem:self.sidebarSplitViewItem];
        }

        _sourceListViewController = sourceListViewController;

        if (_sourceListViewController) {
            NSParameterAssert([_sourceListViewController conformsToProtocol:@protocol(UXSourceList)]);
            self.sidebarSplitViewItem = [NSSplitViewItem sidebarWithViewController:_sourceListViewController];
            self.sidebarSplitViewItem.preferredThicknessFraction = _sourceListViewController.sourceListPreferredWidthFraction;
            self.sidebarSplitViewItem.minimumThickness = _sourceListViewController.sourceListMinimumWidth;
            self.sidebarSplitViewItem.maximumThickness = _sourceListViewController.sourceListMaximumWidth;
            [self insertSplitViewItem:self.sidebarSplitViewItem atIndex:0];
            [_sourceListViewController didMoveToParentViewController:(UXViewController *)self];
            [self.sidebarSplitViewItem addObserver:self forKeyPath:@"collapsed" options:0 context:kCollapsedObserverContext];
            NSView *sourceListView = _sourceListViewController.view;
            CGRect frame = sourceListView.frame;
            frame.size.width = [self _preferredSourceListWidth];
            sourceListView.frame = frame;
        }
    }
}


- (CGFloat)sourceListWidth {
    return CGRectGetWidth(_sourceListViewController.viewIfLoaded.bounds);
}

- (void)setSourceListAutosaveName:(NSString *)sourceListAutosaveName {
    if (![_sourceListAutosaveName isEqualToString:sourceListAutosaveName]) {
        _sourceListAutosaveName = sourceListAutosaveName.copy;
        [self _updateSplitViewAutosaveName];
    }
}


#pragma mark - Collapse

- (BOOL)isSourceListCollapsed {
    return self.sidebarSplitViewItem.isCollapsed;
}

- (BOOL)isSourceListAutoCollapsed {
    return self.isSourceListCollapsed && !self.wantsSourceListCollapsed;
}

- (BOOL)wantsSourceListCollapsed {
    return _wantsSourceListCollapsed;
}

- (BOOL)wantsInspectorCollapsed {
    return self.inspectorSplitViewItem.isCollapsed;
}


#pragma mark - Inspector / Detail accessories


#pragma mark - Observed window / navigation controller

- (void)setObservedWindow:(NSWindow *)observedWindow {
    NSWindow *previousWindow = _observedWindow;

    if (previousWindow != observedWindow) {
        [previousWindow removeObserver:self forKeyPath:NSStringFromSelector(@selector(firstResponder)) context:kFirstResponderObserverContext];
        _observedWindow = observedWindow;
        [observedWindow addObserver:self forKeyPath:NSStringFromSelector(@selector(firstResponder)) options:0 context:kFirstResponderObserverContext];
    }
}

- (void)setObservedNavigationController:(UXNavigationController *)observedNavigationController {
    if (_observedNavigationController != observedNavigationController) {
        [_observedNavigationController removeObserver:self forKeyPath:NSStringFromSelector(@selector(inspectorViewController)) context:kInspectorViewControllerObserverContext];
        _observedNavigationController = observedNavigationController;
        [observedNavigationController addObserver:self forKeyPath:NSStringFromSelector(@selector(inspectorViewController)) options:0 context:kInspectorViewControllerObserverContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == kFirstResponderObserverContext) {
        [self windowDidUpdateFirstResponder];
    } else if (context == kInspectorViewControllerObserverContext) {
        [self _updateInspectorViewController];
    } else if (context == kCollapsedObserverContext) {
        NSSplitViewItem *sidebarSplitViewItem = self.sidebarSplitViewItem;
        BOOL wantsSourceListCollapsed = self.wantsSourceListCollapsed;
        NSUInteger pressedMouseButtons = NSEvent.pressedMouseButtons;

        if (!wantsSourceListCollapsed && sidebarSplitViewItem.isCollapsed && pressedMouseButtons != 1) {
            [NSRunLoop.currentRunLoop performBlock:^{
                [sidebarSplitViewItem setCollapsed:self.wantsSourceListCollapsed];
            }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Selection

- (UXViewController *)selectedViewController {
    return _selectedViewController;
}

- (void)setSelectedViewController:(UXViewController *)selectedViewController {
    [self setSelectedViewController:selectedViewController animated:NO];
}


- (UXNavigationController *)selectedNavigationController {
    return [_navigationControllerByRootViewController objectForKey:_selectedViewController];
}


#pragma mark - Root view controllers


#pragma mark - Navigation

- (id<UXNavigationDestination>)currentNavigationDestination {
    NSMutableArray<UXViewController *> *encounteredViewControllers = [NSMutableArray array];

    for (UXViewController *viewController in self.selectedNavigationController.viewControllers.reverseObjectEnumerator) {
        id<UXNavigationDestination> navigationDestination = viewController.navigationDestination;

        if (navigationDestination) {
            for (UXViewController *encounteredViewController in encounteredViewControllers.reverseObjectEnumerator) {
                [encounteredViewController willEncodeNavigationDestination:navigationDestination];
            }

            return navigationDestination;
        }

        [encounteredViewControllers addObject:viewController];
    }

    return nil;
}

- (BOOL)isNavigating {
    return _viewControllerOperations.operationCount != 0;
}


#pragma mark - Present / Dismiss


#pragma mark - Transition controllers


#pragma mark - UXNavigationControllerDelegate


#pragma mark - Layout guides / intrinsic insets


#pragma mark - Responder / transition coordinator


#pragma mark - Sidebar command


#pragma mark - Hooks


- (void)setSelectedNavigationViewConstraints:(NSArray *)selectedNavigationViewConstraints {
    if (![_selectedNavigationViewConstraints isEqualToArray:selectedNavigationViewConstraints]) {
        [NSLayoutConstraint deactivateConstraints:_selectedNavigationViewConstraints];
        _selectedNavigationViewConstraints = selectedNavigationViewConstraints.copy;
        [NSLayoutConstraint activateConstraints:_selectedNavigationViewConstraints];
    }
}

- (void)setSelectedNavigationTopViewController:(UXViewController *)selectedNavigationTopViewController {
    _selectedNavigationTopViewController = selectedNavigationTopViewController;
}

@end
