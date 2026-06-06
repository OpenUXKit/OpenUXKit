#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionViewLayoutAttributes;

NS_SWIFT_UI_ACTOR
@protocol UXCollectionViewLayoutProxyDelegate <NSObject>

@required
- (nullable NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
