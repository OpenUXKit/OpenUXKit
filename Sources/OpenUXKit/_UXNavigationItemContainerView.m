//
//  _UXNavigationItemContainerView.m
//  OpenUXKit
//
//  Created by JH on 2024/4/26.
//

#import <Foundation/Foundation.h>
#import "_UXNavigationItemContainerView.h"

@interface _UXNavigationItemContainerView () {
    UXImageView *_snaphotView;  // 112 = 0x70
    BOOL _hidesGlobalTrailingView;      // 120 = 0x78
    UXNavigationItem *_item;    // 128 = 0x80
    __weak UXNavigationBar *_navigationBar;    // 136 = 0x88
    NSUInteger _state;  // 144 = 0x90
    CGFloat _minimumWidthForExpandedTitle;      // 152 = 0x98
    CGFloat _minimumWidthForExpandedItems;      // 160 = 0xa0
    NSView *_leftView;  // 168 = 0xa8
    NSMutableArray *_leftItemViews;     // 176 = 0xb0
    NSView *_titleView; // 184 = 0xb8
    NSMutableArray *_rightItemViews;    // 192 = 0xc0
    NSView *_rightView; // 200 = 0xc8
    NSMutableArray *_itemsSortedByPriority;     // 208 = 0xd0
    NSMutableDictionary *_overflowItemsByMinimumWidth;  // 216 = 0xd8
    NSMutableArray *_addedConstraints;  // 224 = 0xe0
    NSLayoutConstraint *_titleCenteringConstraint;      // 232 = 0xe8
    __weak NSView *_titleCenteringConstrainedTitleView;        // 240 = 0xf0
    __weak NSView *_titleCenteringTrackedView; // 248 = 0xf8
    __weak NSView *_titleCenteringConstraintOwnerView; // 256 = 0x100
}

@end

@implementation _UXNavigationItemContainerView



@end
