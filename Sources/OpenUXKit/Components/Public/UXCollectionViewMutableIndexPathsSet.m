#import <OpenUXKit/UXCollectionViewMutableIndexPathsSet.h>
#import "UXCollectionViewIndexPathsSet+Internal.h"
#import "_UXCollectionViewSectionItemIndexes.h"
#import "UXKitPrivateUtilites.h"

@interface UXCollectionViewMutableIndexPathsSet ()

- (void)_adjustForDeletionOfSection:(NSUInteger)section;
- (void)_adjustForInsertionOfSection:(NSUInteger)section;

@end

@implementation UXCollectionViewMutableIndexPathsSet

#pragma mark - Add

- (void)addIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        [self _addOneIndexPath:indexPath];
    }
}

- (void)addIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        if (![indexPath isKindOfClass:[NSIndexPath class]]) {
            [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                                object:self
                                                                  file:@"UXCollectionViewIndexPathsSet.m"
                                                            lineNumber:857
                                                           description:@"unexpected object: %@", indexPath];
        }
        [self _addOneIndexPath:indexPath];
    }
}

- (void)addIndexPathsSet:(UXCollectionViewIndexPathsSet *)indexPathsSet {
    if (indexPathsSet) {
        [self _addIndexPathsSet:indexPathsSet];
    }
}

- (void)addSection:(NSInteger)section itemsInRange:(NSRange)range {
    if ((NSUInteger)section <= (NSUInteger)NSIntegerMax - 1 && range.length != 0 && range.location != NSNotFound) {
        _UXCollectionViewSectionItemIndexes *itemIndexes = [self _itemIndexesForSection:section allowingCreation:YES];
        [itemIndexes addItemsInRange:range];
        [self addIndexPaths:[itemIndexes itemIndexPathsForSection:section]];
    }
}

#pragma mark - Remove

- (void)removeIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        [self _removeOneIndexPath:indexPath];
    }
}

- (void)removeIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        if (![indexPath isKindOfClass:[NSIndexPath class]]) {
            [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                                object:self
                                                                  file:@"UXCollectionViewIndexPathsSet.m"
                                                            lineNumber:941
                                                           description:@"unexpected object: %@", indexPath];
        }
        [self _removeOneIndexPath:indexPath];
    }
}

- (void)removeIndexPathsSet:(UXCollectionViewIndexPathsSet *)indexPathsSet {
    [indexPathsSet->_sectionToItemIndexesMap enumerateKeysAndObjectsUsingBlock:^(NSNumber *sectionKey, _UXCollectionViewSectionItemIndexes *itemIndexes, BOOL *stop) {
        NSUInteger section = [sectionKey isKindOfClass:[NSNumber class]] ? [sectionKey unsignedIntegerValue] : NSNotFound;
        _UXCollectionViewSectionItemIndexes *targetItemIndexes = [self _itemIndexesForSection:section allowingCreation:NO];
        if (targetItemIndexes) {
            [targetItemIndexes removeSectionItemIndexes:itemIndexes];
            if (![targetItemIndexes itemCount]) {
                [self _removeItemIndexesForSection:section];
            }
        }
    }];
}

- (void)removeAllIndexPaths {
    [_sectionToItemIndexesMap removeAllObjects];
    [_sectionIndexes removeAllIndexes];
}

- (void)removeSection:(NSInteger)section {
    [_sectionToItemIndexesMap removeObjectForKey:[NSNumber numberWithUnsignedInteger:section]];
    [_sectionIndexes removeIndex:section];
}

- (void)removeSection:(NSInteger)section itemsInRange:(NSRange)range {
    _UXCollectionViewSectionItemIndexes *itemIndexes = [self _itemIndexesForSection:section allowingCreation:NO];
    if (itemIndexes) {
        [itemIndexes removeItemsInRange:range];
        if (![itemIndexes itemCount]) {
            [self removeSection:section];
        }
    }
}

- (void)removeSections:(NSIndexSet *)sections {
    for (NSUInteger section = [sections firstIndex]; section != NSNotFound; section = [sections indexGreaterThanIndex:section]) {
        [self removeSection:section];
    }
}

#pragma mark - Intersect

- (void)intersectIndexPathsSet:(UXCollectionViewIndexPathsSet *)indexPathsSet {
    UXCollectionViewMutableIndexPathsSet *complement = [indexPathsSet mutableCopy];
    [complement addIndexPathsSet:self];
    [indexPathsSet enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
        if ([self containsIndexPath:indexPath]) {
            [complement removeIndexPath:indexPath];
        }
    }];
    [self removeIndexPathsSet:complement];
}

