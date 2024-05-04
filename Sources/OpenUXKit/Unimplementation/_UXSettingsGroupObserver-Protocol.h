

#import <AppKit/AppKit.h>
@class _UXSettings, _UXSettingsGroup;

@protocol _UXSettingsGroupObserver <NSObject>
- (void)settingsGroup:(_UXSettingsGroup *)arg1 didMoveSettings:(_UXSettings *)arg2 fromIndex:(NSUInteger)arg3 toIndex:(NSUInteger)arg4;
- (void)settingsGroup:(_UXSettingsGroup *)arg1 didRemoveSettings:(_UXSettings *)arg2 atIndex:(NSUInteger)arg3;
- (void)settingsGroup:(_UXSettingsGroup *)arg1 didInsertSettings:(_UXSettings *)arg2 atIndex:(NSUInteger)arg3;
@end

