//
//  UXBar.m
//  OpenUXKit
//
//  Created by JH on 2024/4/21.
//

#import <Foundation/Foundation.h>
#import "UXBar.h"

@interface UXBar ()
{
    _UXSinglePixelLine *_decorationLine;    // 112 = 0x70
    NSMutableSet *_previousBarItemContainers;    // 120 = 0x78
    NSInteger _containerTransitionAnimationCount;    // 128 = 0x80
    NSView *_placeholderTrailingView;    // 136 = 0x88
    BOOL _isInteractiveTransitioning;    // 144 = 0x90
    BOOL _trailingViewNeedsRemoval;    // 145 = 0x91
    NSColor *_barTintColor;    // 152 = 0x98
    CGFloat _interitemSpacing;    // 160 = 0xa0
    CGFloat _height;    // 168 = 0xa8
    CGFloat _baselineOffsetFromBottom;    // 176 = 0xb0
    CGFloat _percent;    // 184 = 0xb8
    UXView<_UXBarItemsContainer> *_nextItemContainer;    // 192 = 0xc0
    NSView *_globalTrailingView;    // 200 = 0xc8
    CGFloat _globalTrailingViewWidthMultiplier;    // 208 = 0xd0
    UXView<_UXBarItemsContainer> *_barItemsContainer;    // 216 = 0xd8
    NSEdgeInsets _decorationInsets;    // 224 = 0xe0
}

@end

@implementation UXBar



@end
