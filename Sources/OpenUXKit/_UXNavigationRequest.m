//
//  _UXNavigationRequest.m
//  
//
//  Created by JH on 2024/2/26.
//

#import <Foundation/Foundation.h>
#import "_UXNavigationRequest.h"

@implementation _UXNavigationRequest

{
    NSMutableArray *_addedViewControllers;    // 8 = 0x8
    BOOL _animated;    // 16 = 0x10
    NSInteger _operation;    // 24 = 0x18
    NSArray<UXViewController *> *_viewControllers;    // 32 = 0x20
}


+ (_UXNavigationRequest *)pushRequestWithViewController:(UXViewController *)viewController animated:(BOOL)animated {
    return [self _requestWithOperation:0x1 viewControllers:[NSArray arrayWithObjects:viewController, nil] animated:animated];
}

+ (_UXNavigationRequest *)_requestWithOperation:(NSInteger)operation viewControllers:(NSArray<UXViewController *> *)viewControllers animated:(BOOL)animated {
    if (viewControllers.count != 0) {
        _UXNavigationRequest *request = [_UXNavigationRequest new];
        request->_animated = animated;
        request->_viewControllers = viewControllers;
        request->_operation = operation;
        return request;
    }
    return nil;
}

+ (_UXNavigationRequest *)popRequestWithViewController:(UXViewController *)viewController animated:(BOOL)animated {
    NSArray<UXViewController *> *viewControllers = [NSArray arrayWithObjects:viewController, nil];
    return [self _requestWithOperation:0x2 viewControllers:viewControllers animated:animated];
}


+ (_UXNavigationRequest *)setRequestWithViewControllers:(NSArray<UXViewController *> *)viewControllers animated:(BOOL)animated {
    if (![viewControllers isKindOfClass:[NSArray class]]) {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd object:self file:@"_UXNavigationRequest.m" lineNumber:__LINE__ description:@"Invalid parameter not satisfying: %@", viewControllers];
    }
    
    if (viewControllers.count == 0) {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd object:self file:@"_UXNavigationRequest.m" lineNumber:__LINE__ description:@"Invalid parameter not satisfying: %@", viewControllers];
    }
    return [self _requestWithOperation:0x0 viewControllers:viewControllers animated:animated];
}

- (void)setupContainmentIfNeededInParentViewController:(id)viewController {
    if (viewController && _addedViewControllers == nil) {
        _addedViewControllers = [NSMutableArray array];
        if (self.operation != 0x2) {
            NSFastEnumerationState *state;
        }
    }
}

- (UXViewController *)viewController {
    return _viewControllers.lastObject;
}

@end
