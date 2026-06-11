#import "UXCollectionViewData.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionViewLayoutAttributes;

// Internal SPI mirrored from UXKit 26.4 (see IDA-Notes/P5-Data.md).
@interface UXCollectionViewData ()

- (void)_prepareToLoadData;
- (void)_validateItemCounts;
- (void)_updateItemCounts;
- (void)_validateContentSize;

// Fills every missing slot of the global items cache, then marks the whole
// content rect as validated. UXKit reuses one UIMutableIndexPath instance for
// the loop; OpenUXKit recreates immutable NSIndexPath instances instead.
- (void)_loadEverything;

// Stores a copy of the attributes in the global items cache and registers the
// global index into every screen page overlapped by the attributes frame.
- (void)_setLayoutAttributes:(nullable UXCollectionViewLayoutAttributes *)layoutAttributes atGlobalItemIndex:(NSInteger)globalItemIndex;

// Rewrites *indexPath with the (section, item) pair for the global item index.
// Leaves *indexPath untouched when the index is beyond the total item count.
// UXKit mutates a preallocated UIMutableIndexPath in place through
// +[UIMutableIndexPath setIndex:atPosition:forIndexPath:]; OpenUXKit has no
// mutable NSIndexPath SPI, so it replaces the object wholesale.
- (void)_setupMutableIndexPath:(NSIndexPath * _Nullable __strong * _Nonnull)indexPath forGlobalItemIndex:(NSInteger)globalItemIndex;

// Returns the mutable set of global item indexes registered on the screen page
// containing `point`, creating it on demand. Returns nil when the page rect
// does not intersect the currently validated layout rect.
- (nullable NSMutableIndexSet *)_screenPageForPoint:(CGPoint)point;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
