/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import "UXViewController.h"
#import "UXCollectionViewDataSource.h"
#import "UXCollectionViewDelegate.h"

@class UXCollectionViewLayout, UXCollectionView, NSString;

@interface UXCollectionViewController : UXViewController <UXCollectionViewDataSource, UXCollectionViewDelegate> {

	UXCollectionViewLayout* _layout;
	UXCollectionView* _collectionView;

}

@property (nonatomic, strong) UXCollectionView *collectionView;              //@synthesize collectionView=_collectionView - In the implementation block
@property (readonly) unsigned long long hash; 
@property (readonly) Class superclass; 
@property (copy, readonly) NSString *description; 
@property (copy, readonly) NSString *debugDescription; 
+ (Class)collectionViewClass;
- (void)dealloc;
- (void)_sendViewDidLoad;
- (id)collectionView;
- (long long)collectionView:(id)arg1 numberOfItemsInSection:(long long)arg2;
- (id)initWithCollectionViewLayout:(id)arg1;
- (long long)numberOfSectionsInCollectionView:(id)arg1;
- (double)scrollView:(id)arg1 pageAlignedOriginOnAxis:(long long)arg2 forProposedDestination:(double)arg3 currentOrigin:(double)arg4 initialOrigin:(double)arg5 velocity:(double)arg6;
- (void)setCollectionView:(id)arg1;
- (void)viewDidLoad;
- (id)collectionView:(id)arg1 cellForItemAtIndexPath:(id)arg2;
- (id)preferredFirstResponder;
@end

