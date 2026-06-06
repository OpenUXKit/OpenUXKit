#import "UXCollectionViewFlowLayout.h"
#import "UXCollectionViewFlowLayout+Internal.h"
#import "UXCollectionViewFlowLayoutInvalidationContext.h"
#import "UXCollectionViewLayoutAttributes.h"
#import "UXCollectionViewLayoutAttributes+Internal.h"
#import "UXCollectionView.h"
#import "_UXFlowLayoutInfo.h"
#import "_UXFlowLayoutSection.h"
#import "_UXFlowLayoutRow.h"
#import "_UXFlowLayoutItem.h"

NSString *const UXFlowLayoutCommonRowHorizontalAlignmentKey = @"UXFlowLayoutCommonRowHorizontalAlignmentKey";
NSString *const UXFlowLayoutLastRowHorizontalAlignmentKey = @"UXFlowLayoutLastRowHorizontalAlignmentKey";
NSString *const UXFlowLayoutRowVerticalAlignmentKey = @"UXFlowLayoutRowVerticalAlignmentKey";

NSString *const UXCollectionElementKindSectionHeader = @"UXCollectionElementKindSectionHeader";
NSString *const UXCollectionElementKindSectionFooter = @"UXCollectionElementKindSectionFooter";

@interface NSObject (UXCollectionViewFlowLayoutDelegate)
- (CGSize)collectionView:(id)collectionView layout:(UXCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize)collectionView:(id)collectionView layout:(UXCollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
- (CGSize)collectionView:(id)collectionView layout:(UXCollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;
- (NSEdgeInsets)collectionView:(id)collectionView layout:(UXCollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(id)collectionView layout:(UXCollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(id)collectionView layout:(UXCollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
- (nullable NSDictionary *)_collectionView:(id)collectionView layout:(UXCollectionViewLayout *)collectionViewLayout flowLayoutRowAlignmentOptionsForSection:(NSInteger)section;
@end

@interface UXCollectionViewLayoutInvalidationContext (UXFlowLayoutInternal)
- (BOOL)invalidateEverything;
- (void)_setInvalidateEverything:(BOOL)invalidateEverything;
- (BOOL)invalidateDataSourceCounts;
@end

@interface UXCollectionViewLayout (UXFlowLayoutInternal)
- (void)_invalidateLayoutUsingContext:(UXCollectionViewLayoutInvalidationContext *)context;
@end

typedef NS_OPTIONS(uint16_t, UXFlowLayoutGridFlags) {
    UXFlowLayoutFlagDelegateSizeForItem            = 1 << 0,
    UXFlowLayoutFlagDelegateReferenceSizeForHeader = 1 << 1,
    UXFlowLayoutFlagDelegateReferenceSizeForFooter = 1 << 2,
    UXFlowLayoutFlagDelegateInsetForSection        = 1 << 3,
    UXFlowLayoutFlagDelegateInteritemSpacing       = 1 << 4,
    UXFlowLayoutFlagDelegateLineSpacing            = 1 << 5,
    UXFlowLayoutFlagDelegateAlignmentOptions       = 1 << 6,
    UXFlowLayoutFlagLayoutDataValid                = 1 << 7,
    UXFlowLayoutFlagDelegateInfoValid              = 1 << 8,
};

@interface UXCollectionViewFlowLayout () {
    uint16_t _gridLayoutFlags;
    CGFloat _interitemSpacing;
    CGFloat _lineSpacing;
    CGSize _itemSize;
    CGSize _headerReferenceSize;
    CGSize _footerReferenceSize;
    NSEdgeInsets _sectionInset;
    _UXFlowLayoutInfo *_data;
    CGSize _currentLayoutSize;
    NSMutableDictionary *_insertedItemsAttributesDict;
    NSMutableDictionary *_insertedSectionHeadersAttributesDict;
    NSMutableDictionary *_insertedSectionFootersAttributesDict;
    NSMutableDictionary *_deletedItemsAttributesDict;
    NSMutableDictionary *_deletedSectionHeadersAttributesDict;
    NSMutableDictionary *_deletedSectionFootersAttributesDict;
    NSInteger _scrollDirection;
    NSDictionary *_rowAlignmentsOptionsDictionary;
    CGRect _visibleBounds;
}
@end

@implementation UXCollectionViewFlowLayout

+ (Class)invalidationContextClass {
    return [UXCollectionViewFlowLayoutInvalidationContext class];
}

- (void)_commonInit {
    _itemSize = CGSizeMake(10.0, 10.0);
    _headerReferenceSize = CGSizeMake(50.0, 50.0);
    _rowAlignmentsOptionsDictionary = @{
        UXFlowLayoutCommonRowHorizontalAlignmentKey: @(3),
        UXFlowLayoutLastRowHorizontalAlignmentKey: @(0),
        UXFlowLayoutRowVerticalAlignmentKey: @(1),
    };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self _commonInit];
        if ([coder containsValueForKey:@"UXFlowLayoutMinimumLineSpacing"]) {
            _lineSpacing = [coder decodeDoubleForKey:@"UXFlowLayoutMinimumLineSpacing"];
        }
        if ([coder containsValueForKey:@"UXFlowLayoutMinimumInteritemSpacing"]) {
            _interitemSpacing = [coder decodeDoubleForKey:@"UXFlowLayoutMinimumInteritemSpacing"];
        }
        if ([coder containsValueForKey:@"UXFlowLayoutItemSize"]) {
            _itemSize = [coder decodeSizeForKey:@"UXFlowLayoutItemSize"];
        }
        if ([coder containsValueForKey:@"UXFlowLayoutHeaderReferenceSize"]) {
            _headerReferenceSize = [coder decodeSizeForKey:@"UXFlowLayoutHeaderReferenceSize"];
        }
        if ([coder containsValueForKey:@"UXFlowLayoutFooterReferenceSize"]) {
            _footerReferenceSize = [coder decodeSizeForKey:@"UXFlowLayoutFooterReferenceSize"];
        }
        if ([coder containsValueForKey:@"UXFlowLayoutSectionInset"]) {
            NSValue *insetValue = [coder decodeObjectForKey:@"UXFlowLayoutSectionInset"];
            [insetValue getValue:&_sectionInset];
        }
        if ([coder containsValueForKey:@"UXFlowLayoutScrollDirection"]) {
            _scrollDirection = [coder decodeIntegerForKey:@"UXFlowLayoutScrollDirection"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeDouble:_lineSpacing forKey:@"UXFlowLayoutMinimumLineSpacing"];
    [coder encodeDouble:_interitemSpacing forKey:@"UXFlowLayoutMinimumInteritemSpacing"];
    [coder encodeSize:_itemSize forKey:@"UXFlowLayoutItemSize"];
    [coder encodeSize:_headerReferenceSize forKey:@"UXFlowLayoutHeaderReferenceSize"];
    [coder encodeSize:_footerReferenceSize forKey:@"UXFlowLayoutFooterReferenceSize"];
    [coder encodeObject:[NSValue valueWithBytes:&_sectionInset objCType:@encode(NSEdgeInsets)] forKey:@"UXFlowLayoutSectionInset"];
    [coder encodeInteger:_scrollDirection forKey:@"UXFlowLayoutScrollDirection"];
}

#pragma mark - Property accessors

- (CGFloat)minimumInteritemSpacing { return _interitemSpacing; }
- (CGFloat)minimumLineSpacing { return _lineSpacing; }
- (CGSize)itemSize { return _itemSize; }
- (CGSize)headerReferenceSize { return _headerReferenceSize; }
- (CGSize)footerReferenceSize { return _footerReferenceSize; }
- (NSEdgeInsets)sectionInset { return _sectionInset; }
- (UXCollectionViewScrollDirection)scrollDirection { return (UXCollectionViewScrollDirection)_scrollDirection; }

- (NSDictionary *)_rowAlignmentOptions { return _rowAlignmentsOptionsDictionary; }
- (void)_setRowAlignmentsOptions:(NSDictionary *)dict { _rowAlignmentsOptionsDictionary = [dict copy]; }

- (BOOL)_isOwningLayout {
    return [[(id)self.collectionView collectionViewLayout] isEqual:self];
}

- (void)_invalidateIfActive {
    if ((_gridLayoutFlags & UXFlowLayoutFlagLayoutDataValid) != 0) {
        [self invalidateLayout];
    }
}

- (void)setMinimumLineSpacing:(CGFloat)spacing {
    if (_lineSpacing != spacing && [self _isOwningLayout] && (_gridLayoutFlags & UXFlowLayoutFlagLayoutDataValid) != 0) {
        _lineSpacing = spacing;
        [self invalidateLayout];
    } else {
        _lineSpacing = spacing;
    }
}

- (void)setMinimumInteritemSpacing:(CGFloat)spacing {
    if (_interitemSpacing != spacing && [self _isOwningLayout] && (_gridLayoutFlags & UXFlowLayoutFlagLayoutDataValid) != 0) {
        _interitemSpacing = spacing;
        [self invalidateLayout];
    } else {
        _interitemSpacing = spacing;
    }
}

- (void)setItemSize:(CGSize)size {
    if ((_gridLayoutFlags & UXFlowLayoutFlagDelegateSizeForItem) == 0
        && !CGSizeEqualToSize(_itemSize, size)
        && [self _isOwningLayout]
        && (_gridLayoutFlags & UXFlowLayoutFlagLayoutDataValid) != 0) {
        _itemSize = size;
        [self invalidateLayout];
    } else {
        _itemSize = size;
    }
}

- (void)setHeaderReferenceSize:(CGSize)size {
    if ((_gridLayoutFlags & UXFlowLayoutFlagDelegateReferenceSizeForHeader) == 0
        && !CGSizeEqualToSize(_headerReferenceSize, size)
        && [self _isOwningLayout]
        && (_gridLayoutFlags & UXFlowLayoutFlagLayoutDataValid) != 0) {
        _headerReferenceSize = size;
        [self invalidateLayout];
    } else {
        _headerReferenceSize = size;
    }
}

- (void)setFooterReferenceSize:(CGSize)size {
    if ((_gridLayoutFlags & UXFlowLayoutFlagDelegateReferenceSizeForFooter) == 0
        && !CGSizeEqualToSize(_footerReferenceSize, size)
        && [self _isOwningLayout]
        && (_gridLayoutFlags & UXFlowLayoutFlagLayoutDataValid) != 0) {
        _footerReferenceSize = size;
        [self invalidateLayout];
    } else {
        _footerReferenceSize = size;
    }
}

- (void)setSectionInset:(NSEdgeInsets)inset {
    BOOL equal = inset.top == _sectionInset.top
              && inset.left == _sectionInset.left
              && inset.bottom == _sectionInset.bottom
              && inset.right == _sectionInset.right;
    if ((_gridLayoutFlags & UXFlowLayoutFlagDelegateInsetForSection) == 0
        && !equal
        && [self _isOwningLayout]
        && (_gridLayoutFlags & UXFlowLayoutFlagLayoutDataValid) != 0) {
        _sectionInset = inset;
        [self invalidateLayout];
    } else {
        _sectionInset = inset;
    }
}

- (void)setScrollDirection:(UXCollectionViewScrollDirection)direction {
    if (_scrollDirection != direction && [self _isOwningLayout] && (_gridLayoutFlags & UXFlowLayoutFlagLayoutDataValid) != 0) {
        _scrollDirection = direction;
        [self invalidateLayout];
    } else {
        _scrollDirection = direction;
    }
}

#pragma mark - Invalidation

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect bounds = [(id)self.collectionView bounds];
    if (_scrollDirection == UXCollectionViewScrollDirectionHorizontal) {
        return newBounds.size.height != bounds.size.height || newBounds.origin.y != bounds.origin.y;
    } else {
        return newBounds.size.width != bounds.size.width || newBounds.origin.x != bounds.origin.x;
    }
}

- (UXCollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds {
    UXCollectionViewFlowLayoutInvalidationContext *context = (UXCollectionViewFlowLayoutInvalidationContext *)[super invalidationContextForBoundsChange:newBounds];
    context.invalidateFlowLayoutDelegateMetrics = NO;
    context.invalidateFlowLayoutAttributes = NO;
    CGRect bounds = [(id)self.collectionView bounds];
    BOOL crossAxisChanged;
    if (_scrollDirection == UXCollectionViewScrollDirectionHorizontal) {
        crossAxisChanged = (newBounds.size.height != bounds.size.height) || (newBounds.origin.y != bounds.origin.y);
    } else {
        crossAxisChanged = (newBounds.size.width != bounds.size.width) || (newBounds.origin.x != bounds.origin.x);
    }
    if (crossAxisChanged) {
        context.invalidateFlowLayoutAttributes = YES;
        [context _setInvalidateEverything:YES];
    }
    return context;
}

- (void)invalidateLayoutWithContext:(UXCollectionViewLayoutInvalidationContext *)context {
    if (![context isKindOfClass:[UXCollectionViewFlowLayoutInvalidationContext class]]) {
        [NSException raise:NSInvalidArgumentException format:@"the invalidation context (%@) sent to -[UXCollectionViewFlowLayout invalidateLayoutWithContext:] is not an instance of type UXCollectionViewFlowLayoutInvalidationContext or a subclass", context];
    }

    UXCollectionViewFlowLayoutInvalidationContext *flowContext = (UXCollectionViewFlowLayoutInvalidationContext *)context;
    if ((flowContext.invalidateFlowLayoutAttributes || context.invalidateDataSourceCounts)
        && (_gridLayoutFlags & UXFlowLayoutFlagLayoutDataValid) != 0) {
        [_data invalidate:!flowContext.invalidateFlowLayoutDelegateMetrics];

        if (flowContext.invalidateFlowLayoutDelegateMetrics) {
            _gridLayoutFlags &= ~UXFlowLayoutFlagDelegateInfoValid;
        }
        _gridLayoutFlags &= ~UXFlowLayoutFlagLayoutDataValid;
    }

    [super invalidateLayoutWithContext:context];
}

- (void)_invalidateButKeepAllInfo {
    UXCollectionViewFlowLayoutInvalidationContext *context = [[[[self class] invalidationContextClass] alloc] init];
    context.invalidateFlowLayoutDelegateMetrics = NO;
    context.invalidateFlowLayoutAttributes = NO;
    [self _invalidateLayoutUsingContext:context];
}

- (void)_invalidateButKeepDelegateInfo {
    UXCollectionViewFlowLayoutInvalidationContext *context = [[[[self class] invalidationContextClass] alloc] init];
    context.invalidateFlowLayoutDelegateMetrics = NO;
    [self _invalidateLayoutUsingContext:context];
}

- (CGSize)synchronizeLayout {
    [self _fetchItemsInfo];
    return _currentLayoutSize;
}

#pragma mark - Layout computation

- (CGSize)collectionViewContentSize {
    [self _fetchItemsInfo];
    return _currentLayoutSize;
}

- (void)_updateDelegateFlags {
    id delegate = [(id)self.collectionView delegate];
    _gridLayoutFlags = (_gridLayoutFlags & ~UXFlowLayoutFlagDelegateSizeForItem)
        | ([delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)] ? UXFlowLayoutFlagDelegateSizeForItem : 0);
    _gridLayoutFlags = (_gridLayoutFlags & ~UXFlowLayoutFlagDelegateReferenceSizeForHeader)
        | ([delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)] ? UXFlowLayoutFlagDelegateReferenceSizeForHeader : 0);
    _gridLayoutFlags = (_gridLayoutFlags & ~UXFlowLayoutFlagDelegateReferenceSizeForFooter)
        | ([delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)] ? UXFlowLayoutFlagDelegateReferenceSizeForFooter : 0);
    _gridLayoutFlags = (_gridLayoutFlags & ~UXFlowLayoutFlagDelegateInsetForSection)
        | ([delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)] ? UXFlowLayoutFlagDelegateInsetForSection : 0);
    _gridLayoutFlags = (_gridLayoutFlags & ~UXFlowLayoutFlagDelegateInteritemSpacing)
        | ([delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)] ? UXFlowLayoutFlagDelegateInteritemSpacing : 0);
    _gridLayoutFlags = (_gridLayoutFlags & ~UXFlowLayoutFlagDelegateLineSpacing)
        | ([delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)] ? UXFlowLayoutFlagDelegateLineSpacing : 0);
    _gridLayoutFlags = (_gridLayoutFlags & ~UXFlowLayoutFlagDelegateAlignmentOptions)
        | ([delegate respondsToSelector:@selector(_collectionView:layout:flowLayoutRowAlignmentOptionsForSection:)] ? UXFlowLayoutFlagDelegateAlignmentOptions : 0);
}

