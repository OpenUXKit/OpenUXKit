#import <OpenUXKit/_UXViewControllerTransitionContext.h>
#import <OpenUXKit/_UXViewControllerTransitionCoordinator.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXKitPrivateUtilites.h>
#import <OpenUXKit/UXViewControllerTransitioning.h>

@interface _UXViewControllerTransitionContext () {
    CGFloat _previousPercentComplete;
    NSArray *_disabledViews;

    struct {
        unsigned int interactorImplementsCompletionSpeed:1;
        unsigned int interactorImplementsCompletionCurve:1;
        unsigned int transitionWasCancelled:1;
        unsigned int transitionIsCompleting:1;
    } _transitionContextFlags;
}

@end


@implementation _UXViewControllerTransitionContext

- (instancetype)init {
    if (self = [super init]) {
        _previousPercentComplete = 0.0;
        _completionVelocity = 1.0;
        _completionCurve = 0;
        _presentationStyle = -1;
        _transitionContextFlags.transitionIsCompleting = YES;
    }

    return self;
}

- (void)setInteractor:(id<UXViewControllerInteractiveTransitioning>)interactor {
    if (_interactor != interactor) {
        _interactor = interactor;

        if (interactor) {
            _transitionContextFlags.interactorImplementsCompletionSpeed = [interactor respondsToSelector:@selector(completionSpeed)];
            _transitionContextFlags.interactorImplementsCompletionCurve = [interactor respondsToSelector:@selector(completionCurve)];
            self.initiallyInteractive = YES;
            self.currentlyInteractive = YES;
        }
    }
}

- (void)__runAlongsideAnimations {
    if (__auxContext) {
        BOOL hasAnimations = NO;
        BOOL currentLoopFlag = NO;
        do {
            currentLoopFlag = hasAnimations;
            NSMutableArray *alongsideAnimations = [__auxContext _alongsideAnimations];

            if (!alongsideAnimations) {
                break;
            }

            [__auxContext _applyBlocks:alongsideAnimations
                         releaseBlocks:^{
                self->__auxContext._alongsideAnimations = nil;
            }];
            hasAnimations = YES;
        } while (!hasAnimations);
        __auxContext._alongsideAnimations = nil;
    }
}

- (void)setTransitionIsInFlight:(BOOL)transitionIsInFlight {
    [self setState:transitionIsInFlight];
}

- (void)completeTransition:(BOOL)completeTransition {
    if (self.willCompleteHandler) {
        self.willCompleteHandler(self, completeTransition);
    }

    if (self.completionHandler) {
        self.completionHandler(self, completeTransition);
    }

    if ([_animator respondsToSelector:@selector(animationEnded:)]) {
        [_animator animationEnded:completeTransition];
    }

    [self _runAlongsideCompletions];
}

- (_UXViewControllerTransitionCoordinator *)_transitionCoordinator {
    if (__auxContext) {
        return __auxContext;
    } else {
        return [[_UXViewControllerTransitionCoordinator alloc] initWithMainContext:self];
    }
}

- (BOOL)transitionIsInFlight {
    return self.state == 1;
}

- (BOOL)transitionWasCancelled {
    return _transitionContextFlags.transitionWasCancelled;
}

- (void)_runAlongsideCompletions {
    if (__auxContext) {
        auto alongsideCompletions = __auxContext._alongsideCompletions;
        [__auxContext _applyBlocks:alongsideCompletions
                     releaseBlocks:^{
            self->__auxContext._alongsideCompletions = nil;
        }];
    }
}

- (void)_enableInteractionForDisabledViews {
}

- (void)_disableInteractionForViews:(id)views {
}

- (void)_interactivityDidChange:(BOOL)interactivityDidChange {
    self.currentlyInteractive = interactivityDidChange;

    if (__auxContext) {
        auto interactiveChangeHandlers = [__auxContext _interactiveChangeHandlers];

        if (interactiveChangeHandlers) {
            [__auxContext _applyBlocks:interactiveChangeHandlers
                         releaseBlocks:^{
                self->__auxContext._interactiveChangeHandlers = nil;
            }];
        }
    }
}

