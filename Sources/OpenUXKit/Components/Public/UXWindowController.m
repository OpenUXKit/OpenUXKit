#import <objc/message.h>
#import "UXWindowController+Internal.h"
#import <OpenUXKit/UXNavigationController.h>
#import "UXNavigationController+Internal.h"
#import <OpenUXKit/UXNavigationBar.h>
#import "UXNavigationBar+Internal.h"
#import <OpenUXKit/UXNavigationItem.h>
#import "UXNavigationItem+Internal.h"
#import <OpenUXKit/UXSourceController.h>
#import <OpenUXKit/UXViewController.h>
#import "UXViewController+Internal.h"
#import <OpenUXKit/UXViewControllerTransitionCoordinator.h>
#import "UXBar+Internal.h"
#import <OpenUXKit/UXToolbar.h>
#import "UXToolbar+Internal.h"
#import <OpenUXKit/UXWindowToolbarController.h>
#import "_UXWindow.h"
#import <OpenUXKit/NSResponder+UXKit.h>

void *UXWindowControllerContentLayoutRectContext = &UXWindowControllerContentLayoutRectContext;
void *UXWindowControllerToolbarNavigationItemContext = &UXWindowControllerToolbarNavigationItemContext;

@implementation UXWindowController

+ (NSWindow *)defaultWindow {
    return [[_UXWindow alloc] initWithContentRect:CGRectMake(0.0, 0.0, 512.0, 512.0)];
}

- (instancetype)initWithWindow:(NSWindow *)window {
    [NSException raise:@"Unable to initialize object"
                format:@"ERROR %@, cannot be initialized with a window, please use the designated initializer -[UXWindowController initWithRootViewController:]",
                       NSStringFromClass(self.class)];
    return nil;
}

- (instancetype)initWithRootViewController:(UXViewController *)rootViewController {
    NSParameterAssert(rootViewController);
    self = [super initWithWindow:[self.class defaultWindow]];
    if (self) {
        NSWindow *window = self.window;
        window.autorecalculatesKeyViewLoop = YES;
        window.delegate = self;
        NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"MainToolbar"];
        toolbar.delegate = self;
        toolbar.displayMode = NSToolbarDisplayModeIconOnly;
        window.toolbar = toolbar;
        self.rootViewController = rootViewController;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.rootViewController = nil;
    self.navigationBarToolbarItem = nil;
    self.window.delegate = nil;
    self.window = nil;
}

#pragma mark - Window

- (void)setWindow:(NSWindow *)window {
    NSWindow *previousWindow = self.window;
    if (previousWindow) {
        [previousWindow removeObserver:self
                            forKeyPath:@"contentLayoutRect"
                               context:UXWindowControllerContentLayoutRectContext];
    }
    [super setWindow:window];
    [self.window addObserver:self
                  forKeyPath:@"contentLayoutRect"
                     options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                     context:UXWindowControllerContentLayoutRectContext];
}

#pragma mark - Root view controller

- (UXViewController *)rootViewController {
    return (UXViewController *)self.window.contentViewController;
}

- (void)setRootViewController:(UXViewController *)rootViewController {
    NSWindow *window = self.window;
    NSView *contentView = window.contentView;
    rootViewController.view.frame = contentView.frame;
    window.contentViewController = rootViewController;
    rootViewController.topLayoutGuide.length = 0.0;

    if (UXNavigationController.useIndividualNSToolbarItems) {
        [self.rootNavigationController detachNavigationBar];
        if ([rootViewController isKindOfClass:[UXSourceController class]]) {
            [(UXSourceController *)rootViewController setWantsDetachedNavigationBars:YES];
        }
    } else {
        [self _setupNavigationBarToolbarItem];
    }

    [self _setupAccessoryBar];
    [self _updateFirstResponder];
}

- (UXNavigationController *)rootNavigationController {
    UXViewController *rootViewController = self.rootViewController;
    if ([rootViewController isKindOfClass:[UXNavigationController class]]) {
        return (UXNavigationController *)rootViewController;
    }
    if ([rootViewController isKindOfClass:[UXSourceController class]]) {
        UXViewController *selectedViewController = [(UXSourceController *)rootViewController selectedViewController];
        return [selectedViewController navigationController];
    }
    return nil;
}

#pragma mark - Titlebar accessory

