#import <AppKit/AppKit.h>
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionViewUpdateItem;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewUpdateGap : NSObject

@property (nonatomic, strong, nullable) UXCollectionViewUpdateItem *firstUpdateItem;
@property (nonatomic, strong, nullable) UXCollectionViewUpdateItem *lastUpdateItem;
@property (nonatomic, readonly) NSArray<UXCollectionViewUpdateItem *> *updateItems;
@property (nonatomic, readonly) NSArray<UXCollectionViewUpdateItem *> *deleteItems;
@property (nonatomic, readonly) NSArray<UXCollectionViewUpdateItem *> *insertItems;
@property (nonatomic, readonly) BOOL isDeleteBasedGap;
@property (nonatomic, readonly) BOOL hasInserts;
@property (nonatomic, readonly) BOOL isSectionBasedGap;
@property (nonatomic) CGRect beginningRect;
@property (nonatomic) CGRect endingRect;

+ (instancetype)gapWithUpdateItem:(UXCollectionViewUpdateItem *)updateItem;

- (void)addUpdateItem:(UXCollectionViewUpdateItem *)updateItem;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
