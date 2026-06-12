#import "UXCollectionViewUpdate+Internal.h"
#import "UXCollectionViewUpdateItem+Internal.h"
#import "UXCollectionViewUpdateGap.h"
#import "UXCollectionViewLayoutAttributes.h"
#import "UXCollectionViewData.h"
#import "NSIndexPath+UXCollectionViewAdditions.h"
#import "UXKitPrivateUtilites.h"

// SPI on UXCollectionView / UXCollectionViewData owned by other targets.
@interface NSObject (UXCollectionViewUpdateSPI)
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItems;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSInteger)numberOfItemsBeforeSection:(NSInteger)section;
- (NSInteger)globalIndexForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)indexPathForItemAtGlobalIndex:(NSInteger)globalIndex;
- (nullable NSSet<NSString *> *)knownSupplementaryElementKinds;
- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForGlobalItemIndex:(NSInteger)globalItemIndex;
- (nullable NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInSection:(NSInteger)section;
- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable id)collectionViewLayout;
- (NSArray<NSIndexPath *> *)indexPathsToDeleteForSupplementaryViewOfKind:(NSString *)elementKind;
- (NSArray<NSIndexPath *> *)indexPathsToDeleteForDecorationViewOfKind:(NSString *)elementKind;
- (NSArray<NSIndexPath *> *)indexPathsToInsertForSupplementaryViewOfKind:(NSString *)elementKind;
- (NSArray<NSIndexPath *> *)indexPathsToInsertForDecorationViewOfKind:(NSString *)elementKind;
@end

@interface UXCollectionViewUpdate () {
    __unsafe_unretained UXCollectionView *_collectionView;
    NSArray<UXCollectionViewUpdateItem *> *_updateItems;
    UXCollectionViewData *_oldModel;
    UXCollectionViewData *_newModel;
    CGRect _oldVisibleBounds;
    CGRect _newVisibleBounds;
    NSMutableIndexSet *_movedItems;
    NSMutableIndexSet *_movedSections;
    NSMutableIndexSet *_deletedSections;
    NSMutableIndexSet *_insertedSections;
    NSInteger *_oldSectionMap;
    NSInteger *_newSectionMap;
    NSInteger *_oldGlobalItemMap;
    NSInteger *_newGlobalItemMap;
    NSMutableArray<NSMutableDictionary *> *_deletedSupplementaryIndexesSectionArray;
    NSMutableArray<NSMutableDictionary *> *_insertedSupplementaryIndexesSectionArray;
    NSMutableDictionary *_deletedSupplementaryTopLevelIndexesDict;
    NSMutableDictionary *_insertedSupplementaryTopLevelIndexesDict;
    NSMutableArray *_viewAnimations;
    NSMutableArray<UXCollectionViewUpdateGap *> *_gaps;
    NSArray<UXCollectionViewUpdateItem *> *_updateItemsSortedByIndexPaths;
}
@end

@implementation UXCollectionViewUpdate

- (instancetype)initWithCollectionView:(UXCollectionView *)collectionView updateItems:(NSArray<UXCollectionViewUpdateItem *> *)updateItems oldModel:(UXCollectionViewData *)oldModel newModel:(UXCollectionViewData *)newModel oldVisibleBounds:(CGRect)oldVisibleBounds newVisibleBounds:(CGRect)newVisibleBounds {
    self = [super init];
    if (self) {
        _collectionView = collectionView;
        _updateItems = updateItems;
        _oldModel = oldModel;
        _newModel = newModel;
        _oldVisibleBounds = oldVisibleBounds;
        _newVisibleBounds = newVisibleBounds;
        [self _computeSectionUpdates];
        [self _computeItemUpdates];
        [self _computeGaps];
    }
    return self;
}

- (void)dealloc {
    free(_oldSectionMap);
    free(_newSectionMap);
    free(_oldGlobalItemMap);
    free(_newGlobalItemMap);
}

- (UXCollectionViewData *)_oldModel {
    return _oldModel;
}

- (UXCollectionViewData *)_newModel {
    return _newModel;
}

- (NSArray *)_insertedSupplementaryIndexesSectionArray {
    return _insertedSupplementaryIndexesSectionArray;
}

- (NSArray *)_deletedSupplementaryIndexesSectionArray {
    return _deletedSupplementaryIndexesSectionArray;
}

- (NSInteger)_oldGlobalItemMapValueAtIndex:(NSInteger)index {
    return _oldGlobalItemMap[index];
}

