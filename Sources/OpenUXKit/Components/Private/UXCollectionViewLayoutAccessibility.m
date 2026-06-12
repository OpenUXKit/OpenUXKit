#import "UXCollectionViewLayoutAccessibility.h"
#import "UXCollectionViewLayoutSectionAccessibility.h"
#import "UXCollectionViewLayout.h"
#import "UXCollectionView.h"

@interface NSObject (UXCollectionViewLayoutAccessibilitySPI)
- (NSInteger)numberOfSections;
- (nullable NSArray<NSIndexPath *> *)indexPathsForVisibleItems;
- (nullable NSArray *)visibleSupplementaryViews;
- (nullable NSIndexPath *)indexPathForCell:(id)cell;
- (nullable NSIndexPath *)indexPathForSupplementaryView:(id)supplementaryView;
- (void)_notifyAccessibilityDelegateToPrepareSection:(id)section;
- (NSInteger)accessibilityIndex;
- (void)setAccessibilityIndex:(NSInteger)accessibilityIndex;
@end

// Mirrors UXKit's private AXCollectionViewEnumerateSections(): walks the section
// cache, skipping NSNull placeholders, and invokes the block for every live
// section element so layout lifecycle calls fan out to the cached sections.
static void UXCollectionViewLayoutAccessibilityEnumerateSections(NSArray *sectionCache, void (^block)(id section)) {
    NSNull *placeholder = [NSNull null];
    for (id section in sectionCache) {
        if (section != placeholder) {
            block(section);
        }
    }
}

@interface UXCollectionViewLayoutAccessibility () {
    NSArray *_accessibilityVisibleChildren;
    __weak UXCollectionViewLayout *_layout;
    NSUInteger __sectionCacheOffset;
    NSMutableArray *__sectionCache;
}
@end

@implementation UXCollectionViewLayoutAccessibility

@synthesize layout = _layout;
@synthesize accessibilityVisibleChildren = _accessibilityVisibleChildren;
@synthesize _sectionCache = __sectionCache;
@synthesize _sectionCacheOffset = __sectionCacheOffset;

+ (Class)sectionAccessibilityClass {
    return [UXCollectionViewLayoutSectionAccessibility class];
}

- (instancetype)initWithLayout:(UXCollectionViewLayout *)layout {
    self = [super init];
    if (self) {
        _layout = layout;
        __sectionCacheOffset = NSNotFound;
    }
    return self;
}

- (UXCollectionView *)collectionView {
    return self.layout.collectionView;
}

- (NSMutableArray *)_sectionCache {
    if (!__sectionCache) {
        __sectionCache = [[NSMutableArray alloc] init];
    }
    return __sectionCache;
}

- (id)_dequeueSectionWithIndex:(NSUInteger)index {
    if (index == NSNotFound) {
        return nil;
    }

    NSNull *placeholder = [NSNull null];
    NSMutableArray *sectionCache = [self _sectionCache];
    NSUInteger currentOffset = self._sectionCacheOffset;
    NSUInteger effectiveOffset;

    if (currentOffset == NSNotFound) {
        [sectionCache addObject:placeholder];
        effectiveOffset = index;
    } else {
        effectiveOffset = currentOffset;
        NSUInteger cacheCount = sectionCache.count;
        NSUInteger lastIndex = cacheCount > 0 ? effectiveOffset + cacheCount - 1 : 0;
        NSUInteger insertionCount = effectiveOffset > index ? effectiveOffset - index : 0;

        if (insertionCount) {
            for (NSUInteger i = 0; i < insertionCount; i++) {
                [sectionCache insertObject:placeholder atIndex:0];
            }
            effectiveOffset = index;
        }

        while (lastIndex < index) {
            [sectionCache addObject:placeholder];
            lastIndex++;
        }
    }

    NSUInteger cacheIndex = index - effectiveOffset;
    id section = [sectionCache objectAtIndexedSubscript:cacheIndex];

    if (section == placeholder) {
        Class sectionClass = [[self class] sectionAccessibilityClass];
        section = [[sectionClass alloc] initWithLayoutAccessibility:self];
        [sectionCache replaceObjectAtIndex:cacheIndex withObject:section];
    }

    [section setAccessibilityIndex:index];
    self._sectionCacheOffset = effectiveOffset;

    UXCollectionView *collectionView = self.collectionView;
    if ([collectionView respondsToSelector:@selector(_notifyAccessibilityDelegateToPrepareSection:)]) {
        [collectionView _notifyAccessibilityDelegateToPrepareSection:section];
    }

    return section;
}

