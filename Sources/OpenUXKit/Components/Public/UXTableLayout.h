#import "UXCollectionViewFlowLayout.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXTableLayout : UXCollectionViewFlowLayout

@property (nonatomic) BOOL floatingHeadersDisabled;
@property (nonatomic) BOOL showsSectionHeaderForSingleSection;
@property (nonatomic) BOOL showsSectionFooterForSingleSection;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
