

#import <objc/NSObject.h>

#import <OpenUXKit/UXNavigationDestination.h>

@class NSSet, NSString, UXDestinationAuxiliaryStore;

@interface _UXNavigationDestination : NSObject <UXNavigationDestination>
{
    NSString *_destinationIdentifier;	// 8 = 0x8
    NSString *_destinationTitle;	// 16 = 0x10
    UXDestinationAuxiliaryStore *_destinationAuxiliaryStore;	// 24 = 0x18
    NSSet *_requiredDestinationAuxiliaryKeys;	// 32 = 0x20
}

+ (BOOL)supportsSecureCoding;

@property(strong, nonatomic) NSSet *requiredDestinationAuxiliaryKeys; // @synthesize requiredDestinationAuxiliaryKeys=_requiredDestinationAuxiliaryKeys;
@property(strong, nonatomic) UXDestinationAuxiliaryStore *destinationAuxiliaryStore; // @synthesize destinationAuxiliaryStore=_destinationAuxiliaryStore;
@property(strong, nonatomic) NSString *destinationTitle; // @synthesize destinationTitle=_destinationTitle;
@property(strong, nonatomic) NSString *destinationIdentifier; // @synthesize destinationIdentifier=_destinationIdentifier;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithCoder:(id)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) NSUInteger hash;
@property(readonly) Class superclass;

@end

