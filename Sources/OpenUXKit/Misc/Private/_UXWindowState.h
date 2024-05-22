#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface _UXWindowState : NSObject

@property (readonly) NSWindowCollectionBehavior collectionBehavior;
@property (readonly) NSWindowStyleMask styleMask;
+ (instancetype)windowStateWithStyleMask:(NSWindowStyleMask)styleMask collectionBehavior:(NSWindowCollectionBehavior)collectionBehavior;
- (void)applyToWindow:(NSWindow *)window;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
