#import <OpenUXKit/UXImageView+Internal.h>
#import <OpenUXKit/_UXResizableImage.h>

@interface CALayer (PrivateSPI)
@property (nonatomic, copy) NSString *contentsScaling;
@end

@implementation UXImageView

@synthesize accessibilityLabel = accessibilityLabel;
@synthesize allowsVibrancy = _allowsVibrancy;

- (instancetype)initWithImage:(NSImage *)image {
    return [self initWithImage:image highlightedImage:nil];
}

- (instancetype)initWithImage:(NSImage *)image highlightedImage:(NSImage *)highlightedImage {
    NSImage *finalImage = nil;
    if (image) {
        finalImage = image;
    } else {
        finalImage = highlightedImage;
    }
    CGSize imageSize = finalImage.size;
    if (self = [self initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)]) {
        self.image = image;
        self.highlightedImage = highlightedImage;
    }
    return self;
    
}


- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawNever;
        _backingScaleFactor = 0.0;
        _proposedSize = CGSizeZero;
    }
    return self;
}

- (void)viewDidChangeEffectiveAppearance {
    [super viewDidChangeEffectiveAppearance];
    
    NSWindow *window = self.window;
    if (window) {
        [self _updateLayerContentsForWindow:window];
    } else {
        [self _updateLayerContentsForWindow:NSApp.mainWindow];
    }
}

- (void)_updateLayerContentsForWindow:(NSWindow *)window {
    NSDictionary<NSDeviceDescriptionKey, id> *deviceDescription = window.screen.deviceDescription;
    [self.effectiveAppearance performAsCurrentDrawingAppearance:^{
        CGRect rect;
        CGImageRef image = [self._currentImage CGImageForProposedRect:&rect context:nil hints:deviceDescription];
        self.layer.contents = (__bridge id _Nullable)(image);
    }];
}

- (NSImage *)_currentImage {
    if (!self.isHighlighted) {
        if (!self.image) {
            return self.highlightedImage;
        }
        return self.image;
    }
    if (self.highlightedImage) {
        return self.highlightedImage;
    }
    return self.image;
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];
    
    if (newWindow) {
        [self _updateBackingScaleFactorForWindow:newWindow];
    }
}

- (void)_updateBackingScaleFactorForWindow:(NSWindow *)window {
    if (_backingScaleFactor != window.backingScaleFactor) {
        _backingScaleFactor = window.backingScaleFactor;
        [self _updateLayerContentsForWindow:window];
    }
}

- (void)viewDidChangeBackingProperties {
    [super viewDidChangeBackingProperties];
    
    [self _updateBackingScaleFactorForWindow:self.window];
}

- (void)setImage:(NSImage *)image {
    _image = image;
    if (!self.isHighlighted) {
        [self _updateForCurrentImage];
    }
}

- (void)_updateForCurrentImage {
    [self _updateProposedSize];
    [self _updateLayerContents];
    if ([self._currentImage isKindOfClass:[_UXResizableImage class]]) {
        _UXResizableImage *currentImage = (_UXResizableImage *)self._currentImage;
        CGRect contentStretchInPixels = [currentImage _contentStretchInPixels];
        CGSize sizeInPixels = [currentImage _sizeInPixels];
        BOOL shouldTile = [currentImage _isTiledWhenStretchedToSize:self.bounds.size];
        [self _setContentStretchInPixels:contentStretchInPixels forContentSize:sizeInPixels shouldTile:shouldTile];
        
    } else {
        self.layer.contentsCenter = CGRectMake(0.0, 0.0, 1.0, 1.0);
        self.layer.contentsScaling = @"stretch";
    }
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay:YES];
}

- (void)_updateProposedSize {
    CGSize proposedSize = [self _proposedSize];
    if (_proposedSize.width != proposedSize.width || _proposedSize.height != proposedSize.height) {
        _proposedSize = proposedSize;
        [self _updateLayerContents];
    }
}