- (NSTitlebarAccessoryViewController *)titlebarAccessoryViewController {
    if (!_titlebarAccessoryViewController) {
        _titlebarAccessoryViewController = [[NSTitlebarAccessoryViewController alloc] init];
        _titlebarAccessoryViewController.view = [[NSView alloc] initWithFrame:CGRectMake(0.0, 0.0, 500.0, 32.0)];
        if (@available(macOS 26.0, *)) {
            SEL setStyleSel = @selector(setPreferredScrollEdgeEffectStyle:);
            if ([_titlebarAccessoryViewController respondsToSelector:setStyleSel]) {
                NSInteger hardStyle = 2;
                ((void (*)(id, SEL, NSInteger))objc_msgSend)(_titlebarAccessoryViewController, setStyleSel, hardStyle);
            }
        }
    }
    return _titlebarAccessoryViewController;
}

#pragma mark - Accessory bar

- (void)_setupAccessoryBar {
    if (_currentAccessoryToolbar) {
        [_currentAccessoryToolbar removeFromSuperview];
    }
    UXNavigationController *rootNavigationController = self.rootNavigationController;
    rootNavigationController.accessoryBarContainer = self;
    _currentAccessoryToolbar = rootNavigationController.accessoryBar;
    if (_currentAccessoryToolbar) {
        UXToolbar *accessoryBar = _currentAccessoryToolbar;
        accessoryBar.bordered = (self.window.styleMask & NSWindowStyleMaskFullSizeContentView) != 0;
        accessoryBar.translatesAutoresizingMaskIntoConstraints = NO;
        NSView *accessoryView = self.titlebarAccessoryViewController.view;
        NSDictionary<NSString *, NSView *> *views = NSDictionaryOfVariableBindings(accessoryBar);
        [accessoryView addSubview:accessoryBar];
        [accessoryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[accessoryBar]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]];
        [accessoryView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[accessoryBar]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:views]];
        [self _setAccessoryBarHidden:rootNavigationController.isAccessoryBarHidden];
    }
}

- (void)_updateAccessoryBar {
    [self _setupAccessoryBar];
}

- (CGFloat)_accessoryBarHeight {
    return 32.0;
}

- (void)_setAccessoryBarHidden:(BOOL)hidden {
    NSWindow *window = self.window;
    NSArray<NSTitlebarAccessoryViewController *> *accessories = window.titlebarAccessoryViewControllers;
    NSTitlebarAccessoryViewController *accessory = self.titlebarAccessoryViewController;
    NSUInteger index = [accessories indexOfObject:accessory];
    CGFloat accessoryWidth = accessory.view.bounds.size.width;

    if (hidden) {
        if (index == NSNotFound) {
            return;
        }
        [window removeTitlebarAccessoryViewControllerAtIndex:index];
    } else {
        CGFloat height = [self _accessoryBarHeight];
        accessory.fullScreenMinHeight = height;
        [accessory.view setFrameSize:CGSizeMake(accessoryWidth, height)];
        if (index != NSNotFound) {
            return;
        }
        [window addTitlebarAccessoryViewController:accessory];
    }
}

#pragma mark - First responder

- (void)_updateFirstResponder {
    NSWindow *window = self.window;
    NSResponder *preferredFirstResponder = self.rootViewController.preferredFirstResponder;
    if ([window isInResponderChainOf:preferredFirstResponder] && [preferredFirstResponder acceptsFirstResponder]) {
        [window makeFirstResponder:preferredFirstResponder];
    }
}

#pragma mark - Toolbar plumbing

- (BOOL)_shouldUseToolbarViewForCentering {
    return NO;
}

- (void)_updateToolbarItems {
    if (UXNavigationController.useIndividualNSToolbarItems) {
        [self _updateToolbarNavigationItem];
    } else {
        [self _updateNavigationBarToolbarItem];
    }
}

- (void)_updateNavigationBarToolbarItem {
    [self _setupNavigationBarToolbarItem];
}