- (void)_trimSectionCacheToVisibleSections:(NSIndexSet *)visibleSections {
    if (self._sectionCacheOffset == NSNotFound) {
        return;
    }

    NSMutableArray *sectionCache = [self _sectionCache];
    if (sectionCache.count == 0) {
        self._sectionCacheOffset = NSNotFound;
        return;
    }

    NSUInteger firstVisible = [visibleSections firstIndex];
    NSUInteger currentOffset = self._sectionCacheOffset;

    if (firstVisible > currentOffset) {
        NSUInteger dropCount = firstVisible - currentOffset;
        if (dropCount > sectionCache.count) {
            for (NSUInteger i = 0; i < sectionCache.count; i++) {
                [sectionCache replaceObjectAtIndex:i withObject:[NSNull null]];
            }
        } else if (dropCount < 6) {
            for (NSUInteger i = 0; i < dropCount; i++) {
                [sectionCache replaceObjectAtIndex:i withObject:[NSNull null]];
            }
        } else {
            [sectionCache removeObjectsInRange:NSMakeRange(0, dropCount)];
        }
        self._sectionCacheOffset = firstVisible;
    }

    NSUInteger lastVisible = [visibleSections lastIndex];
    if (lastVisible != NSNotFound) {
        NSUInteger trimStart = lastVisible + 1;
        if (trimStart < sectionCache.count) {
            [sectionCache removeObjectsInRange:NSMakeRange(trimStart, sectionCache.count - trimStart)];
        }
    }
}

- (NSIndexSet *)_visibleSections {
    UXCollectionView *collectionView = self.collectionView;
    NSMutableIndexSet *sections = [[NSMutableIndexSet alloc] init];

    if ([collectionView respondsToSelector:@selector(indexPathsForVisibleItems)]) {
        for (NSIndexPath *indexPath in [collectionView indexPathsForVisibleItems]) {
            NSUInteger section = [indexPath section];
            if (![sections containsIndex:section]) {
                [sections addIndex:section];
            }
        }
    }

    if ([collectionView respondsToSelector:@selector(visibleSupplementaryViews)]) {
        for (id supplementaryView in [collectionView visibleSupplementaryViews]) {
            NSIndexPath *indexPath = [collectionView indexPathForSupplementaryView:supplementaryView];
            if (indexPath) {
                NSUInteger section = [indexPath section];
                if (![sections containsIndex:section]) {
                    [sections addIndex:section];
                }
            }
        }
    }

    return sections;
}

- (void)_dumpVisibleChildren {
    _accessibilityVisibleChildren = nil;
    NSIndexSet *visibleSections = [self _visibleSections];
    [self _trimSectionCacheToVisibleSections:visibleSections];
}

- (void)accessibilityPrepareLayout {
    [self _dumpVisibleChildren];
    UXCollectionViewLayoutAccessibilityEnumerateSections(__sectionCache, ^(id section) {
        [section accessibilityPrepareLayout];
    });
}

- (void)accessibilityInvalidateLayout {
    [self _dumpVisibleChildren];
    UXCollectionViewLayoutAccessibilityEnumerateSections(__sectionCache, ^(id section) {
        [section accessibilityInvalidateLayout];
    });
}

- (void)accessibilityDidEndScrolling {
    [self _dumpVisibleChildren];
    UXCollectionViewLayoutAccessibilityEnumerateSections(__sectionCache, ^(id section) {
        [section accessibilityDidEndScrolling];
    });
}

- (void)accessibilityPrepareForCollectionViewUpdates:(NSArray *)updateItems {
    [self _dumpVisibleChildren];
    UXCollectionViewLayoutAccessibilityEnumerateSections(__sectionCache, ^(id section) {
        [section accessibilityPrepareForCollectionViewUpdates];
    });
}

- (NSArray *)accessibilityVisibleChildren {
    if (!_accessibilityVisibleChildren) {
        NSMutableArray *children = [[NSMutableArray alloc] init];
        NSIndexSet *visibleSections = [self _visibleSections];
        [visibleSections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            id sectionAccessibility = [self _dequeueSectionWithIndex:section];
            if (sectionAccessibility) {
                [children addObject:sectionAccessibility];
            }
        }];
        [children sortUsingSelector:@selector(compare:)];
        [self _trimSectionCacheToVisibleSections:visibleSections];
        _accessibilityVisibleChildren = children;
    }
    return _accessibilityVisibleChildren;
}

- (NSArray *)accessibilityChildren {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UIAOverrideAccessibilityChildren"]) {
        return [self accessibilityVisibleChildren];
    }
    return nil;
}

