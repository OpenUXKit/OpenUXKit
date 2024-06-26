/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import <AppKit/NSAccessibilityElement.h>

@class NSArray, UXCollectionView, UXCollectionViewLayoutAccessibility;

@interface UXCollectionViewLayoutSectionAccessibility : NSAccessibilityElement {

	NSArray* _accessibilityVisibleChildren;

}

@property (nonatomic, weak, readonly) UXCollectionView *collectionView; 
@property (nonatomic, weak, readonly) UXCollectionViewLayoutAccessibility *layoutAccessibility; 
@property (nonatomic, readonly) unsigned long long sectionIndex; 
- (id)description;
- (long long)compare:(id)arg1;
- (id)accessibilityActionDescription:(id)arg1;
- (void)_dumpVisibleChildren;
- (id)accessibilityActionNames;
- (unsigned long long)accessibilityArrayAttributeCount:(id)arg1;
- (id)accessibilityArrayAttributeValues:(id)arg1 index:(unsigned long long)arg2 maxCount:(unsigned long long)arg3;
- (id)accessibilityAttributeNames;
- (id)accessibilityAttributeValue:(id)arg1;
- (id)accessibilityChildren;
- (void)accessibilityDidEndScrolling;
- (CGRect)accessibilityFrame;
- (id)accessibilityHitTest:(CGPoint)arg1;
- (unsigned long long)accessibilityIndexOfChild:(id)arg1;
- (void)accessibilityInvalidateLayout;
- (void)accessibilityPerformAction:(id)arg1;
- (BOOL)accessibilityPerformScrollToVisible;
- (void)accessibilityPrepareLayout;
- (id)accessibilityRole;
- (id)accessibilitySubrole;
- (id)accessibilityVisibleChildren;
- (id)collectionView;
- (void)setAccessibilityVisibleChildren:(id)arg1;
- (id)visibleSupplementaryViewsInSection:(long long)arg1;
- (unsigned long long)sectionIndex;
- (id)_siblingInDirection:(unsigned long long)arg1 item:(id)arg2;
- (void)accessibilityPrepareForCollectionViewUpdates;
- (id)initWithLayoutAccessibility:(id)arg1;
- (id)layoutAccessibility;
- (id)siblingAboveItem:(id)arg1;
- (id)siblingAfterItem:(id)arg1;
- (id)siblingBeforeItem:(id)arg1;
- (id)siblingBelowItem:(id)arg1;
- (id)visibleCellsInSection:(long long)arg1;
@end

