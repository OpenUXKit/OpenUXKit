#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class _UXSettings, _UXSettingsGroup;

@protocol _UXSettingsGroupObserver <NSObject>

@required
- (void)settingsGroup:(_UXSettingsGroup *)settingsGroup didInsertSettings:(_UXSettings *)settings atIndex:(NSUInteger)index;
- (void)settingsGroup:(_UXSettingsGroup *)settingsGroup didRemoveSettings:(_UXSettings *)settings atIndex:(NSUInteger)index;
- (void)settingsGroup:(_UXSettingsGroup *)settingsGroup didMoveSettings:(_UXSettings *)settings fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
