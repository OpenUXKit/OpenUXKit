

#import <objc/NSObject.h>

@class NSString;

@interface UXTabBarItemSegment : NSObject
{
    BOOL _enabled;	// 8 = 0x8
    NSString *_title;	// 16 = 0x10
}


@property(nonatomic, getter=isEnabled) BOOL enabled; // @synthesize enabled=_enabled;
@property(copy, nonatomic) NSString *title; // @synthesize title=_title;
- (id)description;
- (id)initWithTitle:(id)arg1;
- (id)init;

@end

