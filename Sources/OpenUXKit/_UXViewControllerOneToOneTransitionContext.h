#import "_UXViewControllerTransitionContext.h"

@class UXView, UXViewController;

@interface _UXViewControllerOneToOneTransitionContext : _UXViewControllerTransitionContext


@property (nonatomic) CGRect toStartFrame; // @synthesize toStartFrame=_toStartFrame;
@property (nonatomic) CGRect toEndFrame; // @synthesize toEndFrame=_toEndFrame;
@property (nonatomic) CGRect fromEndFrame; // @synthesize fromEndFrame=_fromEndFrame;
@property (nonatomic) CGRect fromStartFrame; // @synthesize fromStartFrame=_fromStartFrame;
@property (nonatomic, strong) UXViewController *toViewController; // @synthesize toViewController=_toViewController;
@property (nonatomic, strong) UXViewController *fromViewController; // @synthesize fromViewController=_fromViewController;
- (void)setArbitraryTransitionCompletionHandler:(id)arg1;
- (id)arbitraryTransitionCompletionHandler;
@property (nonatomic, readonly) UXView *fromView;
@property (nonatomic, readonly) UXView *toView;
- (CGRect)finalFrameForViewController:(id)arg1;
- (CGRect)initialFrameForViewController:(id)arg1;
- (id)viewControllerForKey:(id)arg1;

@end
