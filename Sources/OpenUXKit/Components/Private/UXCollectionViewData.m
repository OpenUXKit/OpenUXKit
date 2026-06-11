#import "UXCollectionViewData.h"
#import "UXCollectionViewData+Internal.h"
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

// UXKit pages the layout attributes cache by `__pageDimension`, a square page
// side initialized once from the main screen height (+initialize).
static CGFloat UXCollectionViewDataPageDimension = 1024.0;

// UXKit screen page key: ~((uint16)pageY | ((uint16)pageX << 16)). The inverted
// value can never be 0/NULL, which makes it a safe opaque NSMapTable key.
static void *UXCollectionViewDataScreenPageKeyForPoint(CGPoint point) {
    CGFloat pageDimension = UXCollectionViewDataPageDimension;
    uint64_t pageX = (uint16_t)(uint32_t)(point.x / pageDimension);
    uint64_t pageY = (uint16_t)(uint32_t)(point.y / pageDimension);
    return (void *)(uintptr_t)~(pageY | (pageX << 16));
}

static CGRect UXCollectionViewDataScreenPageRectForKey(uintptr_t key) {
    CGFloat pageDimension = UXCollectionViewDataPageDimension;
    uint64_t invertedKey = ~(uint64_t)key;
    uint16_t pageY = (uint16_t)(invertedKey & 0xFFFF);
    uint16_t pageX = (uint16_t)((invertedKey >> 16) & 0xFFFF);
    return CGRectMake(pageDimension * pageX, pageDimension * pageY, pageDimension, pageDimension);
}

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

+ (void)initialize {
    if (self == [UXCollectionViewData class]) {
        CGFloat mainScreenHeight = CGRectGetHeight([NSScreen mainScreen].frame);
        if (mainScreenHeight == 0.0) {
            NSLog(@"Incorrect screen size for %@ in UXCollectionViewData", [NSScreen mainScreen]);
            mainScreenHeight = 1024.0;
        }
        UXCollectionViewDataPageDimension = mainScreenHeight;
    }
}

- (instancetype)initWithCollectionView:(UXCollectionView *)collectionView layout:(UXCollectionViewLayout *)layout {
    self = [super init];
    if (self) {
        _collectionView = collectionView;
        _layout = layout;
        _supplementaryLayoutAttributes = [[NSMutableDictionary alloc] init];
        _decorationLayoutAttributes = [[NSMutableDictionary alloc] init];
        _clonedLayoutAttributes = [[NSMutableArray alloc] init];

        // UXKit: opaque integer keys (page keys), strong object values
        // (NSMutableIndexSet of global item indexes per page).
        NSPointerFunctions *keyFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsIntegerPersonality | NSPointerFunctionsOpaqueMemory];
        NSPointerFunctions *valueFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsStrongMemory];
        _screenPageMap = [[NSMapTable alloc] initWithKeyPointerFunctions:keyFunctions valuePointerFunctions:valueFunctions capacity:0];

        _lastSectionTestedForNumberOfItemsBeforeSection = NSNotFound;
        _lastResultForNumberOfItemsBeforeSection = 0;
    }
    return self;
}

