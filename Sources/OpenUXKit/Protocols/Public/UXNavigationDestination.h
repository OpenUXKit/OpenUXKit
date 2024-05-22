#import <AppKit/AppKit.h>

@class UXDestinationAuxiliaryStore;

@protocol UXNavigationDestination <NSObject, NSSecureCoding>

@property (nonatomic, readonly) NSSet *requiredDestinationAuxiliaryKeys;
@property (nonatomic, readonly) UXDestinationAuxiliaryStore *destinationAuxiliaryStore;
@property (nonatomic, readonly) NSString *destinationTitle;
@property (nonatomic, readonly) NSString *destinationIdentifier;

@end
