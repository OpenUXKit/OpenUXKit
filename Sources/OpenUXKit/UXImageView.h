#import <AppKit/AppKit.h>
#import "UXView.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)


@interface UXImageView : UXView <NSAccessibilityImage>

@property (nonatomic, getter = isHighlighted) BOOL highlighted;
@property (nonatomic, strong, nullable) NSImage *highlightedImage;
@property (nonatomic, strong, nullable) NSImage *image;
@property (nonatomic, readonly, nullable) NSImage *_currentImage;
@property (nonatomic) BOOL allowsVibrancy;
@property (nonatomic, copy, nullable) NSString *accessibilityLabel;

- (instancetype)initWithImage:(nullable NSImage *)image highlightedImage:(nullable NSImage *)highlightedImage;
- (instancetype)initWithImage:(nullable NSImage *)image;
- (void)sizeToFit;
- (void)_updateForCurrentImage;
- (void)_updateProposedSize;
- (void)_updateBackingScaleFactorForWindow:(NSWindow *)window;
- (void)_updateLayerContentsForWindow:(NSWindow *)window;
- (void)_updateLayerContents;
- (CGSize)_proposedSize;
- (void)_setContentStretchInPixels:(CGRect)pixels forContentSize:(CGSize)contentSize shouldTile:(BOOL)shouldTile;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
