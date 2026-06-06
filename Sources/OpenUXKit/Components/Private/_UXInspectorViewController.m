#import "_UXInspectorViewController.h"
#import "UXView.h"

@implementation _UXInspectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [NSColor colorWithWhite:0.0 alpha:0.0].CGColor;
}

- (void)setContentViewController:(UXViewController *)contentViewController {
    if (contentViewController != _contentViewController) {
        if (_contentViewController) {
            [_contentViewController willMoveToParentViewController:nil];
            [_contentViewController.view removeFromSuperview];
            [_contentViewController removeFromParentViewController];
        }

        _contentViewController = contentViewController;

        if (contentViewController) {
            [self addChildViewController:contentViewController];
            [self.view addSubview:contentViewController.view];
            [contentViewController didMoveToParentViewController:self];
            [self.view.leadingAnchor constraintEqualToAnchor:contentViewController.view.leadingAnchor].active = YES;
            [self.view.trailingAnchor constraintEqualToAnchor:contentViewController.view.trailingAnchor].active = YES;
            [self.view.topAnchor constraintEqualToAnchor:contentViewController.view.topAnchor].active = YES;
            [self.view.bottomAnchor constraintEqualToAnchor:contentViewController.view.bottomAnchor].active = YES;
        }
    }
}

@end
