#import <AppKit/AppKit.h>

@class NSImage, NSString;

@interface UXBarItem : NSObject

@property (nonatomic) NSInteger tag; // @synthesize tag=_tag;
@property (strong, nonatomic) NSImage *image; // @synthesize image=_image;
@property (copy, nonatomic) NSString *accessibilityLabel; // @synthesize accessibilityLabel=_accessibilityLabel;
@property (strong, nonatomic) NSString *title; // @synthesize title=_title;
@property (nonatomic, getter=isEnabled) BOOL enabled; // @synthesize enabled=_enabled;

@end

