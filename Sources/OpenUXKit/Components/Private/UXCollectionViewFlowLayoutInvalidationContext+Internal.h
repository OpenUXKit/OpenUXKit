#import "UXCollectionViewFlowLayoutInvalidationContext.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXCollectionViewFlowLayoutInvalidationContext () {
    struct {
        unsigned int invalidateDelegateMetrics : 1;
        unsigned int invalidateAttributes : 1;
    } _flowLayoutInvalidationFlags;
}

@end

NS_HEADER_AUDIT_END(nullability, sendability)
