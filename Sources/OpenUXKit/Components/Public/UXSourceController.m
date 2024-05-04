//
//  UXSourceController.m
//  
//
//  Created by JH on 2024/4/21.
//

#import <Foundation/Foundation.h>
#import <OpenUXKit/UXSourceController.h>

@interface UXSourceController ()
{
    NSView *_tabBarView;    // 16 = 0x10
    _UXSourceSplitView *_splitView;    // 24 = 0x18
    NSLayoutConstraint *_popUpWidthContraint;    // 32 = 0x20
    BOOL _needsToSetInitialMasterWidth;    // 40 = 0x28
    BOOL _isTransitioning;    // 41 = 0x29
    _UXViewControllerOneToOneTransitionContext *_transitionCtx;    // 48 = 0x30
    UXTransitionController *_transitionController;    // 56 = 0x38
    NSMapTable *_navigationControllerByRootViewController;    // 64 = 0x40
    NSMapTable *_transitionControllerClassByToViewControllerClass;    // 72 = 0x48
    NSOperationQueue *_viewControllerOperations;    // 80 = 0x50
    UXNavigationController *_targetNavigationController;    // 88 = 0x58
    id <UXNavigationDestination> _targetNavigationDestination;    // 96 = 0x60
    id <UXNavigationControllerDelegate> _currentNavigationDelegate;    // 104 = 0x68
    id _localEdgeHoverEventMonitor;    // 112 = 0x70
    id _globalEdgeHoverEventMonitor;    // 120 = 0x78
    id _windowResizeObserver;    // 128 = 0x80
    id _windowDeactivateObserver;    // 136 = 0x88
    UXView *_transientlyUncollapsedView;    // 144 = 0x90
    BOOL _hasItemToRevealOnEdgeHover;    // 152 = 0x98
    NSInteger _preferredStyle;    // 160 = 0xa0
    NSInteger _style;    // 168 = 0xa8
    UXViewController<UXSourceList> *_sourceListViewController;    // 176 = 0xb0
    CGFloat _minimumWidthForInlineSourceList;    // 184 = 0xb8
    NSString *_sourceListAutosaveName;    // 192 = 0xc0
    NSArray *_rootViewControllers;    // 200 = 0xc8
    UXViewController *_selectedViewController;    // 208 = 0xd0
    NSSegmentedControl *_segmentedControl;    // 216 = 0xd8
    NSPopUpButton *_popUpButton;    // 224 = 0xe0
    __weak NSWindow *_observedWindow;    // 232 = 0xe8
}
@end

@implementation UXSourceController



@end
