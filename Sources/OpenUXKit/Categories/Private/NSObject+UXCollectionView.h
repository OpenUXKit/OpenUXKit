#import <Foundation/Foundation.h>
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSObject (UXCollectionView)

- (void)performWithoutAnimation:(void (NS_NOESCAPE ^)(void))animation;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
