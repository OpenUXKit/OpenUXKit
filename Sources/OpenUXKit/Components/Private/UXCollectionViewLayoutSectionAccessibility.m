#import "UXCollectionViewLayoutSectionAccessibility.h"
#import "UXCollectionViewLayoutAccessibility.h"
#import "UXCollectionViewLayout.h"
#import "UXCollectionView.h"
#import "UXCollectionViewCell.h"
#import "UXBase.h"

@interface NSObject (UXCollectionViewLayoutSectionAccessibilitySPI)
- (nullable NSArray<NSIndexPath *> *)indexPathsForVisibleItemsInSections:(NSIndexSet *)sections;
- (nullable NSArray *)visibleSupplementaryViews;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (nullable id)cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)indexPathForCell:(id)cell;
- (nullable NSIndexPath *)indexPathForSupplementaryView:(id)supplementaryView;
- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(NSUInteger)scrollPosition animated:(BOOL)animated;
@end

@interface UXCollectionViewLayoutSectionAccessibility () {
    __weak UXCollectionViewLayoutAccessibility *_layoutAccessibility;
    NSArray *_accessibilityVisibleChildren;
}
@end

@implementation UXCollectionViewLayoutSectionAccessibility

@synthesize layoutAccessibility = _layoutAccessibility;
@synthesize accessibilityVisibleChildren = _accessibilityVisibleChildren;

- (instancetype)initWithLayoutAccessibility:(UXCollectionViewLayoutAccessibility *)layoutAccessibility {
    self = [super init];
    if (self) {
        _layoutAccessibility = layoutAccessibility;
        self.accessibilityParent = layoutAccessibility;
        self.accessibilityRoleDescription = UXLocalizedString(@"UXCollectionViewSectionAXRoleDescription");
    }
    return self;
}

- (UXCollectionView *)collectionView {
    return self.layoutAccessibility.layout.collectionView;
}

- (NSUInteger)sectionIndex {
    return self.accessibilityIndex;
}

- (NSAccessibilityRole)accessibilityRole {
    return NSAccessibilityListRole;
}

- (NSString *)accessibilitySubrole {
    return nil;
}

- (CGRect)accessibilityFrame {
    NSInteger section = (NSInteger)self.sectionIndex;
    CGRect frame = CGRectZero;
    for (id cell in [self visibleCellsInSection:section]) {
        frame = NSUnionRect(frame, [cell accessibilityFrame]);
    }
    for (id supplementaryView in [self visibleSupplementaryViewsInSection:section]) {
        frame = NSUnionRect(frame, [supplementaryView accessibilityFrame]);
    }
    return frame;
}

- (NSArray *)accessibilityChildren {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UIAOverrideAccessibilityChildren"]) {
        return [self accessibilityVisibleChildren];
    }
    return nil;
}

- (NSArray *)visibleCellsInSection:(NSInteger)section {
    UXCollectionView *collectionView = self.collectionView;
    NSArray<NSIndexPath *> *indexPaths = [collectionView indexPathsForVisibleItemsInSections:[NSIndexSet indexSetWithIndex:section]];
    NSMutableArray *cells = [[NSMutableArray alloc] initWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        id cell = [collectionView cellForItemAtIndexPath:indexPath];
        if ([cell isAccessibilityElement]) {
            [cells addObject:cell];
        }
    }
    return cells;
}

- (NSArray *)visibleSupplementaryViewsInSection:(NSInteger)section {
    UXCollectionView *collectionView = self.collectionView;
    NSArray *unignoredViews = NSAccessibilityUnignoredChildren([collectionView visibleSupplementaryViews]);
    NSMutableArray *views = [[NSMutableArray alloc] initWithCapacity:1];
    for (id supplementaryView in unignoredViews) {
        NSIndexPath *indexPath = [collectionView indexPathForSupplementaryView:supplementaryView];
        if (indexPath.section == section && [supplementaryView isAccessibilityElement]) {
            CGRect bounds = [supplementaryView bounds];
            if (!CGSizeEqualToSize(bounds.size, CGSizeZero)) {
                [views addObject:supplementaryView];
            }
        }
    }
    return views;
}

- (NSArray *)accessibilityVisibleChildren {
    if (!_accessibilityVisibleChildren) {
        NSInteger section = (NSInteger)self.sectionIndex;
        NSArray *cells = [self visibleCellsInSection:section];
        NSArray *supplementaryViews = [self visibleSupplementaryViewsInSection:section];
        NSMutableArray *children = [[NSMutableArray alloc] initWithCapacity:cells.count + supplementaryViews.count];
        [children addObjectsFromArray:supplementaryViews];
        [children addObjectsFromArray:cells];
        // Reading order: bucket each element's frame midpoint into 10pt bands and
        // sort top-to-bottom, then left-to-right (matches UXKit's comparator).
        [children sortUsingComparator:^NSComparisonResult(NSView *view1, NSView *view2) {
            CGRect frame1 = view1.frame;
            CGRect frame2 = view2.frame;
            NSUInteger midY1 = (NSUInteger)(frame1.origin.y + frame1.size.height * 0.5) / 10;
            NSUInteger midY2 = (NSUInteger)(frame2.origin.y + frame2.size.height * 0.5) / 10;
            if (midY1 < midY2) {
                return NSOrderedAscending;
            }
            if (midY1 > midY2) {
                return NSOrderedDescending;
            }
            NSUInteger midX1 = (NSUInteger)(frame1.origin.x + frame1.size.width * 0.5) / 10;
            NSUInteger midX2 = (NSUInteger)(frame2.origin.x + frame2.size.width * 0.5) / 10;
            if (midX1 < midX2) {
                return NSOrderedAscending;
            }
            if (midX1 > midX2) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        _accessibilityVisibleChildren = children;
    }
    return _accessibilityVisibleChildren;
}

- (NSUInteger)accessibilityArrayAttributeCount:(NSString *)attribute {
    if ([attribute isEqualToString:NSAccessibilityChildrenAttribute]) {
        return [self.collectionView numberOfItemsInSection:(NSInteger)self.sectionIndex];
    }
    return [super accessibilityArrayAttributeCount:attribute];
}

- (NSArray *)accessibilityArrayAttributeValues:(NSString *)attribute index:(NSUInteger)index maxCount:(NSUInteger)maxCount {
    NSArray *values = nil;
    if ([attribute isEqualToString:NSAccessibilityChildrenAttribute]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:(NSInteger)self.sectionIndex];
        if (indexPath) {
            id cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            if (cell) {
                values = @[cell];
            }
        }
    } else {
        values = [super accessibilityArrayAttributeValues:attribute index:index maxCount:maxCount];
    }
    return values ?: @[];
}

- (NSUInteger)accessibilityIndexOfChild:(id)child {
    if ([child isKindOfClass:[UXCollectionViewCell class]]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:child];
        if (indexPath) {
            return indexPath.item;
        }
    }
    return NSNotFound;
}

