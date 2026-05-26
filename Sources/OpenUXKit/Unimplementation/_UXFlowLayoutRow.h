

#import <objc/NSObject.h>

@class NSMutableArray, _UXFlowLayoutSection;

@interface _UXFlowLayoutRow : NSObject
{
    NSMutableArray *_items;	// 8 = 0x8
    CGSize _rowSize;	// 16 = 0x10
    CGRect _rowFrame;	// 32 = 0x20
    NSInteger _index;	// 64 = 0x40
    BOOL _isValid;	// 72 = 0x48
    BOOL _complete;	// 73 = 0x49
    NSInteger _verticalAlignement;	// 80 = 0x50
    NSInteger _horizontalAlignement;	// 88 = 0x58
    BOOL _fixedItemSize;	// 96 = 0x60
    _UXFlowLayoutSection *_section;	// 104 = 0x68
}

@property(nonatomic) BOOL fixedItemSize; // @synthesize fixedItemSize=_fixedItemSize;
@property(nonatomic) BOOL complete; // @synthesize complete=_complete;
@property(readonly, nonatomic) NSMutableArray *items; // @synthesize items=_items;
@property(nonatomic) NSInteger index; // @synthesize index=_index;
@property(nonatomic) CGRect rowFrame; // @synthesize rowFrame=_rowFrame;
@property(nonatomic) CGSize rowSize; // @synthesize rowSize=_rowSize;
@property(nonatomic) _UXFlowLayoutSection *section; // @synthesize section=_section;
- (id)copyFromSection:(id)arg1;
- (id)snapshot;
- (void)dealloc;
- (void)addItem:(id)arg1;
- (void)layoutRow;
- (void)invalidate;
- (id)init;

@end

