//
//  UXBarButtonItem.m
//  
//
//  Created by JH on 2024/4/21.
//

#import <Foundation/Foundation.h>
#import "UXBarButtonItem.h"

@interface UXBarButtonItem ()
{
    NSView *__view;    // 8 = 0x8
    BOOL _ignoresMultiClick;    // 16 = 0x10
    BOOL _condensed;    // 17 = 0x11
    float _visibilityPriority;    // 20 = 0x14
    NSColor *_tintColor;    // 24 = 0x18
    NSInteger _tintAdjustmentMode;    // 32 = 0x20
    SEL _action;    // 40 = 0x28
    __weak id _target;    // 48 = 0x30
    NSString *_toolTip;    // 56 = 0x38
    NSString *_keyEquivalent;    // 64 = 0x40
    NSUInteger _keyEquivalentModifierMask;    // 72 = 0x48
    NSInteger _buttonState;    // 80 = 0x50
    NSInteger _style;    // 88 = 0x58
    CGFloat _width;    // 96 = 0x60
    NSView *_customView;    // 104 = 0x68
    NSLayoutAnchor *_baselineAnchor;    // 112 = 0x70
    UXViewController *_contentViewController;    // 120 = 0x78
    NSInteger _systemItem;    // 128 = 0x80
    __weak UXBarButtonItem *__widthConstrainingItem;    // 136 = 0x88
}

@end

@implementation UXBarButtonItem



@end