- (NSInteger)_newGlobalItemMapValueAtIndex:(NSInteger)index {
    return _newGlobalItemMap[index];
}

- (NSArray<UXCollectionViewUpdateItem *> *)updateItemsSortedByIndexPaths {
    if (!_updateItemsSortedByIndexPaths) {
        _updateItemsSortedByIndexPaths = [_updateItems sortedArrayUsingSelector:@selector(compareIndexPaths:)];
    }
    return _updateItemsSortedByIndexPaths;
}

#pragma mark - Section Updates

- (void)_computeSectionUpdates {
    NSInteger oldSectionCount = [_oldModel numberOfSections];
    NSInteger newSectionCount = [_newModel numberOfSections];
    _oldSectionMap = (NSInteger *)malloc(sizeof(NSInteger) * oldSectionCount);
    _newSectionMap = (NSInteger *)malloc(sizeof(NSInteger) * newSectionCount);
    _deletedSections = [[NSMutableIndexSet alloc] init];
    _insertedSections = [[NSMutableIndexSet alloc] init];
    _movedSections = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet *movedSourceSections = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet *insertedTrackingSections = [[NSMutableIndexSet alloc] init];

    for (NSInteger section = 0; section < oldSectionCount; section++) {
        _oldSectionMap[section] = section;
    }
    for (NSInteger section = 0; section < newSectionCount; section++) {
        _newSectionMap[section] = NSNotFound;
    }

    BOOL hasMoves = NO;
    for (UXCollectionViewUpdateItem *updateItem in _updateItems) {
        NSIndexPath *indexPath = [updateItem _indexPath];
        if ([indexPath item] != NSNotFound) {
            continue;
        }
        UXCollectionUpdateAction action = [updateItem _action];
        if (action == UXCollectionUpdateActionDelete) {
            NSInteger section = [indexPath section];
            _oldSectionMap[section] = NSNotFound;
            [_deletedSections addIndex:section];
            for (NSInteger following = section + 1; following < oldSectionCount; following++) {
                if (_oldSectionMap[following] != NSNotFound) {
                    _oldSectionMap[following]--;
                }
            }
        } else if (action == UXCollectionUpdateActionInsert) {
            NSInteger section = [indexPath section];
            [_insertedSections addIndex:section];
            for (NSInteger oldSection = 0; oldSection < oldSectionCount; oldSection++) {
                NSInteger mapped = _oldSectionMap[oldSection];
                if (mapped != NSNotFound && mapped >= section && ![_movedSections containsIndex:mapped]) {
                    _oldSectionMap[oldSection]++;
                }
            }
            [insertedTrackingSections addIndex:section];
        } else if (action == UXCollectionUpdateActionMove) {
            NSInteger fromSection = [indexPath section];
            NSInteger toSection = [[updateItem _newIndexPath] section];
            _oldSectionMap[fromSection] = toSection;
            [_movedSections addIndex:toSection];
            [movedSourceSections addIndex:fromSection];
            hasMoves = YES;
        }
    }

    if (newSectionCount >= 1 && hasMoves) {
        NSInteger destination = 0;
        for (NSInteger newSection = 0; newSection < newSectionCount; newSection++) {
            if (![_movedSections containsIndex:newSection] && ![insertedTrackingSections containsIndex:newSection]) {
                while (_oldSectionMap[destination] == NSNotFound || [movedSourceSections containsIndex:destination]) {
                    destination++;
                }
                if (destination >= oldSectionCount) {
                    [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                                        object:self
                                                                          file:@"UXCollectionViewUpdate.m"
                                                                    lineNumber:215
                                                                   description:@"out of bounds access to _oldSectionMap"];
                }
                _oldSectionMap[destination++] = newSection;
            }
        }
    }

    for (NSInteger oldSection = 0; oldSection < oldSectionCount; oldSection++) {
        NSInteger mapped = _oldSectionMap[oldSection];
        if (mapped != NSNotFound) {
            _newSectionMap[mapped] = oldSection;
        }
    }
}

#pragma mark - Item Updates

