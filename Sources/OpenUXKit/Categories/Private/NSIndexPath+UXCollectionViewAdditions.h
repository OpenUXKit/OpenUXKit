#import <Foundation/Foundation.h>
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSIndexPath (UXCollectionViewAdditions)

@property (nonatomic, readonly) NSInteger item;
@property (nonatomic, readonly) NSInteger section;
@property (nonatomic, readonly) NSInteger row;

+ (instancetype)indexPathForItem:(NSInteger)item inSection:(NSInteger)section;
+ (instancetype)indexPathForRow:(NSInteger)row inSection:(NSInteger)section;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
