#import "UXCollectionView.h"
#import "_UXCollectionViewOverdraw.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

NS_SWIFT_UI_ACTOR
@interface _UXCollectionView : UXCollectionView <_UXCollectionViewOverdraw>

@property (nonatomic) BOOL overdrawEnabled;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
