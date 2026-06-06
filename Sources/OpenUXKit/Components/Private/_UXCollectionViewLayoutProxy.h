#import <Foundation/Foundation.h>
#import "UXKitDefines.h"
#import "UXCollectionViewLayoutProxyDelegate.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionViewLayout, UXCollectionViewLayoutAttributes;

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXCollectionViewLayoutProxy : NSObject

@property (nonatomic, assign, nullable) id<UXCollectionViewLayoutProxyDelegate> delegate;
@property (nonatomic, readonly, nullable) UXCollectionViewLayout *layout;

+ (Class)layoutAttributesClass;
+ (Class)invalidationContextClass;

- (instancetype)initWithLayout:(nullable UXCollectionViewLayout *)layout;
- (nullable NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
