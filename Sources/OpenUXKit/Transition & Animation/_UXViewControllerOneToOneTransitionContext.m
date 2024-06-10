#import <OpenUXKit/_UXViewControllerOneToOneTransitionContext.h>
#import <OpenUXKit/UXViewController.h>

@interface _UXViewControllerOneToOneTransitionContext ()
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
