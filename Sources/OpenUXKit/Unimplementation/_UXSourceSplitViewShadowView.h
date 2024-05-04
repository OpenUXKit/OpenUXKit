

#import <AppKit/NSView.h>

@interface _UXSourceSplitViewShadowView : NSView
{
    CGFloat _shadowRevealAmount;	// 112 = 0x70
    NSUInteger _shadowEdge;	// 120 = 0x78
}

@property(nonatomic) NSUInteger shadowEdge; // @synthesize shadowEdge=_shadowEdge;
@property(nonatomic) CGFloat shadowRevealAmount; // @synthesize shadowRevealAmount=_shadowRevealAmount;
- (id)makeShadowImage;
- (CGSize)intrinsicContentSize;
- (void)setFrameOrigin:(CGPoint)arg1;
- (void)updateLayer;
- (BOOL)wantsUpdateLayer;
- (id)hitTest:(CGPoint)arg1;

@end

