#import <OpenUXKit/_UXSettings.h>

@implementation _UXSettings

+ (id)settingsFromArchiveDictionary:(NSDictionary *)dictionary {
    _UXSettings *settings = [[self alloc] init];
    [settings restoreFromArchiveDictionary:dictionary];
    return settings;
}

+ (id)settingsFromArchiveFile:(NSString *)file error:(NSError **)error {
    NSData *data = [NSData dataWithContentsOfFile:file options:0 error:error];
    if (!data) {
        return nil;
    }
    NSDictionary *dict = [NSKeyedUnarchiver unarchiveTopLevelObjectWithData:data error:error];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return [self settingsFromArchiveDictionary:dict];
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithDefaultValues {
    self = [self init];
    if (self) {
        [self setDefaultValues];
    }
    return self;
}

- (NSDictionary *)archiveDictionary {
    return @{};
}

- (BOOL)archiveToFile:(NSString *)file error:(NSError **)error {
    NSDictionary *dict = [self archiveDictionary];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict requiringSecureCoding:NO error:error];
    if (!data) {
        return NO;
    }
    return [data writeToFile:file options:NSDataWritingAtomic error:error];
}

- (void)restoreFromArchiveDictionary:(NSDictionary *)dictionary {
}

- (BOOL)restoreFromArchiveFile:(NSString *)file error:(NSError **)error {
    NSData *data = [NSData dataWithContentsOfFile:file options:0 error:error];
    if (!data) {
        return NO;
    }
    NSDictionary *dict = [NSKeyedUnarchiver unarchiveTopLevelObjectWithData:data error:error];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    [self restoreFromArchiveDictionary:dict];
    return YES;
}

- (void)setDefaultValues {
}

- (void)restoreDefaultValues {
    [self setDefaultValues];
}

- (id)copyWithZone:(NSZone *)zone {
    _UXSettings *copy = [[[self class] alloc] init];
    [copy restoreFromArchiveDictionary:[self archiveDictionary]];
    return copy;
}

@end
