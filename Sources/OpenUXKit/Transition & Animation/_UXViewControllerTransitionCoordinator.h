#import <AppKit/AppKit.h>
#import <OpenUXKit/UXViewControllerTransitionCoordinator.h>

@class _UXViewControllerTransitionContext;

@interface _UXViewControllerTransitionCoordinator : NSObject <UXViewControllerTransitionCoordinator>
@property (nonatomic, strong, setter = _setInteractiveChangeHandlers:) NSMutableArray *_interactiveChangeHandlers;
@property (nonatomic, strong, setter = _setAlongsideCompletions:) NSMutableArray *_alongsideCompletions;
@property (nonatomic, strong, setter = _setAlongsideAnimationViews:) NSMutableArray *_alongsideAnimationViews;
@property (nonatomic, strong, setter = _setAlongsideAnimations:) NSMutableArray *_alongsideAnimations;
@property (nonatomic, unsafe_unretained, setter = _setMainContext:) _UXViewControllerTransitionContext *_mainContext;
@property (nonatomic, readonly, getter = isCompleting) BOOL completing;
- (instancetype)initWithMainContext:(_UXViewControllerTransitionContext *)mainContext;
- (void)_applyBlocks:(NSArray *)applyBlocks releaseBlocks:(void(^)(void))releaseBlocks;
- (NSMutableArray *)_alongsideCompletions:(BOOL)needInitial;
- (NSMutableArray *)_alongsideAnimations:(BOOL)needInitial;
- (NSMutableArray *)_interactiveChangeHandlers:(BOOL)needInitial;
@end
