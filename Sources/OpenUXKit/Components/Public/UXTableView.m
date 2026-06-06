#import <objc/runtime.h>
#import "UXTableView.h"
#import "UXTableLayout.h"
#import "UXTableViewHeaderFooterView.h"
#import "UXCollectionDocumentView.h"
#import "UXCollectionViewDataSource.h"
#import "UXCollectionViewDelegate.h"
#import "UXCollectionViewFlowLayout.h"

static NSString *const UXTableHeaderViewReuseIdentifier = @"table_header_view_id";

@interface UXTableView () <UXCollectionViewDataSource, UXCollectionViewDelegate> {
    __weak id<UXTableViewDataSource> _tableViewDataSource;
    __weak id<UXTableViewDelegate> _tableViewDelegate;
    struct {
        unsigned int numberOfSectionsInTableView : 1;
        unsigned int titleForHeaderInSection : 1;
        unsigned int titleForFooterInSection : 1;
    } _tableViewDataSourceFlags;
    struct {
        unsigned int heightForRowAtIndexPath : 1;
        unsigned int heightForHeaderInSection : 1;
        unsigned int heightForFooterInSection : 1;
        unsigned int viewForHeaderInSection : 1;
        unsigned int viewForFooterInSection : 1;
        unsigned int willDisplayCell : 1;
        unsigned int didEndDisplayingCell : 1;
        unsigned int willSelectRow : 1;
        unsigned int didSelectRow : 1;
        unsigned int willDeselectRow : 1;
        unsigned int didDeselectRow : 1;
    } _tableViewDelegateFlags;
}

@end

@implementation UXTableView

@synthesize tableViewDataSource = _tableViewDataSource;
@synthesize tableViewDelegate = _tableViewDelegate;
@synthesize rowHeight = _rowHeight;
@synthesize separatorStyle = _separatorStyle;
@synthesize separatorColor = _separatorColor;
@synthesize separatorInset = _separatorInset;

+ (Class)documentClass {
    return [UXCollectionDocumentView class];
}

+ (UXCollectionViewScrollPosition)collectionViewScrollPositionFromScrollPosition:(UXTableViewScrollPosition)scrollPosition {
    switch (scrollPosition) {
        case UXTableViewScrollPositionTop: return UXCollectionViewScrollPositionTop;
        case UXTableViewScrollPositionMiddle: return UXCollectionViewScrollPositionCenteredVertically;
        case UXTableViewScrollPositionBottom: return UXCollectionViewScrollPositionBottom;
        default: return UXCollectionViewScrollPositionNone;
    }
}

#pragma mark - Init

- (instancetype)initWithFrame:(NSRect)frame {
    return [self initWithFrame:frame style:UXTableViewStylePlain];
}

- (instancetype)initWithFrame:(NSRect)frame style:(UXTableViewStyle)style {
    UXTableLayout *layout = [[UXTableLayout alloc] init];
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    layout.sectionInset = NSEdgeInsetsZero;
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.automaticallyAdjustsContentInsets = NO;
        [self registerClass:[UXTableViewHeaderFooterView class]
forSupplementaryViewOfKind:@"UXCollectionViewElementKindSectionHeader"
       withReuseIdentifier:UXTableHeaderViewReuseIdentifier];
        _rowHeight = 40.0;
        _separatorStyle = UXTableViewCellSeparatorStyleSingleLine;
        _separatorColor = [NSColor lightGrayColor];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frame tableLayout:(UXTableLayout *)layout {
    if (!layout) {
        layout = [[UXTableLayout alloc] init];
    }
    return [super initWithFrame:frame collectionViewLayout:layout];
}

#pragma mark - Data source / delegate bridging

- (void)setTableViewDataSource:(id<UXTableViewDataSource>)dataSource {
    _tableViewDataSource = dataSource;
    _tableViewDataSourceFlags.numberOfSectionsInTableView = [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)];
    _tableViewDataSourceFlags.titleForHeaderInSection = [dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)];
    _tableViewDataSourceFlags.titleForFooterInSection = [dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)];
    self.dataSource = self;
}

- (void)setTableViewDelegate:(id<UXTableViewDelegate>)delegate {
    _tableViewDelegate = delegate;
    _tableViewDelegateFlags.heightForRowAtIndexPath = [delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)];
    _tableViewDelegateFlags.heightForHeaderInSection = [delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)];
    _tableViewDelegateFlags.heightForFooterInSection = [delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)];
    _tableViewDelegateFlags.viewForHeaderInSection = [delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)];
    _tableViewDelegateFlags.viewForFooterInSection = [delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)];
    _tableViewDelegateFlags.willDisplayCell = [delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)];
    _tableViewDelegateFlags.didEndDisplayingCell = [delegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)];
    _tableViewDelegateFlags.willSelectRow = [delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)];
    _tableViewDelegateFlags.didSelectRow = [delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)];
    _tableViewDelegateFlags.willDeselectRow = [delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)];
    _tableViewDelegateFlags.didDeselectRow = [delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)];
    self.delegate = self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UXCollectionView *)collectionView {
    if (!_tableViewDataSourceFlags.numberOfSectionsInTableView) {
        return 1;
    }
    return [_tableViewDataSource numberOfSectionsInTableView:self];
}

