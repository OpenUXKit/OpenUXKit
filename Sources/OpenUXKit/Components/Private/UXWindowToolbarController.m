#import "UXWindowToolbarController.h"
#import "UXNavigationItem.h"
#import "UXNavigationItem+Internal.h"
#import "UXNavigationController.h"
#import "UXNavigationController+Internal.h"
#import "UXBarButtonItem.h"
#import "UXBarButtonItem+Internal.h"

static NSString *const UXWindowToolbarCenteredItemIdentifier = @"UXWindowToolbarCenteredItem";
static void *UXProgressNavigationItemHiddenObserverContext = &UXProgressNavigationItemHiddenObserverContext;

@interface UXWindowToolbarController () {
    NSArray<NSToolbarItemIdentifier> *_defaultItemIdentifiers;
    NSArray<NSToolbarItemIdentifier> *_allowedItemIdentifiers;
    NSDictionary<NSToolbarItemIdentifier, NSToolbarItem *> *_itemByIdentifier;
    NSToolbar *_toolbar;
}
@end

@implementation UXWindowToolbarController

- (instancetype)initWithNavigationItem:(UXNavigationItem *)navigationItem {
    self = [super init];
    if (self) {
        [self setNavigationItem:navigationItem];
    }
    return self;
}

- (void)dealloc {
    [_observedProgressButtonItem removeObserver:self forKeyPath:@"hidden" context:UXProgressNavigationItemHiddenObserverContext];
}

- (NSToolbar *)toolbar {
    if (_toolbar) {
        return _toolbar;
    }
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:self.navigationItem.identifier ?: @""];
    toolbar.displayMode = NSToolbarDisplayModeIconOnly;
    toolbar.delegate = self;
    toolbar.centeredItemIdentifier = UXWindowToolbarCenteredItemIdentifier;
    toolbar.allowsUserCustomization = [UXNavigationController allowToolbarCustomization];
    toolbar.autosavesConfiguration = [UXNavigationController allowToolbarCustomization];
    [self _updateToolbarItems];
    _toolbar = toolbar;
    return _toolbar;
}

- (void)setNavigationItem:(UXNavigationItem *)navigationItem {
    if (_navigationItem == navigationItem) {
        return;
    }
    _navigationItem = navigationItem;
    [self setObservedProgressButtonItem:navigationItem.progressButtonItem];
}

