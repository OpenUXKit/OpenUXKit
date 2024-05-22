/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import "UXBar.h"

@protocol UXToolbarDelegate;
@class NSArray;

@interface UXToolbar : UXBar {

	id<UXToolbarDelegate> _delegate;
	NSArray* _items;

}

@property (nonatomic, weak) id<UXToolbarDelegate> delegate;              //@synthesize delegate=_delegate - In the implementation block
@property (nonatomic, copy) NSArray *items;                              //@synthesize items=_items - In the implementation block
- (id<UXToolbarDelegate>)delegate;
- (void)setDelegate:(id<UXToolbarDelegate>)arg1;
- (void)otherMouseDown:(id)arg1;
- (void)rightMouseDown:(id)arg1;
- (id)initWithFrame:(CGRect)arg1;
- (id)items;
- (void)mouseDown:(id)arg1;
- (void)mouseDragged:(id)arg1;
- (void)mouseMoved:(id)arg1;
- (void)mouseUp:(id)arg1;
- (id)nextResponder;
- (void)otherMouseDragged:(id)arg1;
- (void)otherMouseUp:(id)arg1;
- (void)rightMouseDragged:(id)arg1;
- (void)rightMouseUp:(id)arg1;
- (void)setItems:(id)arg1;
- (long long)barPosition;
- (void)setItems:(id)arg1 animated:(BOOL)arg2;
- (void)_beginInteractiveTransitionForItems:(id)arg1;
- (void)_setItems:(id)arg1 animated:(BOOL)arg2 duration:(double)arg3;
@end
