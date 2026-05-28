#import <Foundation/Foundation.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN
@interface UXDestinationAuxiliaryStore : NSObject <NSSecureCoding>

- (instancetype)init;

- (nullable id)valueForKey:(NSString *)key inNamespace:(nullable NSString *)namespace;
- (void)setValue:(nullable id)value forKey:(NSString *)key inNamespace:(nullable NSString *)namespace;
- (void)setObject:(nullable id)object forKey:(NSString *)key inNamespace:(nullable NSString *)namespace;
- (void)setBlock:(nullable id)block forKey:(NSString *)key inNamespace:(nullable NSString *)namespace;
- (void)addEntriesFromDictionary:(NSDictionary *)dictionary inNamespace:(nullable NSString *)namespace;
- (NSDictionary *)dictionaryWithValuesForKeys:(NSArray<NSString *> *)keys inNamespace:(nullable NSString *)namespace;

- (nullable NSString *)nextActionForNamespace:(nullable NSString *)namespace;
- (void)setNextAction:(nullable NSString *)nextAction forNamespace:(nullable NSString *)namespace;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