- (void)setObservedProgressButtonItem:(UXBarButtonItem *)observedProgressButtonItem {
    if (_observedProgressButtonItem == observedProgressButtonItem) {
        return;
    }
    [_observedProgressButtonItem removeObserver:self forKeyPath:@"hidden" context:UXProgressNavigationItemHiddenObserverContext];
    _observedProgressButtonItem = observedProgressButtonItem;
    [_observedProgressButtonItem addObserver:self forKeyPath:@"hidden" options:0 context:UXProgressNavigationItemHiddenObserverContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if (context == UXProgressNavigationItemHiddenObserverContext) {
        BOOL hidden = [(UXBarButtonItem *)object isHidden];
        NSToolbar *toolbar = [self toolbar];
        NSString *identifier = [(UXBarButtonItem *)object identifier];
        if (hidden) {
            if (@available(macOS 15.0, *)) {
                [toolbar removeItemWithItemIdentifier:identifier];
            } else {
                NSInteger index = [toolbar.items indexOfObjectPassingTest:^BOOL(NSToolbarItem *item, NSUInteger idx, BOOL *stop) {
                    return [item.itemIdentifier isEqualToString:identifier];
                }];
                if (index != NSNotFound) {
                    [toolbar removeItemAtIndex:index];
                }
            }
        } else {
            [toolbar insertItemWithItemIdentifier:identifier atIndex:1];
        }
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - Toolbar Item Updates

- (NSToolbarItem *)_toolbarItemForBarButtonItem:(UXBarButtonItem *)barButtonItem {
    NSString *identifier = barButtonItem.identifier;
    if (!identifier) {
        return nil;
    }
    NSToolbarItem *toolbarItem = nil;
    NSMenu *menu = barButtonItem.menu;
    if (menu) {
        NSMenuToolbarItem *menuItem = [[NSMenuToolbarItem alloc] initWithItemIdentifier:identifier];
        menuItem.menu = menu;
        menuItem.image = barButtonItem.image;
        menuItem.showsIndicator = NO;
        toolbarItem = menuItem;
    } else if (barButtonItem.isSystemItem) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    } else {
        NSView *barButtonView = barButtonItem._view;
        NSAssert(barButtonView != nil, @"Invalid parameter not satisfying: view");
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        toolbarItem.view = barButtonView;
        barButtonItem.toolbarItem = toolbarItem;
        if ([barButtonView isKindOfClass:[NSControl class]]) {
            ((NSControl *)barButtonView).cell.accessibilityIdentifier = identifier;
        } else {
            barButtonView.accessibilityIdentifier = identifier;
        }
    }
    if (!toolbarItem) {
        return nil;
    }
    toolbarItem.visibilityPriority = (NSInteger)barButtonItem.visibilityPriority;
    toolbarItem.navigational = barButtonItem.isNavigational;
    if (@available(macOS 26.0, *)) {
        toolbarItem.backgroundTintColor = barButtonItem.backgroundColor;
    }
    if (@available(macOS 15.0, *)) {
        toolbarItem.hidden = barButtonItem.isHidden;
    }
    if (!toolbarItem.view.isHidden) {
        toolbarItem.label = barButtonItem.label;
        toolbarItem.paletteLabel = barButtonItem.label;
    }
    return toolbarItem;
}

- (void)_updateToolbarItems {
    UXNavigationItem *navigationItem = self.navigationItem;
    NSMutableDictionary<NSToolbarItemIdentifier, NSToolbarItem *> *itemByIdentifier = [NSMutableDictionary dictionary];
    NSMutableOrderedSet<NSToolbarItemIdentifier> *defaultIdentifiers = [NSMutableOrderedSet orderedSet];
    NSMutableSet<NSToolbarItemIdentifier> *allowedIdentifiers = [NSMutableSet set];

    [allowedIdentifiers addObjectsFromArray:@[
        NSToolbarFlexibleSpaceItemIdentifier,
        NSToolbarSpaceItemIdentifier,
        NSToolbarToggleSidebarItemIdentifier,
        NSToolbarSidebarTrackingSeparatorItemIdentifier,
    ]];

    void (^processBarButtonItem)(UXBarButtonItem *) = ^(UXBarButtonItem *barButtonItem) {
        NSString *identifier = barButtonItem.identifier;
        if (!identifier) {
            return;
        }
        NSToolbarItem *toolbarItem = [self _toolbarItemForBarButtonItem:barButtonItem];
        if (toolbarItem) {
            itemByIdentifier[identifier] = toolbarItem;
        }
        if (barButtonItem == self.observedProgressButtonItem && barButtonItem.isHidden) {
            [allowedIdentifiers addObject:identifier];
        } else {
            [defaultIdentifiers addObject:identifier];
            [allowedIdentifiers addObject:identifier];
        }
    };

    if (!navigationItem.hidesSidebarToggleButton) {
        [defaultIdentifiers addObject:NSToolbarToggleSidebarItemIdentifier];
        processBarButtonItem(navigationItem.progressButtonItem);
        [defaultIdentifiers addObject:NSToolbarSidebarTrackingSeparatorItemIdentifier];
        [defaultIdentifiers addObject:NSToolbarFlexibleSpaceItemIdentifier];
    }

    for (UXBarButtonItem *barButtonItem in navigationItem.leadingBarButtonItems) {
        processBarButtonItem(barButtonItem);
        if (barButtonItem == navigationItem.switchLibraryButtonItem) {
            [defaultIdentifiers addObject:NSToolbarSpaceItemIdentifier];
        }
    }

    NSToolbarItemGroup *centerToolbarItemGroup = navigationItem.centerToolbarItemGroup;
    NSView *titleView = navigationItem.titleView;
    if (centerToolbarItemGroup) {
        itemByIdentifier[UXWindowToolbarCenteredItemIdentifier] = centerToolbarItemGroup;
    } else if (titleView) {
        NSToolbarItem *titleItem = [[NSToolbarItem alloc] initWithItemIdentifier:UXWindowToolbarCenteredItemIdentifier];
        titleItem.visibilityPriority = 1000;
        titleItem.view = titleView;
        if (![titleView isKindOfClass:[NSControl class]]) {
            titleItem.bordered = NO;
        }
        itemByIdentifier[UXWindowToolbarCenteredItemIdentifier] = titleItem;
    }
    if (centerToolbarItemGroup || titleView) {
        [defaultIdentifiers addObject:NSToolbarFlexibleSpaceItemIdentifier];
        [defaultIdentifiers addObject:UXWindowToolbarCenteredItemIdentifier];
        [allowedIdentifiers addObject:UXWindowToolbarCenteredItemIdentifier];
        [defaultIdentifiers addObject:NSToolbarFlexibleSpaceItemIdentifier];
    }

    for (UXBarButtonItem *barButtonItem in [navigationItem.trailingBarButtonItems reverseObjectEnumerator]) {
        processBarButtonItem(barButtonItem);
    }

    NSString *searchIdentifier = self.searchToolbarItem.itemIdentifier;
    if (searchIdentifier && !navigationItem.hidesGlobalTrailingView) {
        itemByIdentifier[searchIdentifier] = self.searchToolbarItem;
        [defaultIdentifiers addObject:searchIdentifier];
        [allowedIdentifiers addObject:searchIdentifier];
    }

    _defaultItemIdentifiers = [defaultIdentifiers.array copy];
    _allowedItemIdentifiers = [allowedIdentifiers.allObjects copy];
    _itemByIdentifier = [itemByIdentifier copy];
}

- (void)updateToolbar {
    NSToolbar *toolbar = self.toolbar;
    NSString *searchIdentifier = self.searchToolbarItem.itemIdentifier;
    BOOL searchIsDefault = (searchIdentifier != nil) && [_defaultItemIdentifiers containsObject:searchIdentifier];

    [self _updateToolbarItems];

    NSUInteger index = 0;
    while (index < toolbar.items.count) {
        NSToolbarItem *currentItem = toolbar.items[index];
        NSString *currentIdentifier = currentItem.itemIdentifier;
        NSToolbarItem *replacementItem = _itemByIdentifier[currentIdentifier];
        BOOL shouldRemove = NO;
        if (!replacementItem) {
            shouldRemove = YES;
        } else if (currentItem == self.searchToolbarItem) {
            if (!self.navigationItem.hidesGlobalTrailingView) {
                if (replacementItem != self.searchToolbarItem) {
                    if (![currentItem.view isEqualTo:replacementItem.view]) {
                        shouldRemove = YES;
                    }
                }
            } else {
                shouldRemove = YES;
            }
        } else if (![currentItem.view isEqualTo:replacementItem.view]) {
            shouldRemove = YES;
        }
        if (shouldRemove) {
            [toolbar removeItemAtIndex:index];
        } else {
            index++;
        }
    }

    [_defaultItemIdentifiers enumerateObjectsUsingBlock:^(NSToolbarItemIdentifier identifier, NSUInteger desiredIndex, BOOL *stop) {
        if (searchIsDefault && [identifier isEqualToString:searchIdentifier]) {
            *stop = YES;
            return;
        }
        if ([identifier isEqualToString:NSToolbarFlexibleSpaceItemIdentifier]
            || [identifier isEqualToString:NSToolbarSidebarTrackingSeparatorItemIdentifier]
            || ![[toolbar.items valueForKey:@"itemIdentifier"] containsObject:identifier]) {
            if (desiredIndex <= toolbar.items.count) {
                [toolbar insertItemWithItemIdentifier:identifier atIndex:desiredIndex];
            }
        }
    }];
}

#pragma mark - NSToolbarDelegate

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    return _itemByIdentifier[itemIdentifier];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return _defaultItemIdentifiers ?: @[];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return _allowedItemIdentifiers ?: @[];
}

@end
