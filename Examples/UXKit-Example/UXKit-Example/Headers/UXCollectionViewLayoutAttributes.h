/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import <Cocoa/Cocoa.h>

@class NSString, NSIndexPath;

@interface UXCollectionViewLayoutAttributes : NSObject <NSCopying> {

	unsigned long long _hash;
	NSString* _elementKind;
	NSString* _reuseIdentifier;
	CGRect _frame;
	CGPoint _center;
	CGSize _size;
	double _alpha;
	long long _zIndex;
	BOOL _isFloating;
	CGRect _floatingFrame;
	NSIndexPath* _indexPath;
	NSString* _representedElementKind;
	NSString* _isCloneString;
	struct {
		unsigned isCellKind : 1;
		unsigned isDecorationView : 1;
		unsigned isHidden : 1;
		unsigned isClone : 1;
	}  _layoutFlags;
	BOOL _isPushing;
	double _verticalOffsetFromFloatingPosition;

}

@property (nonatomic) BOOL isPushing;                                                       //@synthesize isPushing=_isPushing - In the implementation block
@property (nonatomic) double verticalOffsetFromFloatingPosition;                            //@synthesize verticalOffsetFromFloatingPosition=_verticalOffsetFromFloatingPosition - In the implementation block
@property (nonatomic) CGRect frame;                                                         //@synthesize frame=_frame - In the implementation block
@property (nonatomic) CGPoint center;                                                       //@synthesize center=_center - In the implementation block
@property (nonatomic) CGSize size;                                                          //@synthesize size=_size - In the implementation block
@property (nonatomic) CGRect bounds; 
@property (nonatomic) double alpha;                                                         //@synthesize alpha=_alpha - In the implementation block
@property (nonatomic) long long zIndex;                                                     //@synthesize zIndex=_zIndex - In the implementation block
@property (nonatomic) BOOL isFloating;                                                      //@synthesize isFloating=_isFloating - In the implementation block
@property (nonatomic) CGRect floatingFrame;                                                 //@synthesize floatingFrame=_floatingFrame - In the implementation block
@property (getter=isHidden, nonatomic) BOOL hidden; 
@property (nonatomic, strong) NSIndexPath *indexPath;                                       //@synthesize indexPath=_indexPath - In the implementation block
@property (nonatomic, readonly) unsigned long long representedElementCategory; 
@property (nonatomic, readonly) NSString *representedElementKind;                           //@synthesize representedElementKind=_representedElementKind - In the implementation block
+ (id)layoutAttributesForDecorationViewOfKind:(id)arg1 withIndexPath:(id)arg2;
+ (id)layoutAttributesForSupplementaryViewOfKind:(id)arg1 withIndexPath:(id)arg2;
+ (id)layoutAttributesForCellWithIndexPath:(id)arg1;
- (void)dealloc;
- (id)copyWithZone:(NSZone*)arg1;
- (id)description;
- (unsigned long long)hash;
- (id)init;
- (BOOL)isEqual:(id)arg1;
- (CGSize)size;
- (BOOL)isHidden;
- (void)setHidden:(BOOL)arg1;
- (void)setSize:(CGSize)arg1;
- (id)indexPath;
- (BOOL)_isCell;
- (id)_elementKind;
- (BOOL)_isClone;
- (BOOL)_isDecorationView;
- (BOOL)_isEquivalentTo:(id)arg1;
- (BOOL)_isSupplementaryView;
- (BOOL)_isTransitionVisibleTo:(id)arg1;
- (id)_reuseIdentifier;
- (void)_setElementKind:(id)arg1;
- (void)_setIsClone:(BOOL)arg1;
- (void)_setReuseIdentifier:(id)arg1;
- (double)alpha;
- (CGRect)bounds;
- (CGPoint)center;
- (CGRect)frame;
- (BOOL)isFloating;
- (unsigned long long)representedElementCategory;
- (id)representedElementKind;
- (void)setAlpha:(double)arg1;
- (void)setBounds:(CGRect)arg1;
- (void)setCenter:(CGPoint)arg1;
- (void)setFrame:(CGRect)arg1;
- (void)setIndexPath:(id)arg1;
- (void)setZIndex:(long long)arg1;
- (long long)zIndex;
- (void)setIsFloating:(BOOL)arg1;
- (void)_setIndexPath:(id)arg1;
- (BOOL)isPushing;
- (CGRect)floatingFrame;
- (void)setFloatingFrame:(CGRect)arg1;
- (void)setIsPushing:(BOOL)arg1;
- (void)setVerticalOffsetFromFloatingPosition:(double)arg1;
- (double)verticalOffsetFromFloatingPosition;
@end

