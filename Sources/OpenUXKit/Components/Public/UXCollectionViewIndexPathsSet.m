#import <OpenUXKit/UXCollectionViewIndexPathsSet+Internal.h>
#import <OpenUXKit/UXCollectionViewMutableIndexPathsSet.h>
#import <OpenUXKit/_UXCollectionViewSectionItemIndexes.h>
#import <OpenUXKit/UXKitPrivateUtilites.h>

@implementation UXCollectionViewIndexPathsSet

+ (instancetype)indexPathsSet {
    return [[self alloc] init];
}

+ (instancetype)indexPathsSetWithIndexPath:(NSIndexPath *)indexPath {
    return [[self alloc] initWithIndexPath:indexPath];
}

+ (instancetype)indexPathsSetWithIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    return [[self alloc] initWithIndexPaths:indexPaths];
}

+ (instancetype)indexPathsSetWithIndexPathsSet:(UXCollectionViewIndexPathsSet *)indexPathsSet {
    return [[self alloc] initWithIndexPathsSet:indexPathsSet];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _sectionIndexes = [[NSMutableIndexSet alloc] init];
        if (!_sectionIndexes) {
            return nil;
        }
        _sectionToItemIndexesMap = [[NSMutableDictionary alloc] init];
        if (!_sectionToItemIndexesMap) {
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath {
    self = [self init];
    if (self && indexPath) {
        [self _addOneIndexPath:indexPath];
    }
    return self;
}

- (instancetype)initWithIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    self = [self init];
    if (self) {
        for (NSIndexPath *indexPath in indexPaths) {
            if (![indexPath isKindOfClass:[NSIndexPath class]]) {
                [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                                    object:self
                                                                      file:@"UXCollectionViewIndexPathsSet.m"
                                                                lineNumber:410
                                                               description:@"unexpected object: %@", indexPath];
            }
            [self _addOneIndexPath:indexPath];
        }
    }
    return self;
}

- (instancetype)initWithIndexPathsSet:(UXCollectionViewIndexPathsSet *)indexPathsSet {
    self = [self init];
    if (self && indexPathsSet) {
        [self _addIndexPathsSet:indexPathsSet];
    }
    return self;
}

- (_UXCollectionViewSectionItemIndexes *)_itemIndexesForSection:(NSUInteger)section allowingCreation:(BOOL)allowingCreation {
    NSNumber *sectionKey = [NSNumber numberWithUnsignedInteger:section];
    _UXCollectionViewSectionItemIndexes *itemIndexes = [_sectionToItemIndexesMap objectForKey:sectionKey];
    if (allowingCreation && !itemIndexes) {
        itemIndexes = [[_UXCollectionViewSectionItemIndexes alloc] init];
        [_sectionToItemIndexesMap setObject:itemIndexes forKey:sectionKey];
        [_sectionIndexes addIndex:section];
        if ([_sectionToItemIndexesMap count] != [_sectionIndexes count]) {
            [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                                object:self
                                                                  file:@"UXCollectionViewIndexPathsSet.m"
                                                            lineNumber:564
                                                           description:@"section index and item map counts are out of sync"];
        }
    }
    return itemIndexes;
}

- (void)_removeItemIndexesForSection:(NSUInteger)section {
    NSNumber *sectionKey = [NSNumber numberWithUnsignedInteger:section];
    if ([_sectionToItemIndexesMap objectForKey:sectionKey]) {
        [_sectionToItemIndexesMap removeObjectForKey:sectionKey];
        [_sectionIndexes removeIndex:section];
        if ([_sectionToItemIndexesMap count] != [_sectionIndexes count]) {
            [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                                object:self
                                                                  file:@"UXCollectionViewIndexPathsSet.m"
                                                            lineNumber:582
                                                           description:@"section index and item map counts are out of sync"];
        }
    }
}

- (void)_addOneIndexPath:(NSIndexPath *)indexPath {
    _UXCollectionViewSectionItemIndexes *itemIndexes = [self _itemIndexesForSection:[indexPath indexAtPosition:0] allowingCreation:YES];
    if (itemIndexes) {
        [itemIndexes addItem:[indexPath indexAtPosition:1]];
    }
}

- (void)_removeOneIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath indexAtPosition:0];
    _UXCollectionViewSectionItemIndexes *itemIndexes = [self _itemIndexesForSection:section allowingCreation:NO];
    if (itemIndexes) {
        [itemIndexes removeItem:[indexPath indexAtPosition:1]];
        if (![itemIndexes itemCount]) {
            [self _removeItemIndexesForSection:section];
        }
    }
}