- (void)dealloc {
    if (_globalItems) {
        for (NSInteger globalItemIndex = 0; globalItemIndex < _numItems; globalItemIndex++) {
            _globalItems[globalItemIndex] = nil;
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
        for (NSInteger globalItemIndex = 0; globalItemIndex < _numItems; globalItemIndex++) {
            _globalItems[globalItemIndex] = nil;
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
    _lastResultForNumberOfItemsBeforeSection = 0;
}

- (void)_validateContentSize {
    if ((_collectionViewDataFlags & UXCollectionViewDataFlagContentSizeValid) != 0) {
        return;
    }
    if ((_collectionViewDataFlags & UXCollectionViewDataFlagLayoutLocked) != 0) {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                            object:self
                                                              file:@"UXCollectionViewData.m"
                                                        lineNumber:253
                                                       description:@"trying to load collection view layout data when layout is locked"];
    }
    _contentSize = [_layout collectionViewContentSize];
    _collectionViewDataFlags |= UXCollectionViewDataFlagContentSizeValid;
}

- (void)_prepareToLoadData {
    if ((_collectionViewDataFlags & UXCollectionViewDataFlagLayoutPrepared) == 0) {
        if ((_collectionViewDataFlags & UXCollectionViewDataFlagLayoutLocked) != 0) {
            [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                                object:self
                                                                  file:@"UXCollectionViewData.m"
                                                            lineNumber:262
                                                           description:@"trying to load collection view layout data when layout is locked"];
        }
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

    // NSNotFound (reset marker) is always > section, so the reset path runs.
    NSInteger startSection = _lastSectionTestedForNumberOfItemsBeforeSection;
    NSInteger result;
    if (startSection <= section) {
        result = _lastResultForNumberOfItemsBeforeSection;
    } else {
        result = 0;
        startSection = 0;
    }

    for (NSInteger sectionIndex = startSection; sectionIndex < section; sectionIndex++) {
        result += _sectionItemCounts[sectionIndex];
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
    [self _prepareToLoadData];
    return CGRectMake(0.0, 0.0, _contentSize.width, _contentSize.height);
}

- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath {
    UXCollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    return attributes ? attributes.frame : CGRectNull;
}

- (CGRect)rectForGlobalItemIndex:(NSInteger)globalIndex {
    return [self rectForItemAtIndexPath:[self indexPathForItemAtGlobalIndex:globalIndex]];
}

- (CGRect)rectForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.length != 1 && indexPath.section >= _numSections) {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                            object:self
                                                              file:@"UXCollectionViewData.m"
                                                        lineNumber:655
                                                       description:@"request for CGRect for supplementary view of kind %@ in section %ld when there are only %ld sections in the collection view", kind, (long)indexPath.section, (long)_numSections];
    }
    UXCollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    return attributes ? attributes.frame : CGRectNull;
}

- (CGRect)rectForDecorationElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.length != 1 && indexPath.section >= _numSections) {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                            object:self
                                                              file:@"UXCollectionViewData.m"
                                                        lineNumber:667
                                                       description:@"request for CGRect for decoration view of kind %@ in section %ld when there are only %ld sections in the collection view", kind, (long)indexPath.section, (long)_numSections];
    }
    UXCollectionViewLayoutAttributes *attributes = [self layoutAttributesForDecorationViewOfKind:kind atIndexPath:indexPath];
    return attributes ? attributes.frame : CGRectNull;
}

#pragma mark - Layout attributes

- (UXCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self _prepareToLoadData];
    NSInteger globalIndex = [self globalIndexForItemAtIndexPath:indexPath];
    if (globalIndex == NSNotFound) {
        return nil;
    }
    UXCollectionViewLayoutAttributes *cached = _globalItems[globalIndex];
    if (cached) {
        return cached;
    }
    UXCollectionViewLayoutAttributes *attributes;
    if ((_collectionViewDataFlags & UXCollectionViewDataFlagLayoutLocked) != 0) {
        attributes = [_layout initialLayoutAttributesForAppearingItemAtIndexPath:indexPath];
    } else {
        attributes = [_layout layoutAttributesForItemAtIndexPath:indexPath];
    }
    [self _setLayoutAttributes:attributes atGlobalItemIndex:globalIndex];
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
    if (globalIndex < 0 || (_numItems != 0 && globalIndex >= _numItems)) {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                            object:self
                                                              file:@"UXCollectionViewData.m"
                                                        lineNumber:308
                                                       description:@"invalid global index: %ld", (long)globalIndex];
    }
    if (globalIndex < 0 || globalIndex >= _numItems) {
        return;
    }
    if (_globalItems[globalIndex] == attributes) {
        return;
    }
    _globalItems[globalIndex] = [attributes copy];

    // Register the global index on every screen page overlapped by the frame.
    // The scan pattern (interior points, bottom edge per column, bottom-right
    // corner) mirrors UXKit exactly.
    CGFloat pageDimension = UXCollectionViewDataPageDimension;
    CGRect frame = attributes.frame;
    for (CGFloat scanX = CGRectGetMinX(frame); scanX <= CGRectGetMaxX(frame) - 1.0; scanX += pageDimension) {
        for (CGFloat scanY = CGRectGetMinY(frame); scanY <= CGRectGetMaxY(frame) - 1.0; scanY += pageDimension) {
            [[self _screenPageForPoint:CGPointMake(scanX, scanY)] addIndex:(NSUInteger)globalIndex];
        }
        [[self _screenPageForPoint:CGPointMake(scanX, CGRectGetMaxY(frame) - 1.0)] addIndex:(NSUInteger)globalIndex];
    }
    [[self _screenPageForPoint:CGPointMake(CGRectGetMaxX(frame) - 1.0, CGRectGetMaxY(frame) - 1.0)] addIndex:(NSUInteger)globalIndex];
}

