#import <AppKit/AppKit.h>

@protocol UXNavigationDestination;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@protocol UXSourceList <NSObject>

@required

@property (nonatomic, readonly) CGFloat sourceListMinimumWidth;
@property (nonatomic, readonly) CGFloat sourceListMaximumWidth;
@property (nonatomic, readonly) CGFloat sourceListPreferredWidthFraction;

- (void)selectNavigationDestination:(id<UXNavigationDestination>)navigationDestination;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
