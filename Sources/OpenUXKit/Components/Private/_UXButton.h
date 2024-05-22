#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

typedef NS_OPTIONS(NSUInteger, UXControlState) {
    UXControlStateNormal       = 0,
    UXControlStateHighlighted  = 1 << 0,                  // used when UXControl isHighlighted is set
    UXControlStateDisabled     = 1 << 1,
    UXControlStateSelected     = 1 << 2,                  // flag usable by app (see below)
    UXControlStateFocused      = 1 << 3,                  // Applicable only when the screen supports focus
    UXControlStateApplication  = 0x00FF0000,              // additional flags available for application use
    UXControlStateReserved     = 0xFF000000               // flags reserved for internal framework use
};

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXButton : NSButton

- (NSColor *)_textColorForState:(UXControlState)state;
- (NSAttributedString *)_attributedStringForState:(UXControlState)state;
- (void)tintColorDidChange;
- (void)setTitleAttributes:(NSDictionary<NSAttributedStringKey, id> *)titleAttributes forState:(UXControlState)state;
- (void)setTitle:(NSString *)title forState:(UXControlState)state;

@end

