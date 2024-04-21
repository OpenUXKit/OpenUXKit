//
//  UXNavigationBar.m
//  OpenUXKit
//
//  Created by JH on 2024/4/21.
//

#import <Foundation/Foundation.h>
#import "UXNavigationBar.h"

@interface UXNavigationBar ()
{
    BOOL _needsRecalculateWindowKeyViewLoop;    // 108 = 0x6c
    BOOL _recalculatingKeyViewLoop;    // 109 = 0x6d
    BOOL _translucent;    // 110 = 0x6e
    BOOL _recalculatingWindowKeyViewLoop;    // 111 = 0x6f
    BOOL _alternateTitleEnabled;    // 112 = 0x70
    BOOL _detached;    // 113 = 0x71
    __weak id <UXNavigationBarDelegate> _delegate;    // 120 = 0x78
    __weak NSView *_titleCenteringTrackedView;    // 128 = 0x80
    NSArray *_items;    // 136 = 0x88
    NSImage *_backIndicatorImage;    // 144 = 0x90
    NSView *_globalTrailingView;    // 152 = 0x98
    double _globalTrailingViewWidthMultiplier;    // 160 = 0xa0
    NSMutableArray *_internalItems;    // 168 = 0xa8
    _UXNavigationItemContainerView *_topItemContainer;    // 176 = 0xb0
    NSInteger _currentOperation;    // 184 = 0xb8
    UXNavigationItem *_transitioningItem;    // 192 = 0xc0
    NSView *_alternateTitleView;    // 200 = 0xc8
    NSView *_alternateCondensedTitleView;    // 208 = 0xd0
    double _leftInteritemSpacing;    // 216 = 0xd8
    double _rightInteritemSpacing;    // 224 = 0xe0
    double _centerYOffset;    // 232 = 0xe8
    NSEdgeInsets _edgeInsets;    // 240 = 0xf0
}
@end

@implementation UXNavigationBar



@end
