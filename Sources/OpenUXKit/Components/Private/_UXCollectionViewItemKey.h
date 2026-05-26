#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionViewLayoutAttributes;

typedef NS_ENUM(NSUInteger, UXCollectionViewItemType) {
    UXCollectionViewItemTypeCell = 1,
    UXCollectionViewItemTypeSupplementaryView = 2,
    UXCollectionViewItemTypeDecorationView = 3,
};

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXCollectionViewItemKey : NSObject <NSCopying>

@property (nonatomic, readonly) UXCollectionViewItemType type;
@property (nonatomic, strong, readonly) NSIndexPath *indexPath;
@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, readonly) BOOL isClone;

+ (instancetype)collectionItemKeyForCellWithIndexPath:(NSIndexPath *)indexPath;
+ (instancetype)collectionItemKeyForSupplementaryViewOfKind:(NSString *)kind andIndexPath:(NSIndexPath *)indexPath;
+ (instancetype)collectionItemKeyForDecorationViewOfKind:(NSString *)kind andIndexPath:(NSIndexPath *)indexPath;
+ (instancetype)collectionItemKeyForLayoutAttributes:(UXCollectionViewLayoutAttributes *)layoutAttributes;

- (instancetype)initWithType:(UXCollectionViewItemType)type indexPath:(NSIndexPath *)indexPath identifier:(NSString *)identifier;
- (instancetype)initWithType:(UXCollectionViewItemType)type indexPath:(NSIndexPath *)indexPath identifier:(NSString *)identifier clone:(BOOL)clone;
- (instancetype)copyAsClone:(BOOL)clone;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
