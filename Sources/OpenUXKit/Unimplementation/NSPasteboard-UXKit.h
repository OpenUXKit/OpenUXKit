

#import <AppKit/NSPasteboard.h>

@class NSString;

@interface NSPasteboard (UXKit)
@property(copy, nonatomic, setter=ux_setSourceIdentifier:) NSString *ux_sourceIdentifier;
@end