- (void)_getSizingInfos {
    UXCollectionView *collectionView = self.collectionView;
    id delegate = [(id)collectionView delegate];
    if (!_data) {
        _data = [[_UXFlowLayoutInfo alloc] init];
        _data.leftToRight = ([(id)collectionView userInterfaceLayoutDirection] == NSUserInterfaceLayoutDirectionLeftToRight);
    }
    _data.horizontal = (_scrollDirection == UXCollectionViewScrollDirectionHorizontal);

    NSInteger sectionCount = [(id)collectionView numberOfSections];

    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
        _UXFlowLayoutSection *section = [_data addSection];
        NSInteger itemsCount = [collectionView numberOfItemsInSection:sectionIndex];
        section.itemsCount = itemsCount;

        if ((_gridLayoutFlags & UXFlowLayoutFlagDelegateSizeForItem) != 0) {
            BOOL fixedSize = YES;
            CGSize firstItemSize = CGSizeZero;
            for (NSInteger itemIndex = 0; itemIndex < itemsCount; itemIndex++) {
                _UXFlowLayoutItem *item = [section addItem];
                CGSize size = [delegate collectionView:collectionView layout:self sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex]];
                if (size.width <= 0.0) {
                    [NSException raise:NSInvalidArgumentException format:@"negative or zero sizes are not supported in the flow layout"];
                }
                if (itemIndex == 0) {
                    firstItemSize = size;
                } else if (!CGSizeEqualToSize(firstItemSize, size)) {
                    fixedSize = NO;
                }
                item.itemFrame = CGRectMake(0.0, 0.0, size.width, size.height);
            }
            if (fixedSize) {
                [section.items removeAllObjects];
                section.itemSize = firstItemSize;
                section.fixedItemSize = YES;
            }
        } else {
            section.fixedItemSize = YES;
            section.itemSize = _itemSize;
        }

        NSEdgeInsets margins;
        if ((_gridLayoutFlags & UXFlowLayoutFlagDelegateInsetForSection) != 0) {
            margins = [delegate collectionView:collectionView layout:self insetForSectionAtIndex:sectionIndex];
        } else {
            margins = _sectionInset;
        }
        section.sectionMargins = margins;

        CGFloat interitem = (_gridLayoutFlags & UXFlowLayoutFlagDelegateInteritemSpacing) != 0
            ? [delegate collectionView:collectionView layout:self minimumInteritemSpacingForSectionAtIndex:sectionIndex]
            : _interitemSpacing;
        section.horizontalInterstice = interitem;

        CGFloat lineSpacing = (_gridLayoutFlags & UXFlowLayoutFlagDelegateLineSpacing) != 0
            ? [delegate collectionView:collectionView layout:self minimumLineSpacingForSectionAtIndex:sectionIndex]
            : _lineSpacing;
        section.verticalInterstice = lineSpacing;

        NSDictionary *alignmentOptions = nil;
        if ((_gridLayoutFlags & UXFlowLayoutFlagDelegateAlignmentOptions) != 0) {
            alignmentOptions = [delegate _collectionView:collectionView layout:self flowLayoutRowAlignmentOptionsForSection:sectionIndex];
        }
        if (!alignmentOptions) {
            alignmentOptions = _rowAlignmentsOptionsDictionary;
        }
        section.rowAlignmentOptions = alignmentOptions;

        CGSize headerSize;
        if ((_gridLayoutFlags & UXFlowLayoutFlagDelegateReferenceSizeForHeader) != 0) {
            headerSize = [delegate collectionView:collectionView layout:self referenceSizeForHeaderInSection:sectionIndex];
        } else {
            headerSize = _headerReferenceSize;
        }
        section.headerDimension = _scrollDirection == UXCollectionViewScrollDirectionHorizontal ? headerSize.width : headerSize.height;

        CGSize footerSize;
        if ((_gridLayoutFlags & UXFlowLayoutFlagDelegateReferenceSizeForFooter) != 0) {
            footerSize = [delegate collectionView:collectionView layout:self referenceSizeForFooterInSection:sectionIndex];
        } else {
            footerSize = _footerReferenceSize;
        }
        section.footerDimension = _scrollDirection == UXCollectionViewScrollDirectionHorizontal ? footerSize.width : footerSize.height;
    }
}

