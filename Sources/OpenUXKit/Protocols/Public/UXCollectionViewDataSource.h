#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionView, UXCollectionViewCell, UXCollectionReusableView;

NS_SWIFT_UI_ACTOR
@protocol UXCollectionViewDataSource <NSObject>

@required
- (NSInteger)collectionView:(UXCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (UXCollectionViewCell *)collectionView:(UXCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSInteger)numberOfSectionsInCollectionView:(UXCollectionView *)collectionView;
- (UXCollectionReusableView *)collectionView:(UXCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
