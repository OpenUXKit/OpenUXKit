#import <Foundation/Foundation.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_PRIVATE
@interface UIMutableIndexPath : NSIndexPath

- (instancetype)initWithIndexes:(const NSUInteger *)indexes length:(NSUInteger)length;

+ (void)setIndex:(NSUInteger)index atPosition:(NSUInteger)position forIndexPath:(NSIndexPath *_Nonnull *_Nonnull)indexPath;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