- (id)accessibilityHitTest:(CGPoint)point {
    for (id child in [self accessibilityChildren]) {
        if (NSPointInRect(point, [child accessibilityFrame])) {
            return [child accessibilityHitTest:point];
        }
    }
    return self;
}

- (NSArray *)accessibilityActionNames {
    // NSAccessibilityScrollToVisibleAction (= @"AXScrollToVisible") is only a named
    // constant on macOS 26+, so the raw value is used to keep the macOS 11 target.
    return @[@"AXScrollToVisible"];
}

- (NSString *)accessibilityActionDescription:(NSString *)action {
    if ([action isEqualToString:@"AXScrollToVisible"]) {
        return NSAccessibilityActionDescription(action);
    }
    return nil;
}

- (void)accessibilityPerformAction:(NSString *)action {
    if ([action isEqualToString:@"AXScrollToVisible"]) {
        [self accessibilityPerformScrollToVisible];
    }
}

- (BOOL)accessibilityPerformScrollToVisible {
    UXCollectionView *collectionView = self.collectionView;
    NSInteger section = (NSInteger)self.sectionIndex;
    NSArray<NSIndexPath *> *visibleIndexPaths = [collectionView indexPathsForVisibleItemsInSections:[NSIndexSet indexSetWithIndex:section]];
    NSIndexPath *indexPath;
    if (visibleIndexPaths.count) {
        indexPath = visibleIndexPaths.firstObject;
    } else if ([collectionView numberOfItemsInSection:section]) {
        indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    } else {
        indexPath = nil;
    }
    // UXKit passes raw scroll position 64 — an SPI "nearest" mode (see P6 reusable view).
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(NSUInteger)64 animated:YES];
    return YES;
}

- (NSComparisonResult)compare:(UXCollectionViewLayoutSectionAccessibility *)other {
    NSUInteger lhs = self.sectionIndex;
    NSUInteger rhs = other.sectionIndex;
    if (lhs < rhs) return NSOrderedAscending;
    if (lhs > rhs) return NSOrderedDescending;
    return NSOrderedSame;
}

- (id)_siblingInDirection:(NSUInteger)direction item:(id)item {
    id result = nil;
    if (item && [item isKindOfClass:[UXCollectionViewCell class]]) {
        UXCollectionView *collectionView = self.collectionView;
        NSIndexPath *indexPath = [collectionView indexPathForCell:item];
        if (indexPath) {
            UXCollectionViewLayout *layout = self.layoutAccessibility.layout;
            NSIndexPath *targetIndexPath = nil;
            switch (direction) {
                case 0:
                    targetIndexPath = [layout indexPathOfItemBefore:indexPath];
                    break;
                case 1:
                    targetIndexPath = [layout indexPathOfItemAfter:indexPath];
                    break;
                case 2:
                    targetIndexPath = [layout indexPathOfItemAbove:indexPath];
                    break;
                case 3:
                    targetIndexPath = [layout indexPathOfItemBelow:indexPath];
                    break;
                default:
                    break;
            }
            if (targetIndexPath) {
                id cell = [collectionView cellForItemAtIndexPath:targetIndexPath];
                if ([cell isAccessibilityElement]) {
                    result = cell;
                }
            }
        }
    }
    // UXKit nils out a sibling that resolves back to the originating item.
    if ([item isEqual:result]) {
        result = nil;
    }
    return result;
}

- (id)siblingBeforeItem:(id)item { return [self _siblingInDirection:0 item:item]; }
- (id)siblingAfterItem:(id)item { return [self _siblingInDirection:1 item:item]; }
- (id)siblingAboveItem:(id)item { return [self _siblingInDirection:2 item:item]; }
- (id)siblingBelowItem:(id)item { return [self _siblingInDirection:3 item:item]; }

- (void)_dumpVisibleChildren {
    _accessibilityVisibleChildren = nil;
}

- (void)accessibilityPrepareLayout {}
- (void)accessibilityInvalidateLayout {}
- (void)accessibilityPrepareForCollectionViewUpdates {}
- (void)accessibilityDidEndScrolling {}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p sectionIndex:%lu>", NSStringFromClass([self class]), self, (unsigned long)self.sectionIndex];
}

@end
