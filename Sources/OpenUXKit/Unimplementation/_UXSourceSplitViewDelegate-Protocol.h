

#import <AppKit/AppKit.h>

@class UXView, _UXSourceSplitView;

@protocol _UXSourceSplitViewDelegate <NSObject>
- (BOOL)sourceSplitView:(_UXSourceSplitView *)arg1 canSpringLoadRevealSubview:(UXView *)arg2;
- (void)sourceSplitView:(_UXSourceSplitView *)arg1 didChangeAutoCollapsedValue:(BOOL)arg2;
- (void)sourceSplitView:(_UXSourceSplitView *)arg1 didResizeMasterWidth:(CGFloat)arg2;
@end

