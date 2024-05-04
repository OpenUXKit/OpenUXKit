

@interface UXCollectionViewFlowLayoutInvalidationContext
{
    struct {
        unsigned int invalidateDelegateMetrics:1;
        unsigned int invalidateAttributes:1;
    } _flowLayoutInvalidationFlags;	// 8 = 0x8
}

@property(nonatomic) BOOL invalidateFlowLayoutDelegateMetrics;
@property(nonatomic) BOOL invalidateFlowLayoutAttributes;
- (id)init;

@end

