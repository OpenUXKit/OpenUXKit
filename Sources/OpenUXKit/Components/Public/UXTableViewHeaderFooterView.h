#import <OpenUXKit/UXCollectionReusableView.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXTableViewHeaderFooterView : UXCollectionReusableView

@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSString *detailText;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
