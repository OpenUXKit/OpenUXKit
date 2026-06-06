#import "UXCollectionViewData.h"
#import "UXCollectionView.h"
#import "UXCollectionViewLayout.h"
#import "UXCollectionViewLayout+Internal.h"
#import "UXCollectionViewLayoutAttributes.h"
#import "UXCollectionViewLayoutAttributes+Internal.h"

@interface NSObject (UXCollectionViewDataSPI)
- (id)dataSource;
- (NSInteger)numberOfSectionsInCollectionView:(id)collectionView;
- (NSInteger)collectionView:(id)collectionView numberOfItemsInSection:(NSInteger)section;
- (BOOL)_dataSourceImplementsNumberOfSections;
@end

typedef NS_OPTIONS(uint8_t, UXCollectionViewDataFlags) {
    UXCollectionViewDataFlagContentSizeValid  = 1 << 0,
    UXCollectionViewDataFlagItemCountsValid   = 1 << 1,
    UXCollectionViewDataFlagLayoutPrepared    = 1 << 2,
    UXCollectionViewDataFlagLayoutLocked      = 1 << 3,
};

@interface UXCollectionViewData () {
    __unsafe_unretained UXCollectionView *_collectionView;
    UXCollectionViewLayout *_layout;
    NSMapTable *_screenPageMap;
    __strong id *_globalItems;
    NSMutableDictionary *_supplementaryLayoutAttributes;
    NSMutableDictionary *_decorationLayoutAttributes;
    NSMutableDictionary *_invalidatedSupplementaryViews;
    CGRect _validLayoutRect;
    NSInteger _numItems;
    NSInteger _numSections;
    NSInteger *_sectionItemCounts;
    NSInteger _lastSectionTestedForNumberOfItemsBeforeSection;
    NSInteger _lastResultForNumberOfItemsBeforeSection;
    CGSize _contentSize;
    uint8_t _collectionViewDataFlags;
    NSMutableArray *_clonedLayoutAttributes;
}
@end

@implementation UXCollectionViewData

@synthesize clonedLayoutAttributes = _clonedLayoutAttributes;

- (instancetype)initWithCollectionView:(UXCollectionView *)collectionView layout:(UXCollectionViewLayout *)layout {
    self = [super init];
    if (self) {
        _collectionView = collectionView;
        _layout = layout;
        _supplementaryLayoutAttributes = [[NSMutableDictionary alloc] init];
        _decorationLayoutAttributes = [[NSMutableDictionary alloc] init];
        _clonedLayoutAttributes = [[NSMutableArray alloc] init];

        NSPointerFunctions *keyFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsStrongMemory];
        NSPointerFunctions *valueFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsStrongMemory];
        _screenPageMap = [[NSMapTable alloc] initWithKeyPointerFunctions:keyFunctions valuePointerFunctions:valueFunctions capacity:0];

        _lastSectionTestedForNumberOfItemsBeforeSection = NSNotFound;
        _lastResultForNumberOfItemsBeforeSection = NSNotFound;
    }
    return self;
}

- (void)dealloc {
    if (_globalItems) {
        for (NSInteger i = 0; i < _numItems; i++) {
            _globalItems[i] = nil;
        }
        free(_globalItems);
    }
    free(_sectionItemCounts);
}

#pragma mark - Flag accessors

- (BOOL)layoutIsPrepared {
    return (_collectionViewDataFlags & UXCollectionViewDataFlagLayoutPrepared) != 0;
}

- (BOOL)isLayoutLocked {
    return (_collectionViewDataFlags & UXCollectionViewDataFlagLayoutLocked) != 0;
}

- (void)setLayoutLocked:(BOOL)layoutLocked {
    if (layoutLocked) {
        _collectionViewDataFlags |= UXCollectionViewDataFlagLayoutLocked;
    } else {
        _collectionViewDataFlags &= ~UXCollectionViewDataFlagLayoutLocked;
    }
}

#pragma mark - Counts

- (void)_validateItemCounts {
    if ((_collectionViewDataFlags & UXCollectionViewDataFlagItemCountsValid) == 0) {
        [self _updateItemCounts];
    }
}

