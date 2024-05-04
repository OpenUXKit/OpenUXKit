

#import <AppKit/NSFilePromiseProvider.h>

@class NSArray, NSMutableArray;

@interface UXCollectionViewFilePromiseProvider : NSFilePromiseProvider
{
    NSMutableArray *_auxiliaryFilePromiseProviders;	// 8 = 0x8
}


- (void)addAuxiliaryFilePromiseProvider:(id)arg1;
@property(readonly, copy, nonatomic) NSArray *auxiliaryFilePromiseProviders;

@end

