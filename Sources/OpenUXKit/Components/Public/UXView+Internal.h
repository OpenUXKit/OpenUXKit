#import <OpenUXKit/UXView.h>

NS_ASSUME_NONNULL_BEGIN

@interface UXView () {
    BOOL _blurEnabled;    // 108 = 0x6c
    NSColor *_backgroundColor;    // 112 = 0x70
    NSColor *_borderColor;    // 120 = 0x78
    NSVisualEffectView *_contentBackgroundVisualEffectsView;    // 128 = 0x80
    BOOL _opaque;    // 136 = 0x88
    BOOL _exclusiveTouch;    // 137 = 0x89
    BOOL _userInteractionEnabled;    // 138 = 0x8a
    BOOL _needsContentBackgroundVisualEffect;    // 139 = 0x8b
    BOOL _accessibilityChildrenHidden;    // 140 = 0x8c
    __weak UXViewController *_viewControllerProxy;    // 144 = 0x90
    NSVisualEffectView *__visualEffectsView;    // 152 = 0x98
}

@property (nonatomic, readonly, nullable) NSVisualEffectView *_visualEffectsView;
@property (nonatomic, weak, nullable) UXViewController *viewControllerProxy;
@property (nonatomic) BOOL needsContentBackgroundVisualEffect;

@end

NS_ASSUME_NONNULL_END
