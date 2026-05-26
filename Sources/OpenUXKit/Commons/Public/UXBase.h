#ifndef UXBase_h
#define UXBase_h

#import <Foundation/Foundation.h>
#import <OpenUXKit/UXKitDefines.h>

typedef void (^UXCompletionHandler)(void);
typedef void (^UXParameterCompletionHandler)(BOOL);

NS_ASSUME_NONNULL_BEGIN

UXKIT_EXTERN NSString * UXLocalizedString(NSString *key);

NS_ASSUME_NONNULL_END

#endif /* UXBase_h */
