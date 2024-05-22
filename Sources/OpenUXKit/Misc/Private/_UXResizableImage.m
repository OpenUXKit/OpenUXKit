#import <OpenUXKit/_UXResizableImage.h>

@interface _UXResizableImage ()

{
   NSImage *_topLeftCorner;    // 8 = 0x8
   NSImage *_topEdgeFill;      // 16 = 0x10
   NSImage *_topRightCorner;   // 24 = 0x18
   NSImage *_leftEdgeFill;     // 32 = 0x20
   NSImage *_centerFill;       // 40 = 0x28
   NSImage *_rightEdgeFill;    // 48 = 0x30
   NSImage *_bottomLeftCorner; // 56 = 0x38
   NSImage *_bottomEdgeFill;   // 64 = 0x40
   NSImage *_bottomRightCorner;        // 72 = 0x48
   CGFloat _scale;     // 80 = 0x50
   BOOL _alwaysStretches;      // 88 = 0x58
}


@end

@implementation _UXResizableImage

- (instancetype)initWithImage:(NSImage *)image capInsets:(NSEdgeInsets)capInsets {
    CGImageRef cgImage = [image CGImageForProposedRect:nil context:nil hints:nil];
    if (self = [super initWithCGImage:cgImage size:image.size]) {
        self.capInsets = capInsets;
        _scale = CGImageGetWidth(cgImage) / image.size.width;
    }
    return self;
}

- (CGRect)_contentRectInPixels {
    return [self _contentInsetsInPixels:NSEdgeInsetsZero emptySizeFallback:^CGRect{
        CGPoint origin = CGPointZero;
        CGSize size = [self _sizeInPixels];
        return CGRectMake(origin.x, origin.y, size.width, size.height);
    }];
}

- (BOOL)_isTiledWhenStretchedToSize:(CGSize)size {
    if (_alwaysStretches) {
        return NO;
    }
    CGSize currentSize = self.size;
    CGFloat v12 = currentSize.width - self.capInsets.left;
    CGFloat v14 = v12 - self.capInsets.right;
    CGFloat v16 = self.capInsets.top;
    return (v14 > 1.0) && ((size.width != currentSize.width) || (currentSize.height - v16 - self.capInsets.bottom > 1.0)) && (size.height != currentSize.height);
}

- (CGRect)_contentStretchInPixels {
    return [self _contentInsetsInPixels:self.capInsets emptySizeFallback:^CGRect{
        CGPoint origin = CGPointZero;
        CGSize size = [self _sizeInPixels];
        return CGRectMake(origin.x, origin.y, size.width, size.height);
    }];
}

- (CGSize)_sizeInPixels {
    CGSize size = self.size;
    CGAffineTransform transform = CGAffineTransformMakeScale(_scale, _scale);
    CGFloat width = size.height * transform.c + transform.a * size.width;
    CGFloat height = size.height * transform.d + transform.b * size.width;
    return CGSizeMake(width, height);
}

- (CGRect)_contentInsetsInPixels:(NSEdgeInsets)contentInsets emptySizeFallback:(CGRect(^)(void))emptySizeFallback {
    CGSize size = self.size;
    CGFloat scale = _scale;
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    CGFloat width = size.width * scale;
    CGFloat height = size.height * scale;
    if (size.width <= 0.0 || size.height <= 0.0) {
        if (emptySizeFallback) {
            CGRect rect = emptySizeFallback();
            x = rect.origin.x;
            y = rect.origin.y;
            width = rect.size.width;
            height = rect.size.height;
        }
    } else {
        CGFloat maybeWidth = width - (contentInsets.left * scale + contentInsets.right * scale);
        CGFloat maybeHeight = height - (contentInsets.top * scale + contentInsets.bottom * scale);
        x = fmax(contentInsets.left * scale + 0.0, 0.0);
        y = fmax(contentInsets.top * scale + 0.0, 0.0);
        width = fmax(maybeWidth, 0.0);
        height = fmax(maybeHeight, 0.0);
    }
    return CGRectMake(x, y, width, height);
}

