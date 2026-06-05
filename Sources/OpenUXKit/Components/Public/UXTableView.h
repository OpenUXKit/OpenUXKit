#import <OpenUXKit/UXCollectionView.h>
#import <OpenUXKit/UXTableViewCell.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXTableView, UXTableLayout, UXTableViewHeaderFooterView;

typedef NS_ENUM(NSInteger, UXTableViewStyle) {
    UXTableViewStylePlain = 0,
    UXTableViewStyleGrouped = 1,
} NS_SWIFT_NAME(UXTableView.Style);

typedef NS_ENUM(NSInteger, UXTableViewScrollPosition) {
    UXTableViewScrollPositionNone = 0,
    UXTableViewScrollPositionTop,
    UXTableViewScrollPositionMiddle,
    UXTableViewScrollPositionBottom,
} NS_SWIFT_NAME(UXTableView.ScrollPosition);

typedef NS_ENUM(NSInteger, UXTableViewRowAnimation) {
    UXTableViewRowAnimationFade,
    UXTableViewRowAnimationRight,
    UXTableViewRowAnimationLeft,
    UXTableViewRowAnimationTop,
    UXTableViewRowAnimationBottom,
    UXTableViewRowAnimationNone,
    UXTableViewRowAnimationMiddle,
    UXTableViewRowAnimationAutomatic = 100,
} NS_SWIFT_NAME(UXTableView.RowAnimation);

typedef NS_ENUM(NSInteger, UXTableViewCellSeparatorStyle) {
    UXTableViewCellSeparatorStyleNone = 0,
    UXTableViewCellSeparatorStyleSingleLine,
} NS_SWIFT_NAME(UXTableViewCell.SeparatorStyle);

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
- (CGFloat)tableView:(UXTableView *)tableView heightForFooterInSection:(NSInteger)section;
- (nullable UXTableViewHeaderFooterView *)tableView:(UXTableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (nullable UXTableViewHeaderFooterView *)tableView:(UXTableView *)tableView viewForFooterInSection:(NSInteger)section;
- (void)tableView:(UXTableView *)tableView willDisplayCell:(UXTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UXTableView *)tableView didEndDisplayingCell:(UXTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UXTableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UXTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UXTableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UXTableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXTableView : UXCollectionView

- (instancetype)initWithFrame:(NSRect)frame style:(UXTableViewStyle)style;
- (instancetype)initWithFrame:(NSRect)frame tableLayout:(nullable UXTableLayout *)layout;

@property (nonatomic, weak, nullable) id<UXTableViewDataSource> tableViewDataSource;
@property (nonatomic, weak, nullable) id<UXTableViewDelegate> tableViewDelegate;

@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) UXTableViewCellSeparatorStyle separatorStyle;
@property (nonatomic, strong, nullable) NSColor *separatorColor;
@property (nonatomic) NSEdgeInsets separatorInset;
@property (nonatomic) CGFloat alpha;
@property (nonatomic, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;
@property (nonatomic) BOOL overdrawEnabled;
@property (nonatomic, setter=_setFloatingHeadersDisabled:) BOOL _floatingHeadersDisabled;

- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (nullable UXTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)indexPathForSelectedRow;
- (nullable NSIndexPath *)indexPathForClickedRow;
- (nullable NSArray<NSIndexPath *> *)indexPathsForVisibleRows;

- (nullable UXTableViewHeaderFooterView *)headerViewForSection:(NSInteger)section;
- (nullable UXTableViewHeaderFooterView *)footerViewForSection:(NSInteger)section;

- (void)selectRowAtIndexPath:(nullable NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UXTableViewScrollPosition)scrollPosition;
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UXTableViewScrollPosition)scrollPosition animated:(BOOL)animated;

- (void)beginUpdates;
- (void)endUpdates;
- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UXTableViewRowAnimation)animation;
- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UXTableViewRowAnimation)animation;
- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UXTableViewRowAnimation)animation;
- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UXTableViewRowAnimation)animation;
- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UXTableViewRowAnimation)animation;
- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier;
- (__kindof UXTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (__kindof UXTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
- (__kindof UXTableViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

- (void)registerClass:(nullable Class)viewClass forHeaderFooterViewReuseIdentifier:(NSString *)identifier;
- (nullable __kindof UXTableViewHeaderFooterView *)dequeueReusableHeaderFooterViewWithIdentifier:(NSString *)identifier;
- (nullable __kindof UXTableViewHeaderFooterView *)dequeueReusableHeaderFooterViewWithReuseIdentifier:(NSString *)identifier forSection:(NSInteger)section;

+ (UXCollectionViewScrollPosition)collectionViewScrollPositionFromScrollPosition:(UXTableViewScrollPosition)scrollPosition;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
