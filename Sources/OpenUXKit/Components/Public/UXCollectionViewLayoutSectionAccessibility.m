#import <OpenUXKit/UXCollectionViewLayoutSectionAccessibility.h>
#import <OpenUXKit/UXCollectionViewLayoutAccessibility.h>
#import <OpenUXKit/UXCollectionViewLayout.h>
#import <OpenUXKit/UXCollectionView.h>
#import <OpenUXKit/UXBase.h>

@interface NSObject (UXCollectionViewLayoutSectionAccessibilitySPI)
- (nullable NSArray<NSIndexPath *> *)indexPathsForVisibleItems;
- (nullable NSArray *)visibleSupplementaryViews;
- (nullable id)cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)indexPathForSupplementaryView:(id)supplementaryView;
- (BOOL)scrollToItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths scrollPosition:(NSUInteger)scrollPosition;
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
    return NSAccessibilityRowRole;
}

- (NSString *)accessibilitySubrole {
    return nil;
}

- (CGRect)accessibilityFrame {
    return [super accessibilityFrame];
}

- (NSArray *)accessibilityChildren {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UIAOverrideAccessibilityChildren"]) {
        return [self accessibilityVisibleChildren];
    }
    return nil;
}

- (NSArray *)visibleCellsInSection:(NSInteger)section {
    UXCollectionView *collectionView = self.collectionView;
    if (![collectionView respondsToSelector:@selector(indexPathsForVisibleItems)]) {
        return @[];
    }

    NSMutableArray *cells = [NSMutableArray array];
    for (NSIndexPath *indexPath in [collectionView indexPathsForVisibleItems]) {
        if ([indexPath section] == section) {
            id cell = [collectionView cellForItemAtIndexPath:indexPath];
            if (cell) {
                [cells addObject:cell];
            }
        }
    }
    return cells;
}

- (NSArray *)visibleSupplementaryViewsInSection:(NSInteger)section {
    UXCollectionView *collectionView = self.collectionView;
    if (![collectionView respondsToSelector:@selector(visibleSupplementaryViews)]) {
        return @[];
    }

    NSMutableArray *views = [NSMutableArray array];
    for (id supplementaryView in [collectionView visibleSupplementaryViews]) {
        NSIndexPath *indexPath = [collectionView indexPathForSupplementaryView:supplementaryView];
        if ([indexPath section] == section) {
            [views addObject:supplementaryView];
        }
    }
    return views;
}

- (NSArray *)accessibilityVisibleChildren {
    if (!_accessibilityVisibleChildren) {
        NSInteger section = (NSInteger)self.sectionIndex;
        NSMutableArray *children = [NSMutableArray array];
        [children addObjectsFromArray:[self visibleSupplementaryViewsInSection:section]];
        [children addObjectsFromArray:[self visibleCellsInSection:section]];
        _accessibilityVisibleChildren = children;
    }
    return _accessibilityVisibleChildren;
}

- (NSUInteger)accessibilityArrayAttributeCount:(NSString *)attribute {
    if ([attribute isEqualToString:NSAccessibilityChildrenAttribute]
        || [attribute isEqualToString:NSAccessibilityVisibleChildrenAttribute]) {
        return [self accessibilityVisibleChildren].count;
    }
    return [super accessibilityArrayAttributeCount:attribute];
}

- (NSArray *)accessibilityArrayAttributeValues:(NSString *)attribute index:(NSUInteger)index maxCount:(NSUInteger)maxCount {
    if ([attribute isEqualToString:NSAccessibilityChildrenAttribute]
        || [attribute isEqualToString:NSAccessibilityVisibleChildrenAttribute]) {
        NSArray *visibleChildren = [self accessibilityVisibleChildren];
        if (index >= visibleChildren.count) {
            return @[];
        }
        NSUInteger count = MIN(maxCount, visibleChildren.count - index);
        return [visibleChildren subarrayWithRange:NSMakeRange(index, count)];
    }
    return [super accessibilityArrayAttributeValues:attribute index:index maxCount:maxCount];
}

- (NSUInteger)accessibilityIndexOfChild:(id)child {
    return [[self accessibilityVisibleChildren] indexOfObjectIdenticalTo:child];
}

- (id)accessibilityHitTest:(CGPoint)point {
    for (id child in [self accessibilityVisibleChildren]) {
        id hit = [child accessibilityHitTest:point];
        if (hit) {
            return hit;
        }
    }
    return self;
}

- (NSArray *)accessibilityActionNames {
    return @[];
}

- (NSString *)accessibilityActionDescription:(NSString *)action {
    if ([action isEqualToString:NSAccessibilityScrollToVisibleAction]) {
        return NSAccessibilityActionDescription(action);
    }
    return nil;
}

- (void)accessibilityPerformAction:(NSString *)action {
    if ([action isEqualToString:NSAccessibilityScrollToVisibleAction]) {
        [self accessibilityPerformScrollToVisible];
    }
}

- (BOOL)accessibilityPerformScrollToVisible {
    UXCollectionView *collectionView = self.collectionView;
    if (![collectionView respondsToSelector:@selector(scrollToItemsAtIndexPaths:scrollPosition:)]) {
        return NO;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:(NSInteger)self.sectionIndex];
    return [collectionView scrollToItemsAtIndexPaths:[NSSet setWithObject:indexPath] scrollPosition:NSCollectionViewScrollPositionTop];
}

- (NSComparisonResult)compare:(UXCollectionViewLayoutSectionAccessibility *)other {
    NSUInteger lhs = self.sectionIndex;
    NSUInteger rhs = other.sectionIndex;
    if (lhs < rhs) return NSOrderedAscending;
    if (lhs > rhs) return NSOrderedDescending;
    return NSOrderedSame;
}

- (id)_siblingInDirection:(NSUInteger)direction item:(id)item {
    NSArray *visibleChildren = [self accessibilityVisibleChildren];
    NSUInteger index = [visibleChildren indexOfObjectIdenticalTo:item];
    if (index == NSNotFound) {
        return nil;
    }
    switch (direction) {
        case 0:
            return index > 0 ? visibleChildren[index - 1] : nil;
        case 1:
            return index + 1 < visibleChildren.count ? visibleChildren[index + 1] : nil;
        default:
            return nil;
    }
}

- (id)siblingBeforeItem:(id)item { return [self _siblingInDirection:0 item:item]; }
- (id)siblingAfterItem:(id)item { return [self _siblingInDirection:1 item:item]; }
- (id)siblingAboveItem:(id)item { return [self _siblingInDirection:0 item:item]; }
- (id)siblingBelowItem:(id)item { return [self _siblingInDirection:1 item:item]; }

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
