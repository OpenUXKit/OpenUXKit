#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXSourceSplitViewSpringLoadingView : NSView <NSSpringLoadingDestination>

@property (copy) BOOL (^ canSpringLoadHandler)(void);
@property (copy) void (^ springLoadingHandler)(BOOL);

- (void)_unSpringLoad;
- (void)_springLoad;
- (BOOL)_canSpringLoad;
- (id)_hitTest:(CGPoint *)point dragTypes:(id)dragTypes;

@end
