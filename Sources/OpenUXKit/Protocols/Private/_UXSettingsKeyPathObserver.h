#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class _UXSettings;

@protocol _UXSettingsKeyPathObserver <NSObject>

@required
- (void)settings:(_UXSettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
