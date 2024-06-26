/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import <AppKit/NSImage.h>

@class NSImage;

@interface _UXResizableImage : NSImage {

	NSImage* _topLeftCorner;
	NSImage* _topEdgeFill;
	NSImage* _topRightCorner;
	NSImage* _leftEdgeFill;
	NSImage* _centerFill;
	NSImage* _rightEdgeFill;
	NSImage* _bottomLeftCorner;
	NSImage* _bottomEdgeFill;
	NSImage* _bottomRightCorner;
	double _scale;
	BOOL _alwaysStretches;

}

@property (nonatomic) BOOL alwaysStretches;              //@synthesize alwaysStretches=_alwaysStretches - In the implementation block
- (void)drawInRect:(CGRect)arg1 fromRect:(CGRect)arg2 operation:(unsigned long long)arg3 fraction:(double)arg4;
- (void)drawInRect:(CGRect)arg1 fromRect:(CGRect)arg2 operation:(unsigned long long)arg3 fraction:(double)arg4 respectFlipped:(BOOL)arg5 hints:(id)arg6;
- (CGSize)_sizeInPixels;
- (CGRect)_contentStretchInPixels;
- (id)initWithImage:(id)arg1 capInsets:(NSEdgeInsets)arg2;
- (BOOL)_isTiledWhenStretchedToSize:(CGSize)arg1;
- (CGRect)_contentRectInPixels;
- (BOOL)alwaysStretches;
- (CGRect)_contentInsetsInPixels:(NSEdgeInsets)arg1 emptySizeFallback:(/*^block*/id)arg2;
- (void)_setupNinePartFromImage:(id)arg1;
- (void)setAlwaysStretches:(BOOL)arg1;
@end

