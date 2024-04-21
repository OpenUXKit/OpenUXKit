//
//  _UXLayoutSpacer.m
//  OpenUXKit
//
//  Created by JH on 2024/4/21.
//

#import <Foundation/Foundation.h>
#import "_UXLayoutSpacer.h"

@interface _UXLayoutSpacer ()
{
    NSLayoutConstraint *_counterDimensionConstraint;    // 8 = 0x8
    NSLayoutConstraint *_dimensionConstraint;    // 16 = 0x10
    BOOL _horizontal;    // 24 = 0x18
    id _lengthUpdateBlock;    // 32 = 0x20
}

@end

@implementation _UXLayoutSpacer



@end
