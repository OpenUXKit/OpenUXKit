//
//     Generated by classdump-c 4.2.0 (64 bit) (iOS port by DreamDevLost, Updated by Kevin Bradley.)(Debug version compiled Feb 25 2024 00:55:05).
//
//  Copyright (C) 1997-2019 Steve Nygard. Updated in 2022 by Kevin Bradley.
//

#import <AppKit/NSWindow.h>

#import "UXKitAppearance-Protocol.h"

@class NSColor, NSString;

@interface NSWindow (UXKit) <UXKitAppearance>
@property(nonatomic, setter=ux_setToolbarHiddenInFullScreen:) BOOL ux_toolbarHiddenInFullScreen;
@property(readonly, nonatomic) BOOL ux_inFullScreen;
- (void)tintColorDidChange;
@property(nonatomic) NSInteger tintAdjustmentMode;
@property(retain, nonatomic) NSColor *tintColor;
- (void)ux_forceEnableStandardWindowButton:(NSWindowButton)windowButton;
@end

