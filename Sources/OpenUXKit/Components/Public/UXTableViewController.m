#import <OpenUXKit/UXTableViewController.h>
#import <OpenUXKit/UXTableLayout.h>
#import <OpenUXKit/UXLayoutSupport.h>

@implementation UXTableViewController

+ (Class)collectionViewClass {
    return [UXTableView class];
}

- (instancetype)init {
    return [self initWithStyle:UXTableViewStylePlain];
}

- (instancetype)initWithStyle:(UXTableViewStyle)style {
    if (style == UXTableViewStyleGrouped) {
        NSLog(@"%s: UXTableViewStyleGrouped is not supported", __PRETTY_FUNCTION__);
    }
    return [self initWithTableLayout:nil];
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

- (id<UXTableViewDelegate>)tableViewDelegate {
    return self.tableView.tableViewDelegate;
}

- (void)_updateContentInsetFromLayoutGuides {
    UXTableView *tableView = self.tableView;
    if (!tableView) {
        return;
    }
    CGFloat top = self.topLayoutGuide.length;
    CGFloat bottom = self.bottomLayoutGuide.length;
    tableView.enclosingScrollView.contentInsets = NSEdgeInsetsMake(top, 0, bottom, 0);
}

- (NSInteger)tableView:(UXTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UXTableViewCell *)tableView:(UXTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
