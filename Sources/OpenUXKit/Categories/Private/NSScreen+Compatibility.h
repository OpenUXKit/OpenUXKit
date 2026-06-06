#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSScreen (Compatibility)

@property (nonatomic, readonly) CGFloat scale;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