- (NSUInteger)accessibilityIndexOfChild:(id)child {
    return [child accessibilityIndex];
}

- (NSUInteger)accessibilityArrayAttributeCount:(NSString *)attribute {
    if ([attribute isEqualToString:NSAccessibilityChildrenAttribute]) {
        return [self accessibilityRowCount];
    }
    return [super accessibilityArrayAttributeCount:attribute];
}

- (NSArray *)accessibilityArrayAttributeValues:(NSString *)attribute index:(NSUInteger)index maxCount:(NSUInteger)maxCount {
    if ([attribute isEqualToString:NSAccessibilityChildrenAttribute]) {
        NSInteger rowCount = [self accessibilityRowCount];
        NSUInteger available = (NSUInteger)rowCount - index;
        NSUInteger count = available >= maxCount ? maxCount : available;
        NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:count];
        // UXKit dequeues the section at `index` on every iteration (the loop
        // variable is the running counter, not the section index), so the same
        // cached section is appended `count` times. Replicated verbatim.
        for (NSUInteger remaining = count; remaining > 0; remaining--) {
            [values addObject:[self _dequeueSectionWithIndex:index]];
        }
        return values;
    }
    return [super accessibilityArrayAttributeValues:attribute index:index maxCount:maxCount];
}

- (CGRect)accessibilityFrame {
    return [super accessibilityFrame];
}

- (CGRect)accessibilityFrameInParentSpace {
    UXCollectionView *collectionView = self.collectionView;
    NSWindow *window = [(id)collectionView window];
    CGRect bounds = [(id)collectionView bounds];
    CGRect windowFrame = window.frame;
    if (fabs(bounds.size.height - windowFrame.size.height) < FLT_EPSILON) {
        bounds.size.height = window.contentLayoutRect.size.height;
    }
    return bounds;
}

- (NSInteger)accessibilityRowCount {
    UXCollectionView *collectionView = self.collectionView;
    if ([collectionView respondsToSelector:@selector(numberOfSections)]) {
        return [collectionView numberOfSections];
    }
    return 0;
}

- (NSInteger)accessibilityColumnCount {
    return 1;
}

- (NSString *)accessibilityLabel {
    return self.layout.accessibilityLabel;
}

- (NSString *)accessibilityRoleDescription {
    return self.layout.accessibilityRoleDescription;
}

- (NSString *)accessibilityIdentifier {
    NSString *identifier = self.layout.accessibilityIdentifier;
    if (identifier) {
        return identifier;
    }
    return [super accessibilityIdentifier];
}

- (NSString *)accessibilitySubrole {
    return nil;
}

- (NSAccessibilityRole)accessibilityRole {
    return NSAccessibilityListRole;
}

- (id)accessibilityParent {
    return self.collectionView;
}

- (id)accessibilityHitTest:(CGPoint)point {
    for (id child in [self accessibilityVisibleChildren]) {
        if (NSPointInRect(point, [child accessibilityFrame])) {
            return [child accessibilityHitTest:point];
        }
    }
    return self;
}

- (void)accessibilityPostNotification:(NSString *)notification {
    if (notification) {
        NSAccessibilityPostNotification(self, notification);
    }
}

- (id)nextSectionForSection:(id)section {
    NSInteger rowCount = [self accessibilityRowCount];
    if (rowCount < 2) {
        return nil;
    }
    NSUInteger sectionIndex = [section sectionIndex];
    NSUInteger nextIndex = (NSInteger)(sectionIndex + 1) < rowCount ? sectionIndex + 1 : 0;
    return [self _dequeueSectionWithIndex:nextIndex];
}

- (id)previousSectionForSection:(id)section {
    NSInteger rowCount = [self accessibilityRowCount];
    if (rowCount < 2) {
        return nil;
    }
    NSUInteger sectionIndex = [section sectionIndex];
    NSUInteger base = sectionIndex ? sectionIndex : (NSUInteger)rowCount;
    return [self _dequeueSectionWithIndex:base - 1];
}

- (id)accessibilityParentForCell:(id)cell {
    UXCollectionView *collectionView = self.collectionView;
    NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
    if (indexPath) {
        return [self _dequeueSectionWithIndex:indexPath.section];
    }
    return nil;
}

- (id)accessibilityParentForReusableView:(id)reusableView {
    UXCollectionView *collectionView = self.collectionView;
    NSIndexPath *indexPath = [collectionView indexPathForSupplementaryView:reusableView];
    if (indexPath) {
        return [self _dequeueSectionWithIndex:indexPath.section];
    }
    return nil;
}

@end
