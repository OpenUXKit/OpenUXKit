

#import <Foundation/NSIndexPath.h>

@interface NSIndexPath (UXCollectionViewAdditions)
+ (id)indexPathForItem:(NSInteger)arg1 inSection:(NSInteger)arg2;
+ (id)indexPathForRow:(NSInteger)arg1 inSection:(NSInteger)arg2;
@property(readonly, nonatomic) NSInteger section;
@property(readonly, nonatomic) NSInteger item;
@property(readonly, nonatomic) NSInteger row;
@end

