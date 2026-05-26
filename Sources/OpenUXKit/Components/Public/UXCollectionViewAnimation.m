#import <OpenUXKit/UXCollectionViewAnimation.h>
#import <OpenUXKit/UXCollectionViewLayoutAttributes.h>
#import <OpenUXKit/UXKitPrivateUtilites.h>
#import <QuartzCore/QuartzCore.h>

// Private SPI implemented by UXCollectionReusableView (owned by the view layer).
@interface UXCollectionReusableView (UXCollectionViewAnimationSPI)
- (nullable UXCollectionViewLayoutAttributes *)_layoutAttributes;
- (void)_setLayoutAttributes:(nullable UXCollectionViewLayoutAttributes *)layoutAttributes;
- (void)_setBaseLayoutAttributes:(nullable UXCollectionViewLayoutAttributes *)layoutAttributes;
- (void)applyLayoutAttributes:(nullable UXCollectionViewLayoutAttributes *)layoutAttributes;
@end

@interface UXCollectionViewAnimation () {
    __strong id _view;
    UXCollectionViewLayoutAttributes *_finalLayoutAttributes;
    CGFloat _startFraction;
    CGFloat _endFraction;
    NSUInteger _viewType;
    NSMutableArray *_completionHandlers;
    NSMutableArray *_startupHandlers;
    void (^_animationBlock)(void);
    struct {
        unsigned int animateFromCurrentPosition : 1;
        unsigned int deleteAterAnimation : 1;
        unsigned int rasterizeAfterAnimation : 1;
        unsigned int resetRasterizationAfterAnimation : 1;
    } _collectionViewAnimationFlags;
}
@end

@implementation UXCollectionViewAnimation

@synthesize viewType = _viewType;
@synthesize finalLayoutAttributes = _finalLayoutAttributes;
@synthesize startFraction = _startFraction;
@synthesize endFraction = _endFraction;

- (instancetype)initWithView:(UXCollectionReusableView *)view
                    viewType:(NSUInteger)viewType
       finalLayoutAttributes:(UXCollectionViewLayoutAttributes *)finalLayoutAttributes
               startFraction:(CGFloat)startFraction
                 endFraction:(CGFloat)endFraction
   animateFromCurrentPosition:(BOOL)animateFromCurrentPosition
        deleteAfterAnimation:(BOOL)deleteAfterAnimation
            customAnimations:(void (^)(void))customAnimations {
    if (!view) {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                            object:self
                                                              file:@"UXCollectionView.m"
                                                        lineNumber:403
                                                       description:@"attempt to create view animation for nil view"];
    }
    self = [super init];
    if (self) {
        id animationTarget = view;
        if ([animationTarget isKindOfClass:[NSView class]] && ![animationTarget isKindOfClass:[UXCollectionReusableView class]]) {
            animationTarget = [animationTarget layer];
        }
        _view = animationTarget;
        _viewType = viewType;
        _finalLayoutAttributes = finalLayoutAttributes;
        _startFraction = startFraction;
        _endFraction = endFraction;
        _collectionViewAnimationFlags.animateFromCurrentPosition = animateFromCurrentPosition ? 1 : 0;
        _collectionViewAnimationFlags.deleteAterAnimation = deleteAfterAnimation ? 1 : 0;
        _completionHandlers = [[NSMutableArray alloc] init];
        _startupHandlers = [[NSMutableArray alloc] init];
        _animationBlock = [customAnimations copy];
    }
    return self;
}

- (UXCollectionReusableView *)view {
    return _view;
}

- (BOOL)animateFromCurrentPosition {
    return _collectionViewAnimationFlags.animateFromCurrentPosition;
}

- (BOOL)deleteAfterAnimation {
    return _collectionViewAnimationFlags.deleteAterAnimation;
}

- (BOOL)rasterizeAfterAnimation {
    return _collectionViewAnimationFlags.rasterizeAfterAnimation;
}

- (void)setRasterizeAfterAnimation:(BOOL)rasterizeAfterAnimation {
    _collectionViewAnimationFlags.rasterizeAfterAnimation = rasterizeAfterAnimation ? 1 : 0;
}

- (BOOL)resetRasterizationAfterAnimation {
    return _collectionViewAnimationFlags.resetRasterizationAfterAnimation;
}

- (void)setResetRasterizationAfterAnimation:(BOOL)resetRasterizationAfterAnimation {
    _collectionViewAnimationFlags.resetRasterizationAfterAnimation = resetRasterizationAfterAnimation ? 1 : 0;
}

