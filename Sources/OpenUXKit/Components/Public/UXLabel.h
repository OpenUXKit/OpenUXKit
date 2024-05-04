#import <AppKit/AppKit.h>
#import <OpenUXKit/UXView.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXLabel : UXView <NSAccessibilityStaticText>

@property (nonatomic) NSInteger numberOfLines;
@property (nonatomic, strong, nullable) NSColor *highlightedTextColor;
@property (nonatomic) CGSize shadowOffset;
@property (nonatomic, strong, nullable) NSColor *shadowColor;
@property (nonatomic, strong, nullable) NSColor *textColor;
@property (nonatomic) BOOL selectable;
@property (nonatomic) BOOL centerVertically;
@property (nonatomic) CGFloat preferredMaxLayoutWidth;
@property (nonatomic) NSInteger textAlignment;
@property (nonatomic) NSUInteger lineBreakMode;
@property (nonatomic, getter = isHighlighted) BOOL highlighted;
@property (nonatomic, copy) NSAttributedString *attributedText;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong, nullable) NSFont *font;
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines;
- (__kindof NSCell *)textFieldCell;
- (CGSize)sizeThatFits:(CGSize)size;
- (void)sizeToFit;
- (CGFloat)lastBaselineOffsetFromBottom;
- (CGFloat)firstBaselineOffsetFromTop;
- (NSEdgeInsets)alignmentRectInsets;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
