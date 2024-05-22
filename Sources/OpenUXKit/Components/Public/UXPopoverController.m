#import <OpenUXKit/UXPopoverController.h>
#import <OpenUXKit/UXPopover.h>
#import <OpenUXKit/UXBarButtonItem.h>
#import <OpenUXKit/UXView.h>
#import <OpenUXKit/UXViewController.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXKitPrivateUtilites.h>

@interface UXPopoverController ()
{
    UXPopover *_popover;    // 16 = 0x10
    __weak id <UXPopoverControllerDelegate> _delegate;    // 24 = 0x18
    NSArray *_passthroughViews;    // 32 = 0x20
}
@end


@implementation UXPopoverController

static const NSRectEdge rectEdges[] = { NSRectEdgeMinY, NSRectEdgeMaxY, NSRectEdgeMinX, NSRectEdgeMaxY, NSRectEdgeMaxY, NSRectEdgeMaxY, NSRectEdgeMaxX };


- (instancetype)initWithContentViewController:(UXViewController *)viewController {
    NSParameterAssert([viewController isKindOfClass:[UXViewController class]]);
    if (self = [super init]) {
        self.contentViewController = viewController;
    }
    return self;
}

- (void)dismissPopoverAnimated:(BOOL)animated {
    [_popover close];
}

- (void)dismissPopover {
    [_popover close];
}

- (void)presentPopoverFromBarButtonItem:(UXBarButtonItem *)item permittedArrowDirections:(UXPopoverArrowDirection)arrowDirections animated:(BOOL)animated {
    UXView *view = [item valueForKey:@"_view"];
    if (arrowDirections - 2 > 6) {
        [self presentPopoverFromRect:view.bounds inView:view preferredEdge:rectEdges[3]];
    } else {
        [self presentPopoverFromRect:view.bounds inView:view preferredEdge:rectEdges[arrowDirections - 2]];
    }
}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UXView *)view preferredEdge:(NSRectEdge)preferredEdge {
    NSViewController *contentViewController = _popover.contentViewController;
    if (contentViewController) {
        [_popover showRelativeToRect:rect ofView:view preferredEdge:preferredEdge];
    } else {
        NSLog(@"Application tried to present UXPopoverController without setting the contentViewController");
    }
}

- (void)setContentViewController:(UXViewController *)newContentViewController {
    NSViewController *currentContentViewController = _popover.contentViewController;
    BOOL isKindOfUXClassOnCurrent = [currentContentViewController isKindOfClass:[UXViewController class]];
    BOOL isKindOfUXClassOnNew = [newContentViewController isKindOfClass:[UXViewController class]];
    if (currentContentViewController != newContentViewController) {
        NSViewController *currentParentViewController = nil;
        if (isKindOfUXClassOnCurrent &&
            ((void)([currentContentViewController removeObserver:self forKeyPath:NSStringFromSelector(@selector(preferredContentSize))]),
             (void)(currentParentViewController = currentContentViewController.parentViewController),
             currentParentViewController == self)) {
            [cast(UXViewController *, currentContentViewController) willMoveToParentViewController:nil];
            if (!isKindOfUXClassOnCurrent) {
LABEL_6:
                self.popover.contentViewController = newContentViewController;
                if (self.popover.isShown) {
                    [self _updateContentSize];
                }
                
                if (isKindOfUXClassOnCurrent && currentParentViewController == self) {
                    [currentContentViewController removeFromParentViewController];
                    if (!isKindOfUXClassOnNew) {
                        return;
                    }
                } else if (!isKindOfUXClassOnNew) {
                    return;
                }
                [newContentViewController didMoveToParentViewController:self];
                return;
            }
        } else if (!isKindOfUXClassOnNew) {
            goto LABEL_6;
        }
        [newContentViewController addObserver:self forKeyPath:NSStringFromSelector(@selector(preferredContentSize)) options:0 context:nil];
        [self addChildViewController:newContentViewController];
        goto LABEL_6;
    }
}

- (UXViewController *)contentViewController {
    return cast(UXViewController *, _popover.contentViewController);
}

- (CGSize)popoverContentSize {
    return _popover.contentSize;
}

- (void)setPopoverContentSize:(CGSize)size animated:(BOOL)animated {
    CGSize currentSize = _popover.contentSize;
    if (currentSize.width != size.width || currentSize.height != size.height) {
        _popover.contentSize = size;
    }
}

- (void)setPopoverContentSize:(CGSize)popoverContentSize {
    [self setPopoverContentSize:popoverContentSize animated:NO];
}

- (BOOL)isPopoverVisible {
    return _popover.isShown;
}

- (void)setPopoverBehavior:(NSPopoverBehavior)popoverBehavior {
    self.popover.behavior = popoverBehavior;
}

- (NSPopoverBehavior)popoverBehavior {
    return self.popover.behavior;
}

- (BOOL)popoverShouldClose:(NSPopover *)popover {
    if ([self.delegate respondsToSelector:@selector(popoverControllerShouldDismissPopover:)]) {
        return [self.delegate popoverControllerShouldDismissPopover:self];
    } else {
        return YES;
    }
}

- (void)popoverDidClose:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)]) {
        [self.delegate popoverControllerDidDismissPopover:self];
    }
}

- (void)popoverWillShow:(NSNotification *)notification {
    [self _updateContentSize];
    _popover.popoverController = self;
}

- (UXPopover *)popover {
    if (_popover == nil) {
        _popover = [UXPopover new];
        _popover.behavior = NSPopoverBehaviorTransient;
        _popover.delegate = self;
    }
    return _popover;
}

- (void)_updateContentSize {
    CGSize preferredContentSize = _popover.contentViewController.preferredContentSize;
    CGSize contentSize = _popover.contentSize;
    if (contentSize.width != preferredContentSize.width || contentSize.height != preferredContentSize.height) {
        _popover.contentSize = preferredContentSize;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(preferredContentSize))]) {
        if (self.isPopoverVisible) {
            [self _updateContentSize];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)dealloc {
    [_popover.contentViewController removeObserver:self forKeyPath:NSStringFromSelector(@selector(preferredContentSize))];
    _popover.delegate = nil;
    
}
@end
