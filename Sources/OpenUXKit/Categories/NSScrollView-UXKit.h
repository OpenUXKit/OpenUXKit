

#import <AppKit/NSScrollView.h>

@interface NSScrollView (UXKit)
@property(nonatomic) __weak id scrollViewDelegate;
@property(nonatomic, getter=isScrollEnabled) BOOL scrollEnabled;
@property(nonatomic) BOOL pagingEnabled;
@end

