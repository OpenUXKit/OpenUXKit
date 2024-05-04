

@class UXTableView;
@protocol UXTableViewDelegate;

@interface UXTableViewController
{
    id <UXTableViewDelegate> _tableViewDelegate;	// 16 = 0x10
}

+ (Class)collectionViewClass;

@property(readonly, nonatomic) id <UXTableViewDelegate> tableViewDelegate; // @synthesize tableViewDelegate=_tableViewDelegate;
- (void)_updateContentInsetFromLayoutGuides;
- (id)preferredFirstResponder;
- (void)viewDidAppear;
- (void)viewWillAppear;
- (void)viewDidLoad;
- (void)didUpdateLayoutGuides;
- (void)viewDidLayoutSubviews;
@property(readonly, nonatomic) UXTableView *tableView;
- (id)initWithNibName:(id)arg1 bundle:(id)arg2;
- (id)init;
- (id)initWithStyle:(NSInteger)arg1;

@end

