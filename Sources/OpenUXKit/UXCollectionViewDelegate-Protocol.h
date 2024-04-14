//
//     Generated by classdump-c 4.2.0 (64 bit) (iOS port by DreamDevLost, Updated by Kevin Bradley.)(Debug version compiled Feb 25 2024 00:55:05).
//
//  Copyright (C) 1997-2019 Steve Nygard. Updated in 2022 by Kevin Bradley.
//

#import <AppKit/AppKit.h>

@class NSArray, NSEvent, NSIndexPath, NSString, UXCollectionReusableView, UXCollectionView, UXCollectionViewCell;

@protocol UXCollectionViewDelegate <NSObject>

@optional
- (CGPoint)collectionView:(UXCollectionView *)arg1 targetContentOffsetOnResizeForProposedContentOffset:(CGPoint)arg2;
- (void)collectionView:(UXCollectionView *)arg1 didPrepareForOverdraw:(CGRect)arg2;
- (void)collectionView:(UXCollectionView *)arg1 itemWasRightClickedAtIndexPath:(NSIndexPath *)arg2 withEvent:(NSEvent *)arg3;
- (void)collectionView:(UXCollectionView *)arg1 itemWasDoubleClickedAtIndexPath:(NSIndexPath *)arg2 withEvent:(NSEvent *)arg3;
- (void)collectionView:(UXCollectionView *)arg1 mouseDownWithEvent:(NSEvent *)arg2;
- (void)collectionView:(UXCollectionView *)arg1 didEndDisplayingSupplementaryView:(UXCollectionReusableView *)arg2 forElementOfKind:(NSString *)arg3 atIndexPath:(NSIndexPath *)arg4;
- (void)collectionView:(UXCollectionView *)arg1 didEndDisplayingCell:(UXCollectionViewCell *)arg2 forItemAtIndexPath:(NSIndexPath *)arg3;
- (void)collectionView:(UXCollectionView *)arg1 willDisplayCell:(UXCollectionViewCell *)arg2 forItemAtIndexPath:(NSIndexPath *)arg3;
- (void)collectionView:(UXCollectionView *)arg1 indexPathsForSelectedItemsDidAdd:(NSArray *)arg2 remove:(NSArray *)arg3 animated:(BOOL)arg4;
- (void)collectionView:(UXCollectionView *)arg1 indexPathsForSelectedItemsWillAdd:(NSArray *)arg2 remove:(NSArray *)arg3 animated:(BOOL)arg4;
- (void)collectionView:(UXCollectionView *)arg1 didDeselectItemAtIndexPath:(NSIndexPath *)arg2;
- (void)collectionView:(UXCollectionView *)arg1 didSelectItemAtIndexPath:(NSIndexPath *)arg2;
- (BOOL)collectionView:(UXCollectionView *)arg1 shouldDeselectItemAtIndexPath:(NSIndexPath *)arg2;
- (BOOL)collectionView:(UXCollectionView *)arg1 shouldSelectItemAtIndexPath:(NSIndexPath *)arg2;
- (void)collectionViewDidEndDecelerating:(UXCollectionView *)arg1;
- (void)collectionViewWillBeginDecelerating:(UXCollectionView *)arg1 targetContentOffset:(CGPoint)arg2;
- (void)collectionViewDidEndScrollingAnimation:(UXCollectionView *)arg1;
- (void)collectionViewDidEndScrolling:(UXCollectionView *)arg1;
- (void)collectionViewDidScroll:(UXCollectionView *)arg1;
- (void)collectionViewWillBeginScrolling:(UXCollectionView *)arg1;
@end

