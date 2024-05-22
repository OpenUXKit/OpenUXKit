#import <OpenUXKit/NSWindow+UXKit.h>
#import <objc/runtime.h>
#import <OpenUXKit/NSView+UXKit.h>
#import <OpenUXKit/UXNavigationController.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXNavigationBar+Internal.h>
#import <OpenUXKit/UXKitPrivateUtilites.h>



@implementation NSWindow (UXKit)

- (BOOL)ux_toolbarHiddenInFullScreen {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)ux_setToolbarHiddenInFullScreen:(BOOL)ux_toolbarHiddenInFullScreen {
    if (self.ux_toolbarHiddenInFullScreen != ux_toolbarHiddenInFullScreen) {
        objc_setAssociatedObject(self, @selector(ux_toolbarHiddenInFullScreen), @(ux_toolbarHiddenInFullScreen), OBJC_ASSOCIATION_COPY_NONATOMIC);
        if (self.ux_inFullScreen) {
            SEL _Nonnull selector = nil;
            if (ux_toolbarHiddenInFullScreen) {
                selector = NSSelectorFromString(@"_enableFullScreenAutohiding");
            } else {
                selector = NSSelectorFromString(@"_disableFullScreenAutohiding");
            }
            if ([self.toolbar respondsToSelector:selector]) {
                SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([self.toolbar performSelector:selector]);
            }
        }
    }
}

- (BOOL)ux_inFullScreen {
    return self.styleMask & NSWindowStyleMaskFullScreen;
}
void _UXApplyTintColorWithViewController(NSColor *tintColor, NSViewController *viewController) {
    if ([viewController isKindOfClass:[UXNavigationController class]]) {
        UXNavigationController *navigationController = cast(UXNavigationController *, viewController);
        if (navigationController.isNavigationBarDetached) {
            navigationController.navigationBar.tintColor = tintColor;
        }
    }
    for (NSViewController *childViewController in viewController.childViewControllers) {
        _UXApplyTintColorWithViewController(tintColor, childViewController);
    }
}

- (NSColor *)tintColor {
    NSColor *tintColor = objc_getAssociatedObject(self, _cmd);
    if (!tintColor) {
        tintColor = [NSColor controlTextColor];
        self.tintColor = tintColor;
    }
    return tintColor;
}

- (void)setTintColor:(NSColor *)tintColor {
    if (!tintColor) {
        tintColor = [NSColor controlTextColor];
    }
    NSColor *currentTintColor = objc_getAssociatedObject(self, @selector(tintColor));
    BOOL isEqual = [tintColor isEqual:currentTintColor];
    objc_setAssociatedObject(self, @selector(tintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (!isEqual) {
        [self tintColorDidChange];
        for (NSView *subview in self.contentView.subviews) {
            subview.tintColor = self.tintColor;
        }
        _UXApplyTintColorWithViewController(tintColor, self.contentViewController);
    }
}

- (UXTintAdjustmentMode)tintAdjustmentMode {
    return UXTintAdjustmentModeNormal;
}

- (void)setTintAdjustmentMode:(UXTintAdjustmentMode)tintAdjustmentMode {
    
}

- (void)tintColorDidChange {
    
}

- (void)ux_forceEnableStandardWindowButton:(NSWindowButton)windowButton {
    NSButton *button = [self standardWindowButton:windowButton];
    NSCell *buttonCell = button.cell;
    SEL selector = NSSelectorFromString(@"setCanBeEnabled:");
    if ([buttonCell respondsToSelector:selector]) {
        SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([buttonCell performSelector:selector withObject:@(YES)]);
    }
}

@end
