#import <AppKit/AppKit.h>
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionView, UXCollectionViewLayoutAccessibility;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewLayoutSectionAccessibility : NSAccessibilityElement

- (instancetype)initWithLayoutAccessibility:(UXCollectionViewLayoutAccessibility *)layoutAccessibility;

@property (nonatomic, weak, readonly, nullable) UXCollectionViewLayoutAccessibility *layoutAccessibility;
@property (nonatomic, weak, readonly, nullable) UXCollectionView *collectionView;
@property (nonatomic, readonly) NSUInteger sectionIndex;
@property (nonatomic, copy, nullable) NSArray *accessibilityVisibleChildren;

- (NSComparisonResult)compare:(UXCollectionViewLayoutSectionAccessibility *)other;

- (nullable id)siblingBeforeItem:(id)item;
- (nullable id)siblingAfterItem:(id)item;
- (nullable id)siblingAboveItem:(id)item;
- (nullable id)siblingBelowItem:(id)item;
- (nullable id)_siblingInDirection:(NSUInteger)direction item:(id)item;

- (nullable NSArray *)visibleSupplementaryViewsInSection:(NSInteger)section;
- (nullable NSArray *)visibleCellsInSection:(NSInteger)section;

- (void)_dumpVisibleChildren;
- (void)accessibilityPrepareLayout;
- (void)accessibilityInvalidateLayout;
- (void)accessibilityPrepareForCollectionViewUpdates;
- (void)accessibilityDidEndScrolling;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
