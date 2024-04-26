//
//  Header.h
//  
//
//  Created by JH on 2024/4/21.
//

#ifndef _UXKITDEFINES_H
#define _UXKITDEFINES_H

#import <AvailabilityMacros.h>
#import <Foundation/NSObjCRuntime.h>

#ifdef __cplusplus
#define UXKIT_EXTERN        extern "C"
#define UXKIT_PRIVATE_EXTERN    __attribute__((visibility("hidden"))) extern "C"
#define UXKIT_PRIVATE          __attribute__((visibility("hidden")))
#else
#define UXKIT_EXTERN        extern
#define UXKIT_PRIVATE_EXTERN    __attribute__((visibility("hidden"))) extern
#define UXKIT_PRIVATE          __attribute__((visibility("hidden")))
#endif

#ifndef NS_SWIFT_BRIDGED_TYPEDEF
#if __has_attribute(swift_bridged_typedef)
#define NS_SWIFT_BRIDGED_TYPEDEF __attribute__((swift_bridged_typedef))
#else
#define NS_SWIFT_BRIDGED_TYPEDEF
#endif
#endif

#ifndef __cplusplus
#define auto __auto_type
#endif

#define cast(cls, var) ((cls)var)

#endif /* _UXKITDEFINES_H */
