#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXSourceSplitViewSpringLoadingView : NSView <NSSpringLoadingDestination>

@property (copy, nullable) BOOL (^canSpringLoadHandler)(void);
@property (copy, nullable) void (^springLoadingHandler)(BOOL);

- (void)_unSpringLoad;
- (void)_springLoad;
- (BOOL)_canSpringLoad;
- (nullable id)_hitTest:(CGPoint *)point dragTypes:(nullable NSArray<NSPasteboardType> *)dragTypes;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
