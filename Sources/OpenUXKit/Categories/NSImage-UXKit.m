#import "NSImage-UXKit.h"
#import <OpenUXKit/_UXResizableImage.h>

@implementation NSImage (UXKit)

+ (NSImage *)imageWithCGImage:(CGImageRef)CGImage {
    return [[NSImage alloc] initWithCGImage:CGImage size:CGSizeZero];
}

+ (NSImage *)imageNamed:(NSString *)name inBundle:(nullable NSBundle *)bundle {
    NSParameterAssert(name);
    NSImage *image = [NSImage imageNamed:name];
    if (bundle && !image) {
        image = [bundle imageForResource:name];
        image.name = name;
    }
    return image;
}

- (NSImage *)imageWithHorizontallyFlippedOrientation {
    NSAffineTransform *transform = [NSAffineTransform transform];
    CGSize size = self.size;
    NSImage *newImage = [[NSImage alloc] initWithSize:size];
    [newImage lockFocus];
    NSAffineTransformStruct transformStruct = {
        .m11 = -1.0,
        .m12 = 0.0,
        .m21 = 0.0,
        .m22 = 1.0,
        .tX = size.width,
        .tY = 0,
    };
    [transform setTransformStruct:transformStruct];
    [transform concat];
    [self drawAtPoint:CGPointZero fromRect:CGRectMake(0.0, 0.0, size.width, size.height) operation:(NSCompositingOperationCopy) fraction:1.0];
    [newImage unlockFocus];
    return newImage;
}

- (NSImage *)imageWithRenderingMode:(UXImageRenderingMode)renderingMode {
    
    if (!renderingMode) {
        renderingMode = UXImageRenderingModeAlwaysOriginal;
    }
    
    if (renderingMode == self.renderingMode) {
        return self;
    } else {
        NSImage *newImage = self.copy;
        newImage.name = nil;
        newImage.template = renderingMode == UXImageRenderingModeAlwaysTemplate;
        return newImage;
    }
}

- (NSImage *)resizableImageWithCapInsets:(NSEdgeInsets)capInsets {
    return [self resizableImageWithCapInsets:capInsets resizingMode:(UXImageResizingModeTile)];
}

- (NSImage *)resizableImageWithCapInsets:(NSEdgeInsets)capInsets resizingMode:(UXImageResizingMode)resizingMode {
    _UXResizableImage *resizeableImage = [[_UXResizableImage alloc] initWithImage:self capInsets:capInsets];
    if (resizingMode == UXImageResizingModeStretch) {
        resizeableImage.alwaysStretches = YES;
    }
    return resizeableImage;
}

- (UXImageRenderingMode)renderingMode {
    if (self.isTemplate) {
        return UXImageRenderingModeAlwaysTemplate;
    } else {
        return UXImageRenderingModeAlwaysOriginal;
    }
}

- (UXImageOrientation)imageOrientation {
    return UXImageOrientationUp;
}

- (CGImageRef)CGImage {
    return [self CGImageForProposedRect:nil context:nil hints:nil];
}

@end
