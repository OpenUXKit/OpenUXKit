#import <AppKit/AppKit.h>

@class UXBarButtonItem;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXNavigationItem : NSObject <NSUserInterfaceItemIdentification>

@property (nonatomic, strong, nullable) NSString *title;
@property (nonatomic, strong, nullable) NSView *titleView;
@property (nonatomic, copy, nullable) NSString *prompt;
@property (nonatomic, strong, nullable) UXBarButtonItem *backBarButtonItem;
@property (nonatomic) BOOL hidesBackButton;
@property (nonatomic, strong, nullable) UXBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong, nullable) UXBarButtonItem *rightBarButtonItem;
@property (nonatomic, strong, nullable) NSArray<UXBarButtonItem *> *leftBarButtonItems;
@property (nonatomic, strong, nullable) NSArray<UXBarButtonItem *> *rightBarButtonItems;
@property (nonatomic, strong, nullable) NSArray<UXBarButtonItem *> *leadingBarButtonItems;
@property (nonatomic, strong, nullable) NSArray<UXBarButtonItem *> *trailingBarButtonItems;

- (instancetype)initWithTitle:(NSString *)title NS_DESIGNATED_INITIALIZER;
- (void)setLeadingBarButtonItems:(nullable NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated;
- (void)setTrailingBarButtonItems:(nullable NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated;
- (void)setLeftBarButtonItem:(nullable UXBarButtonItem *)item animated:(BOOL)animated;
- (void)setLeftBarButtonItems:(nullable NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated;
- (void)setRightBarButtonItem:(nullable UXBarButtonItem *)item animated:(BOOL)animated;
- (void)setRightBarButtonItems:(nullable NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated;

@end


NS_HEADER_AUDIT_END(nullability, sendability)