- (NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    [self validateLayoutInRect:rect];

    NSMutableArray<UXCollectionViewLayoutAttributes *> *result = [NSMutableArray array];

    // Gather the global item indexes registered on every screen page touched
    // by the query rect (deliberately overshooting one page on each axis,
    // matching UXKit's do/while scan).
    NSMutableIndexSet *globalIndexes = [[NSMutableIndexSet alloc] init];
    CGFloat pageDimension = UXCollectionViewDataPageDimension;
    CGFloat scanY = CGRectGetMinY(rect);
    for (;;) {
        CGFloat scanX = CGRectGetMinX(rect);
        BOOL shouldContinueScanningX;
        do {
            NSIndexSet *pageIndexes = [_screenPageMap objectForKey:(__bridge id)UXCollectionViewDataScreenPageKeyForPoint(CGPointMake(scanX, scanY))];
            if (pageIndexes) {
                [globalIndexes addIndexes:pageIndexes];
            }
            shouldContinueScanningX = scanX <= CGRectGetMaxX(rect);
            scanX += pageDimension;
        } while (shouldContinueScanningX);
        if (scanY > CGRectGetMaxY(rect)) {
            break;
        }
        scanY += pageDimension;
    }

    for (NSUInteger globalIndex = [globalIndexes firstIndex]; globalIndex != NSNotFound; globalIndex = [globalIndexes indexGreaterThanIndex:globalIndex]) {
        UXCollectionViewLayoutAttributes *attributes = _globalItems[globalIndex];
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [result addObject:attributes];
        }
    }

    UXCollectionView *collectionView = _collectionView;
    void (^addCachedAttributesIntersectingRect)(NSMutableDictionary *) = ^(NSMutableDictionary *attributesDict) {
        [attributesDict enumerateKeysAndObjectsUsingBlock:^(NSString *elementKind, NSMutableDictionary *kindDict, BOOL *stopOuter) {
            [kindDict enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UXCollectionViewLayoutAttributes *attributes, BOOL *stopInner) {
                CGRect effectiveFrame;
                if (attributes.isFloating) {
                    CGRect convertedFrame = [collectionView.documentView convertRect:attributes.floatingFrame fromView:collectionView];
                    NSEdgeInsets contentInsets = collectionView.contentInsets;
                    effectiveFrame = NSOffsetRect(convertedFrame, contentInsets.left, contentInsets.top);
                } else {
                    effectiveFrame = attributes.frame;
                }
                if (CGRectIntersectsRect(rect, effectiveFrame)) {
                    [result addObject:attributes];
                }
            }];
        }];
    };
    addCachedAttributesIntersectingRect(_supplementaryLayoutAttributes);
    addCachedAttributesIntersectingRect(_decorationLayoutAttributes);

    return [result sortedArrayUsingComparator:^NSComparisonResult(UXCollectionViewLayoutAttributes *left, UXCollectionViewLayoutAttributes *right) {
        if (left.zIndex < right.zIndex) {
            return NSOrderedAscending;
        }
        if (right.zIndex < left.zIndex) {
            return NSOrderedDescending;
        }
        NSIndexPath *leftIndexPath = left.indexPath;
        NSIndexPath *rightIndexPath = right.indexPath;
        if (leftIndexPath.section < rightIndexPath.section) {
            return NSOrderedAscending;
        }
        if (leftIndexPath.section > rightIndexPath.section) {
            return NSOrderedDescending;
        }
        if (leftIndexPath.item < rightIndexPath.item) {
            return NSOrderedAscending;
        }
        if (leftIndexPath.item > rightIndexPath.item) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
}

- (NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInSection:(NSInteger)section {
    NSMutableArray<UXCollectionViewLayoutAttributes *> *result = [NSMutableArray array];
    NSInteger itemsCount = [self numberOfItemsInSection:section];
    for (NSInteger itemIndex = 0; itemIndex < itemsCount; itemIndex++) {
        UXCollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:section]];
        if (attributes) {
            [result addObject:attributes];
        }
    }
    void (^addCachedAttributesInSection)(NSMutableDictionary *) = ^(NSMutableDictionary *attributesDict) {
        for (NSString *elementKind in attributesDict) {
            NSMutableDictionary *kindDict = attributesDict[elementKind];
            for (NSIndexPath *indexPath in kindDict) {
                if (indexPath.length >= 2 && indexPath.section == section) {
                    UXCollectionViewLayoutAttributes *attributes = kindDict[indexPath];
                    if (attributes) {
                        [result addObject:attributes];
                    }
                }
            }
        }
    };
    addCachedAttributesInSection(_supplementaryLayoutAttributes);
    addCachedAttributesInSection(_decorationLayoutAttributes);
    return result;
}

