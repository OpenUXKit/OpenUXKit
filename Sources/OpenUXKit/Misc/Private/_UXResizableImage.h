#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface _UXResizableImage : NSImage

@property (nonatomic) BOOL alwaysStretches;

- (instancetype)initWithImage:(NSImage *)image capInsets:(NSEdgeInsets)capInsets;
- (CGRect)_contentRectInPixels;
- (BOOL)_isTiledWhenStretchedToSize:(CGSize)size;
- (CGRect)_contentStretchInPixels;
- (CGSize)_sizeInPixels;
- (CGRect)_contentInsetsInPixels:(NSEdgeInsets)contentInsets emptySizeFallback:(CGRect (^)(void))emptySizeFallback;
- (void)_setupNinePartFromImage:(NSImage *)image;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