- (void)_setTransitionIsCompleting:(BOOL)transitionIsCompleting {
    _transitionContextFlags.transitionIsCompleting = transitionIsCompleting;
}

- (BOOL)_transitionIsCompleting {
    return _transitionContextFlags.transitionIsCompleting;
}

- (CGRect)finalFrameForViewController:(id)viewController {
    return CGRectZero;
}

- (CGRect)initialFrameForViewController:(id)viewController {
    return CGRectZero;
}

- (UXViewController *)viewControllerForKey:(NSString *)key {
    [NSException raise:NSInvalidArgumentException format:@"%@ is an abstract class!", self.class];
    return nil;
}

- (void)cancelInteractiveTransition {
    if (self.state == 1) {
        _transitionContextFlags.interactorImplementsCompletionSpeed = NO;
        _transitionContextFlags.interactorImplementsCompletionCurve = NO;

        if (_transitionContextFlags.interactorImplementsCompletionSpeed) {
            CGFloat completionSpeed = [self.interactor completionSpeed];

            if (!(completionSpeed < 0.0)) {
                _completionVelocity = -completionSpeed;
            }

            _completionVelocity = completionSpeed;
        }

        if (_transitionContextFlags.interactorImplementsCompletionCurve) {
            _completionCurve = [self.interactor completionCurve];
        }

        if (self.isCurrentlyInteractive) {
            if (self.interactiveUpdateHandler) {
                self.interactiveUpdateHandler(YES, NO, self, _previousPercentComplete);
            }
        }

        [self _interactivityDidChange:NO];
    } else {
        self.state = 2;
    }
}

- (void)finishInteractiveTransition {
    if (self.state == 1) {
        _transitionContextFlags.transitionWasCancelled = NO;
        _transitionContextFlags.transitionIsCompleting = YES;

        if (_transitionContextFlags.interactorImplementsCompletionSpeed) {
            CGFloat completionSpeed = self.interactor.completionSpeed;
            _completionVelocity = completionSpeed;

            if (completionSpeed < 0.0) {
                _completionVelocity = 1.0;
            }
        }

        if (_transitionContextFlags.interactorImplementsCompletionCurve) {
            _completionCurve = self.interactor.completionCurve;
        }

        if (self.isCurrentlyInteractive) {
            if (self.interactiveUpdateHandler) {
                self.interactiveUpdateHandler(YES, YES, self, _previousPercentComplete);
            }
        }

        [self _interactivityDidChange:NO];
    } else {
        self.state = 3;
    }
}

- (void)updateInteractiveTransition:(CGFloat)transition {
    if (self.state == 1) {
        if (self.isCurrentlyInteractive) {
            if (self.interactiveUpdateHandler) {
                if (_previousPercentComplete != transition) {
                    _transitionContextFlags.transitionIsCompleting = NO;
                    _previousPercentComplete = transition;
                    self.interactiveUpdateHandler(NO, NO, self, self.percentOffset + transition);
                }
            }
        }
    }
}

- (void)_updateInteractiveTransitionWithoutTrackingPercentComplete:(CGFloat)transition {
    if (self.initiallyInteractive) {
        if (self.interactiveUpdateHandler) {
            _transitionContextFlags.transitionIsCompleting = NO;
            self.interactiveUpdateHandler(NO, NO, self, transition);
        }
    }
}

- (BOOL)isInteractive {
    return self.isCurrentlyInteractive;
}

- (void)_setPreviousPercentComplete:(CGFloat)previousPercentComplete {
    _previousPercentComplete = previousPercentComplete;
}

- (CGFloat)_previousPercentComplete {
    return _previousPercentComplete;
}

@end