- (void)_updateItemCounts {
    if (_globalItems) {
        for (NSInteger i = 0; i < _numItems; i++) {
            _globalItems[i] = nil;
        }
    }

    id dataSource = [(id)_collectionView dataSource];
    NSInteger sectionCount;
    if ([(id)_collectionView _dataSourceImplementsNumberOfSections]) {
        sectionCount = [dataSource numberOfSectionsInCollectionView:_collectionView];
    } else {
        sectionCount = 1;
    }

    _numItems = 0;
    _numSections = sectionCount;
    _sectionItemCounts = (NSInteger *)realloc(_sectionItemCounts, sizeof(NSInteger) * (size_t)sectionCount);

    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
        NSInteger count = [dataSource collectionView:_collectionView numberOfItemsInSection:sectionIndex];
        if (count < 0) {
            [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                                object:self
                                                                  file:@"UXCollectionViewData.m"
                                                            lineNumber:226
                                                           description:@"invalid item count for section %ld", (long)sectionIndex];
            count = 0;
        }
        _sectionItemCounts[sectionIndex] = count;
        _numItems += count;
    }

    if (_numItems > 0) {
        _globalItems = (__strong id *)realloc(_globalItems, sizeof(id) * (size_t)_numItems);
        bzero(_globalItems, sizeof(id) * (size_t)_numItems);
    }

    _collectionViewDataFlags |= UXCollectionViewDataFlagItemCountsValid;
    _lastSectionTestedForNumberOfItemsBeforeSection = NSNotFound;
    _lastResultForNumberOfItemsBeforeSection = NSNotFound;
}

- (void)_validateContentSize {
    if ((_collectionViewDataFlags & UXCollectionViewDataFlagContentSizeValid) != 0) {
        return;
    }
    NSAssert((_collectionViewDataFlags & UXCollectionViewDataFlagLayoutLocked) == 0, @"trying to load collection view layout data when layout is locked");
    _contentSize = [_layout collectionViewContentSize];
    _collectionViewDataFlags |= UXCollectionViewDataFlagContentSizeValid;
}

- (void)_prepareToLoadData {
    if ((_collectionViewDataFlags & UXCollectionViewDataFlagLayoutPrepared) == 0) {
        NSAssert((_collectionViewDataFlags & UXCollectionViewDataFlagLayoutLocked) == 0, @"trying to load collection view layout data when layout is locked");
        [_layout prepareLayout];
        _collectionViewDataFlags |= UXCollectionViewDataFlagLayoutPrepared;
    }
    [self _validateItemCounts];
    [self _validateContentSize];
}

- (NSInteger)numberOfSections {
    [self _validateItemCounts];
    return _numSections;
}

- (NSInteger)numberOfItems {
    [self _validateItemCounts];
    return _numItems;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    [self _validateItemCounts];
    if (section < 0 || section >= _numSections) {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                            object:self
                                                              file:@"UXCollectionViewData.m"
                                                        lineNumber:529
                                                       description:@"request for number of items in section %ld when there are only %ld sections in the collection view", (long)section, (long)_numSections];
        return 0;
    }
    return _sectionItemCounts[section];
}

- (NSInteger)numberOfItemsBeforeSection:(NSInteger)section {
    [self _validateItemCounts];
    if (section < 0 || section > _numSections) {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                            object:self
                                                              file:@"UXCollectionViewData.m"
                                                        lineNumber:537
                                                       description:@"request for number of items before section %ld when there are only %ld sections in the collection view", (long)section, (long)_numSections];
        return 0;
    }

    NSInteger lastSection = _lastSectionTestedForNumberOfItemsBeforeSection;
    NSInteger result;
    if (lastSection != NSNotFound && lastSection <= section) {
        result = _lastResultForNumberOfItemsBeforeSection;
    } else {
        result = 0;
        lastSection = 0;
    }

    for (NSInteger i = lastSection; i < section; i++) {
        result += _sectionItemCounts[i];
    }

    _lastSectionTestedForNumberOfItemsBeforeSection = section;
    _lastResultForNumberOfItemsBeforeSection = result;
    return result;
}

- (NSInteger)globalIndexForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    if (section < 0 || section >= [self numberOfSections]) {
        return NSNotFound;
    }
    NSInteger item = indexPath.item;
    if (item < 0 || item >= [self numberOfItemsInSection:section]) {
        return NSNotFound;
    }
    return [self numberOfItemsBeforeSection:section] + item;
}

