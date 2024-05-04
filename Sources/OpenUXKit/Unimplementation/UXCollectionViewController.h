

#import <OpenUXKit/UXCollectionViewDataSource-Protocol.h>
#import <OpenUXKit/UXCollectionViewDelegate-Protocol.h>

@class NSString, UXCollectionView, UXCollectionViewLayout;

@interface UXCollectionViewController <UXCollectionViewDataSource, UXCollectionViewDelegate>
{
    UXCollectionViewLayout *_layout;	// 16 = 0x10
    UXCollectionView *_collectionView;	// 24 = 0x18
}

+ (Class)collectionViewClass;

@property(strong, nonatomic) UXCollectionView *collectionView; // @synthesize collectionView=_collectionView;
- (CGFloat)scrollView:(id)arg1 pageAlignedOriginOnAxis:(NSInteger)arg2 forProposedDestination:(CGFloat)arg3 currentOrigin:(CGFloat)arg4 initialOrigin:(CGFloat)arg5 velocity:(CGFloat)arg6;
- (id)collectionView:(id)arg1 cellForItemAtIndexPath:(id)arg2;
- (NSInteger)collectionView:(id)arg1 numberOfItemsInSection:(NSInteger)arg2;
- (NSInteger)numberOfSectionsInCollectionView:(id)arg1;
- (id)preferredFirstResponder;
- (void)viewDidLoad;
- (void)_sendViewDidLoad;
- (void)dealloc;
- (id)initWithCollectionViewLayout:(id)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) NSUInteger hash;
@property(readonly) Class superclass;

@end

