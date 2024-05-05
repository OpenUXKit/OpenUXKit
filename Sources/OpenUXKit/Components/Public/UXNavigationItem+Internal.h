#import <OpenUXKit/UXNavigationItem.h>

NS_ASSUME_NONNULL_BEGIN

@interface UXNavigationItem ()
{
    NSArray *_leftBarButtonItems;    // 8 = 0x8
    NSArray *_rightBarButtonItems;    // 16 = 0x10
    NSTextField *_internalTitleView;    // 24 = 0x18
    BOOL _hidesBackButton;    // 32 = 0x20
    BOOL _hidesAlternateTitleView;    // 33 = 0x21
    BOOL _hidesGlobalTrailingView;    // 34 = 0x22
    BOOL _leftItemsSupplementBackButton;    // 35 = 0x23
    NSString *_title;    // 40 = 0x28
    UXBarButtonItem *_backBarButtonItem;    // 48 = 0x30
    NSView *_titleView;    // 56 = 0x38
    NSString *_prompt;    // 64 = 0x40
    NSView *_condensedTitleView;    // 72 = 0x48
}
@property (nonatomic, strong, nullable) UXBarButtonItem *switchLibraryButtonItem;
@property (nonatomic, readonly, nullable) NSTextField *internalTitleView;
@property (nonatomic, strong, nullable) NSView *condensedTitleView;
@property (nonatomic) BOOL leftItemsSupplementBackButton;
@property (nonatomic) BOOL hidesGlobalTrailingView;
@property (nonatomic) BOOL hidesAlternateTitleView;
@property (nonatomic) NSEdgeInsets layoutMargins;
+ (NSArray<NSString *> *)keyPathsToObserve;
- (void)_updateInternalTitleView;
@end

NS_ASSUME_NONNULL_END
