#import "UXTableLayout.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@protocol UXCollectionViewDelegateFlowLayout;

@interface UXTableLayout ()

@property (nonatomic, readonly, nullable) id<UXCollectionViewDelegateFlowLayout> delegateFlowLayout;
@property (nonatomic, readonly) NSMutableArray *layoutAttributesArray;
@property (nonatomic, readonly) NSMutableDictionary *headerAttributesByIndexPath;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
