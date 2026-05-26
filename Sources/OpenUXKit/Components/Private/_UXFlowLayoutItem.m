#import <OpenUXKit/_UXFlowLayoutItem.h>

@interface _UXFlowLayoutItem () {
    CGRect _itemFrame;
    __unsafe_unretained _UXFlowLayoutRow *_rowObject;
    __unsafe_unretained _UXFlowLayoutSection *_section;
}
@end

@implementation _UXFlowLayoutItem

@synthesize itemFrame = _itemFrame;

- (_UXFlowLayoutSection *)section {
    return _section;
}

- (void)setSection:(_UXFlowLayoutSection *)section {
    _section = section;
}

- (_UXFlowLayoutRow *)rowObject {
    return _rowObject;
}

- (void)setRowObject:(_UXFlowLayoutRow *)rowObject {
    _rowObject = rowObject;
}

- (id)copy {
    _UXFlowLayoutItem *copy = [[_UXFlowLayoutItem alloc] init];
    copy->_itemFrame = _itemFrame;
    return copy;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self copy];
}

@end
