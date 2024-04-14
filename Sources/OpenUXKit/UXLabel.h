//
//     Generated by classdump-c 4.2.0 (64 bit) (iOS port by DreamDevLost, Updated by Kevin Bradley.)(Debug version compiled Feb 25 2024 00:55:05).
//
//  Copyright (C) 1997-2019 Steve Nygard. Updated in 2022 by Kevin Bradley.
//

#import <AppKit/AppKit.h>

@class NSArray, NSAttributedString, NSColor, NSFont, NSString, NSTextField;

@interface UXLabel <NSAccessibilityStaticText>
{
    NSTextField *_concreteTextField;	// 112 = 0x70
    NSArray *_verticalDefaultConstraints;	// 120 = 0x78
    NSArray *_verticalCenteringConstraints;	// 128 = 0x80
    NSColor *_textColor;	// 136 = 0x88
    NSColor *_shadowColor;	// 144 = 0x90
    NSColor *_highlightedTextColor;	// 152 = 0x98
    NSInteger _numberOfLines;	// 160 = 0xa0
    CGSize _shadowOffset;	// 168 = 0xa8
}


@property(nonatomic) NSInteger numberOfLines; // @synthesize numberOfLines=_numberOfLines;
@property(retain, nonatomic) NSColor *highlightedTextColor; // @synthesize highlightedTextColor=_highlightedTextColor;
@property(nonatomic) CGSize shadowOffset; // @synthesize shadowOffset=_shadowOffset;
@property(retain, nonatomic) NSColor *shadowColor; // @synthesize shadowColor=_shadowColor;
@property(retain, nonatomic) NSColor *textColor; // @synthesize textColor=_textColor;
- (id)accessibilityRoleDescription;
- (void)setAccessibilityRoleDescription:(id)arg1;
- (id)accessibilityRole;
- (id)accessibilityLabel;
- (void)setAccessibilityLabel:(id)arg1;
- (id)accessibilityValue;
- (CGRect)textRectForBounds:(CGRect)arg1 limitedToNumberOfLines:(NSInteger)arg2;
- (id)textFieldCell;
@property(nonatomic) BOOL selectable;
@property(nonatomic) BOOL centerVertically;
@property(nonatomic) double preferredMaxLayoutWidth;
@property(nonatomic) NSInteger textAlignment;
@property(nonatomic) NSUInteger lineBreakMode;
@property(nonatomic, getter=isHighlighted) BOOL highlighted;
@property(copy, nonatomic) NSAttributedString *attributedText;
@property(copy, nonatomic) NSString *text;
@property(retain, nonatomic) NSFont *font;
- (CGSize)intrinsicContentSize;
- (CGSize)sizeThatFits:(CGSize)arg1;
- (void)sizeToFit;
- (void)setContentCompressionResistancePriority:(float)arg1 forOrientation:(NSInteger)arg2;
- (double)lastBaselineOffsetFromBottom;
- (double)firstBaselineOffsetFromTop;
- (NSEdgeInsets)alignmentRectInsets;
- (id)initWithFrame:(CGRect)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) NSUInteger hash;
@property(readonly) Class superclass;

@end

