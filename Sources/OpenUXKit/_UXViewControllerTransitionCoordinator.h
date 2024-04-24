#import "AppKit/AppKit.h"

#import "UXViewControllerTransitionCoordinator.h"

@class NSMutableArray, NSString, _UXViewControllerTransitionContext;

@interface _UXViewControllerTransitionCoordinator : NSObject <UXViewControllerTransitionCoordinator> {
    _UXViewControllerTransitionContext *__mainContext;  // 8 = 0x8
    NSMutableArray *__alongsideAnimations;      // 16 = 0x10
    NSMutableArray *__alongsideAnimationViews;  // 24 = 0x18
    NSMutableArray *__alongsideCompletions;     // 32 = 0x20
    NSMutableArray *__interactiveChangeHandlers;        // 40 = 0x28
}

@property (nonatomic, strong, setter = _setInteractiveChangeHandlers:) NSMutableArray *_interactiveChangeHandlers; // @synthesize _interactiveChangeHandlers=__interactiveChangeHandlers;
@property (nonatomic, strong, setter = _setAlongsideCompletions:) NSMutableArray *_alongsideCompletions; // @synthesize _alongsideCompletions=__alongsideCompletions;
@property (nonatomic, strong, setter = _setAlongsideAnimationViews:) NSMutableArray *_alongsideAnimationViews; // @synthesize _alongsideAnimationViews=__alongsideAnimationViews;
@property (nonatomic, strong, setter = _setAlongsideAnimations:) NSMutableArray *_alongsideAnimations; // @synthesize _alongsideAnimations=__alongsideAnimations;
@property (nonatomic, setter = _setMainContext:) _UXViewControllerTransitionContext *_mainContext; // @synthesize _mainContext=__mainContext;
- (void)notifyWhenInteractionEndsUsingBlock:(id)block;
- (BOOL)animateAlongsideTransition:(id)transition completion:(id)completion;
- (BOOL)animateAlongsideTransitionInView:(id)arg1 animation:(id)arg2 completion:(id)arg3;
- (void)_applyBlocks:(id)arg1 releaseBlocks:(id)arg2;
- (id)_alongsideCompletions:(BOOL)arg1;
- (id)_alongsideAnimations:(BOOL)arg1;
- (id)_interactiveChangeHandlers:(BOOL)arg1;
- (id)containerView;
- (id)viewControllerForKey:(id)arg1;
- (CGFloat)transitionDuration;
- (NSInteger)completionCurve;
- (CGFloat)completionVelocity;
- (CGFloat)percentComplete;
- (BOOL)isCompleting;
- (BOOL)isCancelled;
- (BOOL)isInteractive;
- (BOOL)initiallyInteractive;
- (NSInteger)presentationStyle;
- (BOOL)isAnimated;
- (instancetype)initWithMainContext:(id)mainContext;

@end