- (void)_computeItemUpdates {
    NSInteger oldGlobalItemCount = [_oldModel numberOfItems];
    NSAssert(oldGlobalItemCount >= 0, @"oldGlobalItemCount >= 0");
    NSInteger newGlobalItemCount = [_newModel numberOfItems];
    NSAssert(newGlobalItemCount >= 0, @"newGlobalItemCount >= 0");
    _oldGlobalItemMap = (NSInteger *)malloc(sizeof(NSInteger) * oldGlobalItemCount);
    _newGlobalItemMap = (NSInteger *)malloc(sizeof(NSInteger) * newGlobalItemCount);
    _movedItems = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet *movedSourceItems = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet *insertedTrackingItems = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet *affectedItems = [[NSMutableIndexSet alloc] init];

    for (NSInteger item = 0; item < oldGlobalItemCount; item++) {
        _oldGlobalItemMap[item] = item;
    }
    for (NSInteger item = 0; item < newGlobalItemCount; item++) {
        _newGlobalItemMap[item] = NSNotFound;
    }

    BOOL hasMoves = NO;
    for (UXCollectionViewUpdateItem *updateItem in _updateItems) {
        NSIndexPath *indexPath = [updateItem _indexPath];
        NSInteger item = [indexPath item];
        UXCollectionUpdateAction action = [updateItem _action];
        UXCollectionViewData *model;
        if (action == UXCollectionUpdateActionDelete || action == UXCollectionUpdateActionMove) {
            model = _oldModel;
        } else if (action == UXCollectionUpdateActionInsert) {
            model = _newModel;
        } else {
            model = nil;
        }

        [affectedItems removeAllIndexes];
        if (item == NSNotFound) {
            NSInteger section = [indexPath section];
            [affectedItems addIndexesInRange:NSMakeRange([model numberOfItemsBeforeSection:section], [model numberOfItemsInSection:section])];
        } else {
            NSInteger globalIndex = [model globalIndexForItemAtIndexPath:indexPath];
            if (globalIndex == NSNotFound) {
                continue;
            }
            [affectedItems addIndex:globalIndex];
        }

        NSInteger destinationGlobalIndex = 0;
        if (action == UXCollectionUpdateActionMove) {
            NSIndexPath *newIndexPath = [updateItem _newIndexPath];
            if ([updateItem _isSectionOperation]) {
                newIndexPath = [NSIndexPath indexPathForItem:0 inSection:[newIndexPath section]];
            }
            destinationGlobalIndex = [_newModel globalIndexForItemAtIndexPath:newIndexPath];
        }

        for (NSInteger globalItem = [affectedItems firstIndex]; globalItem != NSNotFound; globalItem = [affectedItems indexGreaterThanIndex:globalItem]) {
            if (action == UXCollectionUpdateActionDelete) {
                _oldGlobalItemMap[globalItem] = NSNotFound;
                NSInteger currentOldCount = [_oldModel numberOfItems];
                for (NSInteger following = globalItem + 1; following < currentOldCount; following++) {
                    if (_oldGlobalItemMap[following] != NSNotFound) {
                        _oldGlobalItemMap[following]--;
                    }
                }
            } else if (action == UXCollectionUpdateActionInsert) {
                for (NSInteger oldItem = 0; oldItem < oldGlobalItemCount; oldItem++) {
                    NSInteger mapped = _oldGlobalItemMap[oldItem];
                    if (mapped != NSNotFound && mapped >= globalItem && ![_movedItems containsIndex:mapped]) {
                        _oldGlobalItemMap[oldItem]++;
                        if (_oldGlobalItemMap[oldItem] >= newGlobalItemCount) {
                            [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                                                object:self
                                                                                  file:@"UXCollectionViewUpdate.m"
                                                                            lineNumber:311
                                                                           description:@"row is out of bounds of newGlobalItemCount"];
                        }
                    }
                }
                [insertedTrackingItems addIndex:globalItem];
            } else if (action == UXCollectionUpdateActionMove) {
                if (_oldGlobalItemMap[globalItem] != NSNotFound) {
                    if (destinationGlobalIndex >= newGlobalItemCount) {
                        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                                            object:self
                                                                              file:@"UXCollectionViewUpdate.m"
                                                                        lineNumber:318
                                                                       description:@"newGlobalRowForDestination is out of bounds of newGlobalItemCount"];
                    }
                    _oldGlobalItemMap[globalItem] = destinationGlobalIndex;
                    [_movedItems addIndex:destinationGlobalIndex];
                    [movedSourceItems addIndex:globalItem];
                    destinationGlobalIndex++;
                    hasMoves = YES;
                }
            }
        }
    }

    if (newGlobalItemCount != 0 && hasMoves) {
        NSInteger destination = 0;
        for (NSInteger newItem = 0; newItem < newGlobalItemCount; newItem++) {
            if (![_movedItems containsIndex:newItem] && ![insertedTrackingItems containsIndex:newItem]) {
                if (destination >= oldGlobalItemCount) {
                    break;
                }
                while (_oldGlobalItemMap[destination] == NSNotFound || [movedSourceItems containsIndex:destination]) {
                    destination++;
                    if (destination == oldGlobalItemCount) {
                        goto buildNewMap;
                    }
                }
                _oldGlobalItemMap[destination++] = newItem;
            }
        }
    }