- (void)_updateItemsLayout {
    if (!_data) {
        return;
    }
    BOOL horizontal = _data.horizontal;
    UXCollectionView *collectionView = self.collectionView;
    CGRect bounds = [(id)collectionView bounds];
    NSEdgeInsets contentInsets = [(id)collectionView contentInsets];
    CGFloat dimension = horizontal
        ? (bounds.size.height - contentInsets.top - contentInsets.bottom)
        : (bounds.size.width - contentInsets.left - contentInsets.right);
    if (dimension < 0.0) {
        dimension = 0.0;
    }
    if (dimension == 0.0) {
        return;
    }

    _data.dimension = dimension;
    _currentLayoutSize = CGSizeZero;

    CGFloat offset = 0.0;
    for (_UXFlowLayoutSection *section in _data.sections) {
        [section computeLayout];
        CGRect frame = section.frame;
        if (horizontal) {
            frame.origin.x = offset;
            offset += frame.size.width;
        } else {
            frame.origin.y = offset;
            offset += frame.size.height;
        }
        section.frame = frame;
    }

    if (horizontal) {
        _currentLayoutSize = CGSizeMake(offset, _data.dimension);
    } else {
        _currentLayoutSize = CGSizeMake(_data.dimension, offset);
    }
    _data.contentSize = _currentLayoutSize;
}

