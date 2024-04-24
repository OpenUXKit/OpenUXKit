#import "UXBarItem.h"
#import "UXKitAppearance-Protocol.h"

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

@property (nonatomic, weak, setter = _setWidthConstrainingItem:) UXBarButtonItem *_widthConstrainingItem; // @synthesize _widthConstrainingItem=__widthConstrainingItem;
@property (nonatomic) NSLayoutPriority visibilityPriority; // @synthesize visibilityPriority=_visibilityPriority;
@property (nonatomic, getter = isCondensed) BOOL condensed; // @synthesize condensed=_condensed;
@property (nonatomic, readonly) UXBarButtonSystemItem systemItem; // @synthesize systemItem=_systemItem;
@property (nonatomic, readonly) UXViewController *contentViewController; // @synthesize contentViewController=_contentViewController;
@property (nonatomic, strong) NSLayoutAnchor *baselineAnchor; // @synthesize baselineAnchor=_baselineAnchor;
@property (nonatomic, strong) NSView *customView; // @synthesize customView=_customView;
@property (nonatomic) CGFloat width; // @synthesize width=_width;
@property (nonatomic) UXBarButtonItemStyle style; // @synthesize style=_style;
@property (nonatomic, readonly) NSView *_view;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic) BOOL ignoresMultiClick; // @synthesize ignoresMultiClick=_ignoresMultiClick;
@property (nonatomic) NSControlStateValue buttonState; // @synthesize buttonState=_buttonState;
@property (nonatomic) NSEventModifierFlags keyEquivalentModifierMask; // @synthesize keyEquivalentModifierMask=_keyEquivalentModifierMask;
@property (nonatomic, strong) NSString *keyEquivalent; // @synthesize keyEquivalent=_keyEquivalent;
@property (nonatomic, strong) NSString *toolTip; // @synthesize toolTip=_toolTip;
@property (nonatomic, weak, nullable) id target; // @synthesize target=_target;
@property (nonatomic, nullable) SEL action; // @synthesize action=_action;
@property (nonatomic) UXTintAdjustmentMode tintAdjustmentMode; // @synthesize tintAdjustmentMode=_tintAdjustmentMode;
@property (nonatomic, strong, nullable) NSColor *tintColor; // @synthesize tintColor=_tintColor;
- (nullable id)_viewOfClass:(Class)cls;
- (CGFloat)preferredSpacingToItem:(UXBarItem *)item proposedSpacing:(CGFloat)spacing;
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
