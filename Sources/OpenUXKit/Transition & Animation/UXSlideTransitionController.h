#import <OpenUXKit/UXTransitionController.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXSlideTransitionController: UXTransitionController

- (id)navigationController:(id)arg1 animationControllerForOperation:(NSInteger)arg2 fromViewController:(id)arg3 toViewController:(id)arg4;
- (id)navigationController:(id)arg1 interactionControllerForAnimationController:(id)arg2;
- (void)updateInteractiveTransition:(CGFloat)arg1 inContext:(id)arg2;
- (void)startInteractiveTransition:(id)arg1;
- (void)animateTransition:(id)arg1;

@end

NS_HEADER_AUDIT_END(nullability, sendability)

