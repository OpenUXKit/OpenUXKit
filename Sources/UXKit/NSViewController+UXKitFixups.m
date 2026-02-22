//
//  dummy.m
//  
//
//  Created by JH on 2024/6/9.
//

#import <AppKit/AppKit.h>


@implementation NSViewController (UXKitFixups)

- (id)transitionCoordinator {
    return nil;
}

- (id)_ancestorViewControllerOfClass:(Class)cls {
    return nil;
}

@end
