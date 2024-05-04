

#import <AppKit/NSView.h>

@class UXCollectionView;

@interface UXCollectionDocumentView : NSView
{
    UXCollectionView *_collectionView;	// 112 = 0x70
}


@property(nonatomic) __weak UXCollectionView *collectionView; // @synthesize collectionView=_collectionView;
- (id)accessibilityHitTest:(CGPoint)arg1;
- (void)prepareContentInRect:(CGRect)arg1;
- (BOOL)acceptsFirstResponder;
- (void)_invalidateFocus;
- (void)layout;
- (BOOL)isFlipped;
- (BOOL)wantsUpdateLayer;
- (BOOL)isOpaque;
- (id)initWithFrame:(CGRect)arg1;

@end