- (void)_fetchItemsInfo {
    if ((_gridLayoutFlags & UXFlowLayoutFlagLayoutDataValid) != 0) {
        return;
    }
    UXCollectionView *collectionView = self.collectionView;
    _visibleBounds = [(id)collectionView bounds];

    CGFloat dimension;
    NSEdgeInsets contentInsets = [(id)collectionView contentInsets];
    if (_scrollDirection == UXCollectionViewScrollDirectionHorizontal) {
        dimension = _visibleBounds.size.height - contentInsets.top - contentInsets.bottom;
    } else {
        dimension = _visibleBounds.size.width - contentInsets.left - contentInsets.right;
    }
    if (dimension < 0.0) {
        dimension = 0.0;
    }
    if (dimension == 0.0) {
        return;
    }

    [self _updateDelegateFlags];
    if ((_gridLayoutFlags & UXFlowLayoutFlagDelegateInfoValid) == 0) {
        [self _getSizingInfos];
        _gridLayoutFlags |= UXFlowLayoutFlagDelegateInfoValid;
    }
    [self _updateItemsLayout];
    _gridLayoutFlags |= UXFlowLayoutFlagLayoutDataValid;
}

#pragma mark - Layout attributes

- (BOOL)shouldUpdateVisibleCellLayoutAttributes {
    return NO;
}

