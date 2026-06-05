#import "UXCollectionViewLayoutInvalidationContext+Internal.h"
#import "UXKitPrivateUtilites.h"

@interface UXCollectionViewLayoutInvalidationContext () {
    @protected
    NSMutableDictionary *_invalidatedSupplementaryViews;
    NSArray *_updateItems;
    struct {
        unsigned int invalidateDataSource : 1;
        unsigned int invalidateEverything : 1;
        unsigned int invalidateContentSize : 1;
    } _invalidationContextFlags;
}
@end

@implementation UXCollectionViewLayoutInvalidationContext

- (BOOL)invalidateEverything {
    return _invalidationContextFlags.invalidateEverything;
}

- (void)_setInvalidateEverything:(BOOL)invalidateEverything {
    _invalidationContextFlags.invalidateEverything = invalidateEverything ? 1 : 0;
}

- (BOOL)invalidateDataSourceCounts {
    return _invalidationContextFlags.invalidateDataSource;
}

- (void)_setInvalidateDataSourceCounts:(BOOL)invalidateDataSourceCounts {
    _invalidationContextFlags.invalidateDataSource = invalidateDataSourceCounts ? 1 : 0;
}

- (BOOL)invalidateContentSize {
    return _invalidationContextFlags.invalidateContentSize;
}

- (void)setInvalidateContentSize:(BOOL)invalidateContentSize {
    _invalidationContextFlags.invalidateContentSize = invalidateContentSize ? 1 : 0;
}

- (NSArray *)_updateItems {
    return _updateItems;
}

- (void)_setUpdateItems:(NSArray *)updateItems {
    if (_updateItems != updateItems) {
        _updateItems = [updateItems copy];
    }
}

- (NSDictionary *)_invalidatedSupplementaryViews {
    return _invalidatedSupplementaryViews;
}

- (void)_setInvalidatedSupplementaryViews:(NSDictionary *)invalidatedSupplementaryViews {
    _invalidatedSupplementaryViews = [[NSMutableDictionary alloc] initWithDictionary:invalidatedSupplementaryViews];
}

- (void)_invalidateSupplementaryElementsOfKind:(NSString *)elementKind atIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (elementKind && indexPaths) {
        if (_invalidatedSupplementaryViews) {
            NSArray *existing = [_invalidatedSupplementaryViews objectForKey:elementKind];
            if (existing) {
                NSMutableSet *merged = [NSMutableSet setWithArray:indexPaths];
                [merged addObjectsFromArray:existing];
                [_invalidatedSupplementaryViews setObject:[merged allObjects] forKey:elementKind];
            } else {
                [_invalidatedSupplementaryViews setObject:indexPaths forKey:elementKind];
            }
        } else {
            _invalidatedSupplementaryViews = [[NSMutableDictionary alloc] initWithObjectsAndKeys:indexPaths, elementKind, nil];
        }
    }
}

@end
