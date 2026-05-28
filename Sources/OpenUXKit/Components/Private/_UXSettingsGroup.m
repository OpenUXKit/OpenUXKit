#import <OpenUXKit/_UXSettingsGroup.h>

@interface _UXSettingsGroup () {
    NSMutableArray<_UXSettings *> *_internal_group;
    NSHashTable *_internal_groupObservers;
}
@end

@implementation _UXSettingsGroup

- (instancetype)init {
    self = [super init];
    if (self) {
        _internal_group = [[NSMutableArray alloc] init];
        _internal_groupObservers = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)enumerateSettingsUsingBlock:(void (^)(_UXSettings *, NSUInteger, BOOL *))block {
    [_internal_group enumerateObjectsUsingBlock:block];
}

- (void)addGroupObserver:(id)observer {
    if (observer) {
        [_internal_groupObservers addObject:observer];
    }
}

- (void)removeGroupObserver:(id)observer {
    if (observer) {
        [_internal_groupObservers removeObject:observer];
    }
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained _Nullable [])buffer count:(NSUInteger)len {
    return [_internal_group countByEnumeratingWithState:state objects:buffer count:len];
}

@end