buildNewMap:
    for (NSInteger oldItem = 0; oldItem < oldGlobalItemCount; oldItem++) {
        NSInteger mapped = _oldGlobalItemMap[oldItem];
        if (mapped != NSNotFound) {
            _newGlobalItemMap[mapped] = oldItem;
        }
    }
}

#pragma mark - Supplementary Updates

- (void)_computeSupplementaryUpdates {
    NSInteger oldSectionCount = [_oldModel numberOfSections];
    NSInteger newSectionCount = [_newModel numberOfSections];
    _deletedSupplementaryTopLevelIndexesDict = [[NSMutableDictionary alloc] init];
    _insertedSupplementaryTopLevelIndexesDict = [[NSMutableDictionary alloc] init];
    _deletedSupplementaryIndexesSectionArray = [[NSMutableArray alloc] initWithCapacity:oldSectionCount];
    _insertedSupplementaryIndexesSectionArray = [[NSMutableArray alloc] initWithCapacity:newSectionCount];

    for (NSInteger section = 0; section < oldSectionCount; section++) {
        [_deletedSupplementaryIndexesSectionArray addObject:[NSMutableDictionary dictionary]];
    }
    for (NSInteger section = 0; section < newSectionCount; section++) {
        [_insertedSupplementaryIndexesSectionArray addObject:[NSMutableDictionary dictionary]];
    }

    NSSet<NSString *> *oldKinds = [_oldModel knownSupplementaryElementKinds];
    NSSet<NSString *> *allKinds = [_newModel knownSupplementaryElementKinds];
    if (oldKinds) {
        allKinds = [oldKinds setByAddingObjectsFromSet:allKinds];
    }

    for (NSString *elementKind in allKinds) {
        id layout = [(id)_collectionView collectionViewLayout];
        NSArray<NSIndexPath *> *deletedSupplementary = (NSArray<NSIndexPath *> *)[layout indexPathsToDeleteForSupplementaryViewOfKind:elementKind];
        NSArray<NSIndexPath *> *deletedDecoration = (NSArray<NSIndexPath *> *)[layout indexPathsToDeleteForDecorationViewOfKind:elementKind];
        NSArray<NSIndexPath *> *deletedAll = deletedSupplementary ? [deletedSupplementary arrayByAddingObjectsFromArray:deletedDecoration] : deletedDecoration;
        for (NSIndexPath *indexPath in deletedAll) {
            NSMutableDictionary *targetDict = ([indexPath length] == 1) ? _deletedSupplementaryTopLevelIndexesDict : [_deletedSupplementaryIndexesSectionArray objectAtIndexedSubscript:[indexPath section]];
            NSMutableIndexSet *indexes = [targetDict objectForKeyedSubscript:elementKind];
            if (!indexes) {
                indexes = [[NSMutableIndexSet alloc] init];
                [targetDict setObject:indexes forKeyedSubscript:elementKind];
            }
            [indexes addIndex:([indexPath length] == 1) ? [indexPath indexAtPosition:0] : [indexPath item]];
        }

        NSArray<NSIndexPath *> *insertedSupplementary = (NSArray<NSIndexPath *> *)[layout indexPathsToInsertForSupplementaryViewOfKind:elementKind];
        NSArray<NSIndexPath *> *insertedDecoration = (NSArray<NSIndexPath *> *)[layout indexPathsToInsertForDecorationViewOfKind:elementKind];
        NSArray<NSIndexPath *> *insertedAll = insertedSupplementary ? [insertedSupplementary arrayByAddingObjectsFromArray:insertedDecoration] : insertedDecoration;
        for (NSIndexPath *indexPath in insertedAll) {
            NSMutableDictionary *targetDict = ([indexPath length] == 1) ? _insertedSupplementaryTopLevelIndexesDict : [_insertedSupplementaryIndexesSectionArray objectAtIndexedSubscript:[indexPath section]];
            NSMutableIndexSet *indexes = [targetDict objectForKeyedSubscript:elementKind];
            if (!indexes) {
                indexes = [[NSMutableIndexSet alloc] init];
                [targetDict setObject:indexes forKeyedSubscript:elementKind];
            }
            [indexes addIndex:([indexPath length] == 1) ? [indexPath indexAtPosition:0] : [indexPath item]];
        }
    }
}

