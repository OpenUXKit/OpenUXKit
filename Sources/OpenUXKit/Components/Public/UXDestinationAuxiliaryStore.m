#import <OpenUXKit/UXDestinationAuxiliaryStore.h>

static NSString *const UXAuxiliaryNavigationStoreNamespaceDictArchiveKey = @"UXAuxiliaryNavigationStoreNamespaceDictArchiveKey";
static NSString *const UXAuxiliaryNavigationStoreGlobalDictArchiveKey = @"UXAuxiliaryNavigationStoreGlobalDictArchiveKey";
static NSString *const UXAuxiliaryNavigationStoreNextActionKey = @"nextAction";
static NSString *const UXAuxiliaryNavigationStoreNullAction = @"nullAction";

@interface UXDestinationAuxiliaryStore () {
    NSMutableDictionary *_namespaceDict;
    NSMutableDictionary *_globalDict;
    NSString *_lastAction;
}
@end

@implementation UXDestinationAuxiliaryStore

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _namespaceDict = [[NSMutableDictionary alloc] init];
        _globalDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        NSSet *allowedClasses = [self _allowedClassesForNSCoding];
        _namespaceDict = [coder decodeObjectOfClasses:allowedClasses forKey:UXAuxiliaryNavigationStoreNamespaceDictArchiveKey];
        _globalDict = [coder decodeObjectOfClasses:allowedClasses forKey:UXAuxiliaryNavigationStoreGlobalDictArchiveKey];

        if (!_namespaceDict) {
            _namespaceDict = [[NSMutableDictionary alloc] init];
        }
        if (!_globalDict) {
            _globalDict = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_namespaceDict forKey:UXAuxiliaryNavigationStoreNamespaceDictArchiveKey];
    [coder encodeObject:_globalDict forKey:UXAuxiliaryNavigationStoreGlobalDictArchiveKey];
}

- (NSSet<Class> *)_allowedClassesForNSCoding {
    static NSSet *allowedClasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allowedClasses = [NSSet setWithObjects:
                          [NSArray class],
                          [NSData class],
                          [NSDictionary class],
                          [NSMutableArray class],
                          [NSMutableData class],
                          [NSMutableDictionary class],
                          [NSNumber class],
                          [NSString class],
                          [NSValue class],
                          nil];
    });
    return allowedClasses;
}

- (NSMutableDictionary *)_dictionaryForNamespace:(NSString *)namespace {
    if (!namespace) {
        return _globalDict;
    }

    NSMutableDictionary *dictionary = [_namespaceDict objectForKey:namespace];
    if (!dictionary) {
        dictionary = [[NSMutableDictionary alloc] init];
        [_namespaceDict setObject:dictionary forKey:namespace];
    }
    return dictionary;
}

- (id)valueForKey:(NSString *)key inNamespace:(NSString *)namespace {
    NSParameterAssert(key);
    return [[self _dictionaryForNamespace:namespace] valueForKey:key];
}

- (void)_setRawValue:(id)value forKey:(NSString *)key inNamespace:(NSString *)namespace {
    NSParameterAssert(key);
    [[self _dictionaryForNamespace:namespace] setValue:value forKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key inNamespace:(NSString *)namespace {
    [self _setRawValue:value forKey:key inNamespace:namespace];
}

- (void)setObject:(id)object forKey:(NSString *)key inNamespace:(NSString *)namespace {
    [self _setRawValue:object forKey:key inNamespace:namespace];
}

- (void)setBlock:(id)block forKey:(NSString *)key inNamespace:(NSString *)namespace {
    id copiedBlock = [block copy];
    [self _setRawValue:copiedBlock forKey:key inNamespace:namespace];
}

- (void)addEntriesFromDictionary:(NSDictionary *)dictionary inNamespace:(NSString *)namespace {
    [[self _dictionaryForNamespace:namespace] addEntriesFromDictionary:dictionary];
}

- (NSDictionary *)dictionaryWithValuesForKeys:(NSArray<NSString *> *)keys inNamespace:(NSString *)namespace {
    return [[self _dictionaryForNamespace:namespace] dictionaryWithValuesForKeys:keys];
}

- (NSString *)nextActionForNamespace:(NSString *)namespace {
    NSString *action = [self valueForKey:UXAuxiliaryNavigationStoreNextActionKey inNamespace:namespace];
    if (!action) {
        action = [self valueForKey:UXAuxiliaryNavigationStoreNextActionKey inNamespace:nil];
    }
    if ([action isEqualToString:UXAuxiliaryNavigationStoreNullAction]) {
        return nil;
    }
    return action;
}

- (void)setNextAction:(NSString *)nextAction forNamespace:(NSString *)namespace {
    NSString *targetNamespace = namespace;
    if (!targetNamespace) {
        targetNamespace = _lastAction;
        [self setObject:UXAuxiliaryNavigationStoreNullAction forKey:UXAuxiliaryNavigationStoreNextActionKey inNamespace:nextAction];
    }
    [self setObject:nextAction forKey:UXAuxiliaryNavigationStoreNextActionKey inNamespace:targetNamespace];
    _lastAction = nextAction;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p namespace=%@ global=%@ lastAction=%@>", NSStringFromClass([self class]), self, _namespaceDict, _globalDict, _lastAction];
}

@end
