

#import <AppKit/AppKit.h>

@class NSMutableDictionary, NSString;

@interface UXDestinationAuxiliaryStore : NSObject <NSSecureCoding>
{
    NSMutableDictionary *_namespaceDict;	// 8 = 0x8
    NSMutableDictionary *_globalDict;	// 16 = 0x10
    NSString *_lastAction;	// 24 = 0x18
}

+ (BOOL)supportsSecureCoding;

- (id)_dictionaryForNamespace:(id)arg1;
- (id)debugDescription;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)_allowedClassesForNSCoding;
- (id)nextActionForNamespace:(id)arg1;
- (void)setNextAction:(id)arg1 forNamespace:(id)arg2;
- (id)dictionaryWithValuesForKeys:(id)arg1 inNamespace:(id)arg2;
- (void)addEntriesFromDictionary:(id)arg1 inNamespace:(id)arg2;
- (id)valueForKey:(id)arg1 inNamespace:(id)arg2;
- (void)setValue:(id)arg1 forKey:(id)arg2 inNamespace:(id)arg3;
- (id)init;

@end

