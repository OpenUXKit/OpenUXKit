#import <OpenUXKit/UXCollectionViewFlowLayout.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@protocol UXCollectionViewDelegateFlowLayout;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXTableLayout : UXCollectionViewFlowLayout

@property (nonatomic) BOOL floatingHeadersDisabled;
@property (nonatomic) BOOL showsSectionHeaderForSingleSection;
@property (nonatomic) BOOL showsSectionFooterForSingleSection;

@property (nonatomic, readonly, nullable) id<UXCollectionViewDelegateFlowLayout> delegateFlowLayout;
@property (nonatomic, readonly) NSMutableArray *layoutAttributesArray;
@property (nonatomic, readonly) NSMutableDictionary *headerAttributesByIndexPath;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
