#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#import <os/log.h>
#import "_UXSettings.h"

@interface _UXSettings () {
    NSHashTable<NSObject *> *_keyObservers;
    NSHashTable<NSObject *> *_keyPathObservers;
    NSSet<NSString *> *_internal_childKeys;
    NSSet<NSString *> *_internal_leafKeys;
    NSDictionary<NSString *, Class> *_internal_keyClasses;
    NSDictionary<NSString *, NSString *> *_internal_keyStructs;
    NSString *_internal_associated_name;
    BOOL _isObservingPropertiesAndChildren;
    os_log_t _log;
}
@end

@implementation _UXSettings

#pragma mark - Properties-to-avoid blacklist

+ (NSSet<NSString *> *)_propertiesToAvoid {
    static dispatch_once_t onceToken;
    static NSSet<NSString *> *propertiesToAvoid = nil;
    dispatch_once(&onceToken, ^{
        propertiesToAvoid = [NSSet setWithArray:@[@"hash", @"superclass", @"description", @"debugDescription"]];
    });
    return propertiesToAvoid;
}

+ (BOOL)ignoresKey:(NSString *)key {
    return NO;
}

#pragma mark - Init

+ (id)settingsFromArchiveDictionary:(NSDictionary *)dictionary {
    _UXSettings *settings = [[self alloc] _initWithArchiveDictionary:dictionary];
    return settings;
}

+ (id)settingsFromArchiveFile:(NSString *)file error:(NSError **)error {
    NSData *data = [NSData dataWithContentsOfFile:file options:0 error:error];
    if (!data) {
        return nil;
    }
    NSSet *allowedClasses = [NSSet setWithObjects:[NSDictionary class], [NSArray class], [NSString class], [NSNumber class], [NSData class], [NSDate class], [NSNull class], nil];
    NSDictionary *dict = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:data error:error];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return [self settingsFromArchiveDictionary:dict];
}

- (instancetype)init {
    return [self _initWithArchiveDictionary:nil];
}

- (instancetype)initWithDefaultValues {
    self = [self _startInit];
    if (self) {
        [self _continueInitBySettingDefaultValues];
    }
    return self;
}

- (instancetype)_initWithArchiveDictionary:(NSDictionary *)dictionary {
    _UXSettings *settings = [self _startInit];
    if (settings) {
        [settings _continueInitBySettingDefaultValues];
        [settings _completeInitByApplyingArchiveDictionary:dictionary];
    }
    return settings;
}

- (instancetype)_startInit {
    self = [super init];
    if (self) {
        _keyObservers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPersonality];
        _keyPathObservers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPersonality];
        [self _introspectKeys];
        for (NSString *childKey in _internal_childKeys) {
            Class childClass = _internal_keyClasses[childKey];
            id childInstance = [[childClass alloc] _startInit];
            [self setValue:childInstance forKey:childKey];
        }
        _log = os_log_create("com.openuxkit", "Settings");
    }
    return self;
}

- (void)_introspectKeys {
    NSMutableSet<NSString *> *leafKeys = [NSMutableSet set];
    NSMutableSet<NSString *> *childKeys = [NSMutableSet set];
    NSMutableDictionary<NSString *, Class> *keyClasses = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NSString *> *keyStructs = [NSMutableDictionary dictionary];

    NSSet *propertiesToAvoid = [[self class] _propertiesToAvoid];
    Class cls = [self class];
    Class settingsClass = [_UXSettings class];

    while ([cls isSubclassOfClass:settingsClass]) {
        unsigned int outCount = 0;
        objc_property_t *properties = class_copyPropertyList(cls, &outCount);
        if (properties) {
            for (unsigned int i = 0; i < outCount; i++) {
                objc_property_t property = properties[i];
                NSString *name = [NSString stringWithUTF8String:property_getName(property)];
                NSString *attributes = [NSString stringWithUTF8String:property_getAttributes(property)];

                if ([propertiesToAvoid containsObject:name]) {
                    continue;
                }
                if ([cls ignoresKey:name]) {
                    continue;
                }

                NSScanner *scanner = [NSScanner scannerWithString:attributes];
                Class propertyClass = Nil;
                NSString *structType = nil;
                NSString *typeName = nil;

                if ([scanner scanString:@"T@\"" intoString:NULL]) {
                    if ([scanner scanUpToString:@"\"" intoString:&typeName]) {
                        propertyClass = NSClassFromString(typeName);
                    }
                } else {
                    scanner.scanLocation = 0;
                    if ([scanner scanString:@"T{" intoString:NULL]) {
                        [scanner scanUpToString:@"=" intoString:&structType];
                    }
                }

                if ([propertyClass isSubclassOfClass:settingsClass]) {
                    [childKeys addObject:name];
                    if (propertyClass) {
                        keyClasses[name] = propertyClass;
                    }
                } else {
                    [leafKeys addObject:name];
                    if (propertyClass) {
                        keyClasses[name] = propertyClass;
                    } else if (structType) {
                        keyStructs[name] = structType;
                    }
                }
            }
            free(properties);
        }
        cls = [cls superclass];
    }

    _internal_leafKeys = [leafKeys copy];
    _internal_childKeys = [childKeys copy];
    _internal_keyClasses = [keyClasses copy];
    _internal_keyStructs = [keyStructs copy];
}

