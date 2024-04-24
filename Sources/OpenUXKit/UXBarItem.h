#import <AppKit/AppKit.h>

@class NSImage, NSString;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXBarItem : NSObject

@property (nonatomic) NSInteger tag; // @synthesize tag=_tag;
@property (nonatomic, strong, nullable) NSImage *image; // @synthesize image=_image;
@property (nonatomic, copy, nullable) NSString *accessibilityLabel; // @synthesize accessibilityLabel=_accessibilityLabel;
@property (nonatomic, strong, nullable) NSString *title; // @synthesize title=_title;
@property (nonatomic, getter = isEnabled) BOOL enabled; // @synthesize enabled=_enabled;
@property (nonatomic, copy) NSString *accessibilityIdentifier;
@end



NS_HEADER_AUDIT_END(nullability, sendability)
