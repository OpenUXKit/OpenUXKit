#import <AppKit/NSColor.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSColor (Compatibility)

@property (nonatomic, class, readonly) NSColor *lightTextColor;
@property (nonatomic, class, readonly) NSColor *systemBackgroundColor;
@property (nonatomic, class, readonly) NSColor *secondarySystemBackgroundColor;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