- (void)_continueInitBySettingDefaultValues {
    for (NSString *childKey in _internal_childKeys) {
        _UXSettings *child = [self valueForKey:childKey];
        [child _continueInitBySettingDefaultValues];
    }
    [self setDefaultValues];
}

- (void)_completeInitByApplyingArchiveDictionary:(NSDictionary *)dictionary {
    for (NSString *key in dictionary.allKeys) {
        id value = dictionary[key];
        if ([_internal_childKeys containsObject:key]) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                _UXSettings *child = [self valueForKey:key];
                [child _completeInitByApplyingArchiveDictionary:value];
            } else {
                os_log_info(_log, "Warning: skipping archive value for child key %{public}@ (expected class NSDictionary, found %{public}@)",
                            key, [value class]);
            }
        } else if ([key isEqualToString:@"_internal_associated_name"]) {
            if ([value isKindOfClass:[NSString class]]) {
                [self _setAssociatedName:value];
            } else {
                os_log_info(_log, "Warning: skipping archive value for child key %@ (expected class NSString, found %{public}@)",
                            key, [value class]);
            }
        } else {
            [self applyArchiveValue:value forKey:key];
        }
    }
}

- (void)setDefaultValues {
}

- (void)setValuesFromModel:(_UXSettings *)model {
    NSDictionary *dictionary = [model archiveDictionary];
    [self _completeInitByApplyingArchiveDictionary:dictionary];
}

- (NSSet<NSString *> *)_allKeys {
    return [_internal_childKeys setByAddingObjectsFromSet:_internal_leafKeys];
}

#pragma mark - Archive

- (NSDictionary *)archiveDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (NSString *key in [self _allKeys]) {
        id archiveValue = [self archiveValueForKey:key];
        if (archiveValue) {
            dictionary[key] = archiveValue;
        }
    }
    [self _addInternalEntriesToArchiveDictionary:dictionary];
    return dictionary;
}

- (id)archiveValueForKey:(NSString *)key {
    if ([_internal_childKeys containsObject:key]) {
        _UXSettings *child = [self valueForKey:key];
        return [child archiveDictionary];
    }
    if ([_internal_leafKeys containsObject:key]) {
        Class propertyClass = _internal_keyClasses[key];
        NSString *structType = _internal_keyStructs[key];
        if (propertyClass == [NSColor class]) {
            return [self _dictionaryForColorKey:key];
        }
        if (propertyClass == [NSFont class]) {
            return [self _dictionaryForFontKey:key];
        }
        if (structType) {
            return [self _dictionaryForStructKey:key ofType:structType];
        }
        return [self valueForKey:key];
    }
    return nil;
}

- (void)applyArchiveValue:(id)value forKey:(NSString *)key {
    if (![_internal_leafKeys containsObject:key]) {
        return;
    }
    Class propertyClass = _internal_keyClasses[key];
    NSString *structType = _internal_keyStructs[key];

    if (propertyClass == [NSColor class]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSColor *color = [self _colorForKey:key fromDictionary:value];
            if (color) {
                [self setValue:color forKey:key];
            }
        }
        return;
    }
    if (propertyClass == [NSFont class]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSFont *font = [self _fontForKey:key fromDictionary:value];
            if (font) {
                [self setValue:font forKey:key];
            }
        }
        return;
    }
    if (structType) {
        [self _structValueForKey:key ofType:structType fromDictionary:value];
        return;
    }
    [self setValue:value forKey:key];
}

