#import <OpenUXKit/UXTableView.h>
#import <OpenUXKit/UXTableLayout.h>

@interface UXTableView () {
    __weak id<UXTableViewDataSource> _tableViewDataSource;
    __weak id<UXTableViewDelegate> _tableViewDelegate;
}
@end

@implementation UXTableView

@synthesize tableViewDataSource = _tableViewDataSource;
@synthesize tableViewDelegate = _tableViewDelegate;

- (instancetype)initWithFrame:(NSRect)frame tableLayout:(UXTableLayout *)layout {
    if (!layout) {
        layout = [[UXTableLayout alloc] init];
    }
    return [super initWithFrame:frame collectionViewLayout:layout];
}

- (instancetype)initWithFrame:(NSRect)frame {
    return [self initWithFrame:frame tableLayout:nil];
}

@end
