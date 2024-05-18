/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import "UXCollectionReusableView.h"

@class NSMutableArray, UXLabel, UXView;

@interface UXTableViewHeaderFooterView : UXCollectionReusableView {

	NSMutableArray* _constraints;
	UXLabel* _textLabel;
	UXLabel* _detailTextLabel;
	UXView* _contentView;
	UXView* _backgroundView;

}

@property (nonatomic, strong) UXLabel *textLabel;                    //@synthesize textLabel=_textLabel - In the implementation block
@property (nonatomic, strong) UXLabel *detailTextLabel;              //@synthesize detailTextLabel=_detailTextLabel - In the implementation block
@property (nonatomic, strong) UXView *contentView;                   //@synthesize contentView=_contentView - In the implementation block
@property (nonatomic, strong) UXView *backgroundView;                //@synthesize backgroundView=_backgroundView - In the implementation block
- (id)initWithCoder:(id)arg1;
- (void)prepareForReuse;
- (void)setContentView:(id)arg1;
- (id)backgroundView;
- (id)contentView;
- (id)initWithFrame:(CGRect)arg1;
- (void)setBackgroundView:(id)arg1;
- (void)updateConstraints;
- (id)initWithReuseIdentifier:(id)arg1;
- (id)detailTextLabel;
- (void)setDetailTextLabel:(id)arg1;
- (void)setTextLabel:(id)arg1;
- (id)textLabel;
@end

