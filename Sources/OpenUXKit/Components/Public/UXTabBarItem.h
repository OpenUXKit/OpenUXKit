#import "UXBarItem.h"
#import "UXKitDefines.h"

@class UXTabBarItemSegment;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXTabBarItem : UXBarItem

@property (nonatomic, copy, nullable) NSArray<UXTabBarItemSegment *> *representedSegments;
@property (nonatomic, copy, nullable) NSSet<NSString *> *possibleTitles;

- (instancetype)initWithTitle:(nullable NSString *)title;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
