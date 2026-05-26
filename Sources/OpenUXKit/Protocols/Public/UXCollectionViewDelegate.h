#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionView, UXCollectionViewCell, UXCollectionReusableView;

NS_SWIFT_UI_ACTOR
@protocol UXCollectionViewDelegate <NSObject>

@optional
- (BOOL)collectionView:(UXCollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)collectionView:(UXCollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UXCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UXCollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UXCollectionView *)collectionView willDisplayCell:(UXCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UXCollectionView *)collectionView didEndDisplayingCell:(UXCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UXCollectionView *)collectionView didEndDisplayingSupplementaryView:(UXCollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UXCollectionView *)collectionView didPrepareForOverdraw:(CGRect)overdraw;
- (void)collectionView:(UXCollectionView *)collectionView indexPathsForSelectedItemsDidAdd:(NSArray<NSIndexPath *> *)added remove:(NSArray<NSIndexPath *> *)removed animated:(BOOL)animated;
- (void)collectionView:(UXCollectionView *)collectionView indexPathsForSelectedItemsWillAdd:(NSArray<NSIndexPath *> *)added remove:(NSArray<NSIndexPath *> *)removed animated:(BOOL)animated;
- (void)collectionView:(UXCollectionView *)collectionView itemWasDoubleClickedAtIndexPath:(NSIndexPath *)indexPath withEvent:(NSEvent *)event;
- (void)collectionView:(UXCollectionView *)collectionView itemWasRightClickedAtIndexPath:(NSIndexPath *)indexPath withEvent:(NSEvent *)event;
- (void)collectionView:(UXCollectionView *)collectionView mouseDownWithEvent:(NSEvent *)event;
- (CGPoint)collectionView:(UXCollectionView *)collectionView targetContentOffsetOnResizeForProposedContentOffset:(CGPoint)proposedContentOffset;
- (void)collectionViewDidScroll:(UXCollectionView *)collectionView;
- (void)collectionViewWillBeginScrolling:(UXCollectionView *)collectionView;
- (void)collectionViewDidEndScrolling:(UXCollectionView *)collectionView;
- (void)collectionViewDidEndScrollingAnimation:(UXCollectionView *)collectionView;
- (void)collectionViewWillBeginDecelerating:(UXCollectionView *)collectionView targetContentOffset:(CGPoint)targetContentOffset;
- (void)collectionViewDidEndDecelerating:(UXCollectionView *)collectionView;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
