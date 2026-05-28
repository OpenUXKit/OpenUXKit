#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

@class UXBarButtonItem, UXNavigationItem;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface UXWindowToolbarController : NSObject <NSToolbarDelegate>

@property (nonatomic, strong, nullable) UXBarButtonItem *observedProgressButtonItem;
@property (nonatomic, strong, nullable) UXNavigationItem *navigationItem;
@property (nonatomic, strong, nullable) NSSearchToolbarItem *searchToolbarItem;
@property (nonatomic, readonly) NSToolbar *toolbar;

- (instancetype)initWithNavigationItem:(nullable UXNavigationItem *)navigationItem;
- (void)updateToolbar;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
