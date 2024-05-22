/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import "UXViewController.h"
#import <Cocoa/Cocoa.h>

@protocol UXPopoverControllerDelegate;
@class UXPopover, NSArray, UXViewController, NSString;

@interface UXPopoverController : UXViewController <NSPopoverDelegate> {

	UXPopover* _popover;
	id<UXPopoverControllerDelegate> _delegate;
	NSArray* _passthroughViews;

}

@property (nonatomic, readonly) UXPopover *popover; 
@property (nonatomic, weak) id<UXPopoverControllerDelegate> delegate;                      //@synthesize delegate=_delegate - In the implementation block
@property (nonatomic, strong) UXViewController *contentViewController; 
@property (getter=isPopoverVisible, nonatomic, readonly) BOOL popoverVisible; 
@property (nonatomic) long long popoverBehavior; 
@property (nonatomic) CGSize popoverContentSize; 
@property (nonatomic, copy) NSArray *passthroughViews;                                     //@synthesize passthroughViews=_passthroughViews - In the implementation block
@property (readonly) unsigned long long hash; 
@property (readonly) Class superclass; 
@property (copy, readonly) NSString *description; 
@property (copy, readonly) NSString *debugDescription; 
- (void)dealloc;
- (id<UXPopoverControllerDelegate>)delegate;
- (void)setDelegate:(id<UXPopoverControllerDelegate>)arg1;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void*)arg4;
- (id)popover;
- (long long)popoverBehavior;
- (id)contentViewController;
- (void)dismissPopover;
- (BOOL)isPopoverVisible;
- (void)popoverDidClose:(id)arg1;
- (BOOL)popoverShouldClose:(id)arg1;
- (void)popoverWillShow:(id)arg1;
- (void)setContentViewController:(id)arg1;
- (void)setPopoverBehavior:(long long)arg1;
- (id)passthroughViews;
- (void)setPassthroughViews:(id)arg1;
- (void)setPopoverContentSize:(CGSize)arg1 animated:(BOOL)arg2;
- (void)_updateContentSize;
- (void)dismissPopoverAnimated:(BOOL)arg1;
- (id)initWithContentViewController:(id)arg1;
- (CGSize)popoverContentSize;
- (void)presentPopoverFromBarButtonItem:(id)arg1 permittedArrowDirections:(unsigned long long)arg2 animated:(BOOL)arg3;
- (void)setPopoverContentSize:(CGSize)arg1;
- (void)presentPopoverFromRect:(CGRect)arg1 inView:(id)arg2 preferredEdge:(unsigned long long)arg3;
@end
