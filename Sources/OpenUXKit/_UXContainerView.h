#import <AppKit/AppKit.h>
#import "UXView.h"
#import "UXKitDefines.h"

UXKIT_PRIVATE
@interface _UXContainerView : UXView

@property (nonatomic) BOOL wantsMaterialBackground;
@property (nonatomic, strong) NSView *contentView;

- (void)wrapContentView;

@end

