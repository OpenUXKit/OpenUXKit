#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionReusableView, UXCollectionViewLayoutAttributes;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewAnimation : NSObject

@property (nonatomic, readonly, nullable) UXCollectionReusableView *view;
@property (nonatomic, readonly) NSUInteger viewType;
@property (nonatomic, readonly, nullable) UXCollectionViewLayoutAttributes *finalLayoutAttributes;
@property (nonatomic, readonly) CGFloat startFraction;
@property (nonatomic, readonly) CGFloat endFraction;
@property (nonatomic, readonly) BOOL animateFromCurrentPosition;
@property (nonatomic, readonly) BOOL deleteAfterAnimation;
@property (nonatomic) BOOL rasterizeAfterAnimation;
@property (nonatomic) BOOL resetRasterizationAfterAnimation;

- (instancetype)initWithView:(UXCollectionReusableView *)view
                    viewType:(NSUInteger)viewType
       finalLayoutAttributes:(nullable UXCollectionViewLayoutAttributes *)finalLayoutAttributes
               startFraction:(CGFloat)startFraction
                 endFraction:(CGFloat)endFraction
   animateFromCurrentPosition:(BOOL)animateFromCurrentPosition
        deleteAfterAnimation:(BOOL)deleteAfterAnimation
            customAnimations:(nullable void (^)(void (^completion)(BOOL finished)))customAnimations;

- (void)addStartupHandler:(void (^)(void))startupHandler;
- (void)addCompletionHandler:(void (^)(void))completionHandler;
- (void)start;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
