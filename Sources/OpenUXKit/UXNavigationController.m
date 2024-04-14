//
//  UXNavigationController.m
//  
//
//  Created by JH on 2024/2/26.
//

#import "UXNavigationController.h"

@interface UXNavigationController ()
{
    NSMutableArray *_navigationRequests;    // 16 = 0x10
    NSMutableArray *_targetViewControllers;    // 24 = 0x18
    NSMutableArray *_currentViewControllers;    // 32 = 0x20
    UXNavigationBar *_navigationBar;    // 40 = 0x28
    UXToolbar *_accessoryBar;    // 48 = 0x30
    UXToolbar *_toolbar;    // 56 = 0x38
    struct {
        unsigned int willShowViewController:1;
        unsigned int didShowViewController:1;
        unsigned int interactionControllerForAnimationController:1;
        unsigned int animationControllerForOperation:1;
        unsigned int shouldBeginInteractivePopFromViewControllerToViewController:1;
    } _delegateFlags;    // 64 = 0x40
    BOOL _isPerformingToolbarsChanges;    // 68 = 0x44
    struct {
        BOOL toolbarItems;
        BOOL subtoolbarItems;
        BOOL positions;
        BOOL visibility;
        BOOL appearance;
    } _toolbarsNeedUpdateFlags;    // 69 = 0x45
    BOOL _navigationBarHidden;    // 74 = 0x4a
    BOOL _navigationBarDetached;    // 75 = 0x4b
    BOOL _toolbarHidden;    // 76 = 0x4c
    BOOL _subtoolbarHidden;    // 77 = 0x4d
    BOOL _backButtonMenuEnabled;    // 78 = 0x4e
    BOOL _shouldAnimateToolbarUpdates;    // 79 = 0x4f
    BOOL __fullScreenMode;    // 80 = 0x50
    BOOL __locked;    // 81 = 0x51
    BOOL __hidesBackTitles;    // 82 = 0x52
    BOOL _isTransitioning;    // 83 = 0x53
    BOOL _isInteractive;    // 84 = 0x54
    UXToolbar *_subtoolbar;    // 88 = 0x58
    __weak id <UXNavigationControllerDelegate> _delegate;    // 96 = 0x60
    NSGestureRecognizer *_interactivePopGestureRecognizer;    // 104 = 0x68
//    Class _navigationBarClass;    // 112 = 0x70
//    Class _toolbarClass;    // 120 = 0x78
    _UXWindowState *_windowState;    // 128 = 0x80
    _UXContainerView *_containerView;    // 136 = 0x88
    NSMutableArray *_addedConstraints;    // 144 = 0x90
    NSLayoutConstraint *_topConstraint;    // 152 = 0x98
    NSLayoutConstraint *_bottomConstraint;    // 160 = 0xa0
    NSLayoutConstraint *_navigationBarTopConstraint;    // 168 = 0xa8
    NSArray *_navigationBarConstraints;    // 176 = 0xb0
    NSLayoutConstraint *_toolbarVerticalConstraint;    // 184 = 0xb8
    NSLayoutConstraint *_toolbarLeadingConstraint;    // 192 = 0xc0
    NSLayoutConstraint *_topViewControllerLeftConstraint;    // 200 = 0xc8
    NSArray *_topViewControllerOtherConstraints;    // 208 = 0xd0
    _UXViewControllerOneToOneTransitionContext *_currentTransitionContext;    // 216 = 0xd8
    UXNavigationControllerOperation _currentOperation;    // 224 = 0xe0
    UXTransitionController *_defaultTransitionController;    // 232 = 0xe8
    UXViewController *_observedViewController;    // 240 = 0xf0
    UXViewController *_provisionalPreviousViewController;    // 248 = 0xf8
    UXView *_toolbarExtendedBackgroundView;    // 256 = 0x100
    id _testingTransitionAnimationCompletionHandler;    // 264 = 0x108
    NSVisualEffectView *_toolbarVisualEffectsView;    // 272 = 0x110
    NSVisualEffectView *_subtoolbarVisualEffectsView;    // 280 = 0x118
    double __leadingContentInset;    // 288 = 0x120
    UXBarPosition __toolbarPosition;    // 296 = 0x128
    UXBarPosition __subtoolbarPosition;    // 304 = 0x130
    NSUInteger __defaultPushTransition;    // 312 = 0x138
    NSUInteger __defaultPopTransition;    // 320 = 0x140
//    id <_UXAccessoryBarContainer> _accessoryBarContainer;    // 328 = 0x148
}
@end

@implementation UXNavigationController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _addedConstraints = [NSMutableArray array];
        _navigationRequests = [NSMutableArray array];
        _targetViewControllers = [NSMutableArray array];
        _currentViewControllers = [NSMutableArray array];
        __toolbarPosition = UXBarPositionTop;
        __subtoolbarPosition = UXBarPositionTop;
        _subtoolbarHidden = YES;
        __defaultPushTransition = 0x64;
        __defaultPopTransition = 0x65;
        _interactivePopGestureRecognizer = [NSGestureRecognizer new];
        _backButtonMenuEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"UXBackButtonMenuEnabled"];
    }
    return self;
}

@end
