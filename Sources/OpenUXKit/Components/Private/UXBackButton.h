

#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXBackButton : NSSegmentedControl
@property (nonatomic, strong, nullable) NSImage *image;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic) BOOL hidesTitle;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
