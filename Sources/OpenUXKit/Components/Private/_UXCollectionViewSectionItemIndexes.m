#import <OpenUXKit/_UXCollectionViewSectionItemIndexes.h>
#import <OpenUXKit/NSIndexPath+UXCollectionViewAdditions.h>
#import <OpenUXKit/UXKitPrivateUtilites.h>

@interface _UXCollectionViewSectionItemIndexes () {
    NSMutableIndexSet *_itemIndexesSet;
}
@end

@implementation _UXCollectionViewSectionItemIndexes

- (instancetype)init {
    self = [super init];
    if (self) {
        _itemIndexesSet = [[NSMutableIndexSet alloc] init];
        if (!_itemIndexesSet) {
            return nil;
        }
    }
    return self;
}

- (void)addItem:(NSUInteger)item {
    [_itemIndexesSet addIndex:item];
}

- (void)removeItem:(NSUInteger)item {
    [_itemIndexesSet removeIndex:item];
}

- (BOOL)containsItem:(NSUInteger)item {
    return [_itemIndexesSet containsIndex:item];
}

- (void)addItemsInRange:(NSRange)range {
    [_itemIndexesSet addIndexesInRange:range];
}

- (void)removeItemsInRange:(NSRange)range {
    [_itemIndexesSet removeIndexesInRange:range];
}

- (void)addSectionItemIndexes:(_UXCollectionViewSectionItemIndexes *)sectionItemIndexes {
    if (sectionItemIndexes) {
        [_itemIndexesSet addIndexes:sectionItemIndexes->_itemIndexesSet];
    }
}

- (void)removeSectionItemIndexes:(_UXCollectionViewSectionItemIndexes *)sectionItemIndexes {
    if (sectionItemIndexes) {
        [_itemIndexesSet removeIndexes:sectionItemIndexes->_itemIndexesSet];
    }
}

- (void)adjustForDeletionOfItem:(NSUInteger)item {
    if (item != NSNotFound) {
        [_itemIndexesSet removeIndex:item];
        [_itemIndexesSet shiftIndexesStartingAtIndex:item + 1 by:-1];
    }
}

- (void)adjustForDeletionOfItems:(NSIndexSet *)items {
    [items enumerateRangesWithOptions:NSEnumerationReverse usingBlock:^(NSRange range, BOOL *stop) {
        [self->_itemIndexesSet removeIndexesInRange:range];
        [self->_itemIndexesSet shiftIndexesStartingAtIndex:range.location + range.length by:-(NSInteger)range.length];
    }];
}

- (void)adjustForInsertionOfItem:(NSUInteger)item {
    if (item != NSNotFound) {
        [_itemIndexesSet shiftIndexesStartingAtIndex:item by:1];
    }
}

- (void)adjustForInsertionOfItems:(NSIndexSet *)items {
    [items enumerateRangesWithOptions:0 usingBlock:^(NSRange range, BOOL *stop) {
        [self->_itemIndexesSet shiftIndexesStartingAtIndex:range.location by:(NSInteger)range.length];
    }];
}

- (NSIndexSet *)items {
    return [_itemIndexesSet copy];
}

- (NSUInteger)itemCount {
    return [_itemIndexesSet count];
}

- (NSUInteger)firstItem {
    return [_itemIndexesSet firstIndex];
}

- (NSUInteger)lastItem {
    return [_itemIndexesSet lastIndex];
}

- (NSArray<NSIndexPath *> *)itemIndexPathsForSection:(NSUInteger)section {
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray arrayWithCapacity:[_itemIndexesSet count]];
    for (NSUInteger index = [_itemIndexesSet firstIndex]; index != NSNotFound; index = [_itemIndexesSet indexGreaterThanIndex:index]) {
        NSUInteger indexes[2] = {section, index};
        [indexPaths addObject:[NSIndexPath indexPathWithIndexes:indexes length:2]];
    }
    return indexPaths;
}

- (void)enumerateItemsUsingBlock:(void (NS_NOESCAPE ^)(NSUInteger item, BOOL *stop))block {
    BOOL stop = NO;
    for (NSUInteger index = [_itemIndexesSet firstIndex]; index != NSNotFound; index = [_itemIndexesSet indexGreaterThanIndex:index]) {
        block(index, &stop);
        if (stop) {
            break;
        }
    }
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:[_UXCollectionViewSectionItemIndexes class]]) {
        return NO;
    }
    _UXCollectionViewSectionItemIndexes *other = object;
    return [_itemIndexesSet isEqualToIndexSet:other->_itemIndexesSet];
}

- (id)copyWithZone:(NSZone *)zone {
    _UXCollectionViewSectionItemIndexes *copy = [[_UXCollectionViewSectionItemIndexes allocWithZone:zone] init];
    if (copy) {
        [copy->_itemIndexesSet addIndexes:_itemIndexesSet];
    }
    return copy;
}

- (NSString *)description {
    NSMutableString *result = [NSMutableString string];
    __block BOOL needsSeparator = NO;
    [_itemIndexesSet enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        if (needsSeparator) {
            [result appendString:@","];
        }
        if (range.length < 2) {
            [result appendFormat:@"%lu", (unsigned long)range.location];
        } else {
            [result appendFormat:@"%lu-%lu", (unsigned long)range.location, (unsigned long)(range.location + range.length - 1)];
        }
        needsSeparator = YES;
    }];
    return result;
}

@end
