#import <OpenUXKit/_UXSettingsGroup.h>

@interface _UXSettingsGroup () {
    NSMutableArray<_UXSettings *> *_internal_group;
    NSHashTable<NSObject *> *_internal_groupObservers;
}
@end

@implementation _UXSettingsGroup

- (instancetype)_startInit {
    self = [super _startInit];
    if (self) {
        _internal_group = [[NSMutableArray alloc] init];
        _internal_groupObservers = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

#pragma mark - Group observers

- (void)addGroupObserver:(id)observer {
    if (observer) {
        [_internal_groupObservers addObject:observer];
        [self _startOrStopObservingPropertiesAndChildren];
    }
}

- (void)removeGroupObserver:(id)observer {
    if (observer) {
        [_internal_groupObservers removeObject:observer];
        [self _startOrStopObservingPropertiesAndChildren];
    }
}

- (BOOL)_hasObservers {
    return [super _hasObservers] || _internal_groupObservers.count > 0;
}

#pragma mark - Observing children

- (void)_startObservingPropertiesAndChildren {
    [super _startObservingPropertiesAndChildren];
    for (_UXSettings *settings in _internal_group) {
        [self _startObservingChild:settings];
    }
}

- (void)_stopObservingPropertiesAndChildren {
    [super _stopObservingPropertiesAndChildren];
    for (_UXSettings *settings in _internal_group) {
        [self _stopObservingChild:settings];
    }
}

#pragma mark - Collection

- (NSUInteger)count {
    return _internal_group.count;
}

- (_UXSettings *)settingsAtIndex:(NSUInteger)index {
    return [_internal_group objectAtIndex:index];
}

- (BOOL)containsSettings:(_UXSettings *)settings {
    return [_internal_group containsObject:settings];
}

- (NSUInteger)indexOfSettings:(_UXSettings *)settings {
    return [_internal_group indexOfObject:settings];
}

- (void)addSettings:(_UXSettings *)settings {
    [self insertSettings:settings atIndex:_internal_group.count];
}

- (void)insertSettings:(_UXSettings *)settings atIndex:(NSUInteger)index {
    if ([self _isObservingPropertiesAndChildren]) {
        [self _startObservingChild:settings];
    }
    [_internal_group insertObject:settings atIndex:index];
    [self _sendInsert:settings atIndex:index];
}

- (void)removeSettings:(_UXSettings *)settings {
    NSUInteger index = [_internal_group indexOfObject:settings];
    if (index != NSNotFound) {
        [self removeSettingsAtIndex:index];
    }
}

- (void)removeSettingsAtIndex:(NSUInteger)index {
    _UXSettings *settings = [_internal_group objectAtIndex:index];
    if ([self _isObservingPropertiesAndChildren]) {
        [self _stopObservingChild:settings];
    }
    [_internal_group removeObjectAtIndex:index];
    [self _sendRemove:settings atIndex:index];
}

- (void)moveSettings:(_UXSettings *)settings toIndex:(NSUInteger)index {
    NSUInteger fromIndex = [_internal_group indexOfObject:settings];
    if (fromIndex != NSNotFound) {
        [self moveSettingsAtIndex:fromIndex toIndex:index];
    }
}

- (void)moveSettingsAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    if (fromIndex == toIndex) {
        return;
    }
    _UXSettings *settings = [_internal_group objectAtIndex:fromIndex];
    [_internal_group removeObjectAtIndex:fromIndex];
    [_internal_group insertObject:settings atIndex:toIndex];
    [self _sendMove:settings fromIndex:fromIndex toIndex:toIndex];
}

- (void)enumerateSettingsUsingBlock:(void (^)(_UXSettings *, NSUInteger, BOOL *))block {
    [_internal_group enumerateObjectsUsingBlock:block];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained _Nullable [])buffer count:(NSUInteger)len {
    return [_internal_group countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - Notifications

- (void)_sendInsert:(_UXSettings *)settings atIndex:(NSUInteger)index {
    for (id observer in _internal_groupObservers.allObjects) {
        if ([observer respondsToSelector:@selector(settingsGroup:didInsertSettings:atIndex:)]) {
            [observer settingsGroup:self didInsertSettings:settings atIndex:index];
        }
    }
}

- (void)_sendRemove:(_UXSettings *)settings atIndex:(NSUInteger)index {
    for (id observer in _internal_groupObservers.allObjects) {
        if ([observer respondsToSelector:@selector(settingsGroup:didRemoveSettings:atIndex:)]) {
            [observer settingsGroup:self didRemoveSettings:settings atIndex:index];
        }
    }
}

- (void)_sendMove:(_UXSettings *)settings fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    for (id observer in _internal_groupObservers.allObjects) {
        if ([observer respondsToSelector:@selector(settingsGroup:didMoveSettings:fromIndex:toIndex:)]) {
            [observer settingsGroup:self didMoveSettings:settings fromIndex:fromIndex toIndex:toIndex];
        }
    }
}

#pragma mark - Settings observer forwarding

- (void)settings:(_UXSettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    NSUInteger index = [_internal_group indexOfObject:settings];
    if (index != NSNotFound) {
        NSString *combined = [NSString stringWithFormat:@"%lu.%@", (unsigned long)index, keyPath];
        [self _sendKeyPathChanged:combined];
    } else {
        [super settings:settings changedValueForKeyPath:keyPath];
    }
}

#pragma mark - Archive

- (NSDictionary *)archiveDictionary {
    NSMutableDictionary *dictionary = [[super archiveDictionary] mutableCopy] ?: [NSMutableDictionary dictionary];
    NSMutableArray *group = [NSMutableArray arrayWithCapacity:_internal_group.count];
    for (_UXSettings *settings in _internal_group) {
        [group addObject:settings.archiveDictionary];
    }
    dictionary[@"_internal_group"] = group;
    return dictionary;
}

- (void)_addInternalEntriesToArchiveDictionary:(NSMutableDictionary *)dictionary {
    [super _addInternalEntriesToArchiveDictionary:dictionary];
}

- (void)setValuesFromModel:(_UXSettingsGroup *)model {
    [_internal_group removeAllObjects];
    for (_UXSettings *settings in model->_internal_group) {
        [_internal_group addObject:[settings copy]];
    }
}

- (id)valueForUndefinedKey:(NSString *)key {
    NSScanner *scanner = [NSScanner scannerWithString:key];
    NSInteger index = 0;
    if ([scanner scanInteger:&index] && scanner.isAtEnd) {
        if (index >= 0 && (NSUInteger)index < _internal_group.count) {
            return _internal_group[index];
        }
    }
    return [super valueForUndefinedKey:key];
}

- (void)_continueInitBySettingDefaultValues {
    [super _continueInitBySettingDefaultValues];
}

- (void)_completeInitByApplyingArchiveDictionary:(NSDictionary *)dictionary {
    [super _completeInitByApplyingArchiveDictionary:dictionary];
    NSArray *groupArray = dictionary[@"_internal_group"];
    if ([groupArray isKindOfClass:[NSArray class]]) {
        [_internal_group removeAllObjects];
        for (id entry in groupArray) {
            if ([entry isKindOfClass:[NSDictionary class]]) {
                _UXSettings *settings = [[[self class] alloc] init];
                [settings _completeInitByApplyingArchiveDictionary:entry];
                [_internal_group addObject:settings];
            }
        }
    }
}

@end
