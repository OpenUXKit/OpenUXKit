#import "UXCollectionClipView.h"

@interface NSClipView (UXCollectionClipViewPrivateSPI)
- (void)_invalidateFocus;
@end

@implementation UXCollectionClipView

- (void)_invalidateFocus {
    // Intentionally suppress focus ring invalidation. The collection view manages
    // its own focus drawing, so the default NSClipView behaviour is overridden to
    // do nothing.
}

@end
