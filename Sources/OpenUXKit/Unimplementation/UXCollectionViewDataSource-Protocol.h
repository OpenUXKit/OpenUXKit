

#import <AppKit/AppKit.h>

@class NSIndexPath, NSString, UXCollectionReusableView, UXCollectionView, UXCollectionViewCell;

@protocol UXCollectionViewDataSource <NSObject>
- (UXCollectionViewCell *)collectionView:(UXCollectionView *)arg1 cellForItemAtIndexPath:(NSIndexPath *)arg2;
- (NSInteger)collectionView:(UXCollectionView *)arg1 numberOfItemsInSection:(NSInteger)arg2;

@optional
- (UXCollectionReusableView *)collectionView:(UXCollectionView *)arg1 viewForSupplementaryElementOfKind:(NSString *)arg2 atIndexPath:(NSIndexPath *)arg3;
- (NSInteger)numberOfSectionsInCollectionView:(UXCollectionView *)arg1;
@end

