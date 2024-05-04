#import <OpenUXKit/UXBarButtonItem+Internal.h>
#import <OpenUXKit/UXView.h>
#import <OpenUXKit/_UXButton.h>
#import <OpenUXKit/UXLabel.h>
#import <OpenUXKit/NSView-UXKit.h>
#import <OpenUXKit/UXViewController.h>
#import <OpenUXKit/UXKitDefines.h>

@implementation UXBarButtonItem
@synthesize tintColor;
@synthesize tintAdjustmentMode;

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithCustomView:(NSView *)customView {
    NSParameterAssert(customView);
    self = [self initWithStyle:UXBarButtonItemStylePlain target:nil action:nil];
    if (self) {
        self.customView = customView;
    }
    return self;
}

- (instancetype)initWithStyle:(UXBarButtonItemStyle)style target:(id)target action:(SEL)action {
    if (self = [super init]) {
        _systemItem = UXBarButtonSystemItemNone;
        _style = style;
        _target = target;
        _action = action;
        _identifier = NSStringFromSelector(action);
    }
    return self;
}

- (instancetype)initWithBarButtonSystemItem:(UXBarButtonSystemItem)systemItem target:(id)target action:(SEL)action {
    if (self = [self initWithStyle:(UXBarButtonItemStylePlain) target:target action:action]) {
        _systemItem = systemItem;
        _isSystemItem = YES;
    }
    return self;
}


- (instancetype)initWithContentViewController:(UXViewController *)contentViewController {
    NSParameterAssert([contentViewController isKindOfClass:[UXViewController class]]);
    self = [self initWithCustomView:contentViewController.view];
    if (self) {
        _contentViewController = contentViewController;
    }
    return self;
}

