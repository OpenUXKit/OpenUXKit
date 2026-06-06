#import <OpenUXKit/NSTextField+Compatibility.h>

@implementation NSTextField (Compatibility)

@dynamic textAlignment;
@dynamic placeholder;
@dynamic text;

- (NSString *)text {
    return self.stringValue;
}

- (void)setText:(NSString *)text {
    self.stringValue = text ?: @"";
}

- (NSString *)placeholder {
    return self.placeholderString;
}

- (void)setPlaceholder:(NSString *)placeholder {
    self.placeholderString = placeholder;
}

- (NSInteger)textAlignment {
    return (NSInteger)self.alignment;
}

- (void)setTextAlignment:(NSInteger)textAlignment {
    self.alignment = (NSTextAlignment)textAlignment;
}

@end
