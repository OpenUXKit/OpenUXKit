#import <AppKit/AppKit.h>
#import <OpenUXKit/UITextInputTraits.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSTextField (Compatibility) <UITextInputTraits>
@property (nonatomic) NSInteger textAlignment;
@property (nonatomic, copy, nullable) NSString *placeholder;
@property (nonatomic, copy, nullable) NSString *text;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
