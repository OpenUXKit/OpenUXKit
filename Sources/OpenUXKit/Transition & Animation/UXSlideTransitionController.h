

#import <OpenUXKit/UXTransitionController.h>

@interface UXSlideTransitionController: UXTransitionController

- (id)navigationController:(id)arg1 animationControllerForOperation:(NSInteger)arg2 fromViewController:(id)arg3 toViewController:(id)arg4;
- (id)navigationController:(id)arg1 interactionControllerForAnimationController:(id)arg2;
- (void)updateInteractiveTransition:(CGFloat)arg1 inContext:(id)arg2;
- (void)startInteractiveTransition:(id)arg1;
- (void)animateTransition:(id)arg1;

@end

