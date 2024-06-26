

@class NSColor, NSIndexPath, NSMenu;
@protocol UXTableViewDataSource, UXTableViewDelegate;

@interface UXTableView
{
    struct {
        unsigned int delegateImplementsTitleForHeaderInSection:1;
        unsigned int delegateImplementsTitleForFooterInSection:1;
        unsigned int delegateImplementsHeaderViewForSection:1;
        unsigned int delegateImplementsFooterViewForSection:1;
        unsigned int delegateImplementsHeightForHeaderInSection:1;
        unsigned int delegateImplementsHeightForRowAtIndexPath:1;
        unsigned int delegateImplementsDidSelectionRowAtIndexPath:1;
        unsigned int delegateImplementsShouldHighlightRowAtIndexPath:1;
        unsigned int delegateImplementsDidHighlightRowAtIndexPath:1;
        unsigned int delegateImplementsDidUnhighlightRowAtIndexPath:1;
        unsigned int delegateImplementsEditingStyleForRowAtIndexPath:1;
        unsigned int delegateImplementsDidDeselectRowAtIndexPath:1;
    } _tableViewDelegateFlags;	// 128 = 0x80
    struct {
        unsigned int dataSourceImplementsNumberOfSectionsInTableView:1;
        unsigned int dataSourceImplementsCanEditRowAtIndexPath:1;
        unsigned int dataSourceImplementsCommitEditingStyleForRowAtIndexPath:1;
    } _tableViewDataSourceFlags;	// 132 = 0x84
    NSIndexPath *_highlightedIndexPath;	// 136 = 0x88
    NSMenu *_observedMenu;	// 144 = 0x90
    BOOL __floatingHeadersDisabled;	// 152 = 0x98
    id <UXTableViewDataSource> _tableViewDataSource;	// 160 = 0xa0
    id <UXTableViewDelegate> _tableViewDelegate;	// 168 = 0xa8
    CGFloat _rowHeight;	// 176 = 0xb0
    NSInteger _separatorStyle;	// 184 = 0xb8
    NSColor *_separatorColor;	// 192 = 0xc0
    NSEdgeInsets _separatorInset;	// 200 = 0xc8
}

+ (NSUInteger)collectionViewScrollPositionFromScrollPosition:(NSInteger)arg1;
+ (Class)documentClass;

