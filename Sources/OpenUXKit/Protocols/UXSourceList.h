#import <AppKit/AppKit.h>

@protocol UXNavigationDestination;

@protocol UXSourceList <NSObject>

@property (nonatomic, readonly) CGFloat maxSourceListWidth;
@property (nonatomic, readonly) CGFloat minSourceListWidth;
@property (nonatomic, getter = isSourceListCollapsed) BOOL sourceListCollapsed;
- (void)selectNavigationDestination:(id <UXNavigationDestination>)arg1;

@end
