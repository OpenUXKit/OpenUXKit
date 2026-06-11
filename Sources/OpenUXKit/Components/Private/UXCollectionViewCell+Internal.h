#import "UXCollectionViewCell.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXCollectionViewCell () {
    // UXKit 26.4 ivar order: _contentView (568), _selected (576),
    // _selectionBorderShouldUsePrimaryColor (577), _highlighted (578).
    NSView *_contentView;
    BOOL _selected;
    BOOL _selectionBorderShouldUsePrimaryColor;
    BOOL _highlighted;
}

- (void)_setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)_axPerformDoubleClick;
- (nullable id)_axSimulateClick:(NSUInteger)clickType withNumberOfClicks:(NSUInteger)clicks;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
