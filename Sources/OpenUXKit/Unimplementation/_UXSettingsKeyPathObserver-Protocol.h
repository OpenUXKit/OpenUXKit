

#import <AppKit/AppKit.h>

@class NSString, _UXSettings;

@protocol _UXSettingsKeyPathObserver <NSObject>
- (void)settings:(_UXSettings *)arg1 changedValueForKeyPath:(NSString *)arg2;
@end

