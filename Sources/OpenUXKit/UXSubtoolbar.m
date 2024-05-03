//
//  UXSubtoolbar.m
//  
//
//  Created by JH on 2024/4/21.
//

#import <Foundation/Foundation.h>
#import "UXSubtoolbar.h"

@interface UXSubtoolbar ()
{
    NSLayoutConstraint *_heightConstraint;    // 128 = 0x80
}

@end

@implementation UXSubtoolbar

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _heightConstraint = [self.heightAnchor constraintEqualToConstant:self.height];
        _heightConstraint.active = YES;
    }
    return self;
}

- (void)setHeight:(CGFloat)height {
    [super setHeight:height];
    
    self.heightConstraint.constant = height;
}

+ (CGFloat)defaultHeight {
    return 40.0;
}

@end
