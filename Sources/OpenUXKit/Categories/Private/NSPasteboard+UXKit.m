#import "NSPasteboard+UXKit.h"
#import <objc/runtime.h>

static const char kUXSourceIdentifierAssociationKey;

@implementation NSPasteboard (UXKit)

- (NSString *)ux_sourceIdentifier {
    return objc_getAssociatedObject(self, &kUXSourceIdentifierAssociationKey);
}

- (void)ux_setSourceIdentifier:(NSString *)ux_sourceIdentifier {
    objc_setAssociatedObject(self, &kUXSourceIdentifierAssociationKey, ux_sourceIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
