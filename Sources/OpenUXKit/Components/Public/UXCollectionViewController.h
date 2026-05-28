#import <OpenUXKit/UXViewController.h>
#import <OpenUXKit/UXCollectionView.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionViewLayout;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewController : UXViewController <UXCollectionViewDataSource, UXCollectionViewDelegate>

+ (Class)collectionViewClass;

- (instancetype)initWithCollectionViewLayout:(UXCollectionViewLayout *)layout;

@property (nonatomic, strong) UXCollectionView *collectionView;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
