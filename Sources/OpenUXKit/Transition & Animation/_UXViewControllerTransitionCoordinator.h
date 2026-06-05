#import <AppKit/AppKit.h>
#import <OpenUXKit/UXViewControllerTransitionCoordinator.h>

@class _UXViewControllerTransitionContext;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface _UXViewControllerTransitionCoordinator : NSObject <UXViewControllerTransitionCoordinator>

@property (nonatomic, strong, nullable, setter = _setInteractiveChangeHandlers:) NSMutableArray *_interactiveChangeHandlers;
@property (nonatomic, strong, nullable, setter = _setAlongsideCompletions:) NSMutableArray *_alongsideCompletions;
@property (nonatomic, strong, nullable, setter = _setAlongsideAnimationViews:) NSMutableArray *_alongsideAnimationViews;
@property (nonatomic, strong, nullable, setter = _setAlongsideAnimations:) NSMutableArray *_alongsideAnimations;
@property (nonatomic, unsafe_unretained, nullable, setter = _setMainContext:) _UXViewControllerTransitionContext *_mainContext;
@property (nonatomic, readonly, getter = isCompleting) BOOL completing;

- (instancetype)initWithMainContext:(_UXViewControllerTransitionContext *)mainContext;
- (void)_applyBlocks:(NSArray *)applyBlocks releaseBlocks:(void(^)(void))releaseBlocks;
- (nullable NSMutableArray *)_alongsideCompletions:(BOOL)needInitial;
- (nullable NSMutableArray *)_alongsideAnimations:(BOOL)needInitial;
- (nullable NSMutableArray *)_interactiveChangeHandlers:(BOOL)needInitial;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
