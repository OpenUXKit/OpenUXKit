#import <AppKit/AppKit.h>

@protocol UXNavigationDestination;

@protocol UXSourceList <NSObject>

@required

@property (nonatomic, readonly) CGFloat sourceListMinimumWidth;
@property (nonatomic, readonly) CGFloat sourceListMaximumWidth;
@property (nonatomic, readonly) CGFloat sourceListPreferredWidthFraction;

- (void)selectNavigationDestination:(id <UXNavigationDestination>)navigationDestination;

@end
