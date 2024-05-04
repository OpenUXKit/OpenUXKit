

@class NSView;

@interface UXCollectionViewCell
{
    NSView *_contentView;	// 144 = 0x90
    BOOL _selected;	// 152 = 0x98
    BOOL _selectionBorderShouldUsePrimaryColor;	// 153 = 0x99
    BOOL _highlighted;	// 154 = 0x9a
}

@property(nonatomic, getter=isHighlighted) BOOL highlighted; // @synthesize highlighted=_highlighted;
@property(nonatomic) BOOL selectionBorderShouldUsePrimaryColor; // @synthesize selectionBorderShouldUsePrimaryColor=_selectionBorderShouldUsePrimaryColor;
@property(readonly, nonatomic) NSView *contentView; // @synthesize contentView=_contentView;
@property(nonatomic, getter=isSelected) BOOL selected; // @synthesize selected=_selected;
- (void)_setSelected:(BOOL)arg1 animated:(BOOL)arg2;
- (void)prepareForReuse;
- (void)resizeSubviewsWithOldSize:(CGSize)arg1;
- (BOOL)wantsUpdateLayer;
- (void)dealloc;
- (id)initWithCoder:(id)arg1;
- (id)initWithFrame:(CGRect)arg1;
- (id)_accessibilityIndexPath;
- (id)_accessibilityDefaultRole;
- (id)_dynamicAccessibilityParent;
- (void)setAccessibilitySelected:(BOOL)arg1;
- (BOOL)isAccessibilitySelectorAllowed:(SEL)arg1;
- (BOOL)isAccessibilitySelected;
- (id)_axSimulateClick:(NSUInteger)arg1 withNumberOfClicks:(NSUInteger)arg2;
- (void)_axPerformCGFloatClick;
- (BOOL)accessibilityPerformPress;

@end

