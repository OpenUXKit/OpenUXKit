/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import "UXCollectionViewIndexPathsSet.h"

@interface UXCollectionViewMutableIndexPathsSet : UXCollectionViewIndexPathsSet
- (id)copyWithZone:(NSZone*)arg1;
- (void)addIndexPath:(id)arg1;
- (void)removeSections:(id)arg1;
- (void)_adjustForDeletionOfSection:(unsigned long long)arg1;
- (void)_adjustForInsertionOfSection:(unsigned long long)arg1;
- (void)addIndexPaths:(id)arg1;
- (void)addIndexPathsSet:(id)arg1;
- (void)addSection:(long long)arg1 itemsInRange:(NSRange)arg2;
- (void)adjustForDeletionOfIndexPath:(id)arg1;
- (void)adjustForDeletionOfItems:(id)arg1 inSection:(unsigned long long)arg2;
- (void)adjustForDeletionOfSection:(unsigned long long)arg1;
- (void)adjustForDeletionOfSections:(id)arg1;
- (void)adjustForInsertionOfIndexPath:(id)arg1;
- (void)adjustForInsertionOfItems:(id)arg1 inSection:(unsigned long long)arg2;
- (void)adjustForInsertionOfSection:(unsigned long long)arg1;
- (void)adjustForInsertionOfSections:(id)arg1;
- (void)intersectIndexPathsSet:(id)arg1;
- (void)removeAllIndexPaths;
- (void)removeIndexPath:(id)arg1;
- (void)removeIndexPaths:(id)arg1;
- (void)removeIndexPathsSet:(id)arg1;
- (void)removeSection:(long long)arg1;
- (void)removeSection:(long long)arg1 itemsInRange:(NSRange)arg2;
@end