- (void)_addInternalEntriesToArchiveDictionary:(NSMutableDictionary *)dictionary {
    NSString *associatedName = [self _associatedNameOrNilIfDefault];
    if (associatedName) {
        dictionary[@"_internal_associated_name"] = associatedName;
    }
}

- (BOOL)archiveToFile:(NSString *)file error:(NSError **)error {
    NSDictionary *dictionary = [self archiveDictionary];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary requiringSecureCoding:NO error:error];
    if (!data) {
        return NO;
    }
    return [data writeToFile:file options:NSDataWritingAtomic error:error];
}

- (void)restoreFromArchiveDictionary:(NSDictionary *)dictionary {
    [self _completeInitByApplyingArchiveDictionary:dictionary];
}

- (BOOL)restoreFromArchiveFile:(NSString *)file error:(NSError **)error {
    NSData *data = [NSData dataWithContentsOfFile:file options:0 error:error];
    if (!data) {
        return NO;
    }
    NSSet *allowedClasses = [NSSet setWithObjects:[NSDictionary class], [NSArray class], [NSString class], [NSNumber class], [NSData class], [NSDate class], [NSNull class], nil];
    NSDictionary *dictionary = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:data error:error];
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    [self restoreFromArchiveDictionary:dictionary];
    return YES;
}

- (void)restoreDefaultValues {
    [self setDefaultValues];
}

#pragma mark - Color / Font / Struct dictionary helpers

