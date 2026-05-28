#import <Foundation/Foundation.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_PRIVATE
@interface _UXSettings : NSObject <NSCopying>

+ (nullable id)settingsFromArchiveDictionary:(NSDictionary *)dictionary;
+ (nullable id)settingsFromArchiveFile:(NSString *)file error:(NSError **)error;

- (instancetype)init;
- (instancetype)initWithDefaultValues;

- (NSDictionary *)archiveDictionary;
- (BOOL)archiveToFile:(NSString *)file error:(NSError **)error;
- (void)restoreFromArchiveDictionary:(NSDictionary *)dictionary;
- (BOOL)restoreFromArchiveFile:(NSString *)file error:(NSError **)error;
- (void)setDefaultValues;
- (void)restoreDefaultValues;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
