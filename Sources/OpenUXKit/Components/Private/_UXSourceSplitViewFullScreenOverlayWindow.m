#import <OpenUXKit/_UXSourceSplitViewFullScreenOverlayWindow.h>
#import <OpenUXKit/NSWindow+PrivateSPI.h>

@implementation _UXSourceSplitViewFullScreenOverlayWindow

- (BOOL)_hasActiveAppearanceIgnoringKeyFocus {
    if (self.parentWindow) {
        return [self.parentWindow _hasActiveAppearanceIgnoringKeyFocus];
    } else {
        return YES;
    }
}

@end
