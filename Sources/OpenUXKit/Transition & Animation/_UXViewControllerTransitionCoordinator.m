#import <OpenUXKit/_UXViewControllerTransitionCoordinator.h>
#import <OpenUXKit/_UXViewControllerTransitionContext.h>

@interface _UXViewControllerTransitionCoordinator ()
@end

@implementation _UXViewControllerTransitionCoordinator

- (instancetype)initWithMainContext:(_UXViewControllerTransitionContext *)mainContext {
    if (self = [super init]) {
        __mainContext = mainContext;
        if (!mainContext._auxContext) {
            mainContext._auxContext = self;
        }
    }
    return self;
}

- (BOOL)animateAlongsideTransition:(void (^)(id<UXViewControllerTransitionCoordinatorContext> _Nonnull))animation completion:(void (^)(id<UXViewControllerTransitionCoordinatorContext> _Nonnull))completion {
    return [self animateAlongsideTransitionInView:nil animation:animation completion:completion];
}

- (BOOL)animateAlongsideTransitionInView:(UXView *)view animation:(void (^)(id<UXViewControllerTransitionCoordinatorContext> _Nonnull))animation completion:(void (^)(id<UXViewControllerTransitionCoordinatorContext> _Nonnull))completion {
    BOOL transitionIsInFlight = self._mainContext.transitionIsInFlight;
    if (animation) {
        if (!transitionIsInFlight) {
            NSMutableArray *alongsideAnimations = [self _alongsideAnimations:YES];
            [alongsideAnimations addObject:animation];
            if (view) {
                if (![view isDescendantOf:self._mainContext.containerView]) {
                    if (!self._alongsideAnimationViews) {
                        self._alongsideAnimationViews = [NSMutableArray array];
                    }
                    [self._alongsideAnimationViews addObject:view];
                }
            }
        }
    }
    if (completion) {
        NSMutableArray *alongsideCompletions = [self _alongsideCompletions:YES];
        [alongsideCompletions addObject:completion];
    }
    return (animation == nil) | (transitionIsInFlight ^ 1);
}

#define InitialPropertyIfNeeded(property) \
BOOL isInitial = NO;\
if (property) {\
    isInitial = YES;\
} else {\
    isInitial = !needInitial;\
}\
if (!isInitial) {\
    property = [NSMutableArray array];\
}\
return property;

- (NSMutableArray *)_alongsideCompletions:(BOOL)needInitial {
    InitialPropertyIfNeeded(__alongsideCompletions);
}

- (NSMutableArray *)_alongsideAnimations:(BOOL)needInitial {
    InitialPropertyIfNeeded(__alongsideAnimations);
}

- (NSMutableArray *)_interactiveChangeHandlers:(BOOL)needInitial {
    InitialPropertyIfNeeded(__interactiveChangeHandlers);
}

- (void)_applyBlocks:(NSArray *)applyBlocks releaseBlocks:(void(^)(void))releaseBlocks {
    if (applyBlocks.count) {
        for (void(^applyBlock)(_UXViewControllerTransitionCoordinator *) in applyBlocks) {
            applyBlock(self);
        }
        releaseBlocks();
    }
}

- (BOOL)isCancelled {
    return __mainContext.transitionWasCancelled;
}


- (NSTimeInterval)transitionDuration {
    return __mainContext.duration;
}

- (BOOL)initiallyInteractive {
    return __mainContext.initiallyInteractive;
}

- (BOOL)isAnimated {
    return __mainContext.isAnimated;
}

- (void)notifyWhenInteractionEndsUsingBlock:(void (^)(id<UXViewControllerTransitionCoordinatorContext> _Nonnull))handler {
    if (handler) {
        NSMutableArray *handlers = [self _interactiveChangeHandlers:YES];
        [handlers addObject:handler];
    }
}

- (UXView *)containerView {
    return __mainContext.containerView;
}

- (__kindof UXViewController *)viewControllerForKey:(UXTransitionContextViewControllerKey)key {
    return [__mainContext viewControllerForKey:key];
}

- (NSInteger)completionCurve {
    return __mainContext.completionCurve;
}

- (CGFloat)completionVelocity {
    return __mainContext.completionVelocity;
}

- (CGFloat)percentComplete {
    return __mainContext._previousPercentComplete;
}

- (BOOL)isCompleting {
    return __mainContext._transitionIsCompleting;
}

- (BOOL)isInteractive {
    return __mainContext.isCurrentlyInteractive;
}

- (NSInteger)presentationStyle {
    return __mainContext.presentationStyle;
}



@end