- (void)_addIndexPathsSet:(UXCollectionViewIndexPathsSet *)indexPathsSet {
    [indexPathsSet->_sectionToItemIndexesMap enumerateKeysAndObjectsUsingBlock:^(NSNumber *sectionKey, _UXCollectionViewSectionItemIndexes *itemIndexes, BOOL *stop) {
        NSUInteger section = [sectionKey isKindOfClass:[NSNumber class]] ? [sectionKey unsignedIntegerValue] : NSNotFound;
        _UXCollectionViewSectionItemIndexes *targetItemIndexes = [self _itemIndexesForSection:section allowingCreation:YES];
        [targetItemIndexes addSectionItemIndexes:itemIndexes];
    }];
}

- (void)_enumerateSectionItemIndexesWithBlock:(void (NS_NOESCAPE ^)(NSUInteger section, _UXCollectionViewSectionItemIndexes *itemIndexes, BOOL *stop))block {
    __block BOOL stop = NO;
    [_sectionToItemIndexesMap enumerateKeysAndObjectsUsingBlock:^(NSNumber *sectionKey, _UXCollectionViewSectionItemIndexes *itemIndexes, BOOL *innerStop) {
        if ([sectionKey isKindOfClass:[NSNumber class]]) {
            NSUInteger section = [sectionKey unsignedIntegerValue];
            if (section != NSNotFound) {
                block(section, itemIndexes, &stop);
                if (stop) {
                    *innerStop = YES;
                }
            }
        }
    }];
}

- (NSUInteger)count {
    __block NSUInteger total = 0;
    [self _enumerateSectionItemIndexesWithBlock:^(NSUInteger section, _UXCollectionViewSectionItemIndexes *itemIndexes, BOOL *stop) {
        total += [itemIndexes itemCount];
    }];
    return total;
}

- (NSIndexSet *)sections {
    return [_sectionIndexes copy];
}

- (NSArray<NSIndexPath *> *)allIndexPaths {
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray arrayWithCapacity:[self count]];
    [self _enumerateSectionItemIndexesWithBlock:^(NSUInteger section, _UXCollectionViewSectionItemIndexes *itemIndexes, BOOL *stop) {
        [indexPaths addObjectsFromArray:[itemIndexes itemIndexPathsForSection:section]];
    }];
    return indexPaths;
}

- (BOOL)containsIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return NO;
    }
    _UXCollectionViewSectionItemIndexes *itemIndexes = [self _itemIndexesForSection:[indexPath indexAtPosition:0] allowingCreation:NO];
    if (!itemIndexes) {
        return NO;
    }
    return [itemIndexes containsItem:[indexPath indexAtPosition:1]];
}

- (NSIndexSet *)itemsInSection:(NSInteger)section {
    _UXCollectionViewSectionItemIndexes *itemIndexes = [_sectionToItemIndexesMap objectForKey:[NSNumber numberWithUnsignedInteger:section]];
    if (itemIndexes) {
        return [itemIndexes items];
    }
    return nil;
}

