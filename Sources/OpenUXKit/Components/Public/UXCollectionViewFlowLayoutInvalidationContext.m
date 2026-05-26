#import <OpenUXKit/UXCollectionViewFlowLayoutInvalidationContext.h>

@interface UXCollectionViewFlowLayoutInvalidationContext () {
    struct {
        unsigned int invalidateDelegateMetrics : 1;
        unsigned int invalidateAttributes : 1;
    } _flowLayoutInvalidationFlags;
}
@end

@implementation UXCollectionViewFlowLayoutInvalidationContext

- (instancetype)init {
    self = [super init];
    if (self) {
        _flowLayoutInvalidationFlags.invalidateDelegateMetrics = 1;
        _flowLayoutInvalidationFlags.invalidateAttributes = 1;
    }
    return self;
}

- (BOOL)invalidateFlowLayoutDelegateMetrics {
    return _flowLayoutInvalidationFlags.invalidateDelegateMetrics;
}

- (void)setInvalidateFlowLayoutDelegateMetrics:(BOOL)invalidateFlowLayoutDelegateMetrics {
    _flowLayoutInvalidationFlags.invalidateDelegateMetrics = invalidateFlowLayoutDelegateMetrics ? 1 : 0;
}

- (BOOL)invalidateFlowLayoutAttributes {
    return _flowLayoutInvalidationFlags.invalidateAttributes;
}

- (void)setInvalidateFlowLayoutAttributes:(BOOL)invalidateFlowLayoutAttributes {
    _flowLayoutInvalidationFlags.invalidateAttributes = invalidateFlowLayoutAttributes ? 1 : 0;
}

@end