- (UXCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath usingData:(_UXFlowLayoutInfo *)data {
    if (![data sections] || (NSUInteger)indexPath.section >= data.sections.count) {
        return nil;
    }
    _UXFlowLayoutSection *section = data.sections[indexPath.section];
    if (section.itemsCount == 0 || indexPath.item >= section.itemsCount) {
        return nil;
    }

    CGRect frame = [data frameForItemAtIndexPath:indexPath];
    UXCollectionViewLayoutAttributes *attributes = [[[[self class] layoutAttributesClass] alloc] init];
    attributes.indexPath = indexPath;
    [attributes setFrame:frame];
    return attributes;
}

- (UXCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self _fetchItemsInfo];
    return [self layoutAttributesForItemAtIndexPath:indexPath usingData:_data];
}

- (UXCollectionViewLayoutAttributes *)layoutAttributesForHeaderInSection:(NSInteger)section usingData:(_UXFlowLayoutInfo *)data {
    if ((NSUInteger)section >= data.sections.count) {
        return nil;
    }
    _UXFlowLayoutSection *layoutSection = data.sections[section];
    if (layoutSection.headerDimension <= 0.0) {
        return nil;
    }
    CGRect headerFrame = layoutSection.headerFrame;
    CGRect sectionFrame = layoutSection.frame;
    headerFrame = CGRectOffset(headerFrame, sectionFrame.origin.x, sectionFrame.origin.y);

    UXCollectionViewLayoutAttributes *attributes = [[[[self class] layoutAttributesClass] alloc] init];
    attributes.indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    [attributes _setElementKind:UXCollectionElementKindSectionHeader];
    [attributes setFrame:headerFrame];
    return attributes;
}

