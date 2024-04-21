#import "UXKitAppearance-Protocol.h"
#import "UXBarItem.h"
@class NSColor, NSLayoutAnchor, NSString, NSView, UXViewController;

@interface UXBarButtonItem: UXBarItem <UXKitAppearance>


@property(nonatomic, setter=_setWidthConstrainingItem:) __weak UXBarButtonItem *_widthConstrainingItem; // @synthesize _widthConstrainingItem=__widthConstrainingItem;
@property(nonatomic) float visibilityPriority; // @synthesize visibilityPriority=_visibilityPriority;
@property(nonatomic, getter=isCondensed) BOOL condensed; // @synthesize condensed=_condensed;
@property(readonly, nonatomic) NSInteger systemItem; // @synthesize systemItem=_systemItem;
@property(readonly, nonatomic) UXViewController *contentViewController; // @synthesize contentViewController=_contentViewController;
@property(retain, nonatomic) NSLayoutAnchor *baselineAnchor; // @synthesize baselineAnchor=_baselineAnchor;
@property(retain, nonatomic) NSView *customView; // @synthesize customView=_customView;
@property(nonatomic) double width; // @synthesize width=_width;
@property(nonatomic) NSInteger style; // @synthesize style=_style;
@property(readonly, nonatomic) NSView *_view;
@property (nonatomic, copy) NSString *label;
- (id)_viewOfClass:(Class)arg1;
- (id)image;
- (void)setImage:(id)arg1;
- (BOOL)isEnabled;
- (void)setEnabled:(BOOL)arg1;
@property(nonatomic) BOOL ignoresMultiClick; // @synthesize ignoresMultiClick=_ignoresMultiClick;
@property(nonatomic) NSInteger buttonState; // @synthesize buttonState=_buttonState;
@property(nonatomic) NSUInteger keyEquivalentModifierMask; // @synthesize keyEquivalentModifierMask=_keyEquivalentModifierMask;
@property(retain, nonatomic) NSString *keyEquivalent; // @synthesize keyEquivalent=_keyEquivalent;
@property(retain, nonatomic) NSString *toolTip; // @synthesize toolTip=_toolTip;
@property(nonatomic) __weak id target; // @synthesize target=_target;
@property(nonatomic) SEL action; // @synthesize action=_action;
- (void)setAccessibilityLabel:(id)arg1;
- (void)setTitle:(id)arg1;
- (void)tintColorDidChange;
@property(nonatomic) NSInteger tintAdjustmentMode; // @synthesize tintAdjustmentMode=_tintAdjustmentMode;
@property(retain, nonatomic) NSColor *tintColor; // @synthesize tintColor=_tintColor;
- (double)preferredSpacingToItem:(id)arg1 proposedSpacing:(double)arg2;
- (id)initWithStyle:(NSInteger)arg1 target:(id)arg2 action:(SEL)arg3;
- (id)initWithContentViewController:(id)arg1;
- (id)initWithCustomView:(id)arg1;
- (id)initWithBarButtonSystemItem:(NSInteger)arg1 target:(id)arg2 action:(SEL)arg3;
- (id)initWithTitle:(NSString *)title style:(NSInteger)style target:(id)target action:(SEL)action;
- (id)initWithImage:(NSImage *)image style:(NSInteger)style target:(id)target action:(SEL)action;

@end

