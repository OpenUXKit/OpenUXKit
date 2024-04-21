//
//  _UXViewControllerTransitionContext.m
//  OpenUXKit
//
//  Created by JH on 2024/4/21.
//

#import <Foundation/Foundation.h>
#import "_UXViewControllerTransitionContext.h"

@interface _UXViewControllerTransitionContext ()
{
    CGFloat _previousPercentComplete;    // 8 = 0x8
    NSArray *_disabledViews;    // 16 = 0x10
    struct {
        unsigned int interactorImplementsCompletionSpeed:1;
        unsigned int interactorImplementsCompletionCurve:1;
        unsigned int transitionWasCancelled:1;
        unsigned int transitionIsCompleting:1;
    } _transitionContextFlags;    // 24 = 0x18
    BOOL _initiallyInteractive;    // 28 = 0x1c
    BOOL _currentlyInteractive;    // 29 = 0x1d
    BOOL _animated;    // 30 = 0x1e
    BOOL _presentation;    // 31 = 0x1f
    CGFloat _completionVelocity;    // 32 = 0x20
    NSInteger _completionCurve;    // 40 = 0x28
    _UXViewControllerTransitionCoordinator *__auxContext;    // 48 = 0x30
    CGFloat _duration;    // 56 = 0x38
    NSInteger _state;    // 64 = 0x40
    id _interactiveUpdateHandler;    // 72 = 0x48
    NSInteger _presentationStyle;    // 80 = 0x50
    CGFloat _percentOffset;    // 88 = 0x58
    __weak id <UXViewControllerAnimatedTransitioning> _animator;    // 96 = 0x60
    __weak id <UXViewControllerInteractiveTransitioning> _interactor;    // 104 = 0x68
    __weak UXView *_containerView;    // 112 = 0x70
    id _willCompleteHandler;    // 120 = 0x78
    id _completionHandler;    // 128 = 0x80
}

@end


@implementation _UXViewControllerTransitionContext



@end
