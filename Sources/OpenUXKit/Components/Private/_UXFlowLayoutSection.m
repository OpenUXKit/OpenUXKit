#import "_UXFlowLayoutSection.h"
#import "_UXFlowLayoutInfo.h"
#import "_UXFlowLayoutItem.h"
#import "_UXFlowLayoutRow.h"
#import "UXKitPrivateUtilites.h"

static NSString *const UXFlowLayoutCommonRowHorizontalAlignmentKey = @"UXFlowLayoutCommonRowHorizontalAlignmentKey";
static NSString *const UXFlowLayoutLastRowHorizontalAlignmentKey = @"UXFlowLayoutLastRowHorizontalAlignmentKey";

@interface _UXFlowLayoutSection () {
    NSMutableArray<_UXFlowLayoutItem *> *_items;
    NSMutableArray<_UXFlowLayoutRow *> *_rows;
    NSEdgeInsets _sectionMagins;
    CGFloat _verticalInterstice;
    CGFloat _horizontalInterstice;
    CGRect _headerFrame;
    CGRect _footerFrame;
    CGFloat _headerDimension;
    CGFloat _footerDimension;
    BOOL _isValid;
    CGRect _frame;
    NSDictionary *_rowAlignmentOptions;
    BOOL _fixedItemSize;
    CGSize _itemSize;
    CGFloat _otherMargin;
    CGFloat _beginMargin;
    CGFloat _endMargin;
    CGFloat _actualGap;
    CGFloat _lastRowBeginMargin;
    CGFloat _lastRowEndMargin;
    CGFloat _lastRowActualGap;
    BOOL _lastRowIncomplete;
    NSInteger _itemsCount;
    NSInteger _itemsByRowCount;
    NSInteger _indexOfImcompleteRow;
    __unsafe_unretained _UXFlowLayoutInfo *_layoutInfo;
    NSEdgeInsets _sectionMargins;
}
@end

@implementation _UXFlowLayoutSection

@synthesize items = _items;
@synthesize rows = _rows;
@synthesize verticalInterstice = _verticalInterstice;
@synthesize horizontalInterstice = _horizontalInterstice;
@synthesize sectionMargins = _sectionMargins;
@synthesize frame = _frame;
@synthesize headerFrame = _headerFrame;
@synthesize footerFrame = _footerFrame;
@synthesize headerDimension = _headerDimension;
@synthesize footerDimension = _footerDimension;
@synthesize layoutInfo = _layoutInfo;
@synthesize rowAlignmentOptions = _rowAlignmentOptions;
@synthesize fixedItemSize = _fixedItemSize;
@synthesize itemSize = _itemSize;
@synthesize otherMargin = _otherMargin;
@synthesize beginMargin = _beginMargin;
@synthesize endMargin = _endMargin;
@synthesize actualGap = _actualGap;
@synthesize lastRowBeginMargin = _lastRowBeginMargin;
@synthesize lastRowEndMargin = _lastRowEndMargin;
@synthesize lastRowActualGap = _lastRowActualGap;
@synthesize lastRowIncomplete = _lastRowIncomplete;
@synthesize itemsCount = _itemsCount;
@synthesize itemsByRowCount = _itemsByRowCount;
@synthesize indexOfImcompleteRow = _indexOfImcompleteRow;

- (instancetype)init {
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] initWithCapacity:3];
        _rows = [[NSMutableArray alloc] initWithCapacity:3];
        _verticalInterstice = 10.0;
        _horizontalInterstice = 10.0;
    }
    return self;
}

- (void)dealloc {
    _items = nil;
    _rows = nil;
}

- (_UXFlowLayoutItem *)addItem {
    _UXFlowLayoutItem *item = [[_UXFlowLayoutItem alloc] init];
    [item setSection:self];
    [[self items] addObject:item];
    return item;
}

- (_UXFlowLayoutRow *)addRow {
    _UXFlowLayoutRow *row = [[_UXFlowLayoutRow alloc] init];
    [row setSection:self];
    [[self rows] addObject:row];
    return row;
}

- (void)invalidate {
    _isValid = NO;
    [_items removeAllObjects];
}

- (void)recomputeFromIndex:(NSInteger)index {
}