- (UXCollectionViewLayoutAttributes *)layoutAttributesForFooterInSection:(NSInteger)section usingData:(_UXFlowLayoutInfo *)data {
    if ((NSUInteger)section >= data.sections.count) {
        return nil;
    }
    _UXFlowLayoutSection *layoutSection = data.sections[section];
    if (layoutSection.footerDimension <= 0.0) {
        return nil;
    }
    CGRect footerFrame = layoutSection.footerFrame;
    CGRect sectionFrame = layoutSection.frame;
    footerFrame = CGRectOffset(footerFrame, sectionFrame.origin.x, sectionFrame.origin.y);

    UXCollectionViewLayoutAttributes *attributes = [[[[self class] layoutAttributesClass] alloc] init];
    attributes.indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    [attributes _setElementKind:UXCollectionElementKindSectionFooter];
    [attributes setFrame:footerFrame];
    return attributes;
}

- (UXCollectionViewLayoutAttributes *)layoutAttributesForHeaderInSection:(NSInteger)section {
    [self _fetchItemsInfo];
    return [self layoutAttributesForHeaderInSection:section usingData:_data];
}

- (UXCollectionViewLayoutAttributes *)layoutAttributesForFooterInSection:(NSInteger)section {
    [self _fetchItemsInfo];
    return [self layoutAttributesForFooterInSection:section usingData:_data];
}

- (UXCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if ([elementKind isEqualToString:UXCollectionElementKindSectionHeader]) {
        return [self layoutAttributesForHeaderInSection:indexPath.section];
    }
    if ([elementKind isEqualToString:UXCollectionElementKindSectionFooter]) {
        return [self layoutAttributesForFooterInSection:indexPath.section];
    }
    return nil;
}

