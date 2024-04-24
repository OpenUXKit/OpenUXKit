//
//  UXBarItem.m
//  
//
//  Created by JH on 2024/4/21.
//

#import <Foundation/Foundation.h>
#import "UXBarItem.h"

@interface UXBarItem ()
{
    BOOL _enabled;    // 8 = 0x8
    NSString *_title;    // 16 = 0x10
    NSString *_accessibilityLabel;    // 24 = 0x18
    NSImage *_image;    // 32 = 0x20
    NSInteger _tag;    // 40 = 0x28
}


@end

@implementation UXBarItem

- (instancetype)init {
    if (self = [super init]) {
        self.enabled = YES;
    }
    return self;
}



@end
