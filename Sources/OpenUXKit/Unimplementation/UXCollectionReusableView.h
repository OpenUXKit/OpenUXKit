

#import <AppKit/NSView.h>

@class NSString, UXCollectionView, UXCollectionViewLayoutAttributes;

@interface UXCollectionReusableView : NSView
{
    UXCollectionViewLayoutAttributes *_layoutAttributes;	// 112 = 0x70
    NSString *_reuseIdentifier;	// 120 = 0x78
    UXCollectionView *_collectionView;	// 128 = 0x80
    struct {
        unsigned int updateAnimationCount:5;
        unsigned int wasDequeued:1;
    } _reusableViewFlags;	// 136 = 0x88
    BOOL _isFloatingPinned;	// 140 = 0x8c
}

@property(readonly, nonatomic) BOOL isFloatingPinned; // @synthesize isFloatingPinned=_isFloatingPinned;
@property(readonly, copy, nonatomic) NSString *reuseIdentifier; // @synthesize reuseIdentifier=_reuseIdentifier;
- (id)description;
- (struct CGImage *)_snapshot:(BOOL)arg1;
- (BOOL)_wasDequeued;
- (void)_markAsDequeued;
- (void)_clearUpdateAnimation;
- (void)_addUpdateAnimation;
- (BOOL)_isInUpdateAnimation;
- (void)setIsFloatingPinned:(BOOL)arg1;
- (void)_setCollectionView:(id)arg1;
- (id)_collectionView;
- (void)_setReuseIdentifier:(id)arg1;
- (id)_layoutAttributes;
- (void)_setLayoutAttributes:(id)arg1;
- (void)_setBaseLayoutAttributes:(id)arg1;
- (void)didTransitionFromLayout:(id)arg1 toLayout:(id)arg2;
- (void)willTransitionFromLayout:(id)arg1 toLayout:(id)arg2;
- (void)applyLayoutAttributes:(id)arg1;
- (void)prepareForReuse;
- (BOOL)wantsUpdateLayer;
- (void)dealloc;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)initWithFrame:(CGRect)arg1;
- (id)_layoutSectionAccessibility;
- (id)_accessibilityIndexPath;
- (id)_accessibilityDefaultRole;
- (id)_dynamicAccessibilityParent;
- (BOOL)accessibilityPerformScrollToVisible;
- (void)accessibilityPerformAction:(id)arg1;
- (id)accessibilityActionDescription:(id)arg1;
- (id)accessibilityActionNames;
- (id)accessibilityAttributeValue:(id)arg1;
- (id)accessibilityAttributeNames;
- (id)accessibilityRole;
- (id)accessibilityParent;

@end