- (instancetype)initWithBarButtonSystemItem:(UXBarButtonSystemItem)systemItem width:(CGFloat)width target:(id)target action:(SEL)action {
    
    self = [self initWithBarButtonSystemItem:systemItem target:target action:action];
    if (self) {
        _wantsToUseCustomWidth = YES;
        _width = width;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title style:(UXBarButtonItemStyle)style target:(id)target action:(SEL)action {
    self = [self initWithStyle:style target:target action:action];
    if (self) {
        self.title = title;
    }
    return self;
}

- (instancetype)initWithImage:(NSImage *)image style:(UXBarButtonItemStyle)style target:(id)target action:(SEL)action {
    self = [self initWithStyle:style target:target action:action];
    if (self) {
        self.image = image;
    }
    return self;
}



- (id)_viewOfClass:(Class)cls {
    NSView *customView = _customView;
    if (!customView) {
        customView = __view;
    }
    if ([customView isKindOfClass:cls]) {
        return customView;
    }
    return nil;
}

- (void)setCustomView:(NSView *)customView {
    _customView = customView;
    _contentViewController = nil;
}


- (NSView *)_view {
    NSView *customView = self.customView;
    if (!customView) {
        if (__view) {
            return __view;
        }
        UXBarButtonSystemItem systemItem = _systemItem;
        NSView *view = nil;
        if (systemItem == UXBarButtonSystemItemCancel) {
            UXView *uxView = [UXView new];
            uxView.userInteractionEnabled = NO;
            uxView.translatesAutoresizingMaskIntoConstraints = NO;
            [uxView.widthAnchor constraintEqualToConstant:_wantsToUseCustomWidth ? self.width : 20.0].active = YES;
            view = uxView;
        } else {
            if (systemItem) {
                CGFloat width = self.width;
                if (_style) {
                    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(0.0, 0.0, width, 20.0)];
                    button.bordered = YES;
                    if (_style == UXBarButtonItemStyleBordered) {
                        button.bezelStyle = NSBezelStylePush;
                    } else {
                        button.bezelStyle = NSBezelStyleToolbar;
                    }
                    [button setButtonType:NSButtonTypeMomentaryPushIn];
                    button.font = [NSFont systemFontOfSize:NSFont.systemFontSize];
                    view = button;
                } else {
                    _UXButton *uxButton = [[_UXButton alloc] initWithFrame:NSMakeRect(0.0, 0.0, width, 20)];
                    uxButton.font = [NSFont labelFontOfSize:NSFont.systemFontSize];
                    uxButton.accessibilityTitle = self.title;
                    [uxButton setTitleAttributes:@{
                        NSFontAttributeName: uxButton.font,
                        NSForegroundColorAttributeName: self.tintColor,
                    } forState:UXControlStateNormal];
                    [uxButton setTitleAttributes:@{
                        NSFontAttributeName: uxButton.font,
                        NSForegroundColorAttributeName: [self.tintColor colorWithAlphaComponent:0.7],
                    } forState:UXControlStateHighlighted];
                    view = uxButton;
                }
                view.translatesAutoresizingMaskIntoConstraints = NO;
                view.accessibilityRole = @"AXButton";
                view.accessibilitySubrole = @"AXToolbarButton";
                view.accessibilityLabel = self.accessibilityLabel;
                cast(NSButton *, view).image = self.image;
                cast(NSButton *, view).imagePosition = self.title.length > 0 ? NSImageLeft : NSImageOnly;
                cast(NSButton *, view).toolTip = self.toolTip;
                cast(NSButton *, view).identifier = self.identifier;
                cast(NSButton *, view).keyEquivalent = self.keyEquivalent;
                cast(NSButton *, view).keyEquivalentModifierMask = self.keyEquivalentModifierMask;
                cast(NSButton *, view).state = self.buttonState;
                cast(NSButton *, view).ignoresMultiClick = self.ignoresMultiClick;
                cast(NSButton *, view).tag = self.tag;
                cast(NSButton *, view).action = self.action;
                cast(NSButton *, view).target = self.target;
                cast(NSButton *, view).enabled = self.isEnabled;
                if (NSApp.mainWindow.toolbarStyle == NSWindowToolbarStyleUnified) {
                    cast(NSButton *, view).controlSize = NSControlSizeLarge;
                }
                __view = view;
                return view;
            }
            UXView *uxView = [UXView new];
            uxView.userInteractionEnabled = NO;
            uxView.translatesAutoresizingMaskIntoConstraints = NO;
            view = uxView;
        }
        [view.heightAnchor constraintEqualToConstant:20.0].active = YES;
        __view = view;
        return view;
    }
    return customView;
}

#define GetPropertyOfNSButtonIfExistOtherwiseReturnSuper(property) \
NSButton *button = [self _viewOfClass:[NSButton class]];\
if (button) {\
    return button.property;\
} else {\
    return [super property];\
}

#define GetPropertyOfNSButtonIfExistOtherwiseReturnSuper2(buttonProperty, superProperty) \
NSButton *button = [self _viewOfClass:[NSButton class]];\
if (button) {\
    return button.buttonProperty;\
} else {\
    return [super superProperty];\
}

#define GetPropertyOfNSButtonIfExistOtherwiseReturnIvar(property) \
NSButton *button = [self _viewOfClass:[NSButton class]];\
if (button) {\
    return button.property;\
} else {\
    return _##property;\
}

#define GetPropertyOfNSButtonIfExistOtherwiseReturnIvar2(buttonProperty, selfProperty) \
NSButton *button = [self _viewOfClass:[NSButton class]];\
if (button) {\
    return button.buttonProperty;\
} else {\
    return _##selfProperty;\
}

#define SetPropertyOfNSButtonIfExistAndSetSuper(property) \
super.property = property;\
NSButton *button = [self _viewOfClass:[NSButton class]];\
if (button) {\
    button.property = property;\
}

#define SetPropertyOfNSButtonIfExistAndSetSuper2(buttonProperty, superProperty) \
super.superProperty = superProperty;\
NSButton *button = [self _viewOfClass:[NSButton class]];\
if (button) {\
    button.buttonProperty = superProperty;\
}

#define SetPropertyOfNSButtonIfExistAndSetIvar(property) \
_##property = property;\
NSButton *button = [self _viewOfClass:[NSButton class]];\
if (button) {\
    button.property = property;\
}

#define SetPropertyOfNSButtonIfExistAndSetIvar2(buttonProperty, selfProperty) \
_##selfProperty = selfProperty;\
NSButton *button = [self _viewOfClass:[NSButton class]];\
if (button) {\
    button.buttonProperty = selfProperty;\
}

- (NSImage *)image {
    GetPropertyOfNSButtonIfExistOtherwiseReturnSuper(image);
}

- (void)setImage:(NSImage *)image {
    SetPropertyOfNSButtonIfExistAndSetSuper(image);
}

- (BOOL)isEnabled {
    GetPropertyOfNSButtonIfExistOtherwiseReturnSuper(isEnabled);
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    NSControl *view = [self _viewOfClass:[NSControl class]];
    view.enabled = enabled;
}

- (BOOL)ignoresMultiClick {
    GetPropertyOfNSButtonIfExistOtherwiseReturnIvar(ignoresMultiClick);
}

- (void)setIgnoresMultiClick:(BOOL)ignoresMultiClick {
    SetPropertyOfNSButtonIfExistAndSetIvar(ignoresMultiClick);
}

- (NSControlStateValue)buttonState {
    GetPropertyOfNSButtonIfExistOtherwiseReturnIvar2(state, buttonState);
}

- (void)setButtonState:(NSControlStateValue)buttonState {
    SetPropertyOfNSButtonIfExistAndSetIvar2(state, buttonState);
}

- (NSEventModifierFlags)keyEquivalentModifierMask {
    GetPropertyOfNSButtonIfExistOtherwiseReturnIvar(keyEquivalentModifierMask);
}

- (void)setKeyEquivalentModifierMask:(NSEventModifierFlags)keyEquivalentModifierMask {
    SetPropertyOfNSButtonIfExistAndSetIvar(keyEquivalentModifierMask);
}

- (NSString *)keyEquivalent {
    GetPropertyOfNSButtonIfExistOtherwiseReturnIvar(keyEquivalent);
}

- (void)setKeyEquivalent:(NSString *)keyEquivalent {
    SetPropertyOfNSButtonIfExistAndSetIvar(keyEquivalent);
}

- (NSString *)identifier {
    GetPropertyOfNSButtonIfExistOtherwiseReturnIvar(identifier);
}

- (void)setIdentifier:(NSString *)identifier {
    SetPropertyOfNSButtonIfExistAndSetIvar(identifier);
}

- (NSString *)toolTip {
    GetPropertyOfNSButtonIfExistOtherwiseReturnIvar(toolTip);
}

- (void)setToolTip:(NSString *)toolTip {
    SetPropertyOfNSButtonIfExistAndSetIvar(toolTip);
}

- (id)target {
    GetPropertyOfNSButtonIfExistOtherwiseReturnIvar(target);
}

- (void)setTarget:(id)target {
    SetPropertyOfNSButtonIfExistAndSetIvar(target);
}

- (SEL)action {
    GetPropertyOfNSButtonIfExistOtherwiseReturnIvar(action);
}

- (void)setAction:(SEL)action {
    SetPropertyOfNSButtonIfExistAndSetIvar(action);
}

- (void)setAccessibilityIdentifier:(NSString *)accessibilityIdentifier {
    SetPropertyOfNSButtonIfExistAndSetSuper(accessibilityIdentifier);
}

- (void)setAccessibilityLabel:(NSString *)accessibilityLabel {
    SetPropertyOfNSButtonIfExistAndSetSuper(accessibilityLabel);
}

- (void)setTitle:(NSString *)title {
    SetPropertyOfNSButtonIfExistAndSetSuper(title);
    UXLabel *label = [self _viewOfClass:[UXLabel class]];
    if (label) {
        label.text = title;
    }
}

- (void)tintColorDidChange {
    if ([__view conformsToProtocol:@protocol(UXKitAppearance)]) {
        __view.tintColor = self.tintColor;
    }
}

- (UXTintAdjustmentMode)tintAdjustmentMode {
    return UXTintAdjustmentModeNormal;
}

- (void)setTintAdjustmentMode:(UXTintAdjustmentMode)tintAdjustmentMode {}

- (NSColor *)tintColor {
    if (_tintColor) {
        return _tintColor;
    } else {
        return [NSColor controlTextColor];
    }
}

- (void)setBaselineAnchor:(NSLayoutAnchor *)baselineAnchor {
    if (_baselineAnchor != baselineAnchor) {
        _baselineAnchor = baselineAnchor;
        NSView *view = [self _viewOfClass:[NSView class]];
        if (view.superview) {
            NSLog(@"Warning: change of baseline anchor after the bar button item is used isn't implemented");
        }
    }
}

- (CGFloat)preferredSpacingToItem:(UXBarItem *)item proposedSpacing:(CGFloat)spacing {
    return spacing;
}

@end
