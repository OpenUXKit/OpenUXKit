/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

@class NSString, UXDestinationAuxiliaryStore, NSSet;


@protocol UXNavigationDestination <NSObject,NSSecureCoding>
@property (nonatomic, readonly) NSString *destinationIdentifier; 
@property (nonatomic, readonly) NSString *destinationTitle; 
@property (nonatomic, readonly) UXDestinationAuxiliaryStore *destinationAuxiliaryStore; 
@property (nonatomic, readonly) NSSet *requiredDestinationAuxiliaryKeys; 
@required
-(id)destinationIdentifier;
-(id)destinationAuxiliaryStore;
-(id)destinationTitle;
-(id)requiredDestinationAuxiliaryKeys;

@end
