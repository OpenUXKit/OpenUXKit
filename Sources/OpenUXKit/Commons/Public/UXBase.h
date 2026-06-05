#ifndef UXBase_h
#define UXBase_h

#import <Foundation/Foundation.h>
#import <OpenUXKit/UXKitDefines.h>

typedef void (^UXCompletionHandler)(void);
typedef void (^UXParameterCompletionHandler)(BOOL);

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NSString * UXLocalizedString(NSString *key);

NS_HEADER_AUDIT_END(nullability, sendability)

#endif /* UXBase_h */
