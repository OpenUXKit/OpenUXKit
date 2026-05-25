#import <OpenUXKit/UXView.h>

NS_ASSUME_NONNULL_BEGIN

@interface UXView () {
    BOOL _blurEnabled;
    NSVisualEffectMaterial _blurMaterial;
    NSColor *_backgroundColor;
    NSEdgeInsets _frozenSafeAreaInsets;
    NSVisualEffectView *_contentBackgroundVisualEffectsView;
    BOOL _opaque;
}

@property (nonatomic, readonly, nullable) NSVisualEffectView *_visualEffectsView;
@property (nonatomic, weak, nullable) UXViewController *viewControllerProxy;
@property (nonatomic) BOOL needsContentBackgroundVisualEffect;
@property (nonatomic) BOOL accessibilityChildrenHidden;

+ (nullable id)defaultSpringAnimationForKey:(NSString *)key mass:(CGFloat)mass stiffness:(CGFloat)stiffness damping:(CGFloat)damping velocity:(CGFloat)velocity;
+ (void)_animateUsingDefaultTimingWithOptions:(UXViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^__nullable)(BOOL finished))completion;
+ (NSInteger)_contentModeForLayerContentsGravity:(id)layerContentsGravity;

- (void)_disableBlur;
- (void)_enableBlur;
- (nullable id)_infoForWindow;
- (nullable id)_infoWithChildren;
- (nullable id)_infoWithParents;
- (nullable NSVisualEffectView *)_makeContentBackgroundVisualEffectsView;
- (void)_updateContentBackgroundVisualEffectsView;
- (nullable id)_autoresizingDescription;
- (nullable id)_superDescription;

@end

NS_ASSUME_NONNULL_END