- (UXCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *kindDict = _supplementaryLayoutAttributes[kind];
    if (indexPath.section >= _numSections) {
        [kindDict removeObjectForKey:indexPath];
        return nil;
    }
    UXCollectionViewLayoutAttributes *cached = kindDict[indexPath];
    if (cached) {
        return cached;
    }
    UXCollectionViewLayoutAttributes *attributes;
    if ((_collectionViewDataFlags & UXCollectionViewDataFlagLayoutLocked) != 0) {
        attributes = [_layout initialLayoutAttributesForAppearingSupplementaryElementOfKind:kind atIndexPath:indexPath];
    } else {
        attributes = [_layout layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    }
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
    UXCollectionViewLayoutAttributes *attributes;
    if ((_collectionViewDataFlags & UXCollectionViewDataFlagLayoutLocked) != 0) {
        attributes = [_layout initialLayoutAttributesForAppearingDecorationElementOfKind:kind atIndexPath:indexPath];
    } else {
        attributes = [_layout layoutAttributesForDecorationViewOfKind:kind atIndexPath:indexPath];
    }
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
    for (NSMutableDictionary *kindDict in _decorationLayoutAttributes.objectEnumerator) {
        [result addObjectsFromArray:kindDict.allValues];
    }
    return result;
}

- (NSArray<UXCollectionViewLayoutAttributes *> *)existingSupplementaryLayoutAttributesWithMinimalIndexPathLength:(NSUInteger)length {
    NSMutableArray<UXCollectionViewLayoutAttributes *> *result = [NSMutableArray array];
    void (^addCachedAttributesWithMinimalLength)(NSMutableDictionary *) = ^(NSMutableDictionary *attributesDict) {
        for (NSMutableDictionary *kindDict in attributesDict.objectEnumerator) {
            for (UXCollectionViewLayoutAttributes *attributes in kindDict.objectEnumerator) {
                if (attributes.indexPath.length >= length) {
                    [result addObject:attributes];
                }
            }
        }
    };
    addCachedAttributesWithMinimalLength(_supplementaryLayoutAttributes);
    addCachedAttributesWithMinimalLength(_decorationLayoutAttributes);
    return result;
}

- (NSArray<UXCollectionViewLayoutAttributes *> *)existingSupplementaryLayoutAttributesInSection:(NSInteger)section {
    NSMutableArray<UXCollectionViewLayoutAttributes *> *result = [NSMutableArray array];
    void (^addCachedAttributesInSection)(NSMutableDictionary *) = ^(NSMutableDictionary *attributesDict) {
        for (NSMutableDictionary *kindDict in attributesDict.objectEnumerator) {
            for (UXCollectionViewLayoutAttributes *attributes in kindDict.objectEnumerator) {
                NSIndexPath *indexPath = attributes.indexPath;
                if (indexPath.section == section && indexPath.length >= 2) {
                    [result addObject:attributes];
                }
            }
        }
    };
    addCachedAttributesInSection(_supplementaryLayoutAttributes);
    addCachedAttributesInSection(_decorationLayoutAttributes);
    return result;
}

- (NSSet<NSString *> *)knownSupplementaryElementKinds {
    // UXKit: union of the supplementary and decoration kind keys.
    NSSet *supplementaryKinds = [NSSet setWithArray:_supplementaryLayoutAttributes.allKeys];
    return [supplementaryKinds setByAddingObjectsFromArray:_decorationLayoutAttributes.allKeys];
}

- (NSSet<NSString *> *)knownDecorationElementKinds {
    return [NSSet setWithArray:_decorationLayoutAttributes.allKeys];
}

#pragma mark - Validation / invalidation

// Mirrors UXKit's page-aligned validation rect block: snaps origin down and
// size up to page boundaries, then clips maxX/maxY to the content size.
- (CGRect)_pageAlignedValidationRectForRect:(CGRect)rect {
    [self _validateContentSize];
    CGFloat pageDimension = UXCollectionViewDataPageDimension;
    CGRect alignedRect = rect;

    alignedRect.origin.x = pageDimension * floor(CGRectGetMinX(rect) / pageDimension);
    alignedRect.size.width = pageDimension * ceil((rect.size.width + CGRectGetMinX(rect) - CGRectGetMinX(alignedRect)) / pageDimension);
    if (CGRectGetMaxX(alignedRect) > _contentSize.width) {
        alignedRect.size.width -= CGRectGetMaxX(alignedRect) - _contentSize.width;
    }

    alignedRect.origin.y = pageDimension * floor(CGRectGetMinY(rect) / pageDimension);
    alignedRect.size.height = pageDimension * ceil((rect.size.height + CGRectGetMinY(rect) - CGRectGetMinY(alignedRect)) / pageDimension);
    if (CGRectGetMaxY(alignedRect) > _contentSize.height) {
        alignedRect.size.height -= CGRectGetMaxY(alignedRect) - _contentSize.height;
    }
    return alignedRect;
}

// Mirrors UXKit's load block: pulls the layout attributes for `rect` from the
// layout and distributes them into the caches, then clears contentSizeIsValid.
- (void)_loadLayoutAttributesInRect:(CGRect)rect calledFromMethod:(SEL)callingMethod {
    if ((_collectionViewDataFlags & UXCollectionViewDataFlagLayoutLocked) != 0) {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:callingMethod
                                                            object:self
                                                              file:@"UXCollectionViewData.m"
                                                        lineNumber:367
                                                       description:@"trying to load collection view layout data when layout is locked"];
    }
    NSArray<UXCollectionViewLayoutAttributes *> *attributesList = [_layout layoutAttributesForElementsInRect:rect];
    for (UXCollectionViewLayoutAttributes *attributes in attributesList) {
        if ([attributes _isClone]) {
            [_clonedLayoutAttributes addObject:attributes];
            continue;
        }
        NSIndexPath *indexPath = attributes.indexPath;
        if ([attributes _isCell]) {
            if (indexPath.section >= _numSections || indexPath.item >= _sectionItemCounts[indexPath.section]) {
                [[NSAssertionHandler currentHandler] handleFailureInMethod:callingMethod
                                                                    object:self
                                                                      file:@"UXCollectionViewData.m"
                                                                lineNumber:379
                                                               description:@"UICollectionView recieved layout attributes for a cell with an index path that does not exist: %@", indexPath];
            }
            NSInteger globalIndex = [self globalIndexForItemAtIndexPath:indexPath];
            if (globalIndex != NSNotFound) {
                [self _setLayoutAttributes:attributes atGlobalItemIndex:globalIndex];
            }
        } else {
            NSMutableDictionary *attributesDict = [attributes _isDecorationView] ? _decorationLayoutAttributes : _supplementaryLayoutAttributes;
            NSString *elementKind = [attributes _elementKind];
            UXCollectionViewLayoutAttributes *existing = attributesDict[elementKind][indexPath];
            if (existing) {
                if (![existing isEqual:attributes]) {
                    [[NSAssertionHandler currentHandler] handleFailureInMethod:callingMethod
                                                                        object:self
                                                                          file:@"UXCollectionViewData.m"
                                                                    lineNumber:390
                                                                   description:@"layout attributes for supplementary item at index path (%@) changed from %@ to %@ without invalidating the layout", indexPath, existing, attributes];
                }
            } else {
                if (!elementKind) {
                    [[NSAssertionHandler currentHandler] handleFailureInMethod:callingMethod
                                                                        object:self
                                                                          file:@"UXCollectionViewData.m"
                                                                    lineNumber:393
                                                                   description:@"%@ elementKind is nil.  This probably means you created the UXCollectionViewLayoutAttributes using +alloc/-init instead of one of the class constructors", attributes];
                }
                NSMutableDictionary *kindDict = attributesDict[elementKind];
                if (!kindDict) {
                    kindDict = [NSMutableDictionary dictionary];
                    attributesDict[elementKind] = kindDict;
                }
                kindDict[indexPath] = attributes;
            }
        }
    }
    _collectionViewDataFlags &= ~UXCollectionViewDataFlagContentSizeValid;
}

