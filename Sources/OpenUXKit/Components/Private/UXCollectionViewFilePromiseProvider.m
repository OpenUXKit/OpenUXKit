#import "UXCollectionViewFilePromiseProvider.h"

@interface UXCollectionViewFilePromiseProvider () {
    NSMutableArray<NSFilePromiseProvider *> *_auxiliaryFilePromiseProviders;
}
@end

@implementation UXCollectionViewFilePromiseProvider

- (void)addAuxiliaryFilePromiseProvider:(NSFilePromiseProvider *)provider {
    if (!provider) {
        return;
    }
    if (!_auxiliaryFilePromiseProviders) {
        _auxiliaryFilePromiseProviders = [[NSMutableArray alloc] init];
    }
    [_auxiliaryFilePromiseProviders addObject:provider];
}

- (NSArray<NSFilePromiseProvider *> *)auxiliaryFilePromiseProviders {
    NSArray *copy = [_auxiliaryFilePromiseProviders copy];
    return copy ?: @[];
}

@end
