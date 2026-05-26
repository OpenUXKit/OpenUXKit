#import <OpenUXKit/_UXFlowLayoutRow.h>
#import <OpenUXKit/_UXFlowLayoutSection.h>
#import <OpenUXKit/_UXFlowLayoutInfo.h>
#import <OpenUXKit/_UXFlowLayoutItem.h>
#import <OpenUXKit/UXKitPrivateUtilites.h>

static NSString *const UXFlowLayoutCommonRowHorizontalAlignmentKey = @"UXFlowLayoutCommonRowHorizontalAlignmentKey";
static NSString *const UXFlowLayoutLastRowHorizontalAlignmentKey = @"UXFlowLayoutLastRowHorizontalAlignmentKey";

@interface _UXFlowLayoutRow () {
    NSMutableArray<_UXFlowLayoutItem *> *_items;
    __unsafe_unretained _UXFlowLayoutSection *_section;
    CGSize _rowSize;
    CGRect _rowFrame;
    NSInteger _index;
    BOOL _complete;
    BOOL _fixedItemSize;
    BOOL _isValid;
    NSInteger _verticalAlignement;
    NSInteger _horizontalAlignement;
}
@end

@implementation _UXFlowLayoutRow

@synthesize section = _section;
@synthesize rowSize = _rowSize;
@synthesize rowFrame = _rowFrame;
@synthesize index = _index;
@synthesize items = _items;
@synthesize complete = _complete;
@synthesize fixedItemSize = _fixedItemSize;

- (instancetype)init {
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] initWithCapacity:3];
        _verticalAlignement = 1;
        _horizontalAlignement = 3;
    }
    return self;
}

- (void)dealloc {
    _items = nil;
}

- (void)addItem:(_UXFlowLayoutItem *)item {
    [[self items] addObject:item];
    [item setRowObject:self];
}

- (void)invalidate {
    _isValid = NO;
    [_items removeAllObjects];
}

- (_UXFlowLayoutRow *)copyFromSection:(_UXFlowLayoutSection *)section {
    _UXFlowLayoutRow *copy = [[_UXFlowLayoutRow alloc] init];
    if (copy) {
        copy->_section = section;
        copy->_rowSize = _rowSize;
        copy->_rowFrame = _rowFrame;
        copy->_index = _index;
        copy->_isValid = _isValid;
        copy->_complete = _complete;
        copy->_verticalAlignement = _verticalAlignement;
        copy->_horizontalAlignement = _horizontalAlignement;
        for (_UXFlowLayoutItem *item in [self items]) {
            _UXFlowLayoutItem *itemCopy = [item copy];
            [[copy items] addObject:itemCopy];
            [itemCopy setSection:section];
            [itemCopy setRowObject:copy];
        }
    }
    return copy;
}

- (_UXFlowLayoutRow *)snapshot {
    _UXFlowLayoutRow *snapshot = [[_UXFlowLayoutRow alloc] init];
    for (_UXFlowLayoutItem *item in [self items]) {
        _UXFlowLayoutItem *itemCopy = [[_UXFlowLayoutItem alloc] init];
        [snapshot addItem:itemCopy];
        [itemCopy setItemFrame:[item itemFrame]];
    }
    [snapshot setRowFrame:[self rowFrame]];
    return snapshot;
}

