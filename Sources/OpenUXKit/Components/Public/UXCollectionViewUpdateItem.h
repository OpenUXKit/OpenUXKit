#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class NSIndexPath;

typedef NS_ENUM(NSInteger, UXCollectionUpdateAction) {
    UXCollectionUpdateActionInsert = 0,
    UXCollectionUpdateActionDelete = 1,
    UXCollectionUpdateActionReload = 2,
    UXCollectionUpdateActionMove = 3,
    UXCollectionUpdateActionNone = 4,
} NS_SWIFT_NAME(UXCollectionViewUpdateItem.Action);

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewUpdateItem : NSObject

@property (nonatomic, strong, readonly, nullable) NSIndexPath *indexPathBeforeUpdate;
@property (nonatomic, strong, readonly, nullable) NSIndexPath *indexPathAfterUpdate;
@property (nonatomic, readonly) UXCollectionUpdateAction updateAction;

- (instancetype)initWithInitialIndexPath:(nullable NSIndexPath *)initialIndexPath finalIndexPath:(nullable NSIndexPath *)finalIndexPath updateAction:(UXCollectionUpdateAction)updateAction;
- (instancetype)initWithAction:(UXCollectionUpdateAction)action forIndexPath:(NSIndexPath *)indexPath;
- (instancetype)initWithOldIndexPath:(nullable NSIndexPath *)oldIndexPath newIndexPath:(nullable NSIndexPath *)newIndexPath;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