- (void)_setupNavigationBarToolbarItem {
    NSToolbarItem *navigationBarToolbarItem = self.navigationBarToolbarItem;
    UXNavigationController *rootNavigationController = self.rootNavigationController;
    UXNavigationBar *navigationBar = rootNavigationController.navigationBar;
    if (!navigationBar) {
        return;
    }
    [rootNavigationController detachNavigationBar];
    navigationBar.bordered = NO;
    navigationBar.backgroundColor = nil;
    navigationBar.translatesAutoresizingMaskIntoConstraints = NO;

    NSView *containerView = [[NSView alloc] init];
    [containerView addSubview:navigationBar];
    [NSLayoutConstraint activateConstraints:@[
        [navigationBar.topAnchor constraintEqualToAnchor:containerView.topAnchor],
        [navigationBar.leftAnchor constraintEqualToAnchor:containerView.leftAnchor],
        [navigationBar.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor],
        [navigationBar.rightAnchor constraintEqualToAnchor:containerView.rightAnchor],
    ]];
    navigationBarToolbarItem.view = containerView;
    NSWindow *window = self.window;
    navigationBar.nextResponder = (NSResponder *)navigationBarToolbarItem;

    if ([self _shouldUseToolbarViewForCentering]) {
        NSToolbar *toolbar = window.toolbar;
        if ([toolbar respondsToSelector:@selector(_toolbarView)]) {
            NSView *toolbarView = [toolbar valueForKey:@"_toolbarView"];
            rootNavigationController.navigationBar.titleCenteringTrackedView = toolbarView;
        }
    } else {
        rootNavigationController.navigationBar.titleCenteringTrackedView = navigationBar;
    }
    [rootNavigationController invalidateIntrinsicLayoutInsets];
}

- (void)_updateToolbarNavigationItem {
    NSAssert(UXNavigationController.useIndividualNSToolbarItems, @"UXNavigationController.useIndividualNSToolbarItems");
    UXNavigationController *rootNavigationController = self.rootNavigationController;
    UXSourceController *sourceController = (UXSourceController *)rootNavigationController.sourceController;
    [sourceController willUpdateToolbarForNavigationController:rootNavigationController];
    UXNavigationItem *navigationItem = rootNavigationController.topViewController.navigationItem;
    self.toolbarNavigationItem = navigationItem;
}

- (void)_updateToolbar {
    NSAssert(UXNavigationController.useIndividualNSToolbarItems, @"UXNavigationController.useIndividualNSToolbarItems");
    UXNavigationController *rootNavigationController = self.rootNavigationController;
    UXSourceController *sourceController = (UXSourceController *)rootNavigationController.sourceController;
    NSSearchToolbarItem *searchToolbarItem = sourceController.searchToolbarItem;

    if (_toolbarController) {
        _toolbarController.navigationItem = self.toolbarNavigationItem;
        _toolbarController.searchToolbarItem = searchToolbarItem;
        [_toolbarController updateToolbar];
    } else {
        _toolbarController = [[UXWindowToolbarController alloc] initWithNavigationItem:self.toolbarNavigationItem];
        _toolbarController.searchToolbarItem = searchToolbarItem;
        self.window.toolbar = _toolbarController.toolbar;
    }
}

- (UXNavigationItem *)toolbarNavigationItem {
    return _toolbarNavigationItem;
}

- (void)setToolbarNavigationItem:(UXNavigationItem *)toolbarNavigationItem {
    NSAssert(UXNavigationController.useIndividualNSToolbarItems, @"UXNavigationController.useIndividualNSToolbarItems");
    if (_toolbarNavigationItem == toolbarNavigationItem) {
        return;
    }
    NSArray<NSString *> *keyPaths = [UXNavigationItem keyPathsToObserve];
    for (NSString *keyPath in keyPaths) {
        [_toolbarNavigationItem removeObserver:self
                                    forKeyPath:keyPath
                                       context:UXWindowControllerToolbarNavigationItemContext];
    }
    _toolbarNavigationItem = toolbarNavigationItem;
    [self _updateToolbar];
    [self _updateWindowTitles];
    for (NSString *keyPath in keyPaths) {
        [_toolbarNavigationItem addObserver:self
                                 forKeyPath:keyPath
                                    options:NSKeyValueObservingOptionNew
                                    context:UXWindowControllerToolbarNavigationItemContext];
    }
}

- (void)_updateWindowTitles {
    NSWindow *window = self.window;
    UXNavigationItem *navigationItem = self.toolbarNavigationItem;
    if (navigationItem.useWindowForTitleOutput) {
        window.titleVisibility = NSWindowTitleVisible;
        window.title = navigationItem.title ?: @"";
        window.subtitle = navigationItem.subtitle ?: @"";
    } else {
        window.titleVisibility = NSWindowTitleHidden;
    }
}

#pragma mark - Teardown

