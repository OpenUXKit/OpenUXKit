#import <OpenUXKit/UXView.h>

NS_ASSUME_NONNULL_BEGIN

@interface UXView () {
    NSColor *_backgroundColor;
    NSVisualEffectView *_contentBackgroundVisualEffectsView;
    BOOL _opaque;
    BOOL _accessibilityChildrenHidden;
}

@property (nonatomic, readonly, nullable) NSVisualEffectView *_visualEffectsView;
@property (nonatomic, weak, nullable) UXViewController *viewControllerProxy;
@property (nonatomic) BOOL needsContentBackgroundVisualEffect;

@end

NS_ASSUME_NONNULL_END
