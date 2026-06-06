#import "UXProxyViewController.h"
#import "UXView.h"

@interface UXProxyViewController () {
    UXView *_proxyView;
}
@end

@implementation UXProxyViewController

- (instancetype)initWithView:(UXView *)view {
    self = [super init];
    if (self) {
        _proxyView = view;
    }
    return self;
}

- (UXView *)view {
    return _proxyView;
}

- (BOOL)isViewLoaded {
    return _proxyView != nil;
}

- (void)didMoveToParentViewController:(UXViewController *)parent {
}

@end
