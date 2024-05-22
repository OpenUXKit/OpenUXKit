#import <AppKit/AppKit.h>
#import <OpenUXKit/UXViewControllerTransitioning.h>
#import <OpenUXKit/UXBase.h>
#import <OpenUXKit/UXKitDefines.h>

@class UXView, _UXViewControllerTransitionCoordinator, _UXViewControllerTransitionContext, _UXViewControllerOneToOneTransitionContext;
@protocol UXViewControllerAnimatedTransitioning, UXViewControllerInteractiveTransitioning;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef void (^_UXViewControllerTransitionContextCompletionHandler)(_UXViewControllerTransitionContext *context, BOOL isCompletion);
typedef void (^_UXViewControllerTransitionContextInteractiveUpdateHandler)(BOOL, BOOL, _UXViewControllerTransitionContext *, CGFloat);

@interface _UXViewControllerTransitionContext : NSObject <UXViewControllerContextTransitioning>

@property (nonatomic, copy) _UXViewControllerTransitionContextCompletionHandler completionHandler;
@property (nonatomic, copy) _UXViewControllerTransitionContextCompletionHandler willCompleteHandler;
@property (nonatomic, weak, nullable) UXView *containerView;
@property (nonatomic, weak, nullable) id <UXViewControllerInteractiveTransitioning> interactor;
@property (nonatomic, weak, nullable) id <UXViewControllerAnimatedTransitioning> animator;
@property (nonatomic) CGFloat percentOffset;
@property (nonatomic, getter = isPresentation) BOOL presentation;
@property (nonatomic) NSInteger presentationStyle;
@property (nonatomic, copy) _UXViewControllerTransitionContextInteractiveUpdateHandler interactiveUpdateHandler;
@property (nonatomic) NSInteger state;
@property (nonatomic) CGFloat duration;
@property (nonatomic, strong, setter = _setAuxContext:) _UXViewControllerTransitionCoordinator *_auxContext;
@property (nonatomic) NSInteger completionCurve;
@property (nonatomic) CGFloat completionVelocity;
@property (nonatomic, getter = isAnimated) BOOL animated;
@property (nonatomic, getter = isCurrentlyInteractive) BOOL currentlyInteractive;
@property (nonatomic) BOOL initiallyInteractive;
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
- (nullable UXViewController *)viewControllerForKey:(NSString *)key;
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

NS_HEADER_AUDIT_END(nullability, sendability)
