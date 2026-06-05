#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionView, UXCollectionViewLayout;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewLayoutAccessibility : NSAccessibilityElement

+ (Class)sectionAccessibilityClass;

- (instancetype)initWithLayout:(UXCollectionViewLayout *)layout;

@property (nonatomic, weak, nullable) UXCollectionViewLayout *layout;
@property (nonatomic, weak, readonly, nullable) UXCollectionView *collectionView;

@property (nonatomic, strong, nullable) NSMutableArray *_sectionCache;
@property (nonatomic) NSUInteger _sectionCacheOffset;
@property (nonatomic, copy, readonly, nullable) NSArray *accessibilityVisibleChildren;

- (nullable id)_dequeueSectionWithIndex:(NSUInteger)index;
- (void)_trimSectionCacheToVisibleSections:(nullable NSIndexSet *)visibleSections;
- (nullable NSIndexSet *)_visibleSections;
- (void)_dumpVisibleChildren;

- (void)accessibilityPrepareLayout;
- (void)accessibilityInvalidateLayout;
- (void)accessibilityDidEndScrolling;
- (void)accessibilityPrepareForCollectionViewUpdates:(nullable NSArray *)updateItems;

- (nullable id)nextSectionForSection:(nullable id)section;
- (nullable id)previousSectionForSection:(nullable id)section;
- (nullable id)accessibilityParentForCell:(id)cell;
- (nullable id)accessibilityParentForReusableView:(id)reusableView;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
