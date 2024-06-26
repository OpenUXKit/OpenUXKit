/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import "UXView.h"
#import <Cocoa/Cocoa.h>

@class NSString, NSImage;

@interface UXImageView : UXView <NSAccessibilityImage> {

	double _backingScaleFactor;
	CGSize _proposedSize;
	BOOL _allowsVibrancy;
	BOOL _highlighted;
	NSString* accessibilityLabel;
	NSImage* _image;
	NSImage* _highlightedImage;

}

@property (nonatomic, strong) NSString *accessibilityLabel; 
@property (nonatomic, readonly) NSImage *_currentImage; 
@property (nonatomic, strong) NSImage *image;                              //@synthesize image=_image - In the implementation block
@property (nonatomic, strong) NSImage *highlightedImage;                   //@synthesize highlightedImage=_highlightedImage - In the implementation block
@property (getter=isHighlighted, nonatomic) BOOL highlighted;              //@synthesize highlighted=_highlighted - In the implementation block
@property (nonatomic) BOOL allowsVibrancy;                                 //@synthesize allowsVibrancy=_allowsVibrancy - In the implementation block
@property (readonly) unsigned long long hash; 
@property (readonly) Class superclass; 
@property (copy, readonly) NSString *description; 
@property (copy, readonly) NSString *debugDescription; 
- (void)setImage:(id)arg1;
- (id)image;
- (void)setHighlighted:(BOOL)arg1;
- (id)_currentImage;
- (id)accessibilityLabel;
- (BOOL)allowsVibrancy;
- (id)highlightedImage;
- (id)initWithFrame:(CGRect)arg1;
- (id)initWithImage:(id)arg1;
- (CGSize)intrinsicContentSize;
- (BOOL)isHighlighted;
- (void)setAccessibilityLabel:(id)arg1;
- (void)setAllowsVibrancy:(BOOL)arg1;
- (void)setFrameSize:(CGSize)arg1;
- (void)setHighlightedImage:(id)arg1;
- (void)sizeToFit;
- (void)viewDidChangeBackingProperties;
- (void)viewDidChangeEffectiveAppearance;
- (void)viewWillMoveToWindow:(id)arg1;
- (void)_updateLayerContents;
- (id)initWithImage:(id)arg1 highlightedImage:(id)arg2;
- (CGSize)_proposedSize;
- (void)_setContentStretchInPixels:(CGRect)arg1 forContentSize:(CGSize)arg2 shouldTile:(BOOL)arg3;
- (void)_updateBackingScaleFactorForWindow:(id)arg1;
- (void)_updateForCurrentImage;
- (void)_updateLayerContentsForWindow:(id)arg1;
- (void)_updateProposedSize;
@end

