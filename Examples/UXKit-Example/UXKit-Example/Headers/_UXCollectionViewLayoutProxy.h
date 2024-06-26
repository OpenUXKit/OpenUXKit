/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */


@protocol UXCollectionViewLayoutProxyDelegate;
#import "UXKit-Structs.h"
@class UXCollectionViewLayout;

@interface _UXCollectionViewLayoutProxy : NSObject {

	id<UXCollectionViewLayoutProxyDelegate> _delegate;
	UXCollectionViewLayout* _layout;

}

@property (nonatomic) id<UXCollectionViewLayoutProxyDelegate> delegate;              //@synthesize delegate=_delegate - In the implementation block
@property (nonatomic, readonly) UXCollectionViewLayout *layout;                      //@synthesize layout=_layout - In the implementation block
+ (Class)class;
+ (Class)invalidationContextClass;
+ (Class)layoutAttributesClass;
- (void)dealloc;
- (Class)class;
- (id)forwardingTargetForSelector:(SEL)arg1;
- (id<UXCollectionViewLayoutProxyDelegate>)delegate;
- (void)setDelegate:(id<UXCollectionViewLayoutProxyDelegate>)arg1;
- (id)layout;
- (id)initWithLayout:(id)arg1;
- (id)layoutAttributesForElementsInRect:(CGRect)arg1;
@end

