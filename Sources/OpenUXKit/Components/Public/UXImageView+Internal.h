#import <OpenUXKit/UXImageView.h>

NS_ASSUME_NONNULL_BEGIN

@interface UXImageView ()
{
    CGFloat _backingScaleFactor;    // 112 = 0x70
    CGSize _proposedSize;    // 120 = 0x78
    BOOL _allowsVibrancy;    // 136 = 0x88
    BOOL _highlighted;    // 137 = 0x89
    NSString *accessibilityLabel;    // 144 = 0x90
    NSImage *_image;    // 152 = 0x98
    NSImage *_highlightedImage;    // 160 = 0xa0
}
@property (nonatomic, readonly, nullable) NSImage *_currentImage;

- (void)_updateForCurrentImage;
- (void)_updateProposedSize;
- (void)_updateBackingScaleFactorForWindow:(NSWindow *)window;
- (void)_updateLayerContentsForWindow:(NSWindow *)window;
- (void)_updateLayerContents;
- (CGSize)_proposedSize;
- (void)_setContentStretchInPixels:(CGRect)pixels forContentSize:(CGSize)contentSize shouldTile:(BOOL)shouldTile;
@end

NS_ASSUME_NONNULL_END