- (NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    [self _fetchItemsInfo];
    NSMutableArray<UXCollectionViewLayoutAttributes *> *result = [NSMutableArray array];
    NSArray<NSIndexPath *> *indexPaths = [self indexPathsForItemsInRect:rect usingData:_data];
    for (NSIndexPath *indexPath in indexPaths) {
        UXCollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath usingData:_data];
        if (attributes) {
            [result addObject:attributes];
        }
    }
    NSIndexSet *headerSections = [self indexesForSectionHeadersInRect:rect usingData:_data];
    [headerSections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
        UXCollectionViewLayoutAttributes *attributes = [self layoutAttributesForHeaderInSection:section usingData:self->_data];
        if (attributes) {
            [result addObject:attributes];
        }
    }];
    NSIndexSet *footerSections = [self indexesForSectionFootersInRect:rect usingData:_data];
    [footerSections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
        UXCollectionViewLayoutAttributes *attributes = [self layoutAttributesForFooterInSection:section usingData:self->_data];
        if (attributes) {
            [result addObject:attributes];
        }
    }];
    return result;
}

- (NSArray<NSIndexPath *> *)indexPathsForItemsInRect:(CGRect)rect usingData:(_UXFlowLayoutInfo *)data {
    NSMutableArray<NSIndexPath *> *result = [NSMutableArray array];
    if (!data) {
        return result;
    }
    for (NSUInteger sectionIndex = 0; sectionIndex < data.sections.count; sectionIndex++) {
        _UXFlowLayoutSection *section = data.sections[sectionIndex];
        if (!CGRectIntersectsRect(section.frame, rect)) {
            continue;
        }
        for (NSInteger itemIndex = 0; itemIndex < section.itemsCount; itemIndex++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
            CGRect frame = [data frameForItemAtIndexPath:indexPath];
            if (CGRectIntersectsRect(frame, rect)) {
                [result addObject:indexPath];
            }
        }
    }
    return result;
}

- (NSArray<NSIndexPath *> *)indexPathsForItemsInRect:(CGRect)rect {
    [self _fetchItemsInfo];
    return [self indexPathsForItemsInRect:rect usingData:_data];
}

- (NSIndexSet *)indexesForSectionHeadersInRect:(CGRect)rect usingData:(_UXFlowLayoutInfo *)data {
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (NSUInteger sectionIndex = 0; sectionIndex < data.sections.count; sectionIndex++) {
        _UXFlowLayoutSection *section = data.sections[sectionIndex];
        if (section.headerDimension <= 0.0) {
            continue;
        }
        CGRect headerFrame = CGRectOffset(section.headerFrame, section.frame.origin.x, section.frame.origin.y);
        if (CGRectIntersectsRect(headerFrame, rect)) {
            [indexes addIndex:sectionIndex];
        }
    }
    return indexes;
}

- (NSIndexSet *)indexesForSectionFootersInRect:(CGRect)rect usingData:(_UXFlowLayoutInfo *)data {
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (NSUInteger sectionIndex = 0; sectionIndex < data.sections.count; sectionIndex++) {
        _UXFlowLayoutSection *section = data.sections[sectionIndex];
        if (section.footerDimension <= 0.0) {
            continue;
        }
        CGRect footerFrame = CGRectOffset(section.footerFrame, section.frame.origin.x, section.frame.origin.y);
        if (CGRectIntersectsRect(footerFrame, rect)) {
            [indexes addIndex:sectionIndex];
        }
    }
    return indexes;
}

- (NSIndexSet *)indexesForSectionHeadersInRect:(CGRect)rect {
    return nil;
}

- (NSIndexSet *)indexesForSectionFootersInRect:(CGRect)rect {
    return nil;
}

- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point {
    [self _fetchItemsInfo];
    for (NSUInteger sectionIndex = 0; sectionIndex < _data.sections.count; sectionIndex++) {
        _UXFlowLayoutSection *section = _data.sections[sectionIndex];
        if (!CGRectContainsPoint(section.frame, point)) {
            continue;
        }
        for (NSInteger itemIndex = 0; itemIndex < section.itemsCount; itemIndex++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
            CGRect frame = [_data frameForItemAtIndexPath:indexPath];
            if (CGRectContainsPoint(frame, point)) {
                return indexPath;
            }
        }
    }
    return nil;
}

#pragma mark - Keyboard navigation

- (NSIndexPath *)indexPathOfItemAfter:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return nil;
    }
    UXCollectionView *collectionView = self.collectionView;
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item + 1;
    NSInteger sectionCount = [(id)collectionView numberOfSections];
    while (section < sectionCount) {
        NSInteger itemsCount = [collectionView numberOfItemsInSection:section];
        if (item < itemsCount) {
            return [NSIndexPath indexPathForItem:item inSection:section];
        }
        section++;
        item = 0;
    }
    return nil;
}

