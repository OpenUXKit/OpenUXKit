

#import <AppKit/AppKit.h>

@class NSHashTable, NSMutableArray, NSObject;
@protocol OS_os_log;

@interface _UXSettingsGroup <NSFastEnumeration>
{
    NSMutableArray *_internal_group;	// 72 = 0x48
    NSHashTable *_internal_groupObservers;	// 80 = 0x50
    NSObject<OS_os_log> *_log;	// 88 = 0x58
}


- (NSUInteger)countByEnumeratingWithState:(CDStruct_70511ce9 *)arg1 objects:(id *)arg2 count:(NSUInteger)arg3;
- (void)_sendMove:(id)arg1 fromIndex:(NSUInteger)arg2 toIndex:(NSUInteger)arg3;
- (void)_sendRemove:(id)arg1 atIndex:(NSUInteger)arg2;
- (void)_sendInsert:(id)arg1 atIndex:(NSUInteger)arg2;
- (void)settings:(id)arg1 changedValueForKeyPath:(id)arg2;
- (void)_stopObservingPropertiesAndChildren;
- (void)_startObservingPropertiesAndChildren;
- (BOOL)_hasObservers;
- (void)_addInternalEntriesToArchiveDictionary:(id)arg1;
- (void)setValuesFromModel:(id)arg1;
- (id)archiveDictionary;
- (void)removeGroupObserver:(id)arg1;
- (void)addGroupObserver:(id)arg1;
- (id)valueForUndefinedKey:(id)arg1;
- (void)enumerateSettingsUsingBlock:(id)arg1;
- (void)moveSettingsAtIndex:(NSUInteger)arg1 toIndex:(NSUInteger)arg2;
- (void)moveSettings:(id)arg1 toIndex:(NSUInteger)arg2;
- (void)removeSettingsAtIndex:(NSUInteger)arg1;
- (void)removeSettings:(id)arg1;
- (void)insertSettings:(id)arg1 atIndex:(NSUInteger)arg2;
- (void)addSettings:(id)arg1;
- (NSUInteger)indexOfSettings:(id)arg1;
- (BOOL)containsSettings:(id)arg1;
- (id)settingsAtIndex:(NSUInteger)arg1;
- (NSUInteger)count;
- (void)_completeInitByApplyingArchiveDictionary:(id)arg1;
- (void)_continueInitBySettingDefaultValues;
- (id)_startInit;

@end