- (NSIndexPath *)indexPathForItemAtGlobalIndex:(NSInteger)globalIndex {
    [self _validateItemCounts];
    if (_numSections < 1) {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                            object:self
                                                              file:@"UXCollectionViewData.m"
                                                        lineNumber:627
                                                       description:@"request for index path for global index %ld when there are only %ld items in the collection view", (long)globalIndex, (long)[self numberOfItems]];
        return nil;
    }
    NSInteger remaining = globalIndex;
    for (NSInteger sectionIndex = 0; sectionIndex < _numSections; sectionIndex++) {
        NSInteger count = [self numberOfItemsInSection:sectionIndex];
        if (remaining < count) {
            return [NSIndexPath indexPathForItem:remaining inSection:sectionIndex];
        }
        remaining -= count;
    }
    [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                        object:self
                                                          file:@"UXCollectionViewData.m"
                                                    lineNumber:627
                                                   description:@"request for index path for global index %ld when there are only %ld items in the collection view", (long)globalIndex, (long)[self numberOfItems]];
    return nil;
}

#pragma mark - Rect queries

- (CGRect)collectionViewContentRect {
    [self _validateContentSize];
    return CGRectMake(0.0, 0.0, _contentSize.width, _contentSize.height);
}

- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [[self layoutAttributesForItemAtIndexPath:indexPath] frame];
}

- (CGRect)rectForGlobalItemIndex:(NSInteger)globalIndex {
    return [[self layoutAttributesForGlobalItemIndex:globalIndex] frame];
}

- (CGRect)rectForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UXCollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    return attributes ? attributes.frame : CGRectZero;
}

- (CGRect)rectForDecorationElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UXCollectionViewLayoutAttributes *attributes = [self layoutAttributesForDecorationViewOfKind:kind atIndexPath:indexPath];
    return attributes ? attributes.frame : CGRectZero;
}

#pragma mark - Layout attributes

- (UXCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self _prepareToLoadData];
    NSInteger globalIndex = [self globalIndexForItemAtIndexPath:indexPath];
    if (globalIndex == NSNotFound) {
        return nil;
    }
    UXCollectionViewLayoutAttributes *cached = _globalItems ? (__bridge UXCollectionViewLayoutAttributes *)(__bridge void *)_globalItems[globalIndex] : nil;
    if (cached) {
        return cached;
    }
    UXCollectionViewLayoutAttributes *attributes = [_layout layoutAttributesForItemAtIndexPath:indexPath];
    if (attributes && _globalItems) {
        [self _setLayoutAttributes:attributes atGlobalItemIndex:globalIndex];
    }
    return attributes;
}

- (UXCollectionViewLayoutAttributes *)layoutAttributesForGlobalItemIndex:(NSInteger)globalIndex {
    NSIndexPath *indexPath = [self indexPathForItemAtGlobalIndex:globalIndex];
    if (!indexPath) {
        return nil;
    }
    return [self layoutAttributesForItemAtIndexPath:indexPath];
}

- (void)_setLayoutAttributes:(UXCollectionViewLayoutAttributes *)attributes atGlobalItemIndex:(NSInteger)globalIndex {
    if (!_globalItems || globalIndex < 0 || globalIndex >= _numItems) {
        return;
    }
    _globalItems[globalIndex] = attributes;
}

- (NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    [self _prepareToLoadData];
    return [_layout layoutAttributesForElementsInRect:rect];
}

- (NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInSection:(NSInteger)section {
    [self _prepareToLoadData];
    NSMutableArray<UXCollectionViewLayoutAttributes *> *result = [NSMutableArray array];
    NSInteger itemsCount = [self numberOfItemsInSection:section];
    for (NSInteger itemIndex = 0; itemIndex < itemsCount; itemIndex++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:section];
        UXCollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        if (attributes) {
            [result addObject:attributes];
        }
    }
    [result addObjectsFromArray:[self existingSupplementaryLayoutAttributesInSection:section]];
    return result;
}

