#import <AppKit/AppKit.h>

@protocol _UXBarItemsContainer <NSObject>
@property (nonatomic, readonly) BOOL hidesGlobalTrailingView;
- (void)prepareForTransition;
@end
