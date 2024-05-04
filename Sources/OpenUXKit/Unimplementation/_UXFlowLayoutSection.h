

#import <objc/NSObject.h>

@class NSDictionary, NSMutableArray, _UXFlowLayoutInfo;

@interface _UXFlowLayoutSection : NSObject
{
    NSMutableArray *_items;	// 8 = 0x8
    NSMutableArray *_rows;	// 16 = 0x10
    NSEdgeInsets _sectionMagins;	// 24 = 0x18
    CGFloat _verticalInterstice;	// 56 = 0x38
    CGFloat _horizontalInterstice;	// 64 = 0x40
    CGRect _headerFrame;	// 72 = 0x48
    CGRect _footerFrame;	// 104 = 0x68
    CGFloat _headerDimension;	// 136 = 0x88
    CGFloat _footerDimension;	// 144 = 0x90
    BOOL _isValid;	// 152 = 0x98
    CGRect _frame;	// 160 = 0xa0
    NSDictionary *_rowAlignmentOptions;	// 192 = 0xc0
    BOOL _fixedItemSize;	// 200 = 0xc8
    CGSize _itemSize;	// 208 = 0xd0
    CGFloat _otherMargin;	// 224 = 0xe0
    CGFloat _beginMargin;	// 232 = 0xe8
    CGFloat _endMargin;	// 240 = 0xf0
    CGFloat _actualGap;	// 248 = 0xf8
    CGFloat _lastRowBeginMargin;	// 256 = 0x100
    CGFloat _lastRowEndMargin;	// 264 = 0x108
    CGFloat _lastRowActualGap;	// 272 = 0x110
    BOOL _lastRowIncomplete;	// 280 = 0x118
    NSInteger _itemsCount;	// 288 = 0x120
    NSInteger _itemsByRowCount;	// 296 = 0x128
    NSInteger _indexOfImcompleteRow;	// 304 = 0x130
    _UXFlowLayoutInfo *_layoutInfo;	// 312 = 0x138
    NSEdgeInsets _sectionMargins;	// 320 = 0x140
}

@property(nonatomic) CGSize itemSize; // @synthesize itemSize=_itemSize;
@property(readonly, nonatomic) NSInteger itemsByRowCount; // @synthesize itemsByRowCount=_itemsByRowCount;
@property(nonatomic) NSInteger itemsCount; // @synthesize itemsCount=_itemsCount;
@property(readonly, nonatomic) NSInteger indexOfImcompleteRow; // @synthesize indexOfImcompleteRow=_indexOfImcompleteRow;
@property(readonly, nonatomic) BOOL lastRowIncomplete; // @synthesize lastRowIncomplete=_lastRowIncomplete;
@property(readonly, nonatomic) CGFloat lastRowActualGap; // @synthesize lastRowActualGap=_lastRowActualGap;
@property(readonly, nonatomic) CGFloat lastRowEndMargin; // @synthesize lastRowEndMargin=_lastRowEndMargin;
@property(readonly, nonatomic) CGFloat lastRowBeginMargin; // @synthesize lastRowBeginMargin=_lastRowBeginMargin;
@property(readonly, nonatomic) CGFloat actualGap; // @synthesize actualGap=_actualGap;
@property(readonly, nonatomic) CGFloat endMargin; // @synthesize endMargin=_endMargin;
@property(readonly, nonatomic) CGFloat beginMargin; // @synthesize beginMargin=_beginMargin;
@property(readonly, nonatomic) CGFloat otherMargin; // @synthesize otherMargin=_otherMargin;
@property(nonatomic) BOOL fixedItemSize; // @synthesize fixedItemSize=_fixedItemSize;
@property(strong, nonatomic) NSDictionary *rowAlignmentOptions; // @synthesize rowAlignmentOptions=_rowAlignmentOptions;
@property(nonatomic) CGRect frame; // @synthesize frame=_frame;
@property(nonatomic) _UXFlowLayoutInfo *layoutInfo; // @synthesize layoutInfo=_layoutInfo;
@property(nonatomic) CGRect footerFrame; // @synthesize footerFrame=_footerFrame;
@property(nonatomic) CGRect headerFrame; // @synthesize headerFrame=_headerFrame;
@property(nonatomic) CGFloat footerDimension; // @synthesize footerDimension=_footerDimension;
@property(nonatomic) CGFloat headerDimension; // @synthesize headerDimension=_headerDimension;
@property(nonatomic) NSEdgeInsets sectionMargins; // @synthesize sectionMargins=_sectionMargins;
@property(nonatomic) CGFloat horizontalInterstice; // @synthesize horizontalInterstice=_horizontalInterstice;
@property(nonatomic) CGFloat verticalInterstice; // @synthesize verticalInterstice=_verticalInterstice;
@property(readonly, nonatomic) NSMutableArray *rows; // @synthesize rows=_rows;
@property(readonly, nonatomic) NSMutableArray *items; // @synthesize items=_items;
- (id)copyFromLayoutInfo:(id)arg1;
- (id)snapshot;
- (id)addRow;
- (id)addItem;
- (void)dealloc;
- (void)recomputeFromIndex:(NSInteger)arg1;
- (void)computeLayout;
- (void)invalidate;
- (id)init;

@end

