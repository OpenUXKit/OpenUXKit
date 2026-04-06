#import <OpenUXKit/_UXInspectorViewController.h>
#import <OpenUXKit/UXView.h>

@implementation _UXInspectorViewController

- (void)setContentViewController:(UXViewController *)contentViewController {
    if (_contentViewController == contentViewController) {
        return;
    }

    if (_contentViewController) {
        [_contentViewController willMoveToParentViewController:nil];
        [_contentViewController.view removeFromSuperview];
        [_contentViewController removeFromParentViewController];
    }

    _contentViewController = contentViewController;

    if (contentViewController) {
        [self addChildViewController:contentViewController];
        NSView *containerView = self.view;
        NSView *contentView = contentViewController.view;
        [containerView addSubview:contentView];
        [contentViewController didMoveToParentViewController:self];

        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [containerView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor],
            [containerView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor],
            [containerView.topAnchor constraintEqualToAnchor:contentView.topAnchor],
            [containerView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor],
        ]];
    }
}

@end