- (void)validateLayoutInRect:(CGRect)rect {
    [self _prepareToLoadData];
    if (_invalidatedSupplementaryViews) {
        [self validateSupplementaryViews];
    }
    [self _validateContentSize];

    CGRect clippedRect = CGRectIntersection(CGRectMake(0.0, 0.0, _contentSize.width, _contentSize.height), rect);
    if (CGRectEqualToRect(clippedRect, CGRectZero)) {
        return;
    }
    if (CGRectContainsRect(_validLayoutRect, clippedRect)) {
        return;
    }

    [_clonedLayoutAttributes removeAllObjects];

    CGFloat pageDimension = UXCollectionViewDataPageDimension;
    CGRect alignedRect = [self _pageAlignedValidationRectForRect:rect];

    BOOL slidesAlongValidRect =
        (CGRectGetWidth(rect) == CGRectGetWidth(_validLayoutRect) && CGRectGetMinX(_validLayoutRect) == CGRectGetMinX(rect)) ||
        (CGRectGetHeight(rect) == CGRectGetHeight(_validLayoutRect) && CGRectGetMinY(_validLayoutRect) == CGRectGetMinY(rect));

    if (slidesAlongValidRect) {
        // Sliding window: only the newly exposed strip is loaded; when the
        // window grows beyond 5 pages, the trailing page gets evicted.
        BOOL contiguousWithValidRect;
        if (CGRectGetMinX(_validLayoutRect) == CGRectGetMinX(rect)) {
            if (CGRectGetMinY(_validLayoutRect) <= CGRectGetMinY(rect)) {
                CGFloat overlap = CGRectGetMaxY(_validLayoutRect) - CGRectGetMinY(alignedRect);
                contiguousWithValidRect = overlap >= 0.0;
                if (contiguousWithValidRect) {
                    alignedRect.origin.y += overlap;
                    alignedRect.size.height -= overlap;
                }
                if (CGRectGetHeight(_validLayoutRect) > pageDimension * 5.0) {
                    _validLayoutRect.origin.y += pageDimension;
                    _validLayoutRect.size.height -= pageDimension;
                }
            } else {
                CGFloat overlap = CGRectGetMaxY(alignedRect) - CGRectGetMinY(_validLayoutRect);
                contiguousWithValidRect = overlap >= 0.0;
                if (contiguousWithValidRect) {
                    alignedRect.size.height -= overlap;
                }
                if (CGRectGetHeight(_validLayoutRect) > pageDimension * 5.0) {
                    _validLayoutRect.size.height -= pageDimension;
                }
            }
        } else {
            if (CGRectGetMinX(_validLayoutRect) <= CGRectGetMinX(rect)) {
                CGFloat overlap = CGRectGetMaxX(_validLayoutRect) - CGRectGetMinX(alignedRect);
                contiguousWithValidRect = overlap >= 0.0;
                if (contiguousWithValidRect) {
                    alignedRect.origin.x += overlap;
                    alignedRect.size.width -= overlap;
                }
                if (CGRectGetWidth(_validLayoutRect) > pageDimension * 5.0) {
                    _validLayoutRect.origin.x += pageDimension;
                    _validLayoutRect.size.width -= pageDimension;
                }
            } else {
                CGFloat overlap = CGRectGetMaxX(alignedRect) - CGRectGetMinX(_validLayoutRect);
                contiguousWithValidRect = overlap >= 0.0;
                if (contiguousWithValidRect) {
                    alignedRect.size.width -= overlap;
                }
                if (CGRectGetWidth(_validLayoutRect) > pageDimension * 5.0) {
                    _validLayoutRect.size.width -= pageDimension;
                }
            }
        }

        CGRect reAlignedRect = [self _pageAlignedValidationRectForRect:alignedRect];
        if (!CGRectIsEmpty(reAlignedRect)) {
            if (contiguousWithValidRect) {
                _validLayoutRect = CGRectUnion(_validLayoutRect, reAlignedRect);
            } else {
                _validLayoutRect = reAlignedRect;
            }
            [self _loadLayoutAttributesInRect:reAlignedRect calledFromMethod:_cmd];
        }
    } else {
        _validLayoutRect = alignedRect;
        [self _loadLayoutAttributesInRect:alignedRect calledFromMethod:_cmd];
    }

    // Drop the screen pages that fell out of the validated window. The keys
    // are opaque integers, so the loop variable must stay unretained.
    NSMapTable *screenPageMapCopy = [_screenPageMap copy];
    for (__unsafe_unretained id keyObject in screenPageMapCopy) {
        uintptr_t key = (uintptr_t)(__bridge void *)keyObject;
        if (!CGRectIntersectsRect(UXCollectionViewDataScreenPageRectForKey(key), _validLayoutRect)) {
            [_screenPageMap removeObjectForKey:(__bridge id)(void *)key];
        }
    }
}

