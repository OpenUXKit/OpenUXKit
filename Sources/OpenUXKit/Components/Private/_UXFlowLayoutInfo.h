#import <Foundation/Foundation.h>
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class _UXFlowLayoutSection;

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXFlowLayoutInfo : NSObject <NSCopying>

@property (nonatomic, readonly) NSMutableArray<_UXFlowLayoutSection *> *sections;
@property (nonatomic) BOOL usesFloatingHeaderFooter;
@property (nonatomic) CGFloat dimension;
@property (nonatomic) BOOL horizontal;
@property (nonatomic) BOOL leftToRight;
@property (nonatomic) CGSize contentSize;
@property (nonatomic, strong, nullable) NSDictionary *rowAlignmentOptions;

- (_UXFlowLayoutSection *)addSection;
- (_UXFlowLayoutInfo *)snapshot;
- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidate:(BOOL)keepSections;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
