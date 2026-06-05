#import <OpenUXKit/UXBarItem.h>
#import <OpenUXKit/UXKitAppearance.h>
#import <OpenUXKit/UXKitDefines.h>

@class UXViewController, UXView, NSColor, NSImage, NSMenu, NSToolbarItem;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSInteger, UXBarButtonItemStyle) {
    UXBarButtonItemStylePlain,
    UXBarButtonItemStyleBordered,
    UXBarButtonItemStyleDone,
} NS_SWIFT_NAME(UXBarButtonItem.Style);

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
} NS_SWIFT_NAME(UXBarButtonItem.SystemItem);

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXBarButtonItem : UXBarItem <UXKitAppearance>

@property (nonatomic, copy, nullable) NSString *label;
@property (nonatomic, copy, nullable) NSString *identifier;
@property (nonatomic, strong, nullable) __kindof NSView *customView;
@property (nonatomic) CGFloat width;
@property (nonatomic) UXBarButtonItemStyle style;
@property (nonatomic) BOOL ignoresMultiClick;
@property (nonatomic) NSControlStateValue buttonState;
@property (nonatomic) NSEventModifierFlags keyEquivalentModifierMask;
@property (nonatomic, strong, nullable) NSString *keyEquivalent;
@property (nonatomic, strong, nullable) NSString *toolTip;
@property (nonatomic, weak, nullable) id target;
@property (nonatomic, nullable) SEL action;
@property (nonatomic, copy, nullable) NSColor *backgroundColor;
@property (nonatomic) float visibilityPriority;
@property (nonatomic, weak, nullable) NSToolbarItem *toolbarItem;
@property (nonatomic, getter=isNavigational) BOOL navigational;
@property (nonatomic, strong, nullable) NSMenu *menu;
@property (nonatomic, getter=isHidden) BOOL hidden;
@property (nonatomic, readonly) BOOL isSystemItem;
@property (nonatomic, readonly, nullable) NSView *_view;
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
