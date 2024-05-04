

#import <AppKit/AppKit.h>

@class NSCursor;

@protocol _UXSourceSplitViewCursorProvider <NSObject>
- (NSCursor *)separatorCursor;
@end

