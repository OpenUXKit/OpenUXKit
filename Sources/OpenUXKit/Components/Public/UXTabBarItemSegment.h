#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXTabBarItemSegment : NSObject

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, readonly, nullable) NSImage *symbol;

- (instancetype)initWithTitle:(nullable NSString *)title;
- (instancetype)initWithTitle:(nullable NSString *)title symbol:(nullable NSImage *)symbol;
- (BOOL)isEqualToTabBarItemSegment:(UXTabBarItemSegment *)tabBarItemSegment;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
