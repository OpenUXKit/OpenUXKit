/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import <Cocoa/Cocoa.h>

@class NSMutableIndexSet;

@interface _UXCollectionViewSectionItemIndexes : NSObject <NSCopying> {

	NSMutableIndexSet* _itemIndexesSet;

}
- (void)dealloc;
- (id)copyWithZone:(NSZone*)arg1;
- (id)description;
- (id)init;
- (BOOL)isEqual:(id)arg1;
- (unsigned long long)itemCount;
- (void)addItem:(unsigned long long)arg1;
- (void)removeItem:(unsigned long long)arg1;
- (unsigned long long)firstItem;
- (id)items;
- (unsigned long long)lastItem;
- (BOOL)containsItem:(unsigned long long)arg1;
- (void)enumerateItemsUsingBlock:(/*^block*/id)arg1;
- (void)addItemsInRange:(NSRange)arg1;
- (void)addSectionItemIndexes:(id)arg1;
- (void)adjustForDeletionOfItem:(unsigned long long)arg1;
- (void)adjustForDeletionOfItems:(id)arg1;
- (void)adjustForInsertionOfItem:(unsigned long long)arg1;
- (void)adjustForInsertionOfItems:(id)arg1;
- (id)itemIndexPathsForSection:(unsigned long long)arg1;
- (void)removeItemsInRange:(NSRange)arg1;
- (void)removeSectionItemIndexes:(id)arg1;
@end