- (void)layoutRow {
    BOOL isHorizontal = [[[self section] layoutInfo] horizontal];
    CGFloat dimension = [[[self section] layoutInfo] dimension];
    NSEdgeInsets sectionMargins = [[self section] sectionMargins];

    CGFloat beginMargin;
    CGFloat endMargin;
    CGFloat interstice;
    if (isHorizontal) {
        beginMargin = sectionMargins.top;
        endMargin = sectionMargins.bottom;
        interstice = [[self section] verticalInterstice];
    } else {
        beginMargin = sectionMargins.left;
        endMargin = sectionMargins.right;
        interstice = [[self section] horizontalInterstice];
    }

    CGFloat mainAxisTotal = 0.0;
    CGFloat maxCrossSize = 0.0;
    for (_UXFlowLayoutItem *item in [self items]) {
        CGRect itemFrame = [item itemFrame];
        CGFloat crossSize = isHorizontal ? itemFrame.size.width : itemFrame.size.height;
        if (crossSize > maxCrossSize) {
            maxCrossSize = crossSize;
        }
        mainAxisTotal += isHorizontal ? itemFrame.size.height : itemFrame.size.width;
    }

    CGFloat rowWidth = isHorizontal ? maxCrossSize : dimension;
    CGFloat rowHeight = isHorizontal ? dimension : maxCrossSize;
    [self setRowSize:CGSizeMake(rowWidth, rowHeight)];

    BOOL rowComplete = [self complete];
    NSDictionary *rowAlignmentOptions = [[self section] rowAlignmentOptions];
    NSString *currentAlignmentKey = rowComplete ? UXFlowLayoutCommonRowHorizontalAlignmentKey : UXFlowLayoutLastRowHorizontalAlignmentKey;
    int currentAlignment = [[rowAlignmentOptions objectForKey:currentAlignmentKey] intValue];
    int commonAlignment = [[[[self section] rowAlignmentOptions] objectForKey:UXFlowLayoutCommonRowHorizontalAlignmentKey] intValue];
    int lastRowAlignment = [[[[self section] rowAlignmentOptions] objectForKey:UXFlowLayoutLastRowHorizontalAlignmentKey] intValue];

    NSArray<_UXFlowLayoutItem *> *items = [self items];
    CGFloat startOffset;
    if (currentAlignment == 1) {
        startOffset = beginMargin + (dimension - mainAxisTotal - (CGFloat)([items count] - 1) * interstice - endMargin - beginMargin) * 0.5;
    } else if (currentAlignment == 3) {
        CGFloat availableSpace = dimension - mainAxisTotal;
        if ([items count] <= 1) {
            startOffset = availableSpace * 0.5;
            interstice = 0.0;
        } else {
            interstice = (availableSpace - beginMargin - endMargin) / (CGFloat)([items count] - 1);
            startOffset = beginMargin;
        }
    } else if (currentAlignment == 2) {
        startOffset = dimension - mainAxisTotal - (CGFloat)([items count] - 1) * interstice - endMargin;
    } else {
        startOffset = beginMargin;
    }

    if (![self complete] && [self fixedItemSize] && commonAlignment == 3 && (lastRowAlignment & ~2) == 0) {
        CGFloat lastRowDimension = [[[self section] layoutInfo] dimension];
        NSEdgeInsets lastRowMargins = [[self section] sectionMargins];
        CGFloat marginsSum;
        CGFloat lastRowInterstice;
        if (isHorizontal) {
            marginsSum = lastRowMargins.top + lastRowMargins.bottom;
            lastRowInterstice = [[self section] verticalInterstice];
        } else {
            marginsSum = lastRowMargins.left + lastRowMargins.right;
            lastRowInterstice = [[self section] horizontalInterstice];
        }
        CGFloat remaining = lastRowDimension - marginsSum;
        CGRect lastItemFrame = [[[self items] lastObject] itemFrame];
        CGFloat itemMainSize = isHorizontal ? lastItemFrame.size.height : lastItemFrame.size.width;
        interstice = 0.0;
        if (itemMainSize <= remaining) {
            NSInteger count = -1;
            NSInteger previousCount;
            do {
                previousCount = count;
                remaining -= (lastRowInterstice + itemMainSize);
                ++count;
            } while (itemMainSize <= remaining);
            if (count) {
                interstice = (dimension - itemMainSize * (CGFloat)(previousCount + 2) - beginMargin - endMargin) / (CGFloat)count;
            }
        }
        startOffset = beginMargin;
    }

    CGFloat position = startOffset;
    for (_UXFlowLayoutItem *item in items) {
        CGRect itemFrame = [item itemFrame];
        CGFloat itemMainSize = isHorizontal ? itemFrame.size.height : itemFrame.size.width;
        CGFloat itemCrossSize = isHorizontal ? itemFrame.size.width : itemFrame.size.height;

        CGFloat crossOffset;
        CGFloat centeredCross = maxCrossSize * 0.5 - itemCrossSize * 0.5;
        CGFloat trailingCross = maxCrossSize - itemCrossSize;
        if (_verticalAlignement != 2) {
            trailingCross = 0.0;
        }
        if (_verticalAlignement != 1) {
            crossOffset = trailingCross;
        } else {
            crossOffset = centeredCross;
        }

        CGFloat newItemX;
        CGFloat newItemY;
        if (isHorizontal) {
            newItemX = crossOffset;
            newItemY = position;
        } else {
            newItemX = position;
            newItemY = crossOffset;
        }
        [item setItemFrame:CGRectMake(newItemX, newItemY, itemFrame.size.width, itemFrame.size.height)];

        position += interstice + itemMainSize;
    }
}

@end