- (void)_tearDownViewControllerHierarchyForViewController:(UXViewController *)viewController {
    for (NSViewController *child in viewController.childViewControllers.reverseObjectEnumerator) {
        [self _tearDownViewControllerHierarchyForViewController:(UXViewController *)child];
    }
    void (^teardown)(void) = ^{
        if (viewController.parentViewController) {
            [viewController willMoveToParentViewController:nil];
            [viewController removeFromParentViewController];
        }
    };
    id<UXViewControllerTransitionCoordinator> coordinator = viewController.transitionCoordinator;
    if (coordinator) {
        [coordinator animateAlongsideTransition:nil
                                     completion:^(id<UXViewControllerTransitionCoordinatorContext> context) {
            teardown();
        }];
    } else {
        teardown();
    }
}

- (void)teardownViewControllerHierarchy {
    UXViewController *rootViewController = self.rootViewController;
    [rootViewController willMoveToParentViewController:nil];
    [self _tearDownViewControllerHierarchyForViewController:rootViewController];
    [rootViewController didMoveToParentViewController:nil];
}

#pragma mark - NSToolbarDelegate

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    if (UXNavigationController.useIndividualNSToolbarItems) {
        return nil;
    }
    if (![itemIdentifier isEqualToString:@"NavigationBar"]) {
        return nil;
    }
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    item.maxSize = CGSizeMake(CGFLOAT_MAX, 31.0);
    item.minSize = CGSizeMake(31.0, 31.0);
    self.navigationBarToolbarItem = item;
    [self _setupNavigationBarToolbarItem];
    return item;
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    if (UXNavigationController.useIndividualNSToolbarItems) {
        return @[];
    }
    return @[@"NavigationBar"];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    if (UXNavigationController.useIndividualNSToolbarItems) {
        return @[];
    }
    return @[@"NavigationBar"];
}

#pragma mark - NSWindowDelegate

- (void)windowDidBecomeFirstResponder:(NSNotification *)notification {
    [self _updateFirstResponder];
}

- (void)windowDidRecalculateKeyViewLoop:(NSNotification *)notification {
    UXNavigationController *rootNavigationController = self.rootNavigationController;
    [rootNavigationController.navigationBar recalculateKeyViewLoop];
    [self.rootViewController windowDidRecalculateKeyViewLoop];
}

- (void)windowWillRecalculateKeyViewLoop:(NSNotification *)notification {
    [self.rootViewController windowWillRecalculateKeyViewLoop];
}

- (void)windowWillEnterFullScreen:(NSNotification *)notification {
    UXNavigationController *rootNavigationController = self.rootNavigationController;
    rootNavigationController._fullScreenMode = YES;
    [rootNavigationController invalidateIntrinsicLayoutInsets];
}

- (void)windowWillExitFullScreen:(NSNotification *)notification {
    UXNavigationController *rootNavigationController = self.rootNavigationController;
    rootNavigationController._fullScreenMode = NO;
    [rootNavigationController invalidateIntrinsicLayoutInsets];
}

- (void)windowDidChangeTitle:(NSNotification *)notification {
}

- (void)windowDidChangeSubtitle:(NSNotification *)notification {
}

- (CGRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(CGRect)rect {
    UXNavigationController *rootNavigationController = self.rootNavigationController;
    if (rootNavigationController.isNavigationBarDetached) {
        return rect;
    }
    CGRect frameRect = [NSWindow frameRectForContentRect:CGRectMake(0.0, 0.0, 20.0, 20.0)
                                               styleMask:NSWindowStyleMaskTitled];
    CGFloat titlebarHeight = CGRectGetHeight(frameRect);
    UXNavigationBar *navigationBar = rootNavigationController.navigationBar;
    if (navigationBar) {
        CGFloat navigationBarHeight = CGRectGetHeight(navigationBar.bounds);
        rect.origin.y -= navigationBarHeight - (titlebarHeight - 20.0) + 1.0;
    }
    return rect;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if (context == UXWindowControllerContentLayoutRectContext) {
        [self.rootViewController invalidateIntrinsicLayoutInsets];
    } else if (context == UXWindowControllerToolbarNavigationItemContext) {
        NSArray<NSString *> *titleKeyPaths = @[@"title", @"subtitle", @"useWindowForTitleOutput"];
        if ([titleKeyPaths containsObject:keyPath]) {
            if (self.toolbarNavigationItem.useWindowForTitleOutput) {
                [self _updateWindowTitles];
            }
        } else {
            [self _updateToolbar];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
