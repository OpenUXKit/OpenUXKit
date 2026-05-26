#import <OpenUXKit/UXCollectionViewLayoutInvalidationContext.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewFlowLayoutInvalidationContext : UXCollectionViewLayoutInvalidationContext

@property (nonatomic) BOOL invalidateFlowLayoutDelegateMetrics;
@property (nonatomic) BOOL invalidateFlowLayoutAttributes;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