- (void)validateSupplementaryViews {
    if ((_collectionViewDataFlags & UXCollectionViewDataFlagLayoutLocked) != 0) {
        return;
    }
    for (NSString *kind in _invalidatedSupplementaryViews) {
        id<NSFastEnumeration> indexPaths = _invalidatedSupplementaryViews[kind];
        NSMutableDictionary *kindDict = _supplementaryLayoutAttributes[kind];
        for (NSIndexPath *indexPath in indexPaths) {
            [kindDict removeObjectForKey:indexPath];
            [self layoutAttributesForSupplementaryElementOfKind:kind atIndexPath:indexPath];
        }
    }
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
    // UXKit allocates one UIMutableIndexPath {0, 0} and mutates it in place for
    // every iteration; OpenUXKit swaps in fresh immutable NSIndexPath objects.
    NSIndexPath *reusableIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    for (NSInteger globalItemIndex = 0; globalItemIndex < _numItems; globalItemIndex++) {
        if (_globalItems[globalItemIndex]) {
            continue;
        }
        if ((_collectionViewDataFlags & UXCollectionViewDataFlagLayoutLocked) != 0) {
            [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                                object:self
                                                                  file:@"UXCollectionViewData.m"
                                                            lineNumber:336
                                                           description:@"trying to load collection view layout data when layout is locked"];
        }
        [self _setupMutableIndexPath:&reusableIndexPath forGlobalItemIndex:globalItemIndex];
        [self _setLayoutAttributes:[_layout layoutAttributesForItemAtIndexPath:reusableIndexPath] atGlobalItemIndex:globalItemIndex];
    }
    _validLayoutRect = [self collectionViewContentRect];
}