- (void)computeLayout {
    BOOL isHorizontal = [[self layoutInfo] horizontal];
    CGFloat dimension = [[self layoutInfo] dimension];

    CGFloat availableDimension = 0.0;
    CGFloat headerExtentAlongCross = 0.0;
    CGFloat crossInterstice = 0.0;

    if (_fixedItemSize) {
        CGFloat horizontalInterstice = [self horizontalInterstice];
        CGFloat verticalInterstice = [self verticalInterstice];
        NSEdgeInsets margins = [self sectionMargins];

        CGFloat mainInterstice;
        CGFloat beginInset;
        CGFloat endInset;
        CGFloat fixedItemMainSize;
        CGFloat fixedItemCrossSize;
        if (isHorizontal) {
            mainInterstice = verticalInterstice;
            _otherMargin = margins.right + _headerDimension;
            beginInset = margins.top;
            endInset = margins.bottom;
            fixedItemMainSize = _itemSize.height;
            fixedItemCrossSize = _itemSize.width;
            if (_headerDimension > 0.0) {
                _headerFrame = CGRectMake(0.0, 0.0, _headerDimension, [[self layoutInfo] dimension]);
            } else {
                _headerFrame = CGRectZero;
            }
        } else {
            mainInterstice = horizontalInterstice;
            _otherMargin = margins.bottom + _headerDimension;
            beginInset = margins.left;
            endInset = margins.right;
            fixedItemMainSize = _itemSize.width;
            fixedItemCrossSize = _itemSize.height;
            if (_headerDimension > 0.0) {
                _headerFrame = CGRectMake(0.0, 0.0, [[self layoutInfo] dimension], _headerDimension);
            } else {
                _headerFrame = CGRectZero;
            }
        }

        CGFloat insetSum = beginInset + endInset;
        CGFloat usableDimension = dimension - insetSum;
        CGFloat layoutBaseMargin = _otherMargin;
        NSInteger itemsCount = _itemsCount;

        if (itemsCount >= 1) {
            if (fixedItemMainSize > usableDimension) {
                NSLog(@"The behavior of the UICollectionViewFlowLayout is not defined because:");
                if (isHorizontal) {
                    NSLog(@"the item height must be less than the height of the UICollectionView minus the section insets top and bottom values.");
                } else {
                    NSLog(@"the item width must be less than the width of the UICollectionView minus the section insets left and right values.");
                }
                itemsCount = _itemsCount;
            }

            CGFloat itemMainWithSpacing = mainInterstice + fixedItemMainSize;
            NSInteger itemsByRowCount = (NSInteger)floor((mainInterstice + usableDimension) / itemMainWithSpacing);
            if (itemsByRowCount <= 1) {
                itemsByRowCount = 1;
            }
            NSInteger fullRows = itemsCount / itemsByRowCount;
            _itemsByRowCount = itemsByRowCount;
            _indexOfImcompleteRow = -1;
            NSInteger fullRowsItemCount = (itemsCount / itemsByRowCount) * itemsByRowCount;
            NSInteger lastRowItemCount = itemsCount - fullRowsItemCount;
            _lastRowIncomplete = (itemsCount != fullRowsItemCount);
            if (itemsCount != fullRowsItemCount) {
                _indexOfImcompleteRow = fullRows;
                fullRows++;
            }

            CGFloat slackSpace = mainInterstice - (CGFloat)_itemsByRowCount * itemMainWithSpacing;
            int commonAlignment = [[_rowAlignmentOptions objectForKey:UXFlowLayoutCommonRowHorizontalAlignmentKey] intValue];

            if (commonAlignment == 0) {
                _actualGap = mainInterstice;
                _beginMargin = beginInset;
                _endMargin = [[self layoutInfo] dimension] - beginInset + slackSpace;
            } else if (commonAlignment == 1) {
                _actualGap = mainInterstice;
                _beginMargin = beginInset + ([[self layoutInfo] dimension] - (endInset + beginInset + slackSpace)) * 0.5;
                _endMargin = beginInset;
            } else if (commonAlignment == 2) {
                _actualGap = mainInterstice;
                _beginMargin = [[self layoutInfo] dimension] - endInset + slackSpace;
                _endMargin = endInset;
            } else if (commonAlignment == 3) {
                if (_itemsByRowCount <= 1) {
                    _actualGap = mainInterstice;
                    _beginMargin = beginInset + ([[self layoutInfo] dimension] - fixedItemMainSize - beginInset - endInset) * 0.5;
                    _endMargin = endInset + ([[self layoutInfo] dimension] - fixedItemMainSize - beginInset - endInset) * 0.5;
                } else {
                    _actualGap = ([[self layoutInfo] dimension] - beginInset - endInset - (CGFloat)_itemsByRowCount * fixedItemMainSize) / (CGFloat)(_itemsByRowCount - 1);
                    _beginMargin = beginInset;
                    _endMargin = beginInset;
                }
            } else {
                _actualGap = mainInterstice;
                _beginMargin = beginInset;
            }

            if (_lastRowIncomplete) {
                int lastAlignment = [[_rowAlignmentOptions objectForKey:UXFlowLayoutLastRowHorizontalAlignmentKey] intValue];
                if (lastAlignment == 1) {
                    _lastRowActualGap = mainInterstice;
                    _lastRowBeginMargin = beginInset + ([[self layoutInfo] dimension] - (endInset + beginInset - slackSpace)) * 0.5;
                    _lastRowEndMargin = beginInset;
                } else if (lastAlignment == 2) {
                    _lastRowActualGap = mainInterstice;
                    _lastRowEndMargin = [[self layoutInfo] dimension] - endInset + (mainInterstice - (CGFloat)lastRowItemCount * itemMainWithSpacing);
                } else if (lastAlignment == 3) {
                    if (lastRowItemCount <= 1) {
                        _lastRowActualGap = mainInterstice;
                        _lastRowBeginMargin = beginInset + ([[self layoutInfo] dimension] - fixedItemMainSize - beginInset - endInset) * 0.5;
                        _lastRowEndMargin = endInset + ([[self layoutInfo] dimension] - fixedItemMainSize - beginInset - endInset) * 0.5;
                    } else {
                        _lastRowActualGap = ([[self layoutInfo] dimension] + (mainInterstice - (CGFloat)lastRowItemCount * itemMainWithSpacing) - beginInset - endInset) / (CGFloat)(lastRowItemCount - 1);
                        _lastRowEndMargin = beginInset;
                    }
                } else {
                    _lastRowActualGap = mainInterstice;
                    _lastRowEndMargin = beginInset;
                }
            }

            layoutBaseMargin = layoutBaseMargin + (CGFloat)fullRows * (verticalInterstice + fixedItemCrossSize) - verticalInterstice;
        }

        NSEdgeInsets footerMargins = [self sectionMargins];
        CGFloat footerDimension = _footerDimension;
        if (isHorizontal) {
            availableDimension = layoutBaseMargin + footerMargins.right;
            if (footerDimension > 0.0) {
                _footerFrame = CGRectMake(availableDimension, 0.0, footerDimension, [[self layoutInfo] dimension]);
                availableDimension += footerDimension;
            } else {
                _footerFrame = CGRectZero;
            }
            [self setFrame:CGRectMake(0.0, 0.0, availableDimension, [[self layoutInfo] dimension])];
        } else {
            availableDimension = layoutBaseMargin + footerMargins.bottom;
            if (footerDimension > 0.0) {
                _footerFrame = CGRectMake(0.0, availableDimension, [[self layoutInfo] dimension], footerDimension);
                availableDimension += footerDimension;
            } else {
                _footerFrame = CGRectZero;
            }
            [self setFrame:CGRectMake(0.0, 0.0, [[self layoutInfo] dimension], availableDimension)];
        }

    }

    NSEdgeInsets margins = [self sectionMargins];
    CGFloat availableCrossExtent;
    CGFloat mainInterstice;
    CGFloat headerOffsetAlongMain;
    if (isHorizontal) {
        availableCrossExtent = dimension - (margins.top + margins.bottom);
        mainInterstice = [self verticalInterstice];
        crossInterstice = [self horizontalInterstice];
        headerOffsetAlongMain = margins.left + _headerDimension;
    } else {
        availableCrossExtent = dimension - (margins.left + margins.right);
        mainInterstice = [self horizontalInterstice];
        crossInterstice = [self verticalInterstice];
        headerOffsetAlongMain = margins.top + _headerDimension;
    }
    headerExtentAlongCross = availableCrossExtent;

    if (_headerDimension > 0.0) {
        if (isHorizontal) {
            _headerFrame = CGRectMake(0.0, 0.0, _headerDimension, [[self layoutInfo] dimension]);
        } else {
            _headerFrame = CGRectMake(0.0, 0.0, [[self layoutInfo] dimension], _headerDimension);
        }
    } else {
        _headerFrame = CGRectZero;
    }

    CGFloat availableMain = availableCrossExtent;

    [[self rows] removeAllObjects];
    NSInteger itemCount = (NSInteger)[[self items] count];
    _UXFlowLayoutRow *currentRow = nil;
    BOOL allRowsSingleItem = YES;
    CGFloat remainingInRow = availableMain;
    for (NSInteger itemIndex = 0; itemIndex < itemCount; itemIndex++) {
        _UXFlowLayoutItem *item = [[self items] objectAtIndex:itemIndex];
        CGRect itemFrame = [item itemFrame];
        CGFloat itemMainSize = isHorizontal ? itemFrame.size.height : itemFrame.size.width;

        if (itemMainSize > availableMain) {
            NSLog(@"The behavior of the UICollectionViewFlowLayout is not defined because:");
            if (isHorizontal) {
                NSLog(@"the item height must be less than the height of the UICollectionView minus the section insets top and bottom values.");
            } else {
                NSLog(@"the item width must be less than the width of the UICollectionView minus the section insets left and right values.");
            }
            NSLog(@"Please check the values returned by the delegate.");
        }

        if (!currentRow) {
            currentRow = [self addRow];
        }

        CGFloat itemMainWithSpacing = mainInterstice + itemMainSize;
        if (itemMainSize > remainingInRow) {
            [currentRow setComplete:YES];
            allRowsSingleItem = allRowsSingleItem && ([[currentRow items] count] == 1);
            remainingInRow = availableMain - itemMainWithSpacing;
            [currentRow layoutRow];
            currentRow = [self addRow];
            [currentRow addItem:item];
        } else {
            [currentRow addItem:item];
            remainingInRow -= itemMainWithSpacing;
        }
    }

    [currentRow setFixedItemSize:[self fixedItemSize]];
    if (allRowsSingleItem && [[currentRow items] count] == 1) {
        [currentRow setComplete:YES];
    }
    [currentRow layoutRow];

    CGFloat crossPosition = headerOffsetAlongMain;
    for (_UXFlowLayoutRow *row in [self rows]) {
        CGSize rowSize = [row rowSize];
        CGFloat rowCrossOrigin = isHorizontal ? 0.0 : crossPosition;
        CGFloat rowMainOrigin = isHorizontal ? crossPosition : 0.0;
        CGFloat rowMainSize = isHorizontal ? rowSize.width : rowSize.height;
        crossPosition = crossPosition + crossInterstice + rowMainSize;
        [row setRowFrame:CGRectMake(rowMainOrigin, rowCrossOrigin, rowSize.width, rowSize.height)];
    }

    CGFloat totalExtent = crossPosition - crossInterstice;
    NSEdgeInsets finalMargins = [self sectionMargins];
    CGFloat footerDimension = _footerDimension;
    if (isHorizontal) {
        CGFloat finalMain = totalExtent + finalMargins.right;
        if (footerDimension > 0.0) {
            _footerFrame = CGRectMake(finalMain, 0.0, footerDimension, [[self layoutInfo] dimension]);
            finalMain += _footerDimension;
        } else {
            _footerFrame = CGRectZero;
        }
        [self setFrame:CGRectMake(0.0, 0.0, finalMain, availableCrossExtent)];
    } else {
        CGFloat finalMain = totalExtent + finalMargins.bottom;
        if (footerDimension > 0.0) {
            _footerFrame = CGRectMake(0.0, finalMain, [[self layoutInfo] dimension], footerDimension);
            finalMain += _footerDimension;
        } else {
            _footerFrame = CGRectZero;
        }
        [self setFrame:CGRectMake(0.0, 0.0, availableCrossExtent, finalMain)];
    }
    (void)headerExtentAlongCross;
}

