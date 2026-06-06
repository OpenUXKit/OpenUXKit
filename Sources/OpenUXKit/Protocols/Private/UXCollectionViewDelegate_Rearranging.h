#import <AppKit/AppKit.h>
#import "UXKitDefines.h"
#import "UXCollectionViewDelegate.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionView;

NS_SWIFT_UI_ACTOR
@protocol UXCollectionViewDelegate_Rearranging <UXCollectionViewDelegate>

@optional
- (BOOL)collectionView:(UXCollectionView *)collectionView shouldBeginDraggingSessionWithClickedItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSImage *)collectionView:(UXCollectionView *)collectionView imageForDraggedItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable id<NSPasteboardWriting>)collectionView:(UXCollectionView *)collectionView pasteboardWriterForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSDraggingItem *)collectionView:(UXCollectionView *)collectionView draggingItemForIndexPath:(NSIndexPath *)indexPath proposedDraggingItem:(NSDraggingItem *)proposedDraggingItem;
- (NSDraggingFormation)collectionView:(UXCollectionView *)collectionView preferredDraggingFormationForIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (nullable NSString *)dragSourceIdentifierForCollectionView:(UXCollectionView *)collectionView;
- (void)collectionView:(UXCollectionView *)collectionView createdDraggingSession:(NSDraggingSession *)session forItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (NSDragOperation)collectionView:(UXCollectionView *)collectionView draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context;
- (void)collectionView:(UXCollectionView *)collectionView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint;
- (void)collectionView:(UXCollectionView *)collectionView draggingSession:(NSDraggingSession *)session movedToPoint:(NSPoint)screenPoint;
- (void)collectionView:(UXCollectionView *)collectionView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint dragOperation:(NSDragOperation)operation;
- (BOOL)collectionView:(UXCollectionView *)collectionView prepareForDragOperation:(id<NSDraggingInfo>)draggingInfo;
- (BOOL)collectionView:(UXCollectionView *)collectionView performDragOperation:(id<NSDraggingInfo>)draggingInfo;
- (NSDragOperation)collectionView:(UXCollectionView *)collectionView draggingEntered:(id<NSDraggingInfo>)draggingInfo;
- (NSDragOperation)collectionView:(UXCollectionView *)collectionView draggingUpdated:(id<NSDraggingInfo>)draggingInfo;
- (void)collectionView:(UXCollectionView *)collectionView draggingExited:(nullable id<NSDraggingInfo>)draggingInfo;
- (void)collectionView:(UXCollectionView *)collectionView draggingEnded:(id<NSDraggingInfo>)draggingInfo;
- (BOOL)collectionViewUpdatesLayoutOnDrag:(UXCollectionView *)collectionView;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
