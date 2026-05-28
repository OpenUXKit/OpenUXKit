#import <OpenUXKit/UXTableViewController.h>
#import <OpenUXKit/UXTableLayout.h>

@implementation UXTableViewController

+ (Class)collectionViewClass {
    return [UXTableView class];
}

- (instancetype)initWithTableLayout:(UXTableLayout *)layout {
    if (!layout) {
        layout = [[UXTableLayout alloc] init];
    }
    return [super initWithCollectionViewLayout:layout];
}

- (UXTableView *)tableView {
    return (UXTableView *)self.collectionView;
}

- (NSInteger)tableView:(UXTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UXTableViewCell *)tableView:(UXTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
