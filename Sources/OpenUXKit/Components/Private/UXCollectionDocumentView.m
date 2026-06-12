#import "UXCollectionDocumentView.h"
#import "UXCollectionView.h"

@interface NSObject (UXCollectionDocumentViewSPI)
- (void)_prepareCellsForOverdraw:(CGRect)rect;
- (void)_updateVisibleCellsNow:(BOOL)now;
- (CGRect)documentContentRect;
@end

@interface UXCollectionDocumentView () {
    __weak UXCollectionView *_collectionView;
}
@end

@implementation UXCollectionDocumentView

@synthesize collectionView = _collectionView;

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _collectionView = nil;
        self.wantsLayer = YES;
        self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    }
    return self;
}

- (BOOL)isOpaque {
    return NO;
}

- (BOOL)wantsUpdateLayer {
    return YES;
}

- (BOOL)isFlipped {
    return YES;
}

- (void)layout {
    // Matches UXKit: the document view performs no layout of its own. Its frame
    // is driven by -[UXCollectionView setContentSize:] and the cell refresh by
    // -[UXCollectionView layoutSubviews].
}

- (void)_invalidateFocus {
}

- (BOOL)acceptsFirstResponder {
    return NO;
}

- (void)prepareContentInRect:(CGRect)rect {
    [super prepareContentInRect:rect];
    [(id)_collectionView _prepareCellsForOverdraw:rect];
}

- (id)accessibilityHitTest:(CGPoint)point {
    return [self.collectionView accessibilityHitTest:point];
}

@end