- (NSMutableIndexSet *)_screenPageForPoint:(CGPoint)point {
    CGFloat pageDimension = UXCollectionViewDataPageDimension;
    CGRect pageRect = CGRectMake(pageDimension * floor(point.x / pageDimension),
                                 pageDimension * floor(point.y / pageDimension),
                                 pageDimension,
                                 pageDimension);
    if (!CGRectIntersectsRect(pageRect, _validLayoutRect)) {
        return nil;
    }
    void *key = UXCollectionViewDataScreenPageKeyForPoint(point);
    NSMutableIndexSet *pageIndexes = [_screenPageMap objectForKey:(__bridge id)key];
    if (!pageIndexes) {
        pageIndexes = [[NSMutableIndexSet alloc] init];
        [_screenPageMap setObject:pageIndexes forKey:(__bridge id)key];
    }
    return pageIndexes;
}

- (void)_setupMutableIndexPath:(NSIndexPath * __strong *)indexPath forGlobalItemIndex:(NSInteger)globalItemIndex {
    NSInteger cumulativeCount = 0;
    for (NSInteger sectionIndex = 0; sectionIndex < _numSections; sectionIndex++) {
        cumulativeCount += _sectionItemCounts[sectionIndex];
        if (globalItemIndex < cumulativeCount) {
            NSInteger itemIndex = globalItemIndex - (cumulativeCount - _sectionItemCounts[sectionIndex]);
            *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
            return;
        }
    }
}

