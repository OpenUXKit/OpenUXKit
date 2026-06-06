#import "UXCollectionViewCell.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXCollectionViewCell () {
    NSView *_contentView;
    BOOL _selected;
    BOOL _highlighted;
    BOOL _selectionBorderShouldUsePrimaryColor;
}

- (void)_setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)_axPerformDoubleClick;
- (nullable id)_axSimulateClick:(NSUInteger)clickType withNumberOfClicks:(NSUInteger)clicks;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
