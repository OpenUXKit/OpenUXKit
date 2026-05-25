#import <OpenUXKit/UXImageView.h>

NS_ASSUME_NONNULL_BEGIN

@interface UXImageView ()
{
    CGFloat _backingScaleFactor;    // 112 = 0x70
    CGSize _proposedSize;    // 120 = 0x78
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
