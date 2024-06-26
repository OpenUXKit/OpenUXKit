

#import <objc/NSObject.h>

@class NSMutableArray, UXCollectionReusableView, UXCollectionViewLayoutAttributes;

@interface UXCollectionViewAnimation : NSObject
{
    UXCollectionReusableView *_view;	// 8 = 0x8
    UXCollectionViewLayoutAttributes *_finalLayoutAttributes;	// 16 = 0x10
    CGFloat _startFraction;	// 24 = 0x18
    CGFloat _endFraction;	// 32 = 0x20
    NSUInteger _viewType;	// 40 = 0x28
    NSMutableArray *_completionHandlers;	// 48 = 0x30
    NSMutableArray *_startupHandlers;	// 56 = 0x38
    id _animationBlock;	// 64 = 0x40
    struct {
        unsigned int animateFromCurrentPosition:1;
        unsigned int deleteAterAnimation:1;
        unsigned int rasterizeAfterAnimation:1;
        unsigned int resetRasterizationAfterAnimation:1;
    } _collectionViewAnimationFlags;	// 72 = 0x48
}

@property(readonly, nonatomic) CGFloat endFraction; // @synthesize endFraction=_endFraction;
@property(readonly, nonatomic) CGFloat startFraction; // @synthesize startFraction=_startFraction;
@property(readonly, nonatomic) UXCollectionViewLayoutAttributes *finalLayoutAttributes; // @synthesize finalLayoutAttributes=_finalLayoutAttributes;
@property(readonly, nonatomic) NSUInteger viewType; // @synthesize viewType=_viewType;
@property(readonly, nonatomic) UXCollectionReusableView *view; // @synthesize view=_view;
- (void)addStartupHandler:(id)arg1;
- (void)addCompletionHandler:(id)arg1;
- (void)start;
@property(nonatomic) BOOL resetRasterizationAfterAnimation;
@property(nonatomic) BOOL rasterizeAfterAnimation;
@property(readonly, nonatomic) BOOL deleteAfterAnimation;
@property(readonly, nonatomic) BOOL animateFromCurrentPosition;
- (id)description;
- (void)dealloc;
- (id)initWithView:(id)arg1 viewType:(NSUInteger)arg2 finalLayoutAttributes:(id)arg3 startFraction:(CGFloat)arg4 endFraction:(CGFloat)arg5 animateFromCurrentPosition:(BOOL)arg6 deleteAfterAnimation:(BOOL)arg7 customAnimations:(id)arg8;

@end

