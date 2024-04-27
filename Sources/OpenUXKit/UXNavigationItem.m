//
//  UXNavigationItem.m
//  
//
//  Created by JH on 2024/4/21.
//

#import <Foundation/Foundation.h>
#import "UXNavigationItem.h"

@interface UXNavigationItem ()
{
    NSArray *_leftBarButtonItems;    // 8 = 0x8
    NSArray *_rightBarButtonItems;    // 16 = 0x10
    NSTextField *_internalTitleView;    // 24 = 0x18
    BOOL _hidesBackButton;    // 32 = 0x20
    BOOL _hidesAlternateTitleView;    // 33 = 0x21
    BOOL _hidesGlobalTrailingView;    // 34 = 0x22
    BOOL _leftItemsSupplementBackButton;    // 35 = 0x23
    NSString *_title;    // 40 = 0x28
    UXBarButtonItem *_backBarButtonItem;    // 48 = 0x30
    NSView *_titleView;    // 56 = 0x38
    NSString *_prompt;    // 64 = 0x40
    NSView *_condensedTitleView;    // 72 = 0x48
}

@end

@implementation UXNavigationItem

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        _hidesAlternateTitleView = NO;
        _title = title;
    }
    return self;
}

- (NSArray *)leadingBarButtonItems {
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        return self.rightBarButtonItems;
    } else {
        return self.leftBarButtonItems;
    }
}

- (NSArray *)leftBarButtonItems {
    NSMutableArray *leftBarButtonItems = [NSMutableArray arrayWithArray:_leftBarButtonItems];
    if (NSApp.userInterfaceLayoutDirection != NSUserInterfaceLayoutDirectionRightToLeft) {
        if (self.switchLibraryButtonItem) {
            [leftBarButtonItems insertObject:self.switchLibraryButtonItem atIndex:0];
        }
    }
    if (NSApp.userInterfaceLayoutDirection != NSUserInterfaceLayoutDirectionRightToLeft) {
        if (self.backBarButtonItem) {
            if (!self.hidesBackButton) {
                [leftBarButtonItems insertObject:self.backBarButtonItem atIndex:0];
            }
        }
    }
    return leftBarButtonItems;
}

- (void)setLeadingBarButtonItems:(NSArray *)leadingBarButtonItems {
    [self setLeftBarButtonItems:leadingBarButtonItems animated:NO];
}

- (void)setLeadingBarButtonItems:(NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated {
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        [self setRightBarButtonItems:items animated:animated];
    } else {
        [self setLeftBarButtonItems:items animated:animated];
    }
}

- (void)setLeftBarButtonItems:(NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated {
    [self willChangeValueForKey:NSStringFromSelector(@selector(leftBarButtonItems))];
    _leftBarButtonItems = items;
    [self didChangeValueForKey:NSStringFromSelector(@selector(leftBarButtonItems))];
}

- (NSArray *)trailingBarButtonItems {
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        return self.leftBarButtonItems;
    } else {
        return self.rightBarButtonItems;
    }
}

- (NSArray *)rightBarButtonItems {
    NSMutableArray *rightBarButtonItems = [NSMutableArray arrayWithArray:_rightBarButtonItems];
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        if (self.switchLibraryButtonItem) {
            [rightBarButtonItems insertObject:self.switchLibraryButtonItem atIndex:0];
        }
    }
    
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        if (self.backBarButtonItem) {
            if (!self.hidesBackButton) {
                [rightBarButtonItems insertObject:self.backBarButtonItem atIndex:0];
            }
        }
    }
    return rightBarButtonItems;
}

- (void)setTrailingBarButtonItems:(NSArray *)trailingBarButtonItems {
    [self setTrailingBarButtonItems:trailingBarButtonItems animated:NO];
}

- (void)setTrailingBarButtonItems:(NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated {
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        [self setLeftBarButtonItems:items animated:animated];
    } else {
        [self setRightBarButtonItems:items animated:animated];
    }
}

- (void)setRightBarButtonItems:(NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated {
    [self willChangeValueForKey:NSStringFromSelector(@selector(rightBarButtonItems))];
    _rightBarButtonItems = items;
    [self didChangeValueForKey:NSStringFromSelector(@selector(rightBarButtonItems))];
}

- (void)setLeftBarButtonItems:(NSArray *)leftBarButtonItems {
    [self setLeftBarButtonItems:leftBarButtonItems animated:NO];
}

- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems {
    [self setRightBarButtonItems:rightBarButtonItems animated:NO];
}

- (NSView *)titleView {
    if (_titleView) {
        _titleView.translatesAutoresizingMaskIntoConstraints = NO;
    } else {
        _titleView = self.internalTitleView;
    }
    return _titleView;
}

- (UXBarButtonItem *)rightBarButtonItem {
    return _rightBarButtonItems.firstObject;
}

- (void)setRightBarButtonItem:(UXBarButtonItem *)rightBarButtonItem {
    [self setRightBarButtonItem:rightBarButtonItem animated:NO];
}

- (UXBarButtonItem *)leftBarButtonItem {
    return _leftBarButtonItems.firstObject;
}

- (void)setLeftBarButtonItem:(UXBarButtonItem *)leftBarButtonItem {
    [self setLeftBarButtonItem:leftBarButtonItem animated:NO];
}

- (void)_updateInternalTitleView {
    if (self.title) {
        _internalTitleView.stringValue = self.title;
    } else {
        _internalTitleView.stringValue = @"";
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self _updateInternalTitleView];
}

- (NSTextField *)internalTitleView {
    if (!_internalTitleView) {
        _internalTitleView = [NSTextField labelWithString:@""];
        _internalTitleView.alignment = NSTextAlignmentCenter;
        _internalTitleView.textColor = NSColor.windowFrameTextColor;
        _internalTitleView.font = [NSFont titleBarFontOfSize:NSFont.systemFontSize];
        _internalTitleView.lineBreakMode = NSLineBreakByTruncatingTail;
        _internalTitleView.translatesAutoresizingMaskIntoConstraints = NO;
        [_internalTitleView setContentCompressionResistancePriority:300 forOrientation:(NSLayoutConstraintOrientationHorizontal)];
        [self _updateInternalTitleView];
    }
    return _internalTitleView;
}

- (void)setRightBarButtonItem:(UXBarButtonItem *)item animated:(BOOL)animated {
    [self setRightBarButtonItems:@[item] animated:animated];
}

- (void)setLeftBarButtonItem:(UXBarButtonItem *)item animated:(BOOL)animated {
    [self setLeftBarButtonItems:@[item] animated:animated];
}

+ (NSArray<NSString *> *)keyPathsToObserve {
    static dispatch_once_t onceToken;
    static NSArray<NSString *> *keyPaths = nil;
    dispatch_once(&onceToken, ^{
        keyPaths = @[
            @"title",
            @"titleView",
            @"switchLibraryButtonItem",
            @"leftBarButtonItems",
            @"rightBarButtonItems",
            @"hidesBackButton",
            @"backBarButtonItem",
            @"hidesAlternateTitleView",
            @"searchField",
        ];
    });
    return keyPaths;
}

@end
