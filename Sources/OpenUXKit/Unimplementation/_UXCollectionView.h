

#import <OpenUXKit/_UXCollectionViewOverdraw-Protocol.h>

@class NSString;

@interface _UXCollectionView <_UXCollectionViewOverdraw>
{
}

+ (Class)documentClass;
@property(nonatomic) BOOL overdrawEnabled;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) NSUInteger hash;
@property(readonly) Class superclass;

@end