- (NSDictionary *)_dictionaryForColorKey:(NSString *)key {
    NSColor *color = [self valueForKey:key];
    if (!color) {
        return nil;
    }
    NSColor *rgbColor = [color colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    if (!rgbColor) {
        return nil;
    }
    return @{
        @"r": @(rgbColor.redComponent),
        @"g": @(rgbColor.greenComponent),
        @"b": @(rgbColor.blueComponent),
        @"a": @(rgbColor.alphaComponent),
    };
}

- (NSColor *)_colorForKey:(NSString *)key fromDictionary:(NSDictionary *)dictionary {
    NSNumber *r = dictionary[@"r"];
    NSNumber *g = dictionary[@"g"];
    NSNumber *b = dictionary[@"b"];
    NSNumber *a = dictionary[@"a"];
    if (!r || !g || !b) {
        return nil;
    }
    return [NSColor colorWithSRGBRed:r.doubleValue
                               green:g.doubleValue
                                blue:b.doubleValue
                               alpha:a ? a.doubleValue : 1.0];
}

- (NSDictionary *)_dictionaryForFontKey:(NSString *)key {
    NSFont *font = [self valueForKey:key];
    if (!font) {
        return nil;
    }
    return @{
        @"family": font.familyName ?: @"",
        @"name": font.fontName ?: @"",
        @"size": @(font.pointSize),
    };
}

- (NSFont *)_fontForKey:(NSString *)key fromDictionary:(NSDictionary *)dictionary {
    NSString *name = dictionary[@"name"];
    NSNumber *size = dictionary[@"size"];
    if (!name || !size) {
        return nil;
    }
    return [NSFont fontWithName:name size:size.doubleValue];
}

- (NSDictionary *)_dictionaryForStructKey:(NSString *)key ofType:(NSString *)structType {
    NSValue *value = [self valueForKey:key];
    if (!value) {
        return nil;
    }
    return @{ @"type": structType, @"description": value.description ?: @"" };
}

- (id)_structValueForKey:(NSString *)key ofType:(NSString *)structType fromDictionary:(NSDictionary *)dictionary {
    return nil;
}

#pragma mark - Associated name

- (NSString *)_associatedName {
    if (_internal_associated_name) {
        return _internal_associated_name;
    }
    return NSStringFromClass([self class]);
}

- (NSString *)_associatedNameOrNilIfDefault {
    if (!_internal_associated_name) {
        return nil;
    }
    if ([_internal_associated_name isEqualToString:NSStringFromClass([self class])]) {
        return nil;
    }
    return _internal_associated_name;
}

- (void)_setAssociatedName:(NSString *)name {
    _internal_associated_name = [name copy];
}

#pragma mark - Observers (simplified)

- (void)addKeyObserver:(id)observer {
    [_keyObservers addObject:observer];
    [self _startOrStopObservingPropertiesAndChildren];
}

- (void)removeKeyObserver:(id)observer {
    [_keyObservers removeObject:observer];
    [self _startOrStopObservingPropertiesAndChildren];
}

- (void)addKeyPathObserver:(id)observer {
    [_keyPathObservers addObject:observer];
    [self _startOrStopObservingPropertiesAndChildren];
}

- (void)removeKeyPathObserver:(id)observer {
    [_keyPathObservers removeObject:observer];
    [self _startOrStopObservingPropertiesAndChildren];
}

- (BOOL)_hasObservers {
    return _keyObservers.count > 0 || _keyPathObservers.count > 0;
}

- (BOOL)_isObservingPropertiesAndChildren {
    return _isObservingPropertiesAndChildren;
}

- (void)_startOrStopObservingPropertiesAndChildren {
    BOOL shouldObserve = [self _hasObservers];
    if (shouldObserve && !_isObservingPropertiesAndChildren) {
        [self _startObservingPropertiesAndChildren];
    } else if (!shouldObserve && _isObservingPropertiesAndChildren) {
        [self _stopObservingPropertiesAndChildren];
    }
}

- (void)_startObservingPropertiesAndChildren {
    if (_isObservingPropertiesAndChildren) {
        return;
    }
    _isObservingPropertiesAndChildren = YES;
    for (NSString *leafKey in _internal_leafKeys) {
        [self addObserver:self forKeyPath:leafKey options:0 context:NULL];
    }
    for (NSString *childKey in _internal_childKeys) {
        _UXSettings *child = [self valueForKey:childKey];
        [self _startObservingChild:child];
    }
}

- (void)_stopObservingPropertiesAndChildren {
    if (!_isObservingPropertiesAndChildren) {
        return;
    }
    _isObservingPropertiesAndChildren = NO;
    for (NSString *leafKey in _internal_leafKeys) {
        @try {
            [self removeObserver:self forKeyPath:leafKey];
        } @catch (NSException *exception) {
        }
    }
    for (NSString *childKey in _internal_childKeys) {
        _UXSettings *child = [self valueForKey:childKey];
        [self _stopObservingChild:child];
    }
}

- (void)_startObservingChild:(_UXSettings *)child {
    [child addKeyPathObserver:self];
}

- (void)_stopObservingChild:(_UXSettings *)child {
    [child removeKeyPathObserver:self];
}

- (void)_sendKeyChanged:(NSString *)key {
    for (id observer in _keyObservers.allObjects) {
        if ([observer respondsToSelector:@selector(settings:changedValueForKey:)]) {
            [observer settings:self changedValueForKey:key];
        }
    }
    [self _sendKeyPathChanged:key];
}

- (void)_sendKeyPathChanged:(NSString *)keyPath {
    for (id observer in _keyPathObservers.allObjects) {
        if ([observer respondsToSelector:@selector(settings:changedValueForKeyPath:)]) {
            [observer settings:self changedValueForKeyPath:keyPath];
        }
    }
}

- (NSString *)_keyForChild:(_UXSettings *)child {
    for (NSString *childKey in _internal_childKeys) {
        if ([self valueForKey:childKey] == child) {
            return childKey;
        }
    }
    return nil;
}

- (void)_handleChildGroupChange:(_UXSettings *)child {
    NSString *key = [self _keyForChild:child];
    if (key) {
        [self _sendKeyChanged:key];
    }
}

#pragma mark - Forwarded observer callbacks (UXSettingsObserver-ish)

- (void)settings:(_UXSettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    NSString *childKey = [self _keyForChild:settings];
    if (childKey) {
        NSString *combinedKeyPath = [NSString stringWithFormat:@"%@.%@", childKey, keyPath];
        [self _sendKeyPathChanged:combinedKeyPath];
    }
}

- (void)settingsGroup:(id)group didInsertSettings:(_UXSettings *)settings atIndex:(NSUInteger)index {
}

- (void)settingsGroup:(id)group didRemoveSettings:(_UXSettings *)settings atIndex:(NSUInteger)index {
}

- (void)settingsGroup:(id)group didMoveSettings:(_UXSettings *)settings fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if (object == self && [_internal_leafKeys containsObject:keyPath]) {
        [self _sendKeyChanged:keyPath];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Copy / dealloc

- (id)copyWithZone:(NSZone *)zone {
    _UXSettings *copy = [[[self class] alloc] _initWithArchiveDictionary:[self archiveDictionary]];
    return copy;
}

- (void)dealloc {
    if (_isObservingPropertiesAndChildren) {
        [self _stopObservingPropertiesAndChildren];
    }
}

@end
