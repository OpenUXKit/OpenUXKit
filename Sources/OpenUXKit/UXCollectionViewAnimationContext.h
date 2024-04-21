//
//     Generated by classdump-c 4.2.0 (64 bit) (iOS port by DreamDevLost, Updated by Kevin Bradley.)(Debug version compiled Feb 25 2024 00:55:05).
//
//  Copyright (C) 1997-2019 Steve Nygard. Updated in 2022 by Kevin Bradley.
//

#import <objc/NSObject.h>

@class NSArray;

@interface UXCollectionViewAnimationContext : NSObject
{
    NSArray *_viewAnimations;	// 8 = 0x8
    NSInteger _animationCount;	// 16 = 0x10
    id _completionHandler;	// 24 = 0x18
}

@property(readonly, copy, nonatomic) id completionHandler; // @synthesize completionHandler=_completionHandler;
@property(nonatomic) NSInteger animationCount; // @synthesize animationCount=_animationCount;
@property(strong, nonatomic) NSArray *viewAnimations; // @synthesize viewAnimations=_viewAnimations;
- (void)dealloc;
- (id)initWithCompletionHandler:(id)arg1;

@end

