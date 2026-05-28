#import <OpenUXKit/UXCollectionDocumentView.h>
#import <OpenUXKit/UXCollectionView.h>

@interface NSObject (UXCollectionDocumentViewSPI)
- (void)_prepareCellsForOverdraw:(CGRect)rect;
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
}

- (void)_invalidateFocus {
}

- (BOOL)acceptsFirstResponder {
    return NO;
}

- (void)prepareContentInRect:(CGRect)rect {
    [super prepareContentInRect:rect];
    UXCollectionView *collectionView = _collectionView;
    if ([collectionView respondsToSelector:@selector(_prepareCellsForOverdraw:)]) {
        [collectionView _prepareCellsForOverdraw:rect];
    }
}

- (id)accessibilityHitTest:(CGPoint)point {
    return [self.collectionView accessibilityHitTest:point];
}

@end
