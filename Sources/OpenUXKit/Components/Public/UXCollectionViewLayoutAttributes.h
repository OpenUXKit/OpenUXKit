#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class NSIndexPath;

typedef NS_ENUM(NSUInteger, UXCollectionElementCategory) {
    UXCollectionElementCategoryCell,
    UXCollectionElementCategorySupplementaryView,
    UXCollectionElementCategoryDecorationView,
} NS_SWIFT_NAME(UXCollectionView.ElementCategory);

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewLayoutAttributes : NSObject <NSCopying>

+ (instancetype)layoutAttributesForCellWithIndexPath:(NSIndexPath *)indexPath;
+ (instancetype)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind withIndexPath:(NSIndexPath *)indexPath;
+ (instancetype)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind withIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic) CGRect frame;
@property (nonatomic) CGPoint center;
@property (nonatomic) CGSize size;
@property (nonatomic) CGRect bounds;
@property (nonatomic) CGFloat alpha;
@property (nonatomic) NSInteger zIndex;
@property (nonatomic, getter = isHidden) BOOL hidden;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, readonly) UXCollectionElementCategory representedElementCategory;
@property (nonatomic, readonly, nullable) NSString *representedElementKind;

@property (nonatomic) BOOL isFloating;
@property (nonatomic) CGRect floatingFrame;
@property (nonatomic) CGFloat verticalOffsetFromFloatingPosition;
@property (nonatomic) BOOL isPushing;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
