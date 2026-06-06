#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionViewLayoutAttributes, UXCollectionView, UXCollectionViewLayout;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionReusableView : NSView

@property (nonatomic, copy, readonly, nullable) NSString *reuseIdentifier;
@property (nonatomic, getter=isFloatingPinned) BOOL isFloatingPinned;

- (void)applyLayoutAttributes:(nullable UXCollectionViewLayoutAttributes *)layoutAttributes;
- (void)didTransitionFromLayout:(nullable UXCollectionViewLayout *)layout toLayout:(nullable UXCollectionViewLayout *)toLayout;
- (void)willTransitionFromLayout:(nullable UXCollectionViewLayout *)layout toLayout:(nullable UXCollectionViewLayout *)toLayout;
- (void)prepareForReuse;

- (BOOL)accessibilityPerformScrollToVisible;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
