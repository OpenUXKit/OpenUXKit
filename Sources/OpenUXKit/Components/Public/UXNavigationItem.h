

#import <AppKit/AppKit.h>

@class UXBarButtonItem;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXNavigationItem : NSObject <NSUserInterfaceItemIdentification>
@property (nonatomic, strong) NSView *condensedTitleView;
@property (nonatomic) BOOL leftItemsSupplementBackButton;
@property (nonatomic) BOOL hidesGlobalTrailingView;
@property (nonatomic) BOOL hidesAlternateTitleView;
@property (nonatomic) BOOL hidesBackButton;
@property (nonatomic, copy) NSString *prompt;
@property (nonatomic, strong) NSView *titleView;
@property (nonatomic, strong, nullable) UXBarButtonItem *backBarButtonItem;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UXBarButtonItem *rightBarButtonItem;
@property (nonatomic, strong) NSArray *rightBarButtonItems;
@property (nonatomic, strong) NSArray *leftBarButtonItems;
@property (nonatomic, strong) UXBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UXBarButtonItem *switchLibraryButtonItem;
@property (nonatomic) NSEdgeInsets layoutMargins;
@property (nonatomic, strong) NSArray *trailingBarButtonItems;
@property (nonatomic, readonly) NSTextField *internalTitleView;
@property (nonatomic, strong) NSArray *leadingBarButtonItems;
+ (NSArray<NSString *> *)keyPathsToObserve;
- (instancetype)initWithTitle:(NSString *)title;
- (void)_updateInternalTitleView;
- (void)setLeadingBarButtonItems:(NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated;
- (void)setTrailingBarButtonItems:(NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated;
- (void)setLeftBarButtonItem:(UXBarButtonItem *)item animated:(BOOL)animated;
- (void)setLeftBarButtonItems:(NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated;
- (void)setRightBarButtonItem:(UXBarButtonItem *)item animated:(BOOL)animated;
- (void)setRightBarButtonItems:(NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated;

@end


NS_HEADER_AUDIT_END(nullability, sendability)
