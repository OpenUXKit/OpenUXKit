//
//  UXImageView.m
//  
//
//  Created by JH on 2024/4/21.
//

#import <Foundation/Foundation.h>
#import "UXImageView.h"

@interface UXImageView ()
{
    CGFloat _backingScaleFactor;    // 112 = 0x70
    CGSize _proposedSize;    // 120 = 0x78
    BOOL _allowsVibrancy;    // 136 = 0x88
    BOOL _highlighted;    // 137 = 0x89
    NSString *accessibilityLabel;    // 144 = 0x90
    NSImage *_image;    // 152 = 0x98
    NSImage *_highlightedImage;    // 160 = 0xa0
}
@end

@implementation UXImageView



@end
