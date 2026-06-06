#import <AppKit/AppKit.h>
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN
@interface UXCollectionViewFilePromiseProvider : NSFilePromiseProvider

- (void)addAuxiliaryFilePromiseProvider:(NSFilePromiseProvider *)provider;
@property (nonatomic, copy, readonly, nullable) NSArray<NSFilePromiseProvider *> *auxiliaryFilePromiseProviders;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