#pragma mark - Gaps

- (CGRect)_frameForUpdateItem:(UXCollectionViewUpdateItem *)updateItem usingData:(UXCollectionViewData *)data {
    NSIndexPath *indexPath = [updateItem _indexPath];
    if (![updateItem _isSectionOperation]) {
        return ((UXCollectionViewLayoutAttributes *)[data layoutAttributesForItemAtIndexPath:indexPath]).frame;
    }

    CGRect unionFrame = CGRectNull;
    NSInteger section = [indexPath section];
    NSInteger itemCount = [data numberOfItemsInSection:section];
    NSInteger globalIndex = [data globalIndexForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:[indexPath section]]];
    if (globalIndex != NSNotFound) {
        for (NSInteger offset = 0; offset < itemCount; offset++) {
            CGRect itemFrame = ((UXCollectionViewLayoutAttributes *)[data layoutAttributesForGlobalItemIndex:globalIndex + offset]).frame;
            unionFrame = CGRectUnion(unionFrame, itemFrame);
        }
        for (UXCollectionViewLayoutAttributes *attributes in [data layoutAttributesForElementsInSection:section]) {
            unionFrame = CGRectUnion(unionFrame, attributes.frame);
        }
    }
    return unionFrame;
}

- (NSIndexPath *)_adjustedIndexPathForGapMergeUsingIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = [indexPath item];
    NSInteger section = [indexPath section];
    for (UXCollectionViewUpdateItem *updateItem in [self updateItemsSortedByIndexPaths]) {
        NSInteger delta = ([updateItem _action] == UXCollectionUpdateActionDelete) ? 1 : -1;
        NSIndexPath *itemIndexPath = [updateItem _indexPath];
        if ([updateItem _isSectionOperation]) {
            if ([[updateItem _indexPath] section] < section) {
                section += delta;
            }
        }
        if ([itemIndexPath section] == section) {
            if ([[updateItem _indexPath] item] < item) {
                item += delta;
            }
        }
    }
    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (BOOL)_updateItem:(UXCollectionViewUpdateItem *)firstItem isContiguousWith:(UXCollectionViewUpdateItem *)secondItem {
    if ([firstItem _action] != [secondItem _action]) {
        return NO;
    }
    NSComparisonResult comparison = [firstItem compareIndexPaths:secondItem];
    UXCollectionViewUpdateItem *lowerItem = (comparison == NSOrderedAscending) ? firstItem : secondItem;
    UXCollectionViewUpdateItem *upperItem = (comparison == NSOrderedAscending) ? secondItem : firstItem;
    UXCollectionViewData *data = ([firstItem _action] == UXCollectionUpdateActionInsert) ? _newModel : _oldModel;
    CGRect lowerFrame = [self _frameForUpdateItem:lowerItem usingData:data];
    CGRect upperFrame = [self _frameForUpdateItem:upperItem usingData:data];
    return CGRectGetMaxY(lowerFrame) == CGRectGetMinY(upperFrame);
}

