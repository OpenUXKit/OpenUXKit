#import <AppKit/AppKit.h>
#import <OpenUXKit/UXView.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXContainerView : UXView

@property (nonatomic) BOOL wantsMaterialBackground;
@property (nonatomic, strong, nullable) NSView *contentView;

- (void)wrapContentView;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