- (NSIndexPath *)indexPathOfItemBefore:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return nil;
    }
    UXCollectionView *collectionView = self.collectionView;
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item - 1;
    while (section >= 0) {
        if (item >= 0) {
            return [NSIndexPath indexPathForItem:item inSection:section];
        }
        section--;
        if (section < 0) {
            break;
        }
        item = [collectionView numberOfItemsInSection:section] - 1;
    }
    return nil;
}

- (NSIndexPath *)indexPathOfItemAbove:(NSIndexPath *)indexPath {
    return [self indexPathOfItemBefore:indexPath];
}

- (NSIndexPath *)indexPathOfItemBelow:(NSIndexPath *)indexPath {
    return [self indexPathOfItemAfter:indexPath];
}

#pragma mark - Update animations

- (UXCollectionViewLayoutAttributes *)initialLayoutAttributesForInsertedItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_insertedItemsAttributesDict objectForKey:indexPath];
}

- (UXCollectionViewLayoutAttributes *)initialLayoutAttributesForHeaderInInsertedSection:(NSInteger)section {
    return [_insertedSectionHeadersAttributesDict objectForKey:@(section)];
}

- (UXCollectionViewLayoutAttributes *)initialLayoutAttributesForFooterInInsertedSection:(NSInteger)section {
    return [_insertedSectionFootersAttributesDict objectForKey:@(section)];
}

- (UXCollectionViewLayoutAttributes *)finalLayoutAttributesForDeletedItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_deletedItemsAttributesDict objectForKey:indexPath];
}

- (UXCollectionViewLayoutAttributes *)finalLayoutAttributesForHeaderInDeletedSection:(NSInteger)section {
    return [_deletedSectionHeadersAttributesDict objectForKey:@(section)];
}

- (UXCollectionViewLayoutAttributes *)finalLayoutAttributesForFooterInDeletedSection:(NSInteger)section {
    return [_deletedSectionFootersAttributesDict objectForKey:@(section)];
}

- (void)finalizeCollectionViewUpdates {
    [_insertedItemsAttributesDict removeAllObjects];
    [_insertedSectionHeadersAttributesDict removeAllObjects];
    [_insertedSectionFootersAttributesDict removeAllObjects];
    [_deletedItemsAttributesDict removeAllObjects];
    [_deletedSectionHeadersAttributesDict removeAllObjects];
    [_deletedSectionFootersAttributesDict removeAllObjects];
}

#pragma mark - Private frame helpers

- (CGRect)_frameForHeaderInSection:(NSInteger)section {
    [self _fetchItemsInfo];
    if (section < 0 || section >= (NSInteger)_data.sections.count) {
        return CGRectZero;
    }
    _UXFlowLayoutSection *layoutSection = _data.sections[section];
    return CGRectOffset(layoutSection.headerFrame, layoutSection.frame.origin.x, layoutSection.frame.origin.y);
}

- (CGRect)_frameForFooterInSection:(NSInteger)section {
    [self _fetchItemsInfo];
    if (section < 0 || section >= (NSInteger)_data.sections.count) {
        return CGRectZero;
    }
    _UXFlowLayoutSection *layoutSection = _data.sections[section];
    return CGRectOffset(layoutSection.footerFrame, layoutSection.frame.origin.x, layoutSection.frame.origin.y);
}

- (CGRect)_frameForItemAtSection:(NSIndexPath *)indexPath {
    return [_data frameForItemAtIndexPath:indexPath];
}

- (NSArray<UXCollectionViewLayoutAttributes *> *)_layoutAttributesForItemsInRect:(CGRect)rect {
    NSArray<UXCollectionViewLayoutAttributes *> *all = [self layoutAttributesForElementsInRect:rect];
    NSMutableArray<UXCollectionViewLayoutAttributes *> *items = [NSMutableArray array];
    for (UXCollectionViewLayoutAttributes *attributes in all) {
        if ([attributes _isCell]) {
            [items addObject:attributes];
        }
    }
    return items;
}

#pragma mark - Frame helpers (data-aware)

- (CGRect)_frameForHeaderInSection:(NSInteger)section usingData:(id)data {
    UXCollectionViewLayoutAttributes *attributes = [self layoutAttributesForHeaderInSection:section];
    return attributes ? attributes.frame : CGRectZero;
}

- (CGRect)_frameForFooterInSection:(NSInteger)section usingData:(id)data {
    UXCollectionViewLayoutAttributes *attributes = [self layoutAttributesForFooterInSection:section];
    return attributes ? attributes.frame : CGRectZero;
}

- (CGRect)_frameForItemAtSection:(NSInteger)section andRow:(NSInteger)row usingData:(id)data {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:section];
    UXCollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    return attributes ? attributes.frame : CGRectZero;
}

@end
