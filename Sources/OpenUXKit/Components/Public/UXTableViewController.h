#import "UXCollectionViewController.h"
#import "UXTableView.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXTableLayout;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXTableViewController : UXCollectionViewController <UXTableViewDataSource, UXTableViewDelegate>

- (instancetype)init;
- (instancetype)initWithStyle:(UXTableViewStyle)style;
- (instancetype)initWithTableLayout:(nullable UXTableLayout *)layout;

@property (nonatomic, readonly) UXTableView *tableView;
@property (nonatomic, readonly, nullable) id<UXTableViewDelegate> tableViewDelegate;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
