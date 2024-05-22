#import <OpenUXKit/UXTabBarController.h>


@interface UXTabBarController ()
{
    _UXViewControllerTransitionContext *_transitionCtx;    // 16 = 0x10
    UXTransitionController *_transitionController;    // 24 = 0x18
    UXViewController *_installedViewController;    // 32 = 0x20
    BOOL _needsTransition;    // 40 = 0x28
    BOOL _segmentTransitionInProgress;    // 41 = 0x29
    BOOL _viewControllerTransitionInProgress;    // 42 = 0x2a
    NSArray *_viewControllers;    // 48 = 0x30
    __weak UXViewController *_selectedViewController;    // 56 = 0x38
    NSSegmentedControl *_segmentedControl;    // 64 = 0x40
    NSPopUpButton *_popUpButton;    // 72 = 0x48
    NSLayoutConstraint *_popUpButtonWidthConstraint;    // 80 = 0x50
    NSMapTable *_representedSegmentsToViewControllers;    // 88 = 0x58
    NSArray *_representedSegments;    // 96 = 0x60
    NSSet *_observedItemSegments;    // 104 = 0x68
    UXNavigationItem *_observedNavigationItem;    // 112 = 0x70
    UXViewController *_observedViewController;    // 120 = 0x78
    NSArray *_shortcutMenuItems;    // 128 = 0x80
    NSMapTable *_transitionControllerClassByToViewControllerClass;    // 136 = 0x88
    UXTabBarItemSegment *_selectedItemSegment;    // 144 = 0x90
    UXViewController *_transientViewController;    // 152 = 0x98
}

@end

@implementation UXTabBarController



@end
