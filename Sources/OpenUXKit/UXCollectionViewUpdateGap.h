//
//     Generated by classdump-c 4.2.0 (64 bit) (iOS port by DreamDevLost, Updated by Kevin Bradley.)(Debug version compiled Feb 25 2024 00:55:05).
//
//  Copyright (C) 1997-2019 Steve Nygard. Updated in 2022 by Kevin Bradley.
//

#import <objc/NSObject.h>

@class NSArray, NSMutableArray, UXCollectionViewUpdateItem;

@interface UXCollectionViewUpdateGap : NSObject
{
    UXCollectionViewUpdateItem *_firstUpdateItem;	// 8 = 0x8
    UXCollectionViewUpdateItem *_lastUpdateItem;	// 16 = 0x10
    NSMutableArray *_deleteItems;	// 24 = 0x18
    NSMutableArray *_insertItems;	// 32 = 0x20
    CGRect _beginningRect;	// 40 = 0x28
    CGRect _endingRect;	// 72 = 0x48
}

+ (id)gapWithUpdateItem:(id)arg1;
@property(nonatomic) CGRect endingRect; // @synthesize endingRect=_endingRect;
@property(nonatomic) CGRect beginningRect; // @synthesize beginningRect=_beginningRect;
@property(readonly, nonatomic) NSArray *insertItems; // @synthesize insertItems=_insertItems;
@property(readonly, nonatomic) NSArray *deleteItems; // @synthesize deleteItems=_deleteItems;
@property(strong, nonatomic) UXCollectionViewUpdateItem *lastUpdateItem; // @synthesize lastUpdateItem=_lastUpdateItem;
@property(strong, nonatomic) UXCollectionViewUpdateItem *firstUpdateItem; // @synthesize firstUpdateItem=_firstUpdateItem;
@property(readonly, nonatomic) BOOL isSectionBasedGap;
@property(readonly, nonatomic) NSArray *updateItems;
@property(readonly, nonatomic) BOOL hasInserts;
@property(readonly, nonatomic) BOOL isDeleteBasedGap;
- (void)dealloc;
- (void)addUpdateItem:(id)arg1;
- (id)description;
- (id)init;

@end

