#import <AppKit/AppKit.h>

@class UXDestinationAuxiliaryStore;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@protocol UXNavigationDestination <NSObject, NSSecureCoding>

@property (nonatomic, readonly, nullable) NSSet<NSString *> *requiredDestinationAuxiliaryKeys;
@property (nonatomic, readonly, nullable) UXDestinationAuxiliaryStore *destinationAuxiliaryStore;
@property (nonatomic, readonly) NSString *destinationTitle;
@property (nonatomic, readonly) NSString *destinationIdentifier;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
