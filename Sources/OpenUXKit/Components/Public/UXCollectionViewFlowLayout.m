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

// Match Apple's private UXKit on the wire so a single client (e.g. a Swift
// example app) can register/dequeue supplementary views without caring which
// framework backs `import OpenUXKit`.
NSString *const UXCollectionElementKindSectionHeader = @"UXCollectionViewElementKindSectionHeader";
NSString *const UXCollectionElementKindSectionFooter = @"UXCollectionViewElementKindSectionFooter";

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

// Mirrors UXKit's static `AdjustToScale` helper at <UXKit.framework>/__block_literal_global.4418:
// caches the main screen's backingScaleFactor in a dispatch_once and rounds CGFloat values to
// pixel-aligned coordinates so cells line up on the device grid.  When the scale is 1.0 or has
// not yet been resolved (no screens attached during early app launch) we fall back to a plain
// `round`, matching the UXKit behaviour.
static CGFloat UXFlowLayoutAdjustToScale(CGFloat value) {
    static dispatch_once_t onceToken;
    static CGFloat backingScale = 1.0;
    dispatch_once(&onceToken, ^{
        CGFloat resolvedScale = [[NSScreen mainScreen] backingScaleFactor];
        if (resolvedScale > 0.0) {
            backingScale = resolvedScale;
        }
    });
    if (backingScale == 1.0) {
        return round(value);
    }
    return round(value * backingScale) / backingScale;
}

static CGRect UXFlowLayoutAlignFrameOriginToScale(CGRect frame) {
    frame.origin.x = UXFlowLayoutAdjustToScale(frame.origin.x);
    frame.origin.y = UXFlowLayoutAdjustToScale(frame.origin.y);
    return frame;
}

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
    if (size.width <= 0.0) {
        [NSException raise:NSInvalidArgumentException format:@"negative or zero item sizes are not supported in the flow layout"];
    }
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
    if (size.width < 0.0) {
        [NSException raise:NSInvalidArgumentException format:@"negative sizes of headers are not supported in the flow layout"];
    }
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
    if (size.width < 0.0) {
        [NSException raise:NSInvalidArgumentException format:@"negative sizes of footers are not supported in the flow layout"];
    }
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

// UXKit's -[UXCollectionViewFlowLayout(Internal) synchronizeLayout] is a deliberate stub that
// just returns CGSizeZero (see binary at 0x1dbbf3d38).  Earlier OpenUXKit re-routed the call
// through `_fetchItemsInfo` to keep _currentLayoutSize warm, but the real framework leaves the
// hot-loop scheduling to UXCollectionView's main thread driver.  Match the binary so any
// downstream consumer that probes for "is this layout still bootstrapping?" gets the same
// answer it would from UXKit.
- (CGSize)synchronizeLayout {
    return CGSizeZero;
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
                section.itemSize = firstItemSize;
                section.fixedItemSize = YES;
            }
        } else {
            section.fixedItemSize = YES;
            section.itemSize = _itemSize;
            for (NSInteger itemIndex = 0; itemIndex < itemsCount; itemIndex++) {
                _UXFlowLayoutItem *item = [section addItem];
                item.itemFrame = CGRectMake(0.0, 0.0, _itemSize.width, _itemSize.height);
            }
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

    UXCollectionViewLayoutAttributes *attributes = [[[self class] layoutAttributesClass] layoutAttributesForCellWithIndexPath:indexPath];
    CGRect frame = [self _frameForItemAtSection:indexPath.section andRow:indexPath.item usingData:data];
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
    CGRect headerFrame = [self _frameForHeaderInSection:section usingData:data];
    if (CGRectEqualToRect(headerFrame, CGRectZero)) {
        return nil;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    UXCollectionViewLayoutAttributes *attributes = [[[self class] layoutAttributesClass]
        layoutAttributesForSupplementaryViewOfKind:UXCollectionElementKindSectionHeader
                                     withIndexPath:indexPath];
    [attributes setFrame:headerFrame];
    return attributes;
}

- (UXCollectionViewLayoutAttributes *)layoutAttributesForFooterInSection:(NSInteger)section usingData:(_UXFlowLayoutInfo *)data {
    if ((NSUInteger)section >= data.sections.count) {
        return nil;
    }
    CGRect footerFrame = [self _frameForFooterInSection:section usingData:data];
    if (CGRectEqualToRect(footerFrame, CGRectZero)) {
        return nil;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    UXCollectionViewLayoutAttributes *attributes = [[[self class] layoutAttributesClass]
        layoutAttributesForSupplementaryViewOfKind:UXCollectionElementKindSectionFooter
                                     withIndexPath:indexPath];
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
    // Matches UXKit binary at 0x1dbbf2f98 — for each section whose rect intersects, walk
    // `section.items` (note: this is *not* `section.itemsCount`; UXKit iterates the items
    // array directly so fixed-size sections that cleared their item objects are skipped).
    NSMutableArray<NSIndexPath *> *result = [NSMutableArray arrayWithCapacity:10];
    _UXFlowLayoutInfo *layoutData = data ?: _data;
    if (!layoutData) {
        return result;
    }
    NSArray<_UXFlowLayoutSection *> *sections = layoutData.sections;
    NSInteger sectionCount = (NSInteger)sections.count;
    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
        _UXFlowLayoutSection *section = sections[sectionIndex];
        if (!CGRectIntersectsRect(section.frame, rect)) {
            continue;
        }
        NSInteger itemCount = (NSInteger)section.items.count;
        for (NSInteger itemIndex = 0; itemIndex < itemCount; itemIndex++) {
            CGRect itemRect = [self _frameForItemAtSection:sectionIndex andRow:itemIndex usingData:layoutData];
            if (!CGRectIsNull(CGRectIntersection(itemRect, rect))) {
                [result addObject:[NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex]];
            }
        }
    }
    return result;
}

- (NSArray<NSIndexPath *> *)indexPathsForItemsInRect:(CGRect)rect {
    [self _fetchItemsInfo];
    return [self indexPathsForItemsInRect:rect usingData:_data];
}

// UXKit's indexes* variants (binary at 0x1dbbf32d0 / 0x1dbbf3194) actually return an
// NSArray<NSIndexPath *>, not an NSIndexSet, and gate on section.frame intersecting the
// query rect *before* re-testing the absolute header/footer frame.  OpenUXKit's public
// header was already exposing NSIndexSet long before this phase, so we keep the
// NSIndexSet return type to preserve the public API contract but otherwise mirror the
// "intersect section, then intersect supplementary frame" predicate from the binary.
- (NSIndexSet *)indexesForSectionHeadersInRect:(CGRect)rect usingData:(_UXFlowLayoutInfo *)data {
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    _UXFlowLayoutInfo *layoutData = data ?: _data;
    NSArray<_UXFlowLayoutSection *> *sections = layoutData.sections;
    NSInteger sectionCount = (NSInteger)sections.count;
    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
        _UXFlowLayoutSection *section = sections[sectionIndex];
        if (section.headerDimension <= 0.0) {
            continue;
        }
        if (CGRectIsNull(CGRectIntersection(section.frame, rect))) {
            continue;
        }
        CGRect headerFrame = [self _frameForHeaderInSection:sectionIndex usingData:layoutData];
        if (!CGRectIsNull(CGRectIntersection(headerFrame, rect))) {
            [indexes addIndex:(NSUInteger)sectionIndex];
        }
    }
    return indexes;
}