- (UXCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *kindDict = _supplementaryLayoutAttributes[kind];
    UXCollectionViewLayoutAttributes *cached = kindDict[indexPath];
    if (cached) {
        return cached;
    }
    UXCollectionViewLayoutAttributes *attributes = [_layout layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    if (attributes) {
        if (!kindDict) {
            kindDict = [NSMutableDictionary dictionary];
            _supplementaryLayoutAttributes[kind] = kindDict;
        }
        kindDict[indexPath] = attributes;
    }
    return attributes;
}

- (UXCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *kindDict = _decorationLayoutAttributes[kind];
    UXCollectionViewLayoutAttributes *cached = kindDict[indexPath];
    if (cached) {
        return cached;
    }
    UXCollectionViewLayoutAttributes *attributes = [_layout layoutAttributesForDecorationViewOfKind:kind atIndexPath:indexPath];
    if (attributes) {
        if (!kindDict) {
            kindDict = [NSMutableDictionary dictionary];
            _decorationLayoutAttributes[kind] = kindDict;
        }
        kindDict[indexPath] = attributes;
    }
    return attributes;
}

- (NSArray<UXCollectionViewLayoutAttributes *> *)existingSupplementaryLayoutAttributes {
    NSMutableArray<UXCollectionViewLayoutAttributes *> *result = [NSMutableArray array];
    for (NSMutableDictionary *kindDict in _supplementaryLayoutAttributes.objectEnumerator) {
        [result addObjectsFromArray:kindDict.allValues];
    }
    return result;
}

- (NSArray<UXCollectionViewLayoutAttributes *> *)existingSupplementaryLayoutAttributesWithMinimalIndexPathLength:(NSUInteger)length {
    NSMutableArray<UXCollectionViewLayoutAttributes *> *result = [NSMutableArray array];
    for (NSMutableDictionary *kindDict in _supplementaryLayoutAttributes.objectEnumerator) {
        [kindDict enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UXCollectionViewLayoutAttributes *attrs, BOOL *stop) {
            if (indexPath.length >= length) {
                [result addObject:attrs];
            }
        }];
    }
    return result;
}

- (NSArray<UXCollectionViewLayoutAttributes *> *)existingSupplementaryLayoutAttributesInSection:(NSInteger)section {
    NSMutableArray<UXCollectionViewLayoutAttributes *> *result = [NSMutableArray array];
    for (NSMutableDictionary *kindDict in _supplementaryLayoutAttributes.objectEnumerator) {
        [kindDict enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UXCollectionViewLayoutAttributes *attrs, BOOL *stop) {
            if (indexPath.length >= 2 && indexPath.section == section) {
                [result addObject:attrs];
            }
        }];
    }
    return result;
}

- (NSSet<NSString *> *)knownSupplementaryElementKinds {
    return [NSSet setWithArray:_supplementaryLayoutAttributes.allKeys];
}

- (NSSet<NSString *> *)knownDecorationElementKinds {
    return [NSSet setWithArray:_decorationLayoutAttributes.allKeys];
}

#pragma mark - Validation / invalidation

- (void)validateLayoutInRect:(CGRect)rect {
    [self _prepareToLoadData];
    if (!CGRectContainsRect(_validLayoutRect, rect)) {
        NSArray<UXCollectionViewLayoutAttributes *> *attributes = [_layout layoutAttributesForElementsInRect:rect];
        for (UXCollectionViewLayoutAttributes *attribute in attributes) {
            if ([attribute _isCell]) {
                NSInteger globalIndex = [self globalIndexForItemAtIndexPath:attribute.indexPath];
                if (globalIndex != NSNotFound) {
                    [self _setLayoutAttributes:attribute atGlobalItemIndex:globalIndex];
                }
            } else if ([attribute _isSupplementaryView]) {
                NSString *kind = [attribute _elementKind];
                if (kind) {
                    NSMutableDictionary *kindDict = _supplementaryLayoutAttributes[kind];
                    if (!kindDict) {
                        kindDict = [NSMutableDictionary dictionary];
                        _supplementaryLayoutAttributes[kind] = kindDict;
                    }
                    kindDict[attribute.indexPath] = attribute;
                }
            } else if ([attribute _isDecorationView]) {
                NSString *kind = [attribute _elementKind];
                if (kind) {
                    NSMutableDictionary *kindDict = _decorationLayoutAttributes[kind];
                    if (!kindDict) {
                        kindDict = [NSMutableDictionary dictionary];
                        _decorationLayoutAttributes[kind] = kindDict;
                    }
                    kindDict[attribute.indexPath] = attribute;
                }
            }
        }
        _validLayoutRect = CGRectUnion(_validLayoutRect, rect);
    }
}

