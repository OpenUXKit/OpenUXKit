

#import <AppKit/NSAccessibilityElement.h>

@class NSArray, UXCollectionView, UXCollectionViewLayoutAccessibility;

@interface UXCollectionViewLayoutSectionAccessibility : NSAccessibilityElement
{
    NSArray *_accessibilityVisibleChildren;	// 8 = 0x8
}


- (void)setAccessibilityVisibleChildren:(id)arg1;
- (id)description;
- (BOOL)accessibilityPerformScrollToVisible;
- (void)accessibilityPerformAction:(id)arg1;
- (id)accessibilityActionDescription:(id)arg1;
- (id)accessibilityActionNames;
- (id)accessibilityAttributeValue:(id)arg1;
- (id)accessibilityAttributeNames;
- (id)accessibilityArrayAttributeValues:(id)arg1 index:(NSUInteger)arg2 maxCount:(NSUInteger)arg3;
- (NSUInteger)accessibilityArrayAttributeCount:(id)arg1;
- (NSUInteger)accessibilityIndexOfChild:(id)arg1;
- (id)accessibilityVisibleChildren;
- (id)accessibilityChildren;
- (CGRect)accessibilityFrame;
- (id)accessibilitySubrole;
- (id)accessibilityRole;
- (id)accessibilityHitTest:(CGPoint)arg1;
- (NSInteger)compare:(id)arg1;
- (id)_siblingInDirection:(NSUInteger)arg1 item:(id)arg2;
- (id)siblingBelowItem:(id)arg1;
- (id)siblingAboveItem:(id)arg1;
- (id)siblingAfterItem:(id)arg1;
- (id)siblingBeforeItem:(id)arg1;
- (id)visibleCellsInSection:(NSInteger)arg1;
- (id)visibleSupplementaryViewsInSection:(NSInteger)arg1;
- (void)_dumpVisibleChildren;
- (void)accessibilityPrepareLayout;
- (void)accessibilityInvalidateLayout;
- (void)accessibilityPrepareForCollectionViewUpdates;
- (void)accessibilityDidEndScrolling;
@property(readonly, nonatomic) NSUInteger sectionIndex;
@property(readonly, nonatomic) __weak UXCollectionView *collectionView;
@property(readonly, nonatomic) __weak UXCollectionViewLayoutAccessibility *layoutAccessibility;
- (id)initWithLayoutAccessibility:(id)arg1;

@end

