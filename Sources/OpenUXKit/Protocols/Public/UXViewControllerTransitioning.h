#import <AppKit/AppKit.h>
#import <OpenUXKit/UXBase.h>
#import <OpenUXKit/UXView.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXViewController.h>
#import <OpenUXKit/UXViewControllerTransitionCoordinator.h>

@class UXView, UXViewController;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN UXTransitionContextViewControllerKey const UXTransitionContextFromViewControllerKey NS_SWIFT_NAME(UXTransitionContextViewControllerKey.from);
UXKIT_EXTERN UXTransitionContextViewControllerKey const UXTransitionContextToViewControllerKey NS_SWIFT_NAME(UXTransitionContextViewControllerKey.to);

NS_SWIFT_UI_ACTOR
@protocol UXViewControllerContextTransitioning <NSObject>

// The view in which the animated transition should take place.
@property (nonatomic, readonly) UXView *containerView;

// Most of the time this is YES. For custom transitions that use the new UXModalPresentationCustom
// presentation type we will invoke the animateTransition: even though the transition should not be
// animated. This allows the custom transition to add or remove subviews to the container view.
@property (nonatomic, readonly, getter = isAnimated) BOOL animated;

// The next two values can change if the animating transition is interruptible.
@property (nonatomic, readonly, getter = isInteractive) BOOL interactive; // This indicates whether the transition is currently interactive.

@property (nonatomic, readonly) BOOL transitionWasCancelled;

@property (nonatomic, readonly) UXModalPresentationStyle presentationStyle;

// An interaction controller that conforms to the
// UXViewControllerInteractiveTransitioning protocol (which is vended by a
// container view controller's delegate or, in the case of a presentation, the
// transitioningDelegate) should call these methods as the interactive
// transition is scrubbed and then either cancelled or completed. Note that if
// the animator is interruptible, then calling finishInteractiveTransition: and
// cancelInteractiveTransition: are indications that if the transition is not
// interrupted again it will finish naturally or be cancelled.

- (void)updateInteractiveTransition:(CGFloat)percentComplete;
- (void)finishInteractiveTransition;
- (void)cancelInteractiveTransition;


// This must be called whenever a transition completes (or is cancelled.)
// Typically this is called by the object conforming to the
// UXViewControllerAnimatedTransitioning protocol that was vended by the transitioning
// delegate.  For purely interactive transitions it should be called by the
// interaction controller. This method effectively updates internal view
// controller state at the end of the transition.
- (void)completeTransition:(BOOL)didComplete;


// Currently only two keys are defined by the
// system - UXTransitionContextToViewControllerKey, and
// UXTransitionContextFromViewControllerKey.
// Animators should not directly manipulate a view controller's views and should
// use viewForKey: to get views instead.
- (nullable __kindof UXViewController *)viewControllerForKey:(UXTransitionContextViewControllerKey)key;

// The frame's are set to CGRectZero when they are not known or
// otherwise undefined.  For example the finalFrame of the
// fromViewController will be CGRectZero if and only if the fromView will be
// removed from the window at the end of the transition. On the other
// hand, if the finalFrame is not CGRectZero then it must be respected
// at the end of the transition.
- (CGRect)initialFrameForViewController:(UXViewController *)viewController;
- (CGRect)finalFrameForViewController:(UXViewController *)viewController;

@optional

@property (nonatomic, copy, nullable) UXCompletionHandler arbitraryTransitionCompletionHandler;

@end

@protocol UXViewControllerAnimatedTransitioning <NSObject>
// This is used for percent driven interactive transitions, as well as for
// container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(nullable id<UXViewControllerContextTransitioning>)transitionContext NS_SWIFT_NAME(transitionDuration(using:));
// This method can only be a no-op if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id<UXViewControllerContextTransitioning>)transitionContext NS_SWIFT_NAME(animateTransition(using:));

@optional
// This is a convenience and if implemented will be invoked by the system when the transition context's completeTransition: method is invoked.
- (void)animationEnded:(BOOL)transitionCompleted;
@end

@protocol UXViewControllerInteractiveTransitioning <NSObject>
- (void)startInteractiveTransition:(id <UXViewControllerContextTransitioning>)transitionContext;

@optional
@property (nonatomic, readonly) CGFloat completionSpeed;
@property (nonatomic, readonly) UXViewAnimationCurve completionCurve;
@end



NS_HEADER_AUDIT_END(nullability, sendability)
