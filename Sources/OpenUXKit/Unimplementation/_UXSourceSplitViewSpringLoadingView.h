

#import <AppKit/NSView.h>

@interface _UXSourceSplitViewSpringLoadingView : NSView
{
    BOOL _didSpringLoad;	// 108 = 0x6c
    id _springLoadingHandler;	// 112 = 0x70
    id _canSpringLoadHandler;	// 120 = 0x78
}


@property(copy) id canSpringLoadHandler; // @synthesize canSpringLoadHandler=_canSpringLoadHandler;
@property(copy) id springLoadingHandler; // @synthesize springLoadingHandler=_springLoadingHandler;
- (BOOL)prepareForDragOperation:(id)arg1;
- (void)_unSpringLoad;
- (void)_springLoad;
- (void)draggingEnded:(id)arg1;
- (void)springLoadingExited:(id)arg1;
- (void)springLoadingHighlightChanged:(id)arg1;
- (void)springLoadingActivated:(BOOL)arg1 draggingInfo:(id)arg2;
- (NSUInteger)springLoadingEntered:(id)arg1;
- (CGSize)intrinsicContentSize;
- (id)_hitTest:(CGPoint *)arg1 dragTypes:(id)arg2;
- (BOOL)_canSpringLoad;

@end

