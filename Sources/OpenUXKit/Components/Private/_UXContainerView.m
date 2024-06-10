#import <OpenUXKit/_UXContainerView.h>

@interface _UXContainerView () {
    NSVisualEffectView *_effectView;
}
@end

@implementation _UXContainerView

- (void)setContentView:(NSView *)contentView {
    if (_contentView != contentView) {
        [_contentView removeFromSuperview];
        _contentView = contentView;
        [self wrapContentView];
    }
}

- (void)setWantsMaterialBackground:(BOOL)wantsMaterialBackground {
    if (_wantsMaterialBackground != wantsMaterialBackground) {
        _wantsMaterialBackground = wantsMaterialBackground;
        [self wrapContentView];
    }
}

- (void)wrapContentView {
    if (self.wantsMaterialBackground) {
        if (!_effectView) {
            _effectView = [[NSVisualEffectView alloc] initWithFrame:self.bounds];
            _effectView.translatesAutoresizingMaskIntoConstraints = NO;
            _effectView.material = NSVisualEffectMaterialSidebar;
            _effectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
            [self addSubview:_effectView];
            [NSLayoutConstraint activateConstraints:@[
                 [self.leadingAnchor constraintEqualToAnchor:_effectView.leadingAnchor],
                 [self.trailingAnchor constraintEqualToAnchor:_effectView.trailingAnchor],
                 [self.topAnchor constraintEqualToAnchor:_effectView.topAnchor],
                 [self.bottomAnchor constraintEqualToAnchor:_effectView.bottomAnchor],
            ]];
        }
    } else {
        if (_effectView) {
            [_effectView removeFromSuperview];
            _effectView = nil;
        }
    }

    NSView *contentView = self.contentView;

    if (contentView) {
        NSView *contentSuperview = contentView.superview;
        NSView *targetView = nil;

        if (self.wantsMaterialBackground) {
            if (contentSuperview == _effectView) {
                return;
            } else {
                [contentView removeFromSuperview];
                targetView = _effectView;
            }
        } else {
            if (contentSuperview == self) {
                return;
            } else {
                [contentView removeFromSuperview];
                targetView = self;
            }
        }

        [targetView addSubview:contentView];
        contentSuperview = contentView.superview;
        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
             [contentSuperview.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor],
             [contentSuperview.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor],
             [contentSuperview.topAnchor constraintEqualToAnchor:contentView.topAnchor],
             [contentSuperview.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor],
        ]];
    }
}

@end
