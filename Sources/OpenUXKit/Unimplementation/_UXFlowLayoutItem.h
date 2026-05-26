

#import <objc/NSObject.h>

@class _UXFlowLayoutRow, _UXFlowLayoutSection;

@interface _UXFlowLayoutItem : NSObject
{
    CGRect _itemFrame;	// 8 = 0x8
    _UXFlowLayoutSection *_section;	// 40 = 0x28
    _UXFlowLayoutRow *_rowObject;	// 48 = 0x30
}

@property(nonatomic) CGRect itemFrame; // @synthesize itemFrame=_itemFrame;
@property(nonatomic) _UXFlowLayoutRow *rowObject; // @synthesize rowObject=_rowObject;
@property(nonatomic) _UXFlowLayoutSection *section; // @synthesize section=_section;
- (id)copy;

@end

