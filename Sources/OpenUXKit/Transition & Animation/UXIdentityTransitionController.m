//
//  UXIdentityTransitionController.m
//  
//
//  Created by JH on 2024/4/21.
//

#import <Foundation/Foundation.h>
#import <OpenUXKit/UXIdentityTransitionController.h>
#import <OpenUXKit/UXViewControllerTransitioning.h>
#import <OpenUXKit/_UXViewControllerTransitionContext.h>
#import <OpenUXKit/UXViewController.h>
#import <OpenUXKit/UXView.h>

@interface UXIdentityTransitionController ()

@end

@implementation UXIdentityTransitionController
- (NSTimeInterval)transitionDuration:(id<UXViewControllerContextTransitioning>)transition {
    UXViewController *fromViewController = [transition viewControllerForKey:UXTransitionContextFromViewControllerKey];
    UXViewController *toViewController = [transition viewControllerForKey:UXTransitionContextToViewControllerKey];
    if (fromViewController.view == toViewController.view) {
        return 0.33;
    } else {
        return 0.0;
    }
}

- (void)animateTransition:(id<UXViewControllerContextTransitioning>)transition {
    
    UXViewController *fromViewController = [transition viewControllerForKey:UXTransitionContextFromViewControllerKey];
    UXViewController *toViewController = [transition viewControllerForKey:UXTransitionContextToViewControllerKey];
    if (fromViewController.view == toViewController.view) {
        NSTimeInterval duration = [self transitionDuration:transition];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [transition completeTransition:YES];
        });
    } else {
        CGRect finalFrame = [transition finalFrameForViewController:toViewController];
        toViewController.view.frame = finalFrame;
        toViewController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        if (self.operation == 1) {
            [transition.containerView addSubview:toViewController.view];
        } else {
            [transition.containerView addSubview:toViewController.view positioned:NSWindowBelow relativeTo:fromViewController.view];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [transition completeTransition:YES];
        });
    }
}

@end
