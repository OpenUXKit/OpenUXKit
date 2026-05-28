#import <AppKit/NSWindow.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_PRIVATE
@interface _UXWindow : NSWindow

- (instancetype)initWithContentRect:(CGRect)contentRect;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
