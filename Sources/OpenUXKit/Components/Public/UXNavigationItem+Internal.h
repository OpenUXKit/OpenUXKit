#import <OpenUXKit/UXNavigationItem.h>

NS_ASSUME_NONNULL_BEGIN

@interface UXNavigationItem () {
    NSArray *_leftBarButtonItems;
    NSArray *_rightBarButtonItems;
    NSTextField *_internalTitleView;
}

@property (nonatomic, strong, nullable) UXBarButtonItem *switchLibraryButtonItem;
@property (nonatomic, readonly, nullable) NSTextField *internalTitleView;
@property (nonatomic, strong, nullable) NSView *condensedTitleView;
@property (nonatomic) BOOL leftItemsSupplementBackButton;
@property (nonatomic) BOOL hidesGlobalTrailingView;
@property (nonatomic) BOOL hidesAlternateTitleView;
@property (nonatomic) NSEdgeInsets layoutMargins;
@property (nonatomic, copy, nullable) NSString *subtitle;
@property (nonatomic) BOOL useWindowForTitleOutput;
@property (nonatomic, strong, nullable) UXBarButtonItem *progressButtonItem;
@property (nonatomic, strong, nullable) NSToolbarItemGroup *centerToolbarItemGroup;

+ (NSArray<NSString *> *)keyPathsToObserve;
- (void)_updateInternalTitleView;

@end

NS_ASSUME_NONNULL_END
