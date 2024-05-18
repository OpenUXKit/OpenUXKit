/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import <AppKit/NSPanGestureRecognizer.h>

@class NSEvent;

@interface UXCollectionViewPanGestureRecognizer : NSPanGestureRecognizer {

	NSEvent* _mouseDownEvent;

}

@property (nonatomic, strong) NSEvent *mouseDownEvent;              //@synthesize mouseDownEvent=_mouseDownEvent - In the implementation block
- (void)dealloc;
- (void)mouseDown:(id)arg1;
- (id)mouseDownEvent;
- (void)setMouseDownEvent:(id)arg1;
- (void)uxCancel;
@end

