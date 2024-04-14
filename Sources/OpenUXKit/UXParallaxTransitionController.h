//
//     Generated by classdump-c 4.2.0 (64 bit) (iOS port by DreamDevLost, Updated by Kevin Bradley.)(Debug version compiled Feb 25 2024 00:55:05).
//
//  Copyright (C) 1997-2019 Steve Nygard. Updated in 2022 by Kevin Bradley.
//

@class UXView;

@interface UXParallaxTransitionController
{
    UXView *_dimmingView;	// 24 = 0x18
}

+ (void)_addShadowToView:(id)arg1 withAlpha:(double)arg2;

- (BOOL)navigationController:(id)arg1 shouldBeginInteractivePopFromViewController:(id)arg2 toViewController:(id)arg3;
- (id)navigationController:(id)arg1 animationControllerForOperation:(NSInteger)arg2 fromViewController:(id)arg3 toViewController:(id)arg4;
- (id)navigationController:(id)arg1 interactionControllerForAnimationController:(id)arg2;
- (void)_setupDimmingViewInContext:(id)arg1 withAlpha:(double)arg2;
- (void)updateInteractiveTransition:(double)arg1 inContext:(id)arg2;
- (void)startInteractiveTransition:(id)arg1;
- (void)animateTransition:(id)arg1;

@end

