#import <OpenUXKit/_UXSourceSplitItemView.h>
#import <OpenUXKit/NSView+PrivateSPI.h>

@implementation _UXSourceSplitItemView

- (NSTitlebarSeparatorStyle)titlebarSeparatorStyle {
    return NSTitlebarSeparatorStyleAutomatic;
}

- (CGRect)splitFrame {
    CGRect bounds = self.bounds;
    CGFloat dividerPosition = self.dividerPosition;
    if (dividerPosition > 0.0) {
        CGFloat v12 = dividerPosition;
        bounds.size.width = bounds.size.width - dividerPosition;
        CGFloat v14 = -0.0;
        if (self.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionLeftToRight) {
            v14 = v12;
        }
        bounds.origin.x = bounds.origin.x + v14;
    }
    return [self convertRect:bounds toView:nil];
}

- (BOOL)isTrailingSidebar {
    return NO;
}

- (BOOL)isSidebar {
    return self._semanticContext == 7;
}

@end
