#ifndef UXKitPrivateUtilites_h
#define UXKitPrivateUtilites_h

#import <OpenUXKit/EXTScope.h>
#import <OpenUXKit/EXTKeyPathCoding.h>

#define SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(code)                        \
    _Pragma("clang diagnostic push")                                        \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")     \
    code;                                                                   \
    _Pragma("clang diagnostic pop")

#ifndef __cplusplus
#define auto __auto_type
#endif

#define cast(cls, var) ((cls)var)

#define NSStringFromSelectorLiteral(s) (NSStringFromSelector(@selector(s)))

#endif /* UXKitPrivateUtilites_h */