@property(nonatomic, setter=_setFloatingHeadersDisabled:) BOOL _floatingHeadersDisabled; // @synthesize _floatingHeadersDisabled=__floatingHeadersDisabled;
@property(nonatomic) NSEdgeInsets separatorInset; // @synthesize separatorInset=_separatorInset;
@property(copy, nonatomic) NSColor *separatorColor; // @synthesize separatorColor=_separatorColor;
@property(nonatomic) NSInteger separatorStyle; // @synthesize separatorStyle=_separatorStyle;
@property(nonatomic) CGFloat rowHeight; // @synthesize rowHeight=_rowHeight;
@property(nonatomic) __weak id <UXTableViewDelegate> tableViewDelegate; // @synthesize tableViewDelegate=_tableViewDelegate;
@property(nonatomic) __weak id <UXTableViewDataSource> tableViewDataSource; // @synthesize tableViewDataSource=_tableViewDataSource;
@property(nonatomic) CGFloat alpha;
- (void)_checkForAccessoryViewsInScrollerAreas;
- (void)collectionView:(id)arg1 layout:(id)arg2 supplementaryViewDidEndFloatingAtIndexPath:(id)arg3 kind:(id)arg4;
- (void)collectionView:(id)arg1 layout:(id)arg2 supplementaryViewDidBeginFloatingAtIndexPath:(id)arg3 kind:(id)arg4;
- (CGSize)collectionView:(id)arg1 layout:(id)arg2 sizeForItemAtIndexPath:(id)arg3;
- (CGSize)collectionView:(id)arg1 layout:(id)arg2 referenceSizeForFooterInSection:(NSInteger)arg3;
- (CGSize)collectionView:(id)arg1 layout:(id)arg2 referenceSizeForHeaderInSection:(NSInteger)arg3;
- (void)collectionView:(id)arg1 itemWasRightClickedAtIndexPath:(id)arg2 withEvent:(id)arg3;
- (NSInteger)numberOfSectionsInCollectionView:(id)arg1;
- (id)collectionView:(id)arg1 cellForItemAtIndexPath:(id)arg2;
- (NSInteger)collectionView:(id)arg1 numberOfItemsInSection:(NSInteger)arg2;
- (id)collectionView:(id)arg1 viewForSupplementaryElementOfKind:(id)arg2 atIndexPath:(id)arg3;
- (void)deleteWordBackward:(id)arg1;
- (void)moveRight:(id)arg1;
- (void)keyDown:(id)arg1;
- (void)mouseDragged:(id)arg1;
- (void)mouseUp:(id)arg1;
- (void)mouseDown:(id)arg1;
- (BOOL)acceptsFirstResponder;
- (id)menuForEvent:(id)arg1;
- (void)_menuDidEndTracking:(id)arg1;
- (void)_menuDidBeginTracking:(id)arg1;
- (void)scrollToRowAtIndexPath:(id)arg1 atScrollPosition:(NSInteger)arg2 animated:(BOOL)arg3;
- (void)deselectRowAtIndexPath:(id)arg1 animated:(BOOL)arg2;
- (void)selectRowAtIndexPath:(id)arg1 animated:(BOOL)arg2 scrollPosition:(NSInteger)arg3;
- (id)indexPathForSelectedRow;
- (id)indexPathForClickedRow;
- (id)footerViewForSection:(NSInteger)arg1;
- (id)headerViewForSection:(NSInteger)arg1;
- (void)moveRowAtIndexPath:(id)arg1 toIndexPath:(id)arg2;
- (void)reloadRowsAtIndexPaths:(id)arg1 withRowAnimation:(NSInteger)arg2;
- (void)deleteRowsAtIndexPaths:(id)arg1 withRowAnimation:(NSInteger)arg2;
- (void)insertRowsAtIndexPaths:(id)arg1 withRowAnimation:(NSInteger)arg2;
- (void)deleteSections:(id)arg1 withRowAnimation:(NSInteger)arg2;
- (void)insertSections:(id)arg1 withRowAnimation:(NSInteger)arg2;
- (void)endUpdates;
- (void)beginUpdates;
- (id)indexPathsForVisibleRows;
- (void)sizeToFit;
- (CGSize)sizeThatFits:(CGSize)arg1;
- (NSInteger)numberOfRowsInSection:(NSInteger)arg1;
- (id)dequeueReusableHeaderFooterViewWithIdentifier:(id)arg1;
- (id)dequeueReusableHeaderFooterViewWithReuseIdentifier:(id)arg1 forSection:(NSInteger)arg2;
- (id)dequeueReusableCellWithReuseIdentifier:(id)arg1 forIndexPath:(id)arg2;
- (id)dequeueReusableCellWithIdentifier:(id)arg1;
- (id)dequeueReusableCellWithIdentifier:(id)arg1 forIndexPath:(id)arg2;
- (void)registerClass:(Class)arg1 forHeaderFooterViewReuseIdentifier:(id)arg2;
- (void)registerClass:(Class)arg1 forCellReuseIdentifier:(id)arg2;
- (id)cellForRowAtIndexPath:(id)arg1;
- (void)setDelegate:(id)arg1;
- (void)setDataSource:(id)arg1;
- (BOOL)overdrawEnabled;
- (void)setOverdrawEnabled:(BOOL)arg1;
- (id)init;
- (id)initWithCoder:(id)arg1;
- (id)initWithFrame:(CGRect)arg1;
- (id)initWithFrame:(CGRect)arg1 style:(NSInteger)arg2;
- (id)initWithFrame:(CGRect)arg1 collectionViewLayout:(id)arg2;
- (void)setNeedsDisplay:(BOOL)arg1;
@property(nonatomic, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;

@end

