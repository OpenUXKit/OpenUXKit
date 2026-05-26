#import <AppKit/AppKit.h>
#import <OpenUXKit/UXViewController.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXInspectorViewController : UXViewController

@property (nonatomic, strong, nullable) UXViewController *contentViewController;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