- (void)invalidateSupplementaryViews:(NSDictionary<NSString *, NSArray<NSIndexPath *> *> *)invalidatedSupplementaryViews {
    if ((_collectionViewDataFlags & UXCollectionViewDataFlagLayoutLocked) != 0) {
        return;
    }
    if (_invalidatedSupplementaryViews) {
        [invalidatedSupplementaryViews enumerateKeysAndObjectsUsingBlock:^(NSString *kind, NSArray<NSIndexPath *> *indexPaths, BOOL *stop) {
            NSArray<NSIndexPath *> *existing = self->_invalidatedSupplementaryViews[kind];
            if (existing) {
                if ([existing isEqual:indexPaths]) {
                    return;
                }
                NSMutableSet *merged = [NSMutableSet setWithArray:indexPaths];
                [merged addObjectsFromArray:existing];
                self->_invalidatedSupplementaryViews[kind] = [merged allObjects];
            } else {
                self->_invalidatedSupplementaryViews[kind] = indexPaths;
            }
        }];
    } else {
        _invalidatedSupplementaryViews = [[NSMutableDictionary alloc] initWithDictionary:invalidatedSupplementaryViews];
    }
}

#pragma mark - Description

- (NSString *)description {
    NSMutableString *result = [NSMutableString string];
    [result appendString:[super description]];
    [result appendFormat:@" items: %@ sections: %@", @(_numItems), @(_numSections)];
    if (_numSections >= 1) {
        [result appendString:@" itemsCounts: {"];
        for (NSInteger sectionIndex = 0; sectionIndex < _numSections; sectionIndex++) {
            [result appendFormat:(sectionIndex ? @", %@" : @"%@"), @(_sectionItemCounts[sectionIndex])];
        }
        [result appendString:@"}"];
    }
    [result appendFormat:@"%@%@%@%@",
        (_collectionViewDataFlags & UXCollectionViewDataFlagContentSizeValid) ? @" contentSizeIsValid" : @"",
        (_collectionViewDataFlags & UXCollectionViewDataFlagItemCountsValid) ? @" itemCountsAreValid" : @"",
        (_collectionViewDataFlags & UXCollectionViewDataFlagLayoutPrepared) ? @" layoutIsPrepared" : @"",
        (_collectionViewDataFlags & UXCollectionViewDataFlagLayoutLocked) ? @" layoutLocked" : @""];
    return result;
}

@end
