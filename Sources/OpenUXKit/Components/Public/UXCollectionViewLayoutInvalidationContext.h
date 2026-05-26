#import <Foundation/Foundation.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewLayoutInvalidationContext : NSObject

@property (nonatomic, readonly) BOOL invalidateEverything;
@property (nonatomic, readonly) BOOL invalidateDataSourceCounts;
@property (nonatomic) BOOL invalidateContentSize;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
