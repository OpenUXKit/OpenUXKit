/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXViewControllerTransitionCoordinator.h"

@class _UXViewControllerTransitionContext, NSMutableArray, NSString;

@interface _UXViewControllerTransitionCoordinator : NSObject <UXViewControllerTransitionCoordinator> {

	_UXViewControllerTransitionContext* __mainContext;
	NSMutableArray* __alongsideAnimations;
	NSMutableArray* __alongsideAnimationViews;
	NSMutableArray* __alongsideCompletions;
	NSMutableArray* __interactiveChangeHandlers;

}

@property (setter=_setMainContext:, nonatomic) _UXViewControllerTransitionContext *_mainContext;                              //@synthesize _mainContext=__mainContext - In the implementation block
@property (setter=_setAlongsideAnimations:, nonatomic, strong) NSMutableArray *_alongsideAnimations;                          //@synthesize _alongsideAnimations=__alongsideAnimations - In the implementation block
@property (setter=_setAlongsideAnimationViews:, nonatomic, strong) NSMutableArray *_alongsideAnimationViews;                  //@synthesize _alongsideAnimationViews=__alongsideAnimationViews - In the implementation block
@property (setter=_setAlongsideCompletions:, nonatomic, strong) NSMutableArray *_alongsideCompletions;                        //@synthesize _alongsideCompletions=__alongsideCompletions - In the implementation block
@property (setter=_setInteractiveChangeHandlers:, nonatomic, strong) NSMutableArray *_interactiveChangeHandlers;              //@synthesize _interactiveChangeHandlers=__interactiveChangeHandlers - In the implementation block
@property (readonly) unsigned long long hash; 
@property (readonly) Class superclass; 
@property (copy, readonly) NSString *description; 
@property (copy, readonly) NSString *debugDescription; 
- (BOOL)isCancelled;
- (id)containerView;
- (long long)presentationStyle;
- (double)percentComplete;
- (BOOL)isInteractive;
- (double)transitionDuration;
- (id)_mainContext;
- (BOOL)isAnimated;
- (long long)completionCurve;
- (id)_alongsideAnimationViews;
- (id)_alongsideAnimations;
- (id)_alongsideAnimations:(BOOL)arg1;
- (id)_alongsideCompletions;
- (id)_alongsideCompletions:(BOOL)arg1;
- (void)_applyBlocks:(id)arg1 releaseBlocks:(/*^block*/id)arg2;
- (id)_interactiveChangeHandlers;
- (id)_interactiveChangeHandlers:(BOOL)arg1;
- (void)_setAlongsideAnimationViews:(id)arg1;
- (void)_setAlongsideAnimations:(id)arg1;
- (void)_setAlongsideCompletions:(id)arg1;
- (void)_setInteractiveChangeHandlers:(id)arg1;
- (void)_setMainContext:(id)arg1;
- (BOOL)animateAlongsideTransition:(/*^block*/id)arg1 completion:(/*^block*/id)arg2;
- (BOOL)animateAlongsideTransitionInView:(id)arg1 animation:(/*^block*/id)arg2 completion:(/*^block*/id)arg3;
- (double)completionVelocity;
- (id)initWithMainContext:(id)arg1;
- (BOOL)initiallyInteractive;
- (BOOL)isCompleting;
- (void)notifyWhenInteractionEndsUsingBlock:(/*^block*/id)arg1;
- (id)viewControllerForKey:(id)arg1;
@end
