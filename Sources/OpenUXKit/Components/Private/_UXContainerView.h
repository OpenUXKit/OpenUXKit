#import <AppKit/AppKit.h>
#import <OpenUXKit/UXView.h>
#import <OpenUXKit/UXKitDefines.h>

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXContainerView : UXView

@property (nonatomic) BOOL wantsMaterialBackground;
@property (nonatomic, strong) NSView *contentView;

- (void)wrapContentView;

@end

