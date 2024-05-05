#import <AppKit/AppKit.h>
#import <OpenUXKit/UITextInputTraits.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)


@interface NSTextView (Compatibility) <UITextInputTraits>

@property (nonatomic) NSInteger textAlignment;
@property (nonatomic, copy, nullable) NSString *text;

- (CGSize)sizeThatFits:(CGSize)size;

@end



NS_HEADER_AUDIT_END(nullability, sendability)
