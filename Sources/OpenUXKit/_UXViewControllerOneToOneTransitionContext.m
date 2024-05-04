#import "_UXViewControllerOneToOneTransitionContext.h"
#import "UXViewController.h"

@interface _UXViewControllerOneToOneTransitionContext () {
    id arbitraryTransitionCompletionHandler;    // 136 = 0x88
    UXViewController *_fromViewController;    // 144 = 0x90
    UXViewController *_toViewController;    // 152 = 0x98
    CGRect _fromStartFrame;    // 160 = 0xa0
    CGRect _fromEndFrame;    // 192 = 0xc0
    CGRect _toEndFrame;    // 224 = 0xe0
    CGRect _toStartFrame;    // 256 = 0x100
}

@end

@implementation _UXViewControllerOneToOneTransitionContext

@synthesize arbitraryTransitionCompletionHandler = arbitraryTransitionCompletionHandler;

- (UXViewController *)viewControllerForKey:(NSString *)key {
    if ([key isEqualToString:UXTransitionContextToViewControllerKey]) {
        return self.toViewController;
    } else if ([key isEqualToString:UXTransitionContextFromViewControllerKey]) {
        return self.fromViewController;
    }

    return nil;
}

- (CGRect)initialFrameForViewController:(UXViewController *)viewController {
    if (_toViewController == viewController) {
        return self.toStartFrame;
    } else if (_fromViewController == viewController) {
        return self.fromStartFrame;
    }

    return CGRectZero;
}

- (CGRect)finalFrameForViewController:(UXViewController *)viewController {
    if (_toViewController == viewController) {
        return self.toEndFrame;
    } else if (_fromViewController == viewController) {
        return self.fromEndFrame;
    }

    return CGRectZero;
}

- (UXView *)fromView {
    return _fromViewController.uxView;
}

- (UXView *)toView {
    return _toViewController.uxView;
}

@end