- (void)validateSupplementaryViews {
    if (!_invalidatedSupplementaryViews) {
        return;
    }
    [_invalidatedSupplementaryViews enumerateKeysAndObjectsUsingBlock:^(NSString *kind, NSSet *indexPaths, BOOL *stop) {
        NSMutableDictionary *kindDict = self->_supplementaryLayoutAttributes[kind];
        for (NSIndexPath *indexPath in indexPaths) {
            UXCollectionViewLayoutAttributes *attrs = [self->_layout layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
            if (attrs) {
                if (!kindDict) {
                    kindDict = [NSMutableDictionary dictionary];
                    self->_supplementaryLayoutAttributes[kind] = kindDict;
                }
                kindDict[indexPath] = attrs;
            }
        }
    }];
    _invalidatedSupplementaryViews = nil;
}

- (void)invalidate:(BOOL)keepItemCounts {
    if ((_collectionViewDataFlags & UXCollectionViewDataFlagLayoutLocked) != 0) {
        return;
    }
    uint8_t mask;
    if (keepItemCounts) {
        mask = 0xF2;
    } else {
        mask = 0xF0;
    }
    _collectionViewDataFlags &= mask;
    _validLayoutRect = CGRectNull;
    [_supplementaryLayoutAttributes removeAllObjects];
    [_decorationLayoutAttributes removeAllObjects];
    _invalidatedSupplementaryViews = nil;
    [_screenPageMap removeAllObjects];
}

- (void)_loadEverything {
    [self _prepareToLoadData];
    NSInteger sections = [self numberOfSections];
    for (NSInteger section = 0; section < sections; section++) {
        NSInteger itemCount = [self numberOfItemsInSection:section];
        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            (void)[self layoutAttributesForItemAtIndexPath:indexPath];
        }
    }
}

- (NSValue *)_screenPageForPoint:(CGPoint)point {
    [self _validateContentSize];
    UXCollectionView *collectionView = _collectionView;
    CGFloat pageWidth = collectionView.documentVisibleRect.size.width;
    CGFloat pageHeight = collectionView.documentVisibleRect.size.height;
    if (pageWidth <= 0.0) pageWidth = _contentSize.width;
    if (pageHeight <= 0.0) pageHeight = _contentSize.height;
    NSInteger pageX = (pageWidth > 0.0) ? (NSInteger)floor(point.x / pageWidth) : 0;
    NSInteger pageY = (pageHeight > 0.0) ? (NSInteger)floor(point.y / pageHeight) : 0;
    NSValue *key = [NSValue valueWithBytes:(NSInteger[]){pageX, pageY} objCType:@encode(NSInteger[2])];
    NSValue *cached = [_screenPageMap objectForKey:key];
    if (cached) {
        return cached;
    }
    NSValue *value = [NSValue valueWithPoint:NSMakePoint(pageX, pageY)];
    [_screenPageMap setObject:value forKey:key];
    return value;
}

- (NSIndexPath *)_setupMutableIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return nil;
    }
    NSUInteger length = indexPath.length;
    NSUInteger indexes[length];
    [indexPath getIndexes:indexes];
    return [NSIndexPath indexPathWithIndexes:indexes length:length];
}

- (void)_setupMutableIndexPath:(NSIndexPath * _Nullable * _Nullable)indexPathOut forGlobalItemIndex:(NSInteger)globalItemIndex {
    if (!indexPathOut) {
        return;
    }
    NSIndexPath *indexPath = [self indexPathForItemAtGlobalIndex:globalItemIndex];
    *indexPathOut = [self _setupMutableIndexPath:indexPath];
}

- (void)invalidateSupplementaryViews:(NSSet<NSString *> *)kinds {
    if (!_invalidatedSupplementaryViews) {
        _invalidatedSupplementaryViews = [NSMutableDictionary dictionary];
    }
    for (NSString *kind in kinds) {
        NSMutableDictionary *kindDict = _supplementaryLayoutAttributes[kind];
        NSMutableSet *indexPaths = _invalidatedSupplementaryViews[kind];
        if (!indexPaths) {
            indexPaths = [NSMutableSet set];
            _invalidatedSupplementaryViews[kind] = indexPaths;
        }
        [indexPaths addObjectsFromArray:kindDict.allKeys];
        [kindDict removeAllObjects];
    }
}

@end