- (void)drawInRect:(NSRect)dstSpacePortionRect fromRect:(NSRect)srcSpacePortionRect operation:(NSCompositingOperation)op fraction:(CGFloat)requestedAlpha respectFlipped:(BOOL)respectContextIsFlipped hints:(NSDictionary<NSImageHintKey,id> *)hints {
    if (NSEdgeInsetsEqual(self.capInsets, NSEdgeInsetsZero)) {
        [super drawInRect:dstSpacePortionRect fromRect:srcSpacePortionRect operation:op fraction:requestedAlpha respectFlipped:respectContextIsFlipped hints:hints];
    } else {
        NSDrawNinePartImage(dstSpacePortionRect, _topLeftCorner, _topEdgeFill, _topRightCorner, _leftEdgeFill, _centerFill, _rightEdgeFill, _bottomLeftCorner, _bottomEdgeFill, _bottomRightCorner, op, requestedAlpha, NO);
    }
}

- (void)drawInRect:(NSRect)rect fromRect:(NSRect)fromRect operation:(NSCompositingOperation)op fraction:(CGFloat)delta {
    if (NSEdgeInsetsEqual(self.capInsets, NSEdgeInsetsZero)) {
        [super drawInRect:rect fromRect:fromRect operation:op fraction:delta];
    } else {
        NSDrawNinePartImage(rect, _topLeftCorner, _topEdgeFill, _topRightCorner, _leftEdgeFill, _centerFill, _rightEdgeFill, _bottomLeftCorner, _bottomEdgeFill, _bottomRightCorner, op, delta, NO);
    }
}

NSImage *_uxImageFromRect(NSImage *image, CGFloat x, CGFloat y, CGFloat width, CGFloat height) {
    CGRect rect = CGRectMake(x, y, width, height);
    if (image && !CGRectIsEmpty(rect)) {
        CGImageRef cgImage = [image CGImageForProposedRect:nil context:nil hints:nil];
        CGFloat cgImageWidth = CGImageGetWidth(cgImage);
        CGSize nsImageSize = image.size;
        CGAffineTransform transform = CGAffineTransformMakeScale(cgImageWidth / nsImageSize.width, cgImageWidth / nsImageSize.width);
        CGRect appliedTransformRect = CGRectApplyAffineTransform(rect, transform);
        CGImageRef newCGImage = CGImageCreateWithImageInRect(cgImage, appliedTransformRect);
        return [[NSImage alloc] initWithCGImage:newCGImage size:appliedTransformRect.size];;
    }
    return nil;
}

- (void)_setupNinePartFromImage:(NSImage *)image {
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    CGFloat left = fmax(self.capInsets.left, 1.0);
    CGFloat top = fmax(self.capInsets.top, 1.0);
    CGFloat right = fmax(self.capInsets.right, 1.0);
    CGFloat bottom = fmax(self.capInsets.bottom, 1.0);
    CGFloat v17 = width - left - right;
    CGFloat v22 = width - right;
    CGFloat v31 = height - bottom;
    _topLeftCorner = _uxImageFromRect(image, 0.0, 0.0, left, top);
    _topEdgeFill = _uxImageFromRect(image, left, 0.0, v17, top);
    _topRightCorner = _uxImageFromRect(image, v22, 0.0, right, top);
    _leftEdgeFill = _uxImageFromRect(image, 0.0, top, left, height - top - bottom);
    _centerFill = _uxImageFromRect(image, left, top, v17, height - top - bottom);
    _rightEdgeFill = _uxImageFromRect(image, v22, top, right, height - top - bottom);
    _bottomLeftCorner = _uxImageFromRect(image, 0.0, v31, left, bottom);
    _bottomEdgeFill = _uxImageFromRect(image, left, v31, v17, bottom);
    _bottomRightCorner = _uxImageFromRect(image, v22, v31, right, bottom);
}

@end
