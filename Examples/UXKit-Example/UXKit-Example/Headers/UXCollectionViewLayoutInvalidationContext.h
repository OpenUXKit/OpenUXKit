/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */


#import "UXKit-Structs.h"
@class NSMutableDictionary, NSArray;

@interface UXCollectionViewLayoutInvalidationContext : NSObject {

	NSMutableDictionary* _invalidatedSupplementaryViews;
	NSArray* _updateItems;
	struct {
		unsigned invalidateDataSource : 1;
		unsigned invalidateEverything : 1;
		unsigned invalidateContentSize : 1;
	}  _invalidationContextFlags;

}

@property (nonatomic, readonly) BOOL invalidateEverything; 
@property (nonatomic, readonly) BOOL invalidateDataSourceCounts; 
- (void)dealloc;
- (void)_setInvalidateDataSourceCounts:(BOOL)arg1;
- (id)_invalidatedSupplementaryViews;
- (void)_setInvalidateEverything:(BOOL)arg1;
- (void)_setInvalidatedSupplementaryViews:(id)arg1;
- (void)_setUpdateItems:(id)arg1;
- (id)_updateItems;
- (BOOL)invalidateDataSourceCounts;
- (BOOL)invalidateEverything;
- (void)_invalidateSupplementaryElementsOfKind:(id)arg1 atIndexPaths:(id)arg2;
- (BOOL)invalidateContentSize;
- (void)setInvalidateContentSize:(BOOL)arg1;
@end

