#import <AppKit/AppKit.h>
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionView;

@interface NSEvent (UXCollectionViewAdditions)

- (CGPoint)pointForLayoutOfCollectionView:(UXCollectionView *)collectionView;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
