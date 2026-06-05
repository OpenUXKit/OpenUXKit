#import <AppKit/AppKit.h>
#import <OpenUXKit/UXControl.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXButton : NSButton

- (nullable NSColor *)_textColorForState:(UXControlState)state;
- (nullable NSAttributedString *)_attributedStringForState:(UXControlState)state;
- (void)tintColorDidChange;
- (void)setTitleAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)titleAttributes forState:(UXControlState)state;
- (void)setTitle:(nullable NSString *)title forState:(UXControlState)state;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
