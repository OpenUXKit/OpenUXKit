#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface UXBackButton : NSSegmentedControl

@property (nonatomic, strong, nullable) NSImage *image;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic) BOOL hidesTitle;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
