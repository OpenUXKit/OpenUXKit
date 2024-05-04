

#import <objc/NSObject.h>

@class NSArray, NSMutableDictionary;

@interface UXCollectionViewLayoutInvalidationContext : NSObject
{
    NSMutableDictionary *_invalidatedSupplementaryViews;	// 8 = 0x8
    NSArray *_updateItems;	// 16 = 0x10
    struct {
        unsigned int invalidateDataSource:1;
        unsigned int invalidateEverything:1;
        unsigned int invalidateContentSize:1;
    } _invalidationContextFlags;	// 24 = 0x18
}

- (id)_updateItems;
- (void)_setUpdateItems:(id)arg1;
- (void)setInvalidateContentSize:(BOOL)arg1;
- (BOOL)invalidateContentSize;
- (void)_setInvalidateEverything:(BOOL)arg1;
@property(readonly, nonatomic) BOOL invalidateEverything;
- (void)_setInvalidateDataSourceCounts:(BOOL)arg1;
@property(readonly, nonatomic) BOOL invalidateDataSourceCounts;
- (void)_invalidateSupplementaryElementsOfKind:(id)arg1 atIndexPaths:(id)arg2;
- (void)_setInvalidatedSupplementaryViews:(id)arg1;
- (id)_invalidatedSupplementaryViews;
- (void)dealloc;

@end

