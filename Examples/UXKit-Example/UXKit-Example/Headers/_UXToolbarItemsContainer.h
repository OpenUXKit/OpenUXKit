/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import "UXView.h"
#import "_UXBarItemsContainer.h"

@class NSMutableArray, NSArray, NSString;

@interface _UXToolbarItemsContainer : UXView <_UXBarItemsContainer> {

	NSMutableArray* __addedConstraints;
	BOOL _singleItemMode;
	BOOL _isTransitioning;
	NSArray* _items;
	double _interitemSpacing;
	double _baselineOffsetFromBottom;
	NSEdgeInsets _layoutMargins;

}

@property (nonatomic, readonly) NSArray *items;                            //@synthesize items=_items - In the implementation block
@property (nonatomic) double interitemSpacing;                             //@synthesize interitemSpacing=_interitemSpacing - In the implementation block
@property (nonatomic) double baselineOffsetFromBottom;                     //@synthesize baselineOffsetFromBottom=_baselineOffsetFromBottom - In the implementation block
@property (nonatomic) NSEdgeInsets layoutMargins;                          //@synthesize layoutMargins=_layoutMargins - In the implementation block
@property (nonatomic, readonly) BOOL hidesGlobalTrailingView; 
@property (readonly) unsigned long long hash; 
@property (readonly) Class superclass; 
@property (copy, readonly) NSString *description; 
@property (copy, readonly) NSString *debugDescription; 
+ (id)toolbarItemsContainerForToolbar:(id)arg1 items:(id)arg2;
- (double)baselineOffsetFromBottom;
- (id)initWithFrame:(CGRect)arg1;
- (id)items;
- (double)lastBaselineOffsetFromBottom;
- (void)updateConstraints;
- (void)setBaselineOffsetFromBottom:(double)arg1;
- (NSEdgeInsets)layoutMargins;
- (void)setLayoutMargins:(NSEdgeInsets)arg1;
- (void)prepareForTransition;
- (double)interitemSpacing;
- (void)setInteritemSpacing:(double)arg1;
- (BOOL)hidesGlobalTrailingView;
@end
