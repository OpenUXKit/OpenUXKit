#import <AppKit/AppKit.h>

@interface _UXWindowState : NSObject

@property (readonly) NSWindowCollectionBehavior collectionBehavior;
@property (readonly) NSWindowStyleMask styleMask;
+ (instancetype)windowStateWithStyleMask:(NSWindowStyleMask)styleMask collectionBehavior:(NSWindowCollectionBehavior)collectionBehavior;
- (void)applyToWindow:(NSWindow *)window;

@end