- (void)addStartupHandler:(void (^)(void))startupHandler {
    if (startupHandler) {
        [_startupHandlers addObject:[startupHandler copy]];
    }
}

- (void)addCompletionHandler:(void (^)(void))completionHandler {
    if (completionHandler) {
        [_completionHandlers addObject:[completionHandler copy]];
    }
}

- (void)start {
    CGFloat duration = [CATransaction disableActions] ? 0.0 : 0.25;
    CGFloat startFraction = _startFraction;
    CGFloat endFraction = _endFraction;
    if (startFraction > 0.0 || endFraction < 1.0) {
        if (endFraction < startFraction) {
            [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                                object:self
                                                                  file:@"UXCollectionView.m"
                                                            lineNumber:479
                                                           description:@"Cell animation stop fraction must be greater than start fraction"];
            startFraction = _startFraction;
            endFraction = _endFraction;
        }
        duration = duration * (endFraction - startFraction);
    }

    for (void (^startupHandler)(void) in _startupHandlers) {
        startupHandler();
    }
    [_startupHandlers removeAllObjects];

    if (![_view isKindOfClass:[UXCollectionReusableView class]]) {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                            object:self
                                                              file:@"UXCollectionView.m"
                                                        lineNumber:489
                                                       description:@"Collection View no longer support raw layer or view animations."];
    }

    UXCollectionReusableView *view = _view;
    if (_animationBlock) {
        [view _setBaseLayoutAttributes:_finalLayoutAttributes];
        _animationBlock();
        [view applyLayoutAttributes:_finalLayoutAttributes];

        for (void (^completionHandler)(void) in _completionHandlers) {
            completionHandler();
        }
        [_completionHandlers removeAllObjects];
    } else {
        BOOL animateFromCurrentPosition = _collectionViewAnimationFlags.animateFromCurrentPosition;
        UXCollectionViewLayoutAttributes *finalLayoutAttributes = _finalLayoutAttributes;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.allowsImplicitAnimation = YES;
            context.duration = duration;
            CAMediaTimingFunction *timingFunction = context.timingFunction;
            if (!timingFunction) {
                timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
            }
            context.timingFunction = timingFunction;

            CGRect targetFrame = finalLayoutAttributes.frame;

            CABasicAnimation *frameOriginAnimation = [CABasicAnimation animationWithKeyPath:@"frameOrigin"];
            if (!animateFromCurrentPosition) {
                CGRect currentFrame = [view _layoutAttributes].frame;
                frameOriginAnimation.fromValue = [NSValue valueWithPoint:currentFrame.origin];
            }
            frameOriginAnimation.toValue = [NSValue valueWithPoint:targetFrame.origin];
            frameOriginAnimation.timingFunction = timingFunction;
            frameOriginAnimation.removedOnCompletion = YES;

            CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
            if (!animateFromCurrentPosition) {
                CGRect currentFrame = [view _layoutAttributes].frame;
                boundsAnimation.fromValue = [NSValue valueWithRect:CGRectMake(0.0, 0.0, currentFrame.size.width, currentFrame.size.height)];
            }
            boundsAnimation.toValue = [NSValue valueWithRect:CGRectMake(0.0, 0.0, targetFrame.size.width, targetFrame.size.height)];
            boundsAnimation.timingFunction = timingFunction;
            boundsAnimation.removedOnCompletion = YES;

            CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"alphaValue"];
            if (!animateFromCurrentPosition) {
                alphaAnimation.fromValue = [NSNumber numberWithFloat:(float)[view _layoutAttributes].alpha];
            }
            alphaAnimation.toValue = [NSNumber numberWithFloat:(float)finalLayoutAttributes.alpha];
            alphaAnimation.timingFunction = timingFunction;
            alphaAnimation.removedOnCompletion = YES;

            view.animations = [NSDictionary dictionaryWithObjects:@[frameOriginAnimation, boundsAnimation, alphaAnimation]
                                                          forKeys:@[@"frameOrigin", @"bounds", @"alphaValue"]];
            [view _setLayoutAttributes:finalLayoutAttributes];
        } completionHandler:^{
            for (void (^completionHandler)(void) in self->_completionHandlers) {
                completionHandler();
            }
            [self->_completionHandlers removeAllObjects];
        }];
    }
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" view: %@", _view];
}

@end
