#import <Foundation/Foundation.h>
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class _UXSettings, _UXSettingsGroup;

UXKIT_PRIVATE
@interface _UXSettings : NSObject <NSCopying>

+ (nullable id)settingsFromArchiveDictionary:(NSDictionary *)dictionary;
+ (nullable id)settingsFromArchiveFile:(NSString *)file error:(NSError **)error;
+ (BOOL)ignoresKey:(NSString *)key;

- (instancetype)init;
- (instancetype)initWithDefaultValues;

- (NSDictionary *)archiveDictionary;
- (BOOL)archiveToFile:(NSString *)file error:(NSError **)error;
- (void)restoreFromArchiveDictionary:(NSDictionary *)dictionary;
- (BOOL)restoreFromArchiveFile:(NSString *)file error:(NSError **)error;
- (void)setDefaultValues;
- (void)restoreDefaultValues;

- (void)setValuesFromModel:(_UXSettings *)model;
- (void)addKeyObserver:(id)observer;
- (void)removeKeyObserver:(id)observer;
- (void)addKeyPathObserver:(id)observer;
- (void)removeKeyPathObserver:(id)observer;

@end

UXKIT_PRIVATE
@interface _UXSettings (Internal)

- (instancetype)_startInit __attribute__((objc_method_family(init)));
- (instancetype)_initWithArchiveDictionary:(nullable NSDictionary *)dictionary __attribute__((objc_method_family(init)));
- (void)_introspectKeys;
- (void)_continueInitBySettingDefaultValues;
- (void)_completeInitByApplyingArchiveDictionary:(NSDictionary *)dictionary;

- (nullable id)archiveValueForKey:(NSString *)key;
- (void)applyArchiveValue:(nullable id)value forKey:(NSString *)key;
- (NSSet<NSString *> *)_allKeys;
- (void)_addInternalEntriesToArchiveDictionary:(NSMutableDictionary *)dictionary;

- (NSString *)_associatedName;
- (nullable NSString *)_associatedNameOrNilIfDefault;
- (void)_setAssociatedName:(nullable NSString *)name;

- (BOOL)_hasObservers;
- (BOOL)_isObservingPropertiesAndChildren;
- (void)_startOrStopObservingPropertiesAndChildren;
- (void)_startObservingPropertiesAndChildren;
- (void)_stopObservingPropertiesAndChildren;
- (void)_startObservingChild:(_UXSettings *)child;
- (void)_stopObservingChild:(_UXSettings *)child;
- (nullable NSString *)_keyForChild:(_UXSettings *)child;
- (void)_handleChildGroupChange:(_UXSettings *)child;
- (void)_sendKeyChanged:(NSString *)key;
- (void)_sendKeyPathChanged:(NSString *)keyPath;

- (void)settings:(_UXSettings *)settings changedValueForKey:(NSString *)key;
- (void)settings:(_UXSettings *)settings changedValueForKeyPath:(NSString *)keyPath;
- (void)settingsGroup:(id)group didInsertSettings:(_UXSettings *)settings atIndex:(NSUInteger)index;
- (void)settingsGroup:(id)group didRemoveSettings:(_UXSettings *)settings atIndex:(NSUInteger)index;
- (void)settingsGroup:(id)group didMoveSettings:(_UXSettings *)settings fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