- (CGSize)_proposedSize {
    CGSize viewSize = self.frame.size;
    CGSize imageSize = self._currentImage.size;
    CGFloat scaleFactor = viewSize.width / fmax(imageSize.width, 1.0) * (viewSize.height / fmax(imageSize.height, 1.0));
    CGFloat zoomFactor = 2.0;
    if (scaleFactor <= 1.5) {
        zoomFactor = 1.0;
        if (scaleFactor < 0.333) {
            zoomFactor = 0.5;
        }
    }
    CGAffineTransform transform = CGAffineTransformMakeScale(zoomFactor, zoomFactor);
    CGFloat width = imageSize.height * transform.c + transform.a * imageSize.width;
    CGFloat height = imageSize.height * transform.d + transform.b * imageSize.width;
    return CGSizeMake(width, height);
}

- (void)_updateLayerContents {
    if (self.window) {
        [self _updateLayerContentsForWindow:self.window];
    } else {
        [self _updateLayerContentsForWindow:NSApp.mainWindow];
    }
}

- (void)setHighlightedImage:(NSImage *)highlightedImage {
    _highlightedImage = highlightedImage;
    if (self.isHighlighted) {
        [self _updateForCurrentImage];
    }
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [self _updateProposedSize];
}


- (void)sizeToFit {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.intrinsicContentSize.width, self.intrinsicContentSize.height);
}

- (void)setHighlighted:(BOOL)highlighted {
    if (_highlighted != highlighted) {
        _highlighted = highlighted;
        [self _updateForCurrentImage];
    }
}

- (void)_setContentStretchInPixels:(CGRect)pixels forContentSize:(CGSize)contentSize shouldTile:(BOOL)shouldTile {
    CGFloat normalizedVerticalOrigin = pixels.origin.y;
    CGFloat normalizedHorizontalOrigin = pixels.origin.x;
    CGFloat normalizedVerticalScale = 1.0;
    CGFloat normalizedHorizontalScale = 1.0;
    BOOL isStretchToFullWidth = pixels.origin.x == 0.0 && pixels.size.width == contentSize.width;
    if (!isStretchToFullWidth) {
        CGFloat adjustedWidth = fmax(pixels.size.width + -1.0, 0.0);
        CGFloat x = 0;
        if (shouldTile) {
            x = pixels.origin.x;
        } else {
            x = pixels.origin.x + 0.5;
        }
        CGFloat effectiveWidth = 0;
        if (shouldTile) {
            effectiveWidth = pixels.size.width;
        } else {
            effectiveWidth = adjustedWidth;
        }
        normalizedHorizontalOrigin = x / contentSize.width;
        if (effectiveWidth <= 1.0 && !shouldTile) {
            normalizedHorizontalOrigin = normalizedHorizontalOrigin + -0.01 / contentSize.height;
            effectiveWidth = 0.02;
        }
        normalizedHorizontalScale = effectiveWidth / contentSize.width;
    }
    if (normalizedVerticalOrigin != 0.0 || pixels.size.height != contentSize.height) {
        CGFloat adjustedHeight = fmax(pixels.size.height + -1.0, 0.0);
        CGFloat adjustedVerticalOrigin = 0;
        if (shouldTile) {
            adjustedVerticalOrigin = normalizedVerticalOrigin;
        } else {
            adjustedVerticalOrigin = normalizedVerticalOrigin + 0.5;
        }
        CGFloat effectiveHeight = 0;
        if (shouldTile) {
            effectiveHeight = pixels.size.height;
        } else {
            effectiveHeight = adjustedHeight;
        }
        normalizedVerticalOrigin = adjustedVerticalOrigin / contentSize.height;
        if (effectiveHeight <= 1.0 && !shouldTile) {
            normalizedVerticalOrigin = normalizedVerticalOrigin + -0.01 / contentSize.height;
            effectiveHeight = 0.02;
        }
        normalizedVerticalScale = effectiveHeight / contentSize.height;
    }
    self.layer.contentsCenter = CGRectMake(normalizedHorizontalOrigin, normalizedVerticalOrigin, normalizedHorizontalScale, normalizedVerticalScale);
    NSString *contentScaling = @"repeat";
    if (!shouldTile) {
        contentScaling = @"stretch";
    }
    self.layer.contentsScaling = contentScaling;
}

- (NSSize)intrinsicContentSize {
    return self.image.size;
}


@end
