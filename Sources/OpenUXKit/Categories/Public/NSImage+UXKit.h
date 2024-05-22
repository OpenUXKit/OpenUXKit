#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSInteger, UXImageOrientation) {
    UXImageOrientationUp,            // default orientation
    UXImageOrientationDown,          // 180 deg rotation
    UXImageOrientationLeft,          // 90 deg CCW
    UXImageOrientationRight,         // 90 deg CW
    UXImageOrientationUpMirrored,    // as above but image mirrored along other axis. horizontal flip
    UXImageOrientationDownMirrored,  // horizontal flip
    UXImageOrientationLeftMirrored,  // vertical flip
    UXImageOrientationRightMirrored, // vertical flip
};


/* UIImage will implement the resizing mode the fastest way possible while
 retaining the desired visual appearance.
 Note that if an image's resizable area is one point then UIImageResizingModeTile
 is visually indistinguishable from UIImageResizingModeStretch.
 */
typedef NS_ENUM(NSInteger, UXImageResizingMode) {
    UXImageResizingModeTile = 0,
    UXImageResizingModeStretch = 1
};

/* Images are created with UIImageRenderingModeAutomatic by default. An image with this mode is interpreted as a template image or an original image based on the context in which it is rendered. For example, navigation bars, tab bars, toolbars, and segmented controls automatically treat their foreground images as templates, while image views and web views treat their images as originals. You can use UIImageRenderingModeAlwaysTemplate to force your image to always be rendered as a template or UIImageRenderingModeAlwaysOriginal to force your image to always be rendered as an original.
 */
typedef NS_ENUM(NSInteger, UXImageRenderingMode) {
    UXImageRenderingModeAutomatic,          // Use the default rendering mode for the context where the image is used
    UXImageRenderingModeAlwaysOriginal,     // Always draw the original image, without treating it as a template
    UXImageRenderingModeAlwaysTemplate,     // Always draw the image as a template image, ignoring its color information
};


@interface NSImage (UXKit)

@property (nonatomic, readonly) UXImageRenderingMode renderingMode;
@property (nonatomic, readonly) UXImageOrientation imageOrientation;
@property (nonatomic, readonly, nullable) CGImageRef CGImage;

+ (NSImage *)imageWithCGImage:(CGImageRef)CGImage;
+ (NSImage *)imageNamed:(NSString *)name inBundle:(nullable NSBundle *)bundle;
- (NSImage *)imageWithRenderingMode:(UXImageRenderingMode)renderingMode;
- (NSImage *)imageWithHorizontallyFlippedOrientation;
- (NSImage *)resizableImageWithCapInsets:(NSEdgeInsets)capInsets resizingMode:(UXImageResizingMode)resizingMode;
- (NSImage *)resizableImageWithCapInsets:(NSEdgeInsets)capInsets;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
