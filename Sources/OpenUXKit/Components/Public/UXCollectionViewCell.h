#import <OpenUXKit/UXCollectionReusableView.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewCell : UXCollectionReusableView

@property (nonatomic, readonly) NSView *contentView;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic) BOOL selectionBorderShouldUsePrimaryColor;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

- (void)_setSelected:(BOOL)selected animated:(BOOL)animated;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
