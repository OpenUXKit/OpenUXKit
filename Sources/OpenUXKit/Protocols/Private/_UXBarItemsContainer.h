#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@protocol _UXBarItemsContainer <NSObject>

@required
@property (nonatomic, readonly) BOOL hidesGlobalTrailingView;

@optional
- (void)prepareForTransition;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