- (_UXFlowLayoutSection *)copyFromLayoutInfo:(_UXFlowLayoutInfo *)layoutInfo {
    _UXFlowLayoutSection *copy = [[_UXFlowLayoutSection alloc] init];
    if (copy) {
        copy->_sectionMagins = _sectionMagins;
        copy->_verticalInterstice = _verticalInterstice;
        copy->_horizontalInterstice = _horizontalInterstice;
        copy->_frame = _frame;
        copy->_isValid = _isValid;
        copy->_headerFrame = _headerFrame;
        copy->_footerFrame = _footerFrame;
        copy->_headerDimension = _headerDimension;
        copy->_footerDimension = _footerDimension;
        [copy setLayoutInfo:layoutInfo];
        copy->_fixedItemSize = _fixedItemSize;
        copy->_itemSize = _itemSize;
        copy->_itemsCount = _itemsCount;
        copy->_itemsByRowCount = _itemsByRowCount;
        copy->_indexOfImcompleteRow = _indexOfImcompleteRow;
        copy->_beginMargin = _beginMargin;
        copy->_endMargin = _endMargin;
        copy->_actualGap = _actualGap;
        copy->_lastRowIncomplete = _lastRowIncomplete;
        copy->_lastRowBeginMargin = _lastRowBeginMargin;
        copy->_lastRowEndMargin = _lastRowEndMargin;
        copy->_lastRowActualGap = _lastRowActualGap;
        copy->_otherMargin = _otherMargin;
        for (_UXFlowLayoutRow *row in [self rows]) {
            _UXFlowLayoutRow *rowCopy = [row copyFromSection:copy];
            [[copy rows] addObject:rowCopy];
            [[copy items] addObjectsFromArray:[rowCopy items]];
        }
    }
    return copy;
}

- (_UXFlowLayoutSection *)snapshot {
    _UXFlowLayoutSection *snapshot = [[_UXFlowLayoutSection alloc] init];
    for (_UXFlowLayoutRow *row in [self rows]) {
        _UXFlowLayoutRow *rowSnapshot = [row snapshot];
        [[snapshot rows] addObject:rowSnapshot];
        [[snapshot items] addObjectsFromArray:[rowSnapshot items]];
    }
    [snapshot setFrame:[self frame]];
    return snapshot;
}

@end
