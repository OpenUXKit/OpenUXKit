//
//     Generated by classdump-c 4.2.0 (64 bit) (iOS port by DreamDevLost, Updated by Kevin Bradley.)(Debug version compiled Feb 25 2024 00:55:05).
//
//  Copyright (C) 1997-2019 Steve Nygard. Updated in 2022 by Kevin Bradley.
//

@interface UXCollectionViewFlowLayoutInvalidationContext
{
    struct {
        unsigned int invalidateDelegateMetrics:1;
        unsigned int invalidateAttributes:1;
    } _flowLayoutInvalidationFlags;	// 8 = 0x8
}

@property(nonatomic) BOOL invalidateFlowLayoutDelegateMetrics;
@property(nonatomic) BOOL invalidateFlowLayoutAttributes;
- (id)init;

@end

