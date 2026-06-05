#import <OpenUXKit/UXView.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXView () {
    NSColor *_backgroundColor;
    NSVisualEffectView *_contentBackgroundVisualEffectsView;
    BOOL _opaque;
    BOOL _accessibilityChildrenHidden;
    NSEdgeInsets _frozenSafeAreaInsets;
}

@property (nonatomic, readonly, nullable) NSVisualEffectView *_visualEffectsView;
@property (nonatomic, weak, nullable) UXViewController *viewControllerProxy;
@property (nonatomic) BOOL needsContentBackgroundVisualEffect;
@property (nonatomic) BOOL wantsSafeAreaInsetsFrozen;
@property (nonatomic) NSEdgeInsets frozenSafeAreaInsets;

- (id)_superDescription;
- (id)_autoresizingDescription;
- (id)_infoForWindow;
- (id)_infoWithParents;
- (id)_infoWithChildren;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