- (NSIndexSet *)indexesForSectionFootersInRect:(CGRect)rect usingData:(_UXFlowLayoutInfo *)data {
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    _UXFlowLayoutInfo *layoutData = data ?: _data;
    NSArray<_UXFlowLayoutSection *> *sections = layoutData.sections;
    NSInteger sectionCount = (NSInteger)sections.count;
    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++) {
        _UXFlowLayoutSection *section = sections[sectionIndex];
        if (section.footerDimension <= 0.0) {
            continue;
        }
        if (CGRectIsNull(CGRectIntersection(section.frame, rect))) {
            continue;
        }
        CGRect footerFrame = [self _frameForFooterInSection:sectionIndex usingData:layoutData];
        if (!CGRectIsNull(CGRectIntersection(footerFrame, rect))) {
            [indexes addIndex:(NSUInteger)sectionIndex];
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
    // UXKit's indexPathForItemAtPoint: (binary at 0x1dbbf2cc0) walks three nested levels —
    // section.frame -> row.rowFrame -> item.itemFrame — rather than flattening to a
    // section/item loop.  Mirror that traversal so RTL/horizontal layouts that depend on
    // row-relative hit-testing line up with the framework.  Each level's frame is stored in
    // its parent's coordinate space; UXKit's check uses CGRectContainsPoint on the raw
    // frame (no origin offset) which is fine because rowFrame is already absolute within
    // the section and itemFrame is row-local but only consulted after the row hit succeeds.
    for (_UXFlowLayoutSection *section in _data.sections) {
        if (!CGRectContainsPoint(section.frame, point)) {
            continue;
        }
        for (_UXFlowLayoutRow *row in section.rows) {
            if (!CGRectContainsPoint(row.rowFrame, point)) {
                continue;
            }
            for (_UXFlowLayoutItem *item in row.items) {
                if (!CGRectContainsPoint(item.itemFrame, point)) {
                    continue;
                }
                NSInteger sectionIndex = [_data.sections indexOfObject:section];
                NSInteger itemIndex = [section.items indexOfObject:item];
                return [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
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
    // UXKit releases all six update-tracking dictionaries (see binary at 0x1dbbf3eb8); the
    // dictionaries are lazily recreated by the update-collection pipeline on the next
    // performBatchUpdates: call.  We mirror that "release & nil" pattern instead of
    // removeAllObjects so allocation patterns and memory footprint stay aligned.
    _insertedItemsAttributesDict = nil;
    _insertedSectionHeadersAttributesDict = nil;
    _insertedSectionFootersAttributesDict = nil;
    _deletedItemsAttributesDict = nil;
    _deletedSectionHeadersAttributesDict = nil;
    _deletedSectionFootersAttributesDict = nil;
}

#pragma mark - Private frame helpers (data-aware)

// UXKit's frame helpers compose the section origin with the relevant child frame and then
// snap the origin to the screen's backing scale using `AdjustToScale.__s` (decompiled at
// 0x1dbbf3f74 / 0x1dbbf4080 / 0x1dbbf4160).  Width/height are left untouched.  Mirror the
// exact rounding pattern (round(value * scale) / scale, falling back to round() at 1.0)
// so cells line up on pixel boundaries identically to the original framework.
- (CGRect)_frameForHeaderInSection:(NSInteger)section usingData:(_UXFlowLayoutInfo *)data {
    _UXFlowLayoutInfo *layoutData = data ?: _data;
    if (section < 0 || section >= (NSInteger)layoutData.sections.count) {
        return CGRectZero;
    }
    _UXFlowLayoutSection *layoutSection = layoutData.sections[section];
    CGRect headerFrame = layoutSection.headerFrame;
    CGRect sectionFrame = layoutSection.frame;
    return UXFlowLayoutAlignFrameOriginToScale(CGRectMake(headerFrame.origin.x + sectionFrame.origin.x,
                                                         headerFrame.origin.y + sectionFrame.origin.y,
                                                         headerFrame.size.width,
                                                         headerFrame.size.height));
}

- (CGRect)_frameForFooterInSection:(NSInteger)section usingData:(_UXFlowLayoutInfo *)data {
    _UXFlowLayoutInfo *layoutData = data ?: _data;
    if (section < 0 || section >= (NSInteger)layoutData.sections.count) {
        return CGRectZero;
    }
    _UXFlowLayoutSection *layoutSection = layoutData.sections[section];
    CGRect footerFrame = layoutSection.footerFrame;
    CGRect sectionFrame = layoutSection.frame;
    return UXFlowLayoutAlignFrameOriginToScale(CGRectMake(footerFrame.origin.x + sectionFrame.origin.x,
                                                         footerFrame.origin.y + sectionFrame.origin.y,
                                                         footerFrame.size.width,
                                                         footerFrame.size.height));
}

// UXKit's _frameForItemAtSection:andRow:usingData: composes three origins: the section frame
// origin, the in-row item frame origin, and the row's frame origin in the section, then
// pixel-aligns the result (binary at 0x1dbbf4160).  The `row` parameter is misnamed in the
// selector — UXKit actually passes a *flat item index*, looks the item up directly in
// `section.items[row]`, then queries `item.rowObject.rowFrame` for the row offset.
- (CGRect)_frameForItemAtSection:(NSInteger)section andRow:(NSInteger)row usingData:(_UXFlowLayoutInfo *)data {
    _UXFlowLayoutInfo *layoutData = data ?: _data;
    if (section < 0 || section >= (NSInteger)layoutData.sections.count) {
        return CGRectZero;
    }
    _UXFlowLayoutSection *layoutSection = layoutData.sections[section];
    if (row < 0 || row >= (NSInteger)layoutSection.items.count) {
        return CGRectZero;
    }
    _UXFlowLayoutItem *item = layoutSection.items[row];
    CGRect itemFrame = item.itemFrame;
    CGRect rowFrame = item.rowObject.rowFrame;
    CGRect sectionFrame = layoutSection.frame;
    return UXFlowLayoutAlignFrameOriginToScale(CGRectMake(itemFrame.origin.x + sectionFrame.origin.x + rowFrame.origin.x,
                                                         itemFrame.origin.y + sectionFrame.origin.y + rowFrame.origin.y,
                                                         itemFrame.size.width,
                                                         itemFrame.size.height));
}

// Convenience wrappers that mirror the no-data UXKit selectors; they materialise the layout
// data lazily and then forward to the usingData: variant so we share the pixel-aligned path.
- (CGRect)_frameForHeaderInSection:(NSInteger)section {
    [self _fetchItemsInfo];
    return [self _frameForHeaderInSection:section usingData:_data];
}

- (CGRect)_frameForFooterInSection:(NSInteger)section {
    [self _fetchItemsInfo];
    return [self _frameForFooterInSection:section usingData:_data];
}

- (CGRect)_frameForItemAtSection:(NSIndexPath *)indexPath {
    [self _fetchItemsInfo];
    return [self _frameForItemAtSection:indexPath.section andRow:indexPath.item usingData:_data];
}

// UXKit derives _layoutAttributesForItemsInRect: from the section/row tables directly
// (binary at 0x1dbbf18bc, the layout fast path) but for OpenUXKit we still defer to the
// already-aligned `layoutAttributesForElementsInRect:` and filter cells.  Skipping the
// fixed-item-size math optimisation costs a small amount of CPU at the boundary of large
// scrolls, but the frames produced are identical and we keep the implementation focused
// on the algorithms users can actually observe.  Revisit during P9 if profiling shows it
// matters.
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

@end
