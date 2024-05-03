#import <AppKit/AppKit.h>
#import "UXView.h"

@interface UXLabel : UXView <NSAccessibilityStaticText>

@property (nonatomic) NSInteger numberOfLines; // @synthesize numberOfLines=_numberOfLines;
@property (nonatomic, strong) NSColor *highlightedTextColor; // @synthesize highlightedTextColor=_highlightedTextColor;
@property (nonatomic) CGSize shadowOffset; // @synthesize shadowOffset=_shadowOffset;
@property (nonatomic, strong) NSColor *shadowColor; // @synthesize shadowColor=_shadowColor;
@property (nonatomic, strong) NSColor *textColor; // @synthesize textColor=_textColor;
@property (nonatomic) BOOL selectable;
@property (nonatomic) BOOL centerVertically;
@property (nonatomic) CGFloat preferredMaxLayoutWidth;
@property (nonatomic) NSInteger textAlignment;
@property (nonatomic) NSUInteger lineBreakMode;
@property (nonatomic, getter = isHighlighted) BOOL highlighted;
@property (nonatomic, copy) NSAttributedString *attributedText;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSFont *font;
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines;
- (id)textFieldCell;
- (CGSize)sizeThatFits:(CGSize)size;
- (void)sizeToFit;
- (CGFloat)lastBaselineOffsetFromBottom;
- (CGFloat)firstBaselineOffsetFromTop;
- (NSEdgeInsets)alignmentRectInsets;

@end