- (NSInteger)collectionView:(UXCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_tableViewDataSource tableView:self numberOfRowsInSection:section];
}

- (UXCollectionViewCell *)collectionView:(UXCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_tableViewDataSource tableView:self cellForRowAtIndexPath:indexPath];
}

- (UXCollectionReusableView *)collectionView:(UXCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:@"UXCollectionViewElementKindSectionHeader"]) {
        if (_tableViewDelegateFlags.viewForHeaderInSection) {
            UXTableViewHeaderFooterView *view = [_tableViewDelegate tableView:self viewForHeaderInSection:indexPath.section];
            if (view) {
                return view;
            }
        }
        UXTableViewHeaderFooterView *headerView = [self dequeueReusableSupplementaryViewOfKind:kind
                                                                          withReuseIdentifier:UXTableHeaderViewReuseIdentifier
                                                                                 forIndexPath:indexPath];
        if (_tableViewDataSourceFlags.titleForHeaderInSection) {
            headerView.text = [_tableViewDataSource tableView:self titleForHeaderInSection:indexPath.section];
        }
        return headerView;
    }
    return nil;
}

- (void)collectionView:(UXCollectionView *)collectionView indexPathsForSelectedItemsDidAdd:(NSArray<NSIndexPath *> *)added remove:(NSArray<NSIndexPath *> *)removed animated:(BOOL)animated {
    if (_tableViewDelegateFlags.didSelectRow) {
        for (NSIndexPath *indexPath in added) {
            [_tableViewDelegate tableView:self didSelectRowAtIndexPath:indexPath];
        }
    }
    if (_tableViewDelegateFlags.didDeselectRow) {
        for (NSIndexPath *indexPath in removed) {
            [_tableViewDelegate tableView:self didDeselectRowAtIndexPath:indexPath];
        }
    }
}

#pragma mark - Counts / lookups

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return [self numberOfItemsInSection:section];
}

- (UXTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (UXTableViewCell *)[self cellForItemAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForSelectedRow {
    return self.indexPathsForSelectedItems.firstObject;
}

- (NSIndexPath *)indexPathForClickedRow {
    return nil;
}

- (NSArray<NSIndexPath *> *)indexPathsForVisibleRows {
    return nil;
}

- (UXTableViewHeaderFooterView *)headerViewForSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    return (UXTableViewHeaderFooterView *)[self viewForSupplementaryElementOfKind:@"UXCollectionViewElementKindSectionHeader"
                                                                      atIndexPath:indexPath];
}

- (UXTableViewHeaderFooterView *)footerViewForSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    return (UXTableViewHeaderFooterView *)[self viewForSupplementaryElementOfKind:@"UXCollectionViewElementKindSectionFooter"
                                                                      atIndexPath:indexPath];
}

#pragma mark - Selection / scrolling

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UXTableViewScrollPosition)scrollPosition {
    UXCollectionViewScrollPosition position = [self.class collectionViewScrollPositionFromScrollPosition:scrollPosition];
    [self selectItemAtIndexPath:indexPath animated:animated scrollPosition:position];
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self deselectItemAtIndexPath:indexPath animated:animated];
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UXTableViewScrollPosition)scrollPosition animated:(BOOL)animated {
    UXCollectionViewScrollPosition position = [self.class collectionViewScrollPositionFromScrollPosition:scrollPosition];
    [self scrollToItemAtIndexPath:indexPath atScrollPosition:position animated:animated];
}

#pragma mark - Updates (stubs - mirror UIKit API)

- (void)beginUpdates {}
- (void)endUpdates {}
- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UXTableViewRowAnimation)animation {}
- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UXTableViewRowAnimation)animation {}
- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UXTableViewRowAnimation)animation {}
- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UXTableViewRowAnimation)animation {}
- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UXTableViewRowAnimation)animation {}
- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {}

