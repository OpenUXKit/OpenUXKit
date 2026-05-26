#import <OpenUXKit/NSIndexPath+UXCollectionViewAdditions.h>

@implementation NSIndexPath (UXCollectionViewAdditions)

+ (instancetype)indexPathForItem:(NSInteger)item inSection:(NSInteger)section {
    NSUInteger indexes[2] = {(NSUInteger)section, (NSUInteger)item};
    return [NSIndexPath indexPathWithIndexes:indexes length:2];
}

+ (instancetype)indexPathForRow:(NSInteger)row inSection:(NSInteger)section {
    return [self indexPathForItem:row inSection:section];
}

- (NSInteger)section {
    return (NSInteger)[self indexAtPosition:0];
}

- (NSInteger)item {
    return (NSInteger)[self indexAtPosition:1];
}

- (NSInteger)row {
    return [self item];
}

@end
