#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

@class UXBarButtonItem;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXNavigationItem : NSObject

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *subtitle;
@property (nonatomic, strong, nullable) NSView *titleView;
@property (nonatomic, copy, nullable) NSString *prompt;
@property (nonatomic, strong, nullable) UXBarButtonItem *backBarButtonItem;
@property (nonatomic) BOOL hidesBackButton;
@property (nonatomic) BOOL hidesSidebarToggleButton;
@property (nonatomic) BOOL useWindowForTitleOutput;
@property (nonatomic, copy, nullable) NSString *identifier;
@property (nonatomic, strong, nullable) UXBarButtonItem *progressButtonItem;
@property (nonatomic, strong, nullable) NSToolbarItemGroup *centerToolbarItemGroup;
@property (nonatomic, strong, nullable) UXBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong, nullable) UXBarButtonItem *rightBarButtonItem;
@property (nonatomic, strong, nullable) NSArray<UXBarButtonItem *> *leftBarButtonItems;
@property (nonatomic, strong, nullable) NSArray<UXBarButtonItem *> *rightBarButtonItems;
@property (nonatomic, strong, nullable) NSArray<UXBarButtonItem *> *leadingBarButtonItems;
@property (nonatomic, strong, nullable) NSArray<UXBarButtonItem *> *trailingBarButtonItems;

- (instancetype)initWithTitle:(NSString *)title NS_DESIGNATED_INITIALIZER;
- (void)setLeadingBarButtonItems:(nullable NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated NS_SWIFT_NAME(setLeadingBarButtonItems(_:animated:));
- (void)setTrailingBarButtonItems:(nullable NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated NS_SWIFT_NAME(setTrailingBarButtonItems(_:animated:));
- (void)setLeftBarButtonItem:(nullable UXBarButtonItem *)item animated:(BOOL)animated NS_SWIFT_NAME(setLeftBarButtonItem(_:animated:));
- (void)setLeftBarButtonItems:(nullable NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated NS_SWIFT_NAME(setLeftBarButtonItems(_:animated:));
- (void)setRightBarButtonItem:(nullable UXBarButtonItem *)item animated:(BOOL)animated NS_SWIFT_NAME(setRightBarButtonItem(_:animated:));
- (void)setRightBarButtonItems:(nullable NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated NS_SWIFT_NAME(setRightBarButtonItems(_:animated:));

@end


NS_HEADER_AUDIT_END(nullability, sendability)
