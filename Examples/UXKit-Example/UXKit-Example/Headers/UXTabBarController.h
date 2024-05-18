/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXViewController.h"
#import <Cocoa/Cocoa.h>

@class _UXViewControllerTransitionContext, UXTransitionController, UXViewController, NSArray, NSSegmentedControl, NSPopUpButton, NSLayoutConstraint, NSToolbarItemGroup, NSMapTable, NSSet, UXNavigationItem, UXTabBarItemSegment, NSString;

@interface UXTabBarController : UXViewController <NSMenuItemValidation> {

	_UXViewControllerTransitionContext* _transitionCtx;
	UXTransitionController* _transitionController;
	UXViewController* _installedViewController;
	BOOL _needsTransition;
	BOOL _segmentTransitionInProgress;
	BOOL _viewControllerTransitionInProgress;
	NSArray* _viewControllers;
	UXViewController* _selectedViewController;
	NSSegmentedControl* _segmentedControl;
	NSPopUpButton* _popUpButton;
	NSLayoutConstraint* _popUpButtonWidthConstraint;
	NSToolbarItemGroup* _toolbarItemGroup;
	NSArray* _centerToolbarItemGroupTitles;
	NSMapTable* _representedSegmentsToViewControllers;
	NSArray* _representedSegments;
	NSSet* _observedItemSegments;
	NSSet* _observedTabBarItems;
	UXNavigationItem* _observedNavigationItem;
	UXViewController* _observedViewController;
	NSArray* _shortcutMenuItems;
	NSMapTable* _transitionControllerClassByToViewControllerClass;
	UXTabBarItemSegment* _selectedItemSegment;
	UXViewController* _transientViewController;

}

