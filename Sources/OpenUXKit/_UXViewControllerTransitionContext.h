#import <AppKit/AppKit.h>
#import "UXViewControllerContextTransitioning-Protocol.h"

@class NSArray, NSString, UXView, _UXViewControllerTransitionCoordinator, _UXViewControllerTransitionContext;
@protocol UXViewControllerAnimatedTransitioning, UXViewControllerInteractiveTransitioning;

typedef void (^_UXViewControllerTransitionContextCompletionHandler)(_UXViewControllerTransitionContext *context, BOOL isCompletion);
typedef void (^_UXViewControllerTransitionContextInteractiveUpdateHandler)(BOOL, BOOL, _UXViewControllerTransitionContext *, CGFloat);
@interface _UXViewControllerTransitionContext : NSObject <UXViewControllerContextTransitioning>

@property (nonatomic, copy) _UXViewControllerTransitionContextCompletionHandler completionHandler; // @synthesize completionHandler=_completionHandler;
@property (nonatomic, copy) _UXViewControllerTransitionContextCompletionHandler willCompleteHandler; // @synthesize willCompleteHandler=_willCompleteHandler;
@property (nonatomic) __weak UXView *containerView; // @synthesize containerView=_containerView;
@property (nonatomic) __weak id <UXViewControllerInteractiveTransitioning> interactor; // @synthesize interactor=_interactor;
@property (nonatomic) __weak id <UXViewControllerAnimatedTransitioning> animator; // @synthesize animator=_animator;
@property (nonatomic) CGFloat percentOffset; // @synthesize percentOffset=_percentOffset;
@property (nonatomic, getter = isPresentation) BOOL presentation; // @synthesize presentation=_presentation;
@property (nonatomic) NSInteger presentationStyle; // @synthesize presentationStyle=_presentationStyle;
@property (nonatomic, copy) _UXViewControllerTransitionContextInteractiveUpdateHandler interactiveUpdateHandler; // @synthesize interactiveUpdateHandler=_interactiveUpdateHandler;
@property (nonatomic) NSInteger state; // @synthesize state=_state;
@property (nonatomic) CGFloat duration; // @synthesize duration=_duration;
@property (nonatomic, strong, setter = _setAuxContext:) _UXViewControllerTransitionCoordinator *_auxContext; // @synthesize _auxContext=__auxContext;
@property (nonatomic) NSInteger completionCurve; // @synthesize completionCurve=_completionCurve;
@property (nonatomic) CGFloat completionVelocity; // @synthesize completionVelocity=_completionVelocity;
@property (nonatomic, getter = isAnimated) BOOL animated; // @synthesize animated=_animated;
@property (nonatomic, getter = isCurrentlyInteractive) BOOL currentlyInteractive; // @synthesize currentlyInteractive=_currentlyInteractive;
@property (nonatomic) BOOL initiallyInteractive; // @synthesize initiallyInteractive=_initiallyInteractive;
@property (nonatomic) BOOL transitionIsInFlight;

- (void)_enableInteractionForDisabledViews;
- (void)_disableInteractionForViews:(id)views;
- (void)__runAlongsideAnimations;
- (void)_interactivityDidChange:(BOOL)interactivityDidChange;
- (void)_runAlongsideCompletions;
- (void)_setTransitionIsCompleting:(BOOL)transitionIsCompleting;
- (BOOL)_transitionIsCompleting;
- (BOOL)transitionWasCancelled;
- (CGRect)finalFrameForViewController:(id)viewController;
- (CGRect)initialFrameForViewController:(id)viewController;
- (id)viewControllerForKey:(id)key;
- (void)completeTransition:(BOOL)completeTransition;
- (void)cancelInteractiveTransition;
- (void)finishInteractiveTransition;
- (void)updateInteractiveTransition:(CGFloat)transition;
- (void)_updateInteractiveTransitionWithoutTrackingPercentComplete:(CGFloat)transition;
- (void)_setPreviousPercentComplete:(CGFloat)previousPercentComplete;
- (CGFloat)_previousPercentComplete;
- (_UXViewControllerTransitionCoordinator *)_transitionCoordinator;
- (BOOL)isInteractive;

@end
