#import <OpenUXKit/UXBarItem.h>
#import <OpenUXKit/UXKitAppearance.h>

@class UXViewController, UXView;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSInteger, UXBarButtonItemStyle) {
    UXBarButtonItemStylePlain,
    UXBarButtonItemStyleBordered,
    UXBarButtonItemStyleDone,
};

typedef NS_ENUM(NSInteger, UXBarButtonSystemItem) {
    UXBarButtonSystemItemNone = -1,
    UXBarButtonSystemItemDone,
    UXBarButtonSystemItemCancel,
    UXBarButtonSystemItemEdit,
    UXBarButtonSystemItemSave,
    UXBarButtonSystemItemAdd,
    UXBarButtonSystemItemFlexibleSpace,
    UXBarButtonSystemItemFixedSpace,
    UXBarButtonSystemItemCompose,
    UXBarButtonSystemItemReply,
    UXBarButtonSystemItemAction,
    UXBarButtonSystemItemOrganize,
    UXBarButtonSystemItemBookmarks,
    UXBarButtonSystemItemSearch,
    UXBarButtonSystemItemRefresh,
    UXBarButtonSystemItemStop,
    UXBarButtonSystemItemCamera,
    UXBarButtonSystemItemTrash,
    UXBarButtonSystemItemPlay,
    UXBarButtonSystemItemPause,
    UXBarButtonSystemItemRewind,
    UXBarButtonSystemItemFastForward,
    UXBarButtonSystemItemUndo,
    UXBarButtonSystemItemRedo,
    UXBarButtonSystemItemPageCurl,
    UXBarButtonSystemItemClose
};

@interface UXBarButtonItem : UXBarItem <UXKitAppearance>

@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) NSView *customView;
@property (nonatomic) CGFloat width;
@property (nonatomic) UXBarButtonItemStyle style;
@property (nonatomic) BOOL ignoresMultiClick;
@property (nonatomic) NSControlStateValue buttonState;
@property (nonatomic) NSEventModifierFlags keyEquivalentModifierMask;
@property (nonatomic, strong) NSString *keyEquivalent;
@property (nonatomic, strong) NSString *toolTip;
@property (nonatomic, weak, nullable) id target;
@property (nonatomic, nullable) SEL action;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithStyle:(UXBarButtonItemStyle)style target:(nullable id)target action:(nullable SEL)action NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithContentViewController:(UXViewController *)contentViewController;
- (instancetype)initWithCustomView:(NSView *)customView;
- (instancetype)initWithBarButtonSystemItem:(UXBarButtonSystemItem)systemItem target:(nullable id)target action:(nullable SEL)action;
- (instancetype)initWithBarButtonSystemItem:(UXBarButtonSystemItem)systemItem width:(CGFloat)width target:(nullable id)target action:(nullable SEL)action;
- (instancetype)initWithTitle:(NSString *)title style:(UXBarButtonItemStyle)style target:(nullable id)target action:(nullable SEL)action;
- (instancetype)initWithImage:(NSImage *)image style:(UXBarButtonItemStyle)style target:(nullable id)target action:(nullable SEL)action;

@end


NS_HEADER_AUDIT_END(nullability, sendability)
