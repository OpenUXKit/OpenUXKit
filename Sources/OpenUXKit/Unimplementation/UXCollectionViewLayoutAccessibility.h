

#import <AppKit/NSAccessibilityElement.h>

@class NSArray, NSMutableArray, UXCollectionView, UXCollectionViewLayout;

@interface UXCollectionViewLayoutAccessibility : NSAccessibilityElement
{
    NSArray *_accessibilityVisibleChildren;	// 8 = 0x8
    UXCollectionViewLayout *_layout;	// 16 = 0x10
    NSUInteger __sectionCacheOffset;	// 24 = 0x18
    NSMutableArray *__sectionCache;	// 32 = 0x20
}

+ (Class)sectionAccessibilityClass;

@property(strong, nonatomic) NSMutableArray *_sectionCache; // @synthesize _sectionCache=__sectionCache;
@property(nonatomic) NSUInteger _sectionCacheOffset; // @synthesize _sectionCacheOffset=__sectionCacheOffset;
@property(nonatomic) __weak UXCollectionViewLayout *layout; // @synthesize layout=_layout;
- (id)_dequeueSectionWithIndex:(NSUInteger)arg1;
- (void)_trimSectionCacheToVisibleSections:(id)arg1;
- (id)_visibleSections;
- (void)accessibilityPostNotification:(id)arg1;
@property(copy, nonatomic) NSArray *accessibilitySelectedCells; // @dynamic accessibilitySelectedCells;
- (id)accessibilityArrayAttributeValues:(id)arg1 index:(NSUInteger)arg2 maxCount:(NSUInteger)arg3;
- (NSUInteger)accessibilityArrayAttributeCount:(id)arg1;
- (NSUInteger)accessibilityIndexOfChild:(id)arg1;
- (id)accessibilityChildren;
@property(readonly, copy, nonatomic) NSArray *accessibilityVisibleChildren; // @synthesize accessibilityVisibleChildren=_accessibilityVisibleChildren;
- (CGRect)accessibilityFrameInParentSpace;
- (CGRect)accessibilityFrame;
- (NSInteger)accessibilityColumnCount;
- (NSInteger)accessibilityRowCount;
- (id)accessibilityLabel;
- (id)accessibilityRoleDescription;
- (id)accessibilityIdentifier;
- (id)accessibilitySubrole;
- (id)accessibilityRole;
- (id)accessibilityParent;
- (id)accessibilityHitTest:(CGPoint)arg1;
- (id)nextSectionForSection:(id)arg1;
- (id)previousSectionForSection:(id)arg1;
- (id)accessibilityParentForCell:(id)arg1;
- (id)accessibilityParentForReusableView:(id)arg1;
- (void)_dumpVisibleChildren;
- (void)accessibilityPrepareLayout;
- (void)accessibilityInvalidateLayout;
- (void)accessibilityDidEndScrolling;
- (void)accessibilityPrepareForCollectionViewUpdates:(id)arg1;
@property(readonly, nonatomic) __weak UXCollectionView *collectionView;
- (id)initWithLayout:(id)arg1;

@end

