#import <OpenUXKit/UXBarItem.h>
#import <OpenUXKit/UXKitAppearance.h>
#import <OpenUXKit/UXKitDefines.h>

@class UXViewController, UXView, NSColor, NSImage, NSMenu, NSToolbarItem;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSInteger, UXBarButtonItemStyle) {
    UXBarButtonItemStylePlain    = 0,
    UXBarButtonItemStyleBordered = 1,
    UXBarButtonItemStyleDone     = 2,
} NS_SWIFT_NAME(UXBarButtonItem.Style);

typedef NSString *UXBarButtonItemIdentifier NS_TYPED_EXTENSIBLE_ENUM NS_SWIFT_NAME(UXBarButtonItem.Identifier);

typedef float UXBarButtonItemVisibilityPriority NS_TYPED_EXTENSIBLE_ENUM NS_SWIFT_NAME(UXBarButtonItem.VisibilityPriority);

UXKIT_EXTERN const UXBarButtonItemVisibilityPriority UXBarButtonItemVisibilityPriorityStandard;
UXKIT_EXTERN const UXBarButtonItemVisibilityPriority UXBarButtonItemVisibilityPriorityLow;
UXKIT_EXTERN const UXBarButtonItemVisibilityPriority UXBarButtonItemVisibilityPriorityHigh;
UXKIT_EXTERN const UXBarButtonItemVisibilityPriority UXBarButtonItemVisibilityPriorityUser;

typedef NS_ENUM(NSInteger, UXBarButtonSystemItem) {
    UXBarButtonSystemItemNone          = -1,
    UXBarButtonSystemItemDone          = 0,
    UXBarButtonSystemItemCancel        = 1,
    UXBarButtonSystemItemEdit          = 2,
    UXBarButtonSystemItemSave          = 3,
    UXBarButtonSystemItemAdd           = 4,
    UXBarButtonSystemItemFlexibleSpace = 5,
    UXBarButtonSystemItemFixedSpace    = 6,
    UXBarButtonSystemItemCompose       = 7,
    UXBarButtonSystemItemReply         = 8,
    UXBarButtonSystemItemAction        = 9,
    UXBarButtonSystemItemOrganize      = 10,
    UXBarButtonSystemItemBookmarks     = 11,
    UXBarButtonSystemItemSearch        = 12,
    UXBarButtonSystemItemRefresh       = 13,
    UXBarButtonSystemItemStop          = 14,
    UXBarButtonSystemItemCamera        = 15,
    UXBarButtonSystemItemTrash         = 16,
    UXBarButtonSystemItemPlay          = 17,
    UXBarButtonSystemItemPause         = 18,
    UXBarButtonSystemItemRewind        = 19,
    UXBarButtonSystemItemFastForward   = 20,
    UXBarButtonSystemItemUndo          = 21,
    UXBarButtonSystemItemRedo          = 22,
    UXBarButtonSystemItemPageCurl      = 23,
    UXBarButtonSystemItemClose         = 24,
} NS_SWIFT_NAME(UXBarButtonItem.SystemItem);

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
// `UXKitAppearance` is retained for source compatibility (see UXKitAppearance.h);
// silence the deprecation warning on the class declaration itself.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@interface UXBarButtonItem : UXBarItem <UXKitAppearance>
#pragma clang diagnostic pop

@property (nonatomic, copy, nullable) NSString *label;
@property (nonatomic, copy, nullable) UXBarButtonItemIdentifier identifier;
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
@property (nonatomic) UXBarButtonItemVisibilityPriority visibilityPriority;
@property (nonatomic, weak, nullable) NSToolbarItem *toolbarItem;
@property (nonatomic, getter=isNavigational) BOOL navigational;
@property (nonatomic, strong, nullable) NSMenu *menu;
@property (nonatomic, getter=isHidden) BOOL hidden;
@property (nonatomic, readonly) BOOL isSystemItem;
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
