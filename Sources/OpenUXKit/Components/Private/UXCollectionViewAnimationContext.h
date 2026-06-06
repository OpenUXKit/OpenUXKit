#import <Foundation/Foundation.h>
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionViewAnimation;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionViewAnimationContext : NSObject

@property (nonatomic, strong, nullable) NSArray<UXCollectionViewAnimation *> *viewAnimations;
@property (nonatomic) NSInteger animationCount;
@property (nonatomic, copy, readonly, nullable) void (^completionHandler)(void);

- (instancetype)initWithCompletionHandler:(nullable void (^)(void))completionHandler;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
