#import <OpenUXKit/UXCollectionViewController.h>
#import <OpenUXKit/UXTableView.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXTableLayout;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXTableViewController : UXCollectionViewController <UXTableViewDataSource, UXTableViewDelegate>

- (instancetype)initWithTableLayout:(nullable UXTableLayout *)layout;

@property (nonatomic, readonly) UXTableView *tableView;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
