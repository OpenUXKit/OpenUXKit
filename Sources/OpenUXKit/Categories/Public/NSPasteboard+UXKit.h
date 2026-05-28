#import <AppKit/NSPasteboard.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSPasteboard (UXKit)

@property (nonatomic, copy, nullable, setter=ux_setSourceIdentifier:) NSString *ux_sourceIdentifier;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
