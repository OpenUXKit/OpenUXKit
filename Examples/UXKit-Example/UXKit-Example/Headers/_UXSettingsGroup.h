/*
    * This header is generated by classdump-dyld 1.0
    * on Friday, February 2, 2024 at 1:02:18 AM China Standard Time
    * Operating System: Version 14.2.1 (Build 23C71)
    * Image Source: /System/Library/PrivateFrameworks/UXKit.framework/Versions/A/UXKit
    * classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
    */

#import "UXKit-Structs.h"
#import "_UXSettings.h"
#import <Cocoa/Cocoa.h>

@protocol OS_os_log;
@class NSMutableArray, NSHashTable, NSObject;

@interface _UXSettingsGroup : _UXSettings <NSFastEnumeration> {

	NSMutableArray* _internal_group;
	NSHashTable* _internal_groupObservers;
//	NSObject<OS_os_log>* _log;

}
- (unsigned long long)count;
- (unsigned long long)countByEnumeratingWithState:(SCD_Struct_UX1*)arg1 objects:(id*)arg2 count:(unsigned long long)arg3;
- (id)valueForUndefinedKey:(id)arg1;
- (BOOL)_hasObservers;
- (id)archiveDictionary;
- (void)settings:(id)arg1 changedValueForKeyPath:(id)arg2;
- (void)setValuesFromModel:(id)arg1;
- (void)removeSettings:(id)arg1;
- (void)_addInternalEntriesToArchiveDictionary:(id)arg1;
- (void)_completeInitByApplyingArchiveDictionary:(id)arg1;
- (void)_continueInitBySettingDefaultValues;
- (void)_sendInsert:(id)arg1 atIndex:(unsigned long long)arg2;
- (void)_sendMove:(id)arg1 fromIndex:(unsigned long long)arg2 toIndex:(unsigned long long)arg3;
- (void)_sendRemove:(id)arg1 atIndex:(unsigned long long)arg2;
- (id)_startInit;
- (void)_startObservingPropertiesAndChildren;
- (void)_stopObservingPropertiesAndChildren;
- (void)addGroupObserver:(id)arg1;
- (void)addSettings:(id)arg1;
- (BOOL)containsSettings:(id)arg1;
- (void)enumerateSettingsUsingBlock:(/*^block*/id)arg1;
- (unsigned long long)indexOfSettings:(id)arg1;
- (void)insertSettings:(id)arg1 atIndex:(unsigned long long)arg2;
- (void)moveSettings:(id)arg1 toIndex:(unsigned long long)arg2;
- (void)moveSettingsAtIndex:(unsigned long long)arg1 toIndex:(unsigned long long)arg2;
- (void)removeGroupObserver:(id)arg1;
- (void)removeSettingsAtIndex:(unsigned long long)arg1;
- (id)settingsAtIndex:(unsigned long long)arg1;
@end