@property (nonatomic, readonly) NSSegmentedControl *segmentedControl;                                      //@synthesize segmentedControl=_segmentedControl - In the implementation block
@property (nonatomic, readonly) NSPopUpButton *popUpButton;                                                //@synthesize popUpButton=_popUpButton - In the implementation block
@property (nonatomic, readonly) NSLayoutConstraint *popUpButtonWidthConstraint;                            //@synthesize popUpButtonWidthConstraint=_popUpButtonWidthConstraint - In the implementation block
@property (nonatomic, readonly) NSToolbarItemGroup *toolbarItemGroup;                                      //@synthesize toolbarItemGroup=_toolbarItemGroup - In the implementation block
@property (nonatomic, strong) NSArray *centerToolbarItemGroupTitles;                                       //@synthesize centerToolbarItemGroupTitles=_centerToolbarItemGroupTitles - In the implementation block
@property (nonatomic, strong) NSMapTable *representedSegmentsToViewControllers;                            //@synthesize representedSegmentsToViewControllers=_representedSegmentsToViewControllers - In the implementation block
@property (nonatomic, strong) NSArray *representedSegments;                                                //@synthesize representedSegments=_representedSegments - In the implementation block
@property (nonatomic, strong) NSSet *observedItemSegments;                                                 //@synthesize observedItemSegments=_observedItemSegments - In the implementation block
@property (nonatomic, strong) NSSet *observedTabBarItems;                                                  //@synthesize observedTabBarItems=_observedTabBarItems - In the implementation block
@property (nonatomic, strong) UXNavigationItem *observedNavigationItem;                                    //@synthesize observedNavigationItem=_observedNavigationItem - In the implementation block
@property (nonatomic, strong) UXViewController *observedViewController;                                    //@synthesize observedViewController=_observedViewController - In the implementation block
@property (nonatomic, strong) NSArray *shortcutMenuItems;                                                  //@synthesize shortcutMenuItems=_shortcutMenuItems - In the implementation block
@property (nonatomic, readonly) NSMapTable *transitionControllerClassByToViewControllerClass;              //@synthesize transitionControllerClassByToViewControllerClass=_transitionControllerClassByToViewControllerClass - In the implementation block
@property (nonatomic) BOOL segmentTransitionInProgress;                                                    //@synthesize segmentTransitionInProgress=_segmentTransitionInProgress - In the implementation block
@property (nonatomic) BOOL viewControllerTransitionInProgress;                                             //@synthesize viewControllerTransitionInProgress=_viewControllerTransitionInProgress - In the implementation block
@property (nonatomic, strong) UXTabBarItemSegment *selectedItemSegment;                                    //@synthesize selectedItemSegment=_selectedItemSegment - In the implementation block
@property (nonatomic, strong) UXViewController *transientViewController;                                   //@synthesize transientViewController=_transientViewController - In the implementation block
@property (nonatomic, copy) NSArray *viewControllers;                                                      //@synthesize viewControllers=_viewControllers - In the implementation block
@property (nonatomic, weak) UXViewController *selectedViewController;                                      //@synthesize selectedViewController=_selectedViewController - In the implementation block
@property (nonatomic) unsigned long long selectedIndex; 
@property (readonly) unsigned long long hash; 
@property (readonly) Class superclass; 
@property (copy, readonly) NSString *description; 
@property (copy, readonly) NSString *debugDescription; 
- (void)dealloc;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void*)arg4;
- (id)initWithNibName:(id)arg1 bundle:(id)arg2;
- (void)_setSelectedIndex:(unsigned long long)arg1;
- (void)keyDown:(id)arg1;
- (id)segmentedControl;
- (unsigned long long)selectedIndex;
- (id)selectedViewController;
- (void)setSelectedIndex:(unsigned long long)arg1;
- (void)setSelectedViewController:(id)arg1;
- (BOOL)validateMenuItem:(id)arg1;
- (void)viewDidLayout;
- (void)viewDidLoad;
- (void)viewWillDisappear;
- (id)navigationDestination;
- (id)viewControllers;
- (void)setViewControllers:(id)arg1;
- (id)popUpButton;
- (id)transitionCoordinator;
- (id)preferredFirstResponder;
- (void)setTransientViewController:(id)arg1;
- (void)setTransientViewController:(id)arg1 animated:(BOOL)arg2;
- (id)transientViewController;
- (id)observedNavigationItem;
- (void)setObservedNavigationItem:(id)arg1;
- (void)_updateControls;
- (void)invalidateIntrinsicLayoutInsets;
- (void)segmentChanged:(id)arg1;
- (void)setSegmentTransitionInProgress:(BOOL)arg1;
- (void)_beginTransitionWithContext:(id)arg1 operation:(long long)arg2 completion:(/*^block*/id)arg3;
- (BOOL)_canPerformTransition;
- (id)_childViewControllerAbleToNavigateToDestination:(id)arg1;
- (id)_contextForTransitionOperation:(long long)arg1 fromViewController:(id)arg2 toViewController:(id)arg3 transition:(unsigned long long)arg4;
- (unsigned long long)_firstItemSegmentIndexForViewController:(id)arg1;
- (void)_invalidateIntrinsicLayoutInsetsForViewController:(id)arg1;
- (void)_performTransitionIfNeeded;
- (void)_prepareForAnimationInContext:(id)arg1 completion:(/*^block*/id)arg2;
- (void)_prepareViewController:(id)arg1 forTransitionInContext:(id)arg2 completion:(/*^block*/id)arg3;
- (void)_recalculateSegmentedControlWidth;
- (void)_removePopulatedMenuItems;
- (BOOL)_requiresWindowForTransitionPreparation;
- (void)_setNeedsTransition;
- (void)_setObservedNavigationItem:(id)arg1 updateBarButtonItems:(BOOL)arg2;
- (id)_targetViewController;
- (void)_transitionToTargetViewControllerWithCompletion:(/*^block*/id)arg1;
- (void)_transitionToViewController:(id)arg1 animated:(BOOL)arg2 completion:(/*^block*/id)arg3;
- (void)_updateControlsProperties;
- (void)_updateControlsSelection;
- (void)_updateLeftBarButtonItems;
- (void)_updateRightBarButtonItems;
- (void)_updateToolbarProperties;
- (BOOL)canProvideViewControllersForNavigationDestination:(id)arg1;
- (id)centerToolbarItemGroupTitles;
- (id)contentRepresentingViewController;
- (id)observedItemSegments;
- (id)observedTabBarItems;
- (id)observedViewController;
- (id)popUpButtonWidthConstraint;
- (void)popUpChanged:(id)arg1;
- (void)populateShortcutMenuItemsStartingAtIndex:(unsigned long long)arg1 ofMenu:(id)arg2 useSeparators:(BOOL)arg3;
- (void)registerTransitionControllerClass:(Class)arg1 forViewControllerClass:(Class)arg2;
- (id)representedSegments;
- (id)representedSegmentsToViewControllers;
- (void)requestViewControllersForNavigationDestination:(id)arg1 completion:(/*^block*/id)arg2;
- (BOOL)segmentTransitionInProgress;
- (void)selectSegmentFromMenu:(id)arg1;
- (id)selectedItemSegment;
- (void)setCenterToolbarItemGroupTitles:(id)arg1;
- (void)setObservedItemSegments:(id)arg1;
- (void)setObservedTabBarItems:(id)arg1;
- (void)setObservedViewController:(id)arg1;
- (void)setRepresentedSegments:(id)arg1;
- (void)setRepresentedSegmentsToViewControllers:(id)arg1;
- (void)setSelectedIndex:(unsigned long long)arg1 allowsCurrentTabReselectionCallback:(BOOL)arg2;
- (void)setSelectedItemSegment:(id)arg1;
- (void)setShortcutMenuItems:(id)arg1;
- (void)setViewControllerTransitionInProgress:(BOOL)arg1;
- (id)shortcutMenuItems;
- (id)toolbarItemGroup;
- (void)toolbarItemGroupSelectionDidChange:(id)arg1;
- (id)transitionControllerClassByToViewControllerClass;
- (void)unregisterTransitionControllerForTransitionToViewControllerClass:(Class)arg1;
- (void)updateForEqualNavigationDestination:(id)arg1;
- (BOOL)viewControllerTransitionInProgress;
@end

