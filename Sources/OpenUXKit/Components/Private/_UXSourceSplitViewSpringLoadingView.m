#import <OpenUXKit/_UXSourceSplitViewSpringLoadingView.h>

@interface _UXSourceSplitViewSpringLoadingView () {
    BOOL _didSpringLoad;
}

@end

@implementation _UXSourceSplitViewSpringLoadingView

- (NSSize)intrinsicContentSize {
    return CGSizeMake(15.0, -1.0);
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    return NO;
}

- (void)_unSpringLoad {
    self.springLoadingHandler(YES);
}

- (void)_springLoad {
    if (!_didSpringLoad) {
        if (self.springLoadingHandler) {
            self.springLoadingHandler(YES);
        }
    }
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender {
    if (_didSpringLoad) {
        if (self.springLoadingHandler) {
            [self performSelector:@selector(_unSpringLoad) withObject:nil afterDelay:0.25 inModes:@[NSRunLoopCommonModes]];
        }
    }

    _didSpringLoad = NO;
}

- (void)springLoadingExited:(id<NSDraggingInfo>)draggingInfo {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)springLoadingHighlightChanged:(id<NSDraggingInfo>)draggingInfo {
}

- (void)springLoadingActivated:(BOOL)activated draggingInfo:(id<NSDraggingInfo>)draggingInfo {
}

- (NSSpringLoadingOptions)springLoadingEntered:(id<NSDraggingInfo>)draggingInfo {
    if (!_didSpringLoad) {
        [self performSelector:@selector(_springLoad) withObject:nil afterDelay:0.4 inModes:@[NSRunLoopCommonModes]];
    }

    return NSSpringLoadingDisabled;
}

- (id)_hitTest:(CGPoint *)point dragTypes:(id)dragTypes {
    if (NSMouseInRect(*point, self.frame, self.isFlipped)) {
        if (self._canSpringLoad) {
            return self;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (BOOL)_canSpringLoad {
    if (self.isHidden) {
        return NO;
    }

    if (!self.canSpringLoadHandler) {
        return YES;
    }

    return self.canSpringLoadHandler();
}

@end
