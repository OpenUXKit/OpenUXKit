#import "_UXDetailViewController.h"
#import "UXSourceController.h"
#import "UXSourceController+Internal.h"
#import "UXViewController+Internal.h"
#import "UXViewControllerTransitionCoordinator.h"

@implementation _UXDetailViewController {
    CGFloat _previousViewWidth;
}

- (void)viewWillLayout {
    [super viewWillLayout];
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);

    if (_previousViewWidth != viewWidth) {
        _previousViewWidth = viewWidth;
        [self.sourceController _detailViewWidthDidChange];
    }
}

- (void)windowWillExitFullScreen {
    [super windowWillExitFullScreen];
    [self.sourceController windowWillExitFullScreen];
}

- (void)windowWillEnterFullScreen {
    [super windowWillEnterFullScreen];
    [self.sourceController windowWillEnterFullScreen];
}

- (void)contentRepresentingViewControllerDidChange {
    [self.sourceController contentRepresentingViewControllerDidChange];
    [super contentRepresentingViewControllerDidChange];
}

- (id<UXViewControllerTransitionCoordinator>)transitionCoordinator {
    return self.sourceController.transitionCoordinator;
}

@end