#pragma mark - Registration / dequeue

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    [self registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (__kindof UXTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    return nil;
}

- (__kindof UXTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    return (__kindof UXTableViewCell *)[super dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

- (__kindof UXTableViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    return (__kindof UXTableViewCell *)[super dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

- (void)registerClass:(Class)viewClass forHeaderFooterViewReuseIdentifier:(NSString *)identifier {
    [self registerClass:viewClass
forSupplementaryViewOfKind:@"UXCollectionViewElementKindSectionHeader"
   withReuseIdentifier:identifier];
}

- (__kindof UXTableViewHeaderFooterView *)dequeueReusableHeaderFooterViewWithIdentifier:(NSString *)identifier {
    return nil;
}

- (__kindof UXTableViewHeaderFooterView *)dequeueReusableHeaderFooterViewWithReuseIdentifier:(NSString *)identifier forSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    return (UXTableViewHeaderFooterView *)[self dequeueReusableSupplementaryViewOfKind:@"UXCollectionViewElementKindSectionHeader"
                                                                   withReuseIdentifier:identifier
                                                                          forIndexPath:indexPath];
}

#pragma mark - Misc SPI

- (CGFloat)alpha {
    return self.alphaValue;
}

- (void)setAlpha:(CGFloat)alpha {
    self.alphaValue = alpha;
}

- (BOOL)isUserInteractionEnabled {
    return objc_getAssociatedObject(self, @selector(isUserInteractionEnabled)) ? [objc_getAssociatedObject(self, @selector(isUserInteractionEnabled)) boolValue] : YES;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    objc_setAssociatedObject(self, @selector(isUserInteractionEnabled), @(userInteractionEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)overdrawEnabled {
    return YES;
}

- (void)setOverdrawEnabled:(BOOL)overdrawEnabled {
}

- (BOOL)_floatingHeadersDisabled {
    return NO;
}

- (void)_setFloatingHeadersDisabled:(BOOL)disabled {
}

- (void)_checkForAccessoryViewsInScrollerAreas {
}

- (void)_menuDidBeginTracking:(NSNotification *)notification {
}

- (void)_menuDidEndTracking:(NSNotification *)notification {
}

- (CGSize)sizeThatFits:(CGSize)size {
    UXCollectionViewLayout *layout = self.collectionViewLayout;
    [layout invalidateLayout];
    [layout prepareLayout];
    CGSize content = layout.collectionViewContentSize;
    return CGSizeMake(size.width, content.height);
}

- (void)sizeToFit {
    CGSize size = [self sizeThatFits:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
    NSRect frame = self.frame;
    frame.size.height = size.height;
    self.frame = frame;
}

#pragma mark - Key/menu/scroll events (defaults)

- (void)deleteWordBackward:(id)sender {
}

- (void)moveRight:(id)sender {
}

#pragma mark - UXCollectionViewDelegate flow layout

- (CGSize)collectionView:(UXCollectionView *)collectionView layout:(UXCollectionViewLayout *)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = _rowHeight;
    if (_tableViewDelegateFlags.heightForRowAtIndexPath) {
        height = [_tableViewDelegate tableView:self heightForRowAtIndexPath:indexPath];
    }
    return CGSizeMake(self.bounds.size.width, height);
}

- (CGSize)collectionView:(UXCollectionView *)collectionView layout:(UXCollectionViewLayout *)layout referenceSizeForHeaderInSection:(NSInteger)section {
    if (_tableViewDelegateFlags.heightForHeaderInSection) {
        CGFloat h = [_tableViewDelegate tableView:self heightForHeaderInSection:section];
        return CGSizeMake(self.bounds.size.width, h);
    }
    if (_tableViewDataSourceFlags.titleForHeaderInSection) {
        return CGSizeMake(self.bounds.size.width, 28.0);
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UXCollectionView *)collectionView layout:(UXCollectionViewLayout *)layout referenceSizeForFooterInSection:(NSInteger)section {
    if (_tableViewDelegateFlags.heightForFooterInSection) {
        CGFloat h = [_tableViewDelegate tableView:self heightForFooterInSection:section];
        return CGSizeMake(self.bounds.size.width, h);
    }
    return CGSizeZero;
}

- (void)collectionView:(UXCollectionView *)collectionView itemWasRightClickedAtIndexPath:(NSIndexPath *)indexPath withEvent:(NSEvent *)event {
}

- (void)collectionView:(UXCollectionView *)collectionView layout:(UXCollectionViewLayout *)layout supplementaryViewDidBeginFloatingAtIndexPath:(NSIndexPath *)indexPath kind:(NSString *)kind {
    UXTableViewHeaderFooterView *view = (UXTableViewHeaderFooterView *)[self viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    if ([view respondsToSelector:@selector(setFloating:)]) {
        [(id)view setFloating:YES];
    }
}

- (void)collectionView:(UXCollectionView *)collectionView layout:(UXCollectionViewLayout *)layout supplementaryViewDidEndFloatingAtIndexPath:(NSIndexPath *)indexPath kind:(NSString *)kind {
    UXTableViewHeaderFooterView *view = (UXTableViewHeaderFooterView *)[self viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    if ([view respondsToSelector:@selector(setFloating:)]) {
        [(id)view setFloating:NO];
    }
}

@end