- (void)enumerateIndexPathsUsingBlock:(void (NS_NOESCAPE ^)(NSIndexPath *indexPath, BOOL *stop))block {
    __block BOOL stop = NO;
    [self _enumerateSectionItemIndexesWithBlock:^(NSUInteger section, _UXCollectionViewSectionItemIndexes *itemIndexes, BOOL *outerStop) {
        [itemIndexes enumerateItemsUsingBlock:^(NSUInteger item, BOOL *innerStop) {
            NSUInteger indexes[2] = {section, item};
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
            block(indexPath, &stop);
            if (stop) {
                *innerStop = YES;
            }
        }];
        if (stop) {
            *outerStop = YES;
        }
    }];
}

- (NSIndexPath *)firstIndexPath {
    NSUInteger section = [_sectionIndexes firstIndex];
    if (section != NSNotFound) {
        _UXCollectionViewSectionItemIndexes *itemIndexes = [self _itemIndexesForSection:section allowingCreation:NO];
        if (!itemIndexes) {
            return nil;
        }
        NSUInteger item = [itemIndexes firstItem];
        if (item != NSNotFound) {
            NSUInteger indexes[2] = {section, item};
            return [NSIndexPath indexPathWithIndexes:indexes length:2];
        }
    }
    return nil;
}

- (NSIndexPath *)lastIndexPath {
    NSUInteger section = [_sectionIndexes lastIndex];
    if (section != NSNotFound) {
        _UXCollectionViewSectionItemIndexes *itemIndexes = [self _itemIndexesForSection:section allowingCreation:NO];
        if (!itemIndexes) {
            return nil;
        }
        NSUInteger item = [itemIndexes lastItem];
        if (item != NSNotFound) {
            NSUInteger indexes[2] = {section, item};
            return [NSIndexPath indexPathWithIndexes:indexes length:2];
        }
    }
    return nil;
}

- (NSArray<NSIndexPath *> *)indexPathsForSection:(NSInteger)section {
    _UXCollectionViewSectionItemIndexes *itemIndexes = [_sectionToItemIndexesMap objectForKey:[NSNumber numberWithUnsignedInteger:section]];
    if (itemIndexes) {
        return [itemIndexes itemIndexPathsForSection:section];
    }
    return nil;
}

- (NSArray<NSIndexPath *> *)indexPathsForSections:(NSIndexSet *)sections {
    NSMutableArray<NSIndexPath *> *result = [NSMutableArray array];
    for (NSUInteger section = [sections firstIndex]; section != NSNotFound; section = [sections indexGreaterThanIndex:section]) {
        NSArray<NSIndexPath *> *indexPaths = [self indexPathsForSection:section];
        if (indexPaths) {
            [result addObjectsFromArray:indexPaths];
        }
    }
    return result;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    NSArray<NSIndexPath *> *allIndexPaths = [self allIndexPaths];
    return [[UXCollectionViewMutableIndexPathsSet allocWithZone:zone] initWithIndexPaths:allIndexPaths];
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:[UXCollectionViewIndexPathsSet class]]) {
        return NO;
    }
    UXCollectionViewIndexPathsSet *other = object;
    if (![_sectionIndexes isEqualToIndexSet:other->_sectionIndexes]) {
        return NO;
    }
    for (NSUInteger section = [_sectionIndexes firstIndex]; section != NSNotFound; section = [_sectionIndexes indexGreaterThanIndex:section]) {
        _UXCollectionViewSectionItemIndexes *selfItemIndexes = [self _itemIndexesForSection:section allowingCreation:NO];
        _UXCollectionViewSectionItemIndexes *otherItemIndexes = [other _itemIndexesForSection:section allowingCreation:NO];
        if (![selfItemIndexes isEqual:otherItemIndexes]) {
            return NO;
        }
    }
    return YES;
}

- (NSString *)description {
    NSMutableString *result = [NSMutableString string];
    [result appendString:[super description]];
    [result appendFormat:@" (%lu items)", (unsigned long)[self count]];
    for (NSUInteger section = [_sectionIndexes firstIndex]; section != NSNotFound; section = [_sectionIndexes indexGreaterThanIndex:section]) {
        [result appendFormat:@" %lu:%@", (unsigned long)section, [self _itemIndexesForSection:section allowingCreation:NO]];
    }
    return result;
}

@end