- (void)_computeGaps {
    _gaps = [[NSMutableArray alloc] init];
    UXCollectionViewUpdateGap *currentGap = nil;
    BOOL sawInsert = NO;

    for (UXCollectionViewUpdateItem *updateItem in _updateItems) {
        if ([updateItem _action] == UXCollectionUpdateActionDelete) {
            if (currentGap && [self _updateItem:updateItem isContiguousWith:[currentGap firstUpdateItem]]) {
                [currentGap setFirstUpdateItem:updateItem];
                [currentGap addUpdateItem:updateItem];
            } else {
                currentGap = [UXCollectionViewUpdateGap gapWithUpdateItem:updateItem];
                [_gaps addObject:currentGap];
            }
        } else if ([updateItem _action] == UXCollectionUpdateActionInsert) {
            if (currentGap && sawInsert && [self _updateItem:updateItem isContiguousWith:[[currentGap insertItems] lastObject]]) {
                [currentGap setLastUpdateItem:updateItem];
                [currentGap addUpdateItem:updateItem];
            } else {
                BOOL merged = NO;
                for (UXCollectionViewUpdateGap *gap in _gaps) {
                    currentGap = gap;
                    if (![gap isDeleteBasedGap]) {
                        break;
                    }
                    NSIndexPath *adjustedIndexPath = [self _adjustedIndexPathForGapMergeUsingIndexPath:[updateItem _indexPath]];
                    NSComparisonResult compareFirst = [adjustedIndexPath compare:[[gap firstUpdateItem] _indexPath]];
                    NSComparisonResult compareLast = [adjustedIndexPath compare:[[gap lastUpdateItem] _indexPath]];
                    if (compareFirst != NSOrderedAscending && compareLast != NSOrderedDescending) {
                        [gap addUpdateItem:updateItem];
                        sawInsert = YES;
                        merged = YES;
                        break;
                    }
                }
                if (!merged) {
                    currentGap = [UXCollectionViewUpdateGap gapWithUpdateItem:updateItem];
                    [_gaps addObject:currentGap];
                    sawInsert = YES;
                }
            }
        }
        [updateItem _setGap:currentGap];
    }
}

#pragma mark - Supplementary Index Path Mapping

- (NSIndexPath *)newIndexPathForSupplementaryElementOfKind:(NSString *)kind oldIndexPath:(NSIndexPath *)oldIndexPath {
    NSInteger oldSection = [oldIndexPath section];
    NSInteger newSection = _oldSectionMap[oldSection];
    if (newSection == NSNotFound) {
        return nil;
    }
    NSInteger oldItem = [oldIndexPath item];
    if (oldItem == NSNotFound) {
        return [NSIndexPath indexPathWithIndex:newSection];
    }
    if (!_deletedSupplementaryIndexesSectionArray || !_insertedSupplementaryIndexesSectionArray) {
        return nil;
    }
    if (oldSection < 0 || oldSection >= (NSInteger)[_deletedSupplementaryIndexesSectionArray count]) {
        NSLog(@"old section %ld is out of bounds for kind %@ with %@", (long)oldSection, kind, _deletedSupplementaryIndexesSectionArray);
        return nil;
    }
    if (newSection < 0 || newSection >= (NSInteger)[_insertedSupplementaryIndexesSectionArray count]) {
        NSLog(@"new section %ld is out of bounds for kind %@ with %@", (long)oldSection, kind, _insertedSupplementaryIndexesSectionArray);
        return nil;
    }
    NSInteger deletedBefore = [[[_deletedSupplementaryIndexesSectionArray objectAtIndexedSubscript:oldSection] valueForKey:kind] countOfIndexesInRange:NSMakeRange(0, oldItem)];
    NSInteger adjustedItem = oldItem - deletedBefore;
    NSInteger insertedBefore = [[[_insertedSupplementaryIndexesSectionArray objectAtIndexedSubscript:newSection] valueForKey:kind] countOfIndexesInRange:NSMakeRange(0, adjustedItem + 1)];
    NSInteger newItem = insertedBefore + adjustedItem;
    return [NSIndexPath indexPathForItem:newItem inSection:newSection];
}

- (NSIndexPath *)oldIndexPathForSupplementaryElementOfKind:(NSString *)kind newIndexPath:(NSIndexPath *)newIndexPath {
    NSInteger newSection = [newIndexPath section];
    NSInteger oldSection = _newSectionMap[newSection];
    if (oldSection == NSNotFound) {
        return nil;
    }
    NSInteger newItem = [newIndexPath item];
    if (newItem == NSNotFound) {
        return [NSIndexPath indexPathWithIndex:oldSection];
    }
    NSInteger insertedBefore = [[[_insertedSupplementaryIndexesSectionArray objectAtIndexedSubscript:newSection] valueForKey:kind] countOfIndexesInRange:NSMakeRange(0, newItem)];
    NSInteger adjustedItem = newItem - insertedBefore;
    NSInteger deletedBefore = [[[_deletedSupplementaryIndexesSectionArray objectAtIndexedSubscript:oldSection] valueForKey:kind] countOfIndexesInRange:NSMakeRange(0, adjustedItem + 1)];
    NSInteger oldItem = deletedBefore + adjustedItem;
    return [NSIndexPath indexPathForItem:oldItem inSection:oldSection];
}

@end
