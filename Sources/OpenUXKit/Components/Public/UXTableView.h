#import <OpenUXKit/UXCollectionView.h>
#import <OpenUXKit/UXTableViewCell.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXTableView, UXTableLayout;

NS_SWIFT_UI_ACTOR
@protocol UXTableViewDataSource <NSObject>
@required
- (NSInteger)tableView:(UXTableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UXTableViewCell *)tableView:(UXTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (NSInteger)numberOfSectionsInTableView:(UXTableView *)tableView;
- (nullable NSString *)tableView:(UXTableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (nullable NSString *)tableView:(UXTableView *)tableView titleForFooterInSection:(NSInteger)section;
@end

NS_SWIFT_UI_ACTOR
@protocol UXTableViewDelegate <NSObject>
@optional
- (CGFloat)tableView:(UXTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UXTableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (void)tableView:(UXTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UXTableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXTableView : UXCollectionView

- (instancetype)initWithFrame:(NSRect)frame tableLayout:(nullable UXTableLayout *)layout;

@property (nonatomic, weak, nullable) id<UXTableViewDataSource> tableViewDataSource;
@property (nonatomic, weak, nullable) id<UXTableViewDelegate> tableViewDelegate;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
