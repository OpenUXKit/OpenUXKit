/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import "UXViewControllerContextTransitioning.h"

@protocol UXViewControllerAnimatedTransitioning, UXViewControllerInteractiveTransitioning;
@class NSArray, _UXViewControllerTransitionCoordinator, UXView, NSString;

@interface _UXViewControllerTransitionContext : NSObject <UXViewControllerContextTransitioning> {

	double _previousPercentComplete;
	NSArray* _disabledViews;
	struct {
		unsigned interactorImplementsCompletionSpeed : 1;
		unsigned interactorImplementsCompletionCurve : 1;
		unsigned transitionWasCancelled : 1;
		unsigned transitionIsCompleting : 1;
	}  _transitionContextFlags;
	BOOL _initiallyInteractive;
	BOOL _currentlyInteractive;
	BOOL _animated;
	BOOL _presentation;
	double _completionVelocity;
	long long _completionCurve;
	_UXViewControllerTransitionCoordinator* __auxContext;
	double _duration;
	long long _state;
	/*^block*/id _interactiveUpdateHandler;
	long long _presentationStyle;
	double _percentOffset;
	id<UXViewControllerAnimatedTransitioning> _animator;
	id<UXViewControllerInteractiveTransitioning> _interactor;
	UXView* _containerView;
	/*^block*/id _willCompleteHandler;
	/*^block*/id _completionHandler;

}

@property (nonatomic) BOOL initiallyInteractive;                                                                        //@synthesize initiallyInteractive=_initiallyInteractive - In the implementation block
@property (getter=isCurrentlyInteractive, nonatomic) BOOL currentlyInteractive;                                         //@synthesize currentlyInteractive=_currentlyInteractive - In the implementation block
@property (getter=isAnimated, nonatomic) BOOL animated;                                                                 //@synthesize animated=_animated - In the implementation block
@property (nonatomic) double completionVelocity;                                                                        //@synthesize completionVelocity=_completionVelocity - In the implementation block
@property (nonatomic) long long completionCurve;                                                                        //@synthesize completionCurve=_completionCurve - In the implementation block
@property (setter=_setAuxContext:, nonatomic, strong) _UXViewControllerTransitionCoordinator *_auxContext;              //@synthesize _auxContext=__auxContext - In the implementation block
@property (nonatomic) double duration;                                                                                  //@synthesize duration=_duration - In the implementation block
@property (nonatomic) long long state;                                                                                  //@synthesize state=_state - In the implementation block
@property (nonatomic, copy) id interactiveUpdateHandler;                                                                //@synthesize interactiveUpdateHandler=_interactiveUpdateHandler - In the implementation block
@property (nonatomic) long long presentationStyle;                                                                      //@synthesize presentationStyle=_presentationStyle - In the implementation block
@property (getter=isPresentation, nonatomic) BOOL presentation;                                                         //@synthesize presentation=_presentation - In the implementation block
@property (nonatomic) double percentOffset;                                                                             //@synthesize percentOffset=_percentOffset - In the implementation block
@property (nonatomic, weak) id<UXViewControllerAnimatedTransitioning> animator;                                         //@synthesize animator=_animator - In the implementation block
@property (nonatomic, weak) id<UXViewControllerInteractiveTransitioning> interactor;                                    //@synthesize interactor=_interactor - In the implementation block
@property (nonatomic, weak) UXView *containerView;                                                                      //@synthesize containerView=_containerView - In the implementation block
@property (nonatomic, copy) id willCompleteHandler;                                                                     //@synthesize willCompleteHandler=_willCompleteHandler - In the implementation block
@property (nonatomic, copy) id completionHandler;                                                                       //@synthesize completionHandler=_completionHandler - In the implementation block
@property (nonatomic) BOOL transitionIsInFlight; 
@property (nonatomic, copy) id arbitraryTransitionCompletionHandler; 
@property (readonly) unsigned long long hash; 
@property (readonly) Class superclass; 
@property (copy, readonly) NSString *description; 
@property (copy, readonly) NSString *debugDescription; 
- (id)init;
- (long long)state;
- (void)setState:(long long)arg1;
- (double)duration;
- (void)setDuration:(double)arg1;
- (id<UXViewControllerAnimatedTransitioning>)animator;
- (id)completionHandler;
- (id)containerView;
- (long long)presentationStyle;
- (void)setAnimator:(id<UXViewControllerAnimatedTransitioning>)arg1;
- (void)setCompletionHandler:(id)arg1;
- (void)setContainerView:(id)arg1;
- (void)setPresentationStyle:(long long)arg1;
- (void)setPresentation:(BOOL)arg1;
- (void)setAnimated:(BOOL)arg1;
- (BOOL)isInteractive;
- (BOOL)isAnimated;
- (id)_transitionCoordinator;
- (void)_setAuxContext:(id)arg1;
- (long long)completionCurve;
- (void)__runAlongsideAnimations;
- (id)_auxContext;
- (void)_disableInteractionForViews:(id)arg1;
- (void)_enableInteractionForDisabledViews;
- (void)_interactivityDidChange:(BOOL)arg1;
- (double)_previousPercentComplete;
- (void)_runAlongsideCompletions;
- (void)_setPreviousPercentComplete:(double)arg1;
- (void)_setTransitionIsCompleting:(BOOL)arg1;
- (BOOL)_transitionIsCompleting;
- (void)_updateInteractiveTransitionWithoutTrackingPercentComplete:(double)arg1;
- (void)cancelInteractiveTransition;
- (void)completeTransition:(BOOL)arg1;
- (double)completionVelocity;
- (CGRect)finalFrameForViewController:(id)arg1;
- (void)finishInteractiveTransition;
- (CGRect)initialFrameForViewController:(id)arg1;
- (BOOL)initiallyInteractive;
- (id<UXViewControllerInteractiveTransitioning>)interactor;
- (BOOL)isCurrentlyInteractive;
- (BOOL)isPresentation;
- (void)setCompletionCurve:(long long)arg1;
- (void)setCompletionVelocity:(double)arg1;
- (void)setInteractor:(id<UXViewControllerInteractiveTransitioning>)arg1;
- (BOOL)transitionWasCancelled;
- (void)updateInteractiveTransition:(double)arg1;
- (id)viewControllerForKey:(id)arg1;
- (id)interactiveUpdateHandler;
- (double)percentOffset;
- (void)setCurrentlyInteractive:(BOOL)arg1;
- (void)setInitiallyInteractive:(BOOL)arg1;
- (void)setInteractiveUpdateHandler:(id)arg1;
- (void)setPercentOffset:(double)arg1;
- (void)setTransitionIsInFlight:(BOOL)arg1;
- (void)setWillCompleteHandler:(id)arg1;
- (BOOL)transitionIsInFlight;
- (id)willCompleteHandler;
@end

