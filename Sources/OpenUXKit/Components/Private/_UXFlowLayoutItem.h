#import <Foundation/Foundation.h>
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class _UXFlowLayoutSection, _UXFlowLayoutRow;

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXFlowLayoutItem : NSObject <NSCopying>

@property (nonatomic, assign, nullable) _UXFlowLayoutSection *section;
@property (nonatomic, assign, nullable) _UXFlowLayoutRow *rowObject;
@property (nonatomic) CGRect itemFrame;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
