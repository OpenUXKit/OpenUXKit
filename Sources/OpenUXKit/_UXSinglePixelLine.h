//
//     Generated by classdump-c 4.2.0 (64 bit) (iOS port by DreamDevLost, Updated by Kevin Bradley.)(Debug version compiled Feb 25 2024 00:55:05).
//
//  Copyright (C) 1997-2019 Steve Nygard. Updated in 2022 by Kevin Bradley.
//

#import <AppKit/NSView.h>

@class NSColor;

@interface _UXSinglePixelLine : NSView
{
    NSColor *_color;	// 112 = 0x70
}


@property(retain, nonatomic) NSColor *color; // @synthesize color=_color;
- (void)drawRect:(CGRect)arg1;
- (void)viewDidChangeBackingProperties;
- (void)viewDidMoveToSuperview;
- (void)updateHeight;

@end

