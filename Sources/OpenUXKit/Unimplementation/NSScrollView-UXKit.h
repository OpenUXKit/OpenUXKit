#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSScrollView (UXKit)
@property (nonatomic, weak, nullable) id scrollViewDelegate;
@property (nonatomic, getter = isScrollEnabled) BOOL scrollEnabled;
@property (nonatomic) BOOL pagingEnabled;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
