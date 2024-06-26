

#import <objc/NSObject.h>

@class NSIndexPath;

@interface UXCollectionViewUpdateItem : NSObject
{
    NSIndexPath *_initialIndexPath;	// 8 = 0x8
    NSIndexPath *_finalIndexPath;	// 16 = 0x10
    NSInteger _updateAction;	// 24 = 0x18
    id _gap;	// 32 = 0x20
}

@property(readonly, nonatomic) NSInteger updateAction; // @synthesize updateAction=_updateAction;
@property(readonly, strong, nonatomic) NSIndexPath *indexPathAfterUpdate; // @synthesize indexPathAfterUpdate=_finalIndexPath;
@property(readonly, strong, nonatomic) NSIndexPath *indexPathBeforeUpdate; // @synthesize indexPathBeforeUpdate=_initialIndexPath;
- (NSInteger)inverseCompareIndexPaths:(id)arg1;
- (NSInteger)compareIndexPaths:(id)arg1;
- (BOOL)_isSectionOperation;
- (void)_setGap:(id)arg1;
- (id)_gap;
- (id)_indexPath;
- (NSInteger)_action;
- (id)description;
- (void)_setNewIndexPath:(id)arg1;
- (id)_newIndexPath;
- (void)dealloc;
- (id)initWithOldIndexPath:(id)arg1 newIndexPath:(id)arg2;
- (id)initWithAction:(NSInteger)arg1 forIndexPath:(id)arg2;
- (id)initWithInitialIndexPath:(id)arg1 finalIndexPath:(id)arg2 updateAction:(NSInteger)arg3;

@end

