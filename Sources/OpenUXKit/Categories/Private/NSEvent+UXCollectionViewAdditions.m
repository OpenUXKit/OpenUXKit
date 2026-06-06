#import "NSEvent+UXCollectionViewAdditions.h"

@implementation NSEvent (UXCollectionViewAdditions)

- (CGPoint)pointForLayoutOfCollectionView:(UXCollectionView *)collectionView {
    NSView *documentView = [(id)collectionView documentView];
    return [documentView convertPoint:[self locationInWindow] fromView:nil];
}

@end