#pragma mark - Adjust (items)

- (void)adjustForDeletionOfIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        _UXCollectionViewSectionItemIndexes *itemIndexes = [self _itemIndexesForSection:[indexPath indexAtPosition:0] allowingCreation:NO];
        if (itemIndexes) {
            [itemIndexes adjustForDeletionOfItem:[indexPath indexAtPosition:1]];
        }
    }
}

- (void)adjustForDeletionOfItems:(NSIndexSet *)items inSection:(NSUInteger)section {
    _UXCollectionViewSectionItemIndexes *itemIndexes = [self _itemIndexesForSection:section allowingCreation:NO];
    if (itemIndexes) {
        [itemIndexes adjustForDeletionOfItems:items];
    }
}

- (void)adjustForInsertionOfIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        _UXCollectionViewSectionItemIndexes *itemIndexes = [self _itemIndexesForSection:[indexPath indexAtPosition:0] allowingCreation:NO];
        if (itemIndexes) {
            [itemIndexes adjustForInsertionOfItem:[indexPath indexAtPosition:1]];
        }
    }
}

- (void)adjustForInsertionOfItems:(NSIndexSet *)items inSection:(NSUInteger)section {
    _UXCollectionViewSectionItemIndexes *itemIndexes = [self _itemIndexesForSection:section allowingCreation:NO];
    if (itemIndexes) {
        [itemIndexes adjustForInsertionOfItems:items];
    }
}

#pragma mark - Adjust (sections)

- (void)adjustForDeletionOfSection:(NSUInteger)section {
    if (section != NSNotFound) {
        [self _adjustForDeletionOfSection:section];
    }
}

- (void)adjustForDeletionOfSections:(NSIndexSet *)sections {
    for (NSUInteger section = [sections lastIndex]; section != NSNotFound; section = [sections indexLessThanIndex:section]) {
        [self _adjustForDeletionOfSection:section];
    }
}

- (void)_adjustForDeletionOfSection:(NSUInteger)section {
    for (NSUInteger currentSection = [_sectionIndexes indexGreaterThanIndex:section]; currentSection != NSNotFound; currentSection = [_sectionIndexes indexGreaterThanIndex:currentSection]) {
        NSNumber *currentKey = [NSNumber numberWithUnsignedInteger:currentSection];
        _UXCollectionViewSectionItemIndexes *itemIndexes = [_sectionToItemIndexesMap objectForKey:currentKey];
        [_sectionToItemIndexesMap removeObjectForKey:currentKey];
        [_sectionToItemIndexesMap setObject:itemIndexes forKey:[NSNumber numberWithUnsignedInteger:currentSection - 1]];
    }
    [_sectionIndexes shiftIndexesStartingAtIndex:section + 1 by:-1];
}

- (void)adjustForInsertionOfSection:(NSUInteger)section {
    if (section != NSNotFound) {
        [self _adjustForInsertionOfSection:section];
    }
}

- (void)adjustForInsertionOfSections:(NSIndexSet *)sections {
    for (NSUInteger section = [sections firstIndex]; section != NSNotFound; section = [sections indexGreaterThanIndex:section]) {
        [self _adjustForInsertionOfSection:section];
    }
}

- (void)_adjustForInsertionOfSection:(NSUInteger)section {
    NSUInteger currentSection = [_sectionIndexes lastIndex];
    if (currentSection != NSNotFound && currentSection >= section) {
        do {
            NSNumber *currentKey = [NSNumber numberWithUnsignedInteger:currentSection];
            _UXCollectionViewSectionItemIndexes *itemIndexes = [_sectionToItemIndexesMap objectForKey:currentKey];
            [_sectionToItemIndexesMap removeObjectForKey:currentKey];
            [_sectionToItemIndexesMap setObject:itemIndexes forKey:[NSNumber numberWithUnsignedInteger:currentSection + 1]];
            currentSection = [_sectionIndexes indexLessThanIndex:currentSection];
        } while (currentSection != NSNotFound && currentSection >= section);
    }
    [_sectionIndexes shiftIndexesStartingAtIndex:section by:1];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[UXCollectionViewIndexPathsSet allocWithZone:zone] initWithIndexPathsSet:self];
}

@end
