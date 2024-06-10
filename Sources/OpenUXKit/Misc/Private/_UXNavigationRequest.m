#import <OpenUXKit/_UXNavigationRequest.h>
#import <OpenUXKit/UXViewController.h>

@interface _UXNavigationRequest () {
    NSMutableArray *_addedViewControllers;
}

@end


@implementation _UXNavigationRequest

+ (_UXNavigationRequest *)_requestWithOperation:(UXNavigationControllerOperation)operation viewControllers:(NSArray<UXViewController *> *)viewControllers animated:(BOOL)animated {
    if (viewControllers.count) {
        _UXNavigationRequest *request = [_UXNavigationRequest new];
        request->_operation = operation;
        request->_viewControllers = viewControllers;
        request->_animated = animated;
        return request;
    }

    return nil;
}

+ (_UXNavigationRequest *)pushRequestWithViewController:(UXViewController *)viewController animated:(BOOL)animated {
    return [self _requestWithOperation:UXNavigationControllerOperationPush viewControllers:@[viewController] animated:animated];
}

+ (_UXNavigationRequest *)popRequestWithViewController:(UXViewController *)viewController animated:(BOOL)animated {
    return [self _requestWithOperation:UXNavigationControllerOperationPop viewControllers:@[viewController] animated:animated];
}

+ (_UXNavigationRequest *)setRequestWithViewControllers:(NSArray<UXViewController *> *)viewControllers animated:(BOOL)animated {
    NSParameterAssert([viewControllers isKindOfClass:[NSArray class]]);
    NSParameterAssert(viewControllers.count != 0);

    if ([NSSet setWithArray:viewControllers].count != viewControllers.count) {
        NSAssert(false, @"All view controllers in a navigation controller must be distinct (%@)", viewControllers);
    }

    return [self _requestWithOperation:UXNavigationControllerOperationNone viewControllers:viewControllers animated:animated];
}

- (void)setupContainmentIfNeededInParentViewController:(UXViewController *)parentViewController {
    if (parentViewController) {
        if (!_addedViewControllers) {
            _addedViewControllers = [NSMutableArray array];

            if (self.operation != UXNavigationControllerOperationPop) {
                for (UXViewController *viewController in self.viewControllers) {
                    NSViewController *currentParentViewController = viewController.parentViewController;

                    if (!currentParentViewController) {
                        [parentViewController addChildViewController:viewController];
                        [_addedViewControllers addObject:viewController];
                    }
                }
            }
        }
    }
}

- (void)tearDownContainmentIfNeeded {
    if (_addedViewControllers) {
        for (UXViewController *addedViewController in _addedViewControllers) {
            [addedViewController removeFromParentViewController];
        }

        _addedViewControllers = nil;
    }
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    } else {
        if ([object isKindOfClass:self.class]) {
            return [self isEqualToNavigationRequest:object];
        } else {
            return NO;
        }
    }
}

- (BOOL)isEqualToNavigationRequest:(_UXNavigationRequest *)request {
    if (request && request.operation == _operation) {
        return [request.viewControllers isEqualToArray:_viewControllers];
    } else {
        return NO;
    }
}

- (UXViewController *)viewController {
    return _viewControllers.lastObject;
}

- (NSString *)description {
    NSString *operationString = @"none";

    if (_operation == UXNavigationControllerOperationPush) {
        operationString = @"push";
    }

    if (_operation == UXNavigationControllerOperationPop) {
        operationString = @"pop";
    }

    return [NSString stringWithFormat:@"<%@: %p; operation = %@, viewControllers = %@>", self.class, self, operationString, _viewControllers];
}

@end
