#import <OpenUXKit/UXNavigationBar+Internal.h>
#import <OpenUXKit/NSView-UXKit.h>
#import <OpenUXKit/_UXNavigationItemContainerView.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXNavigationItem.h>
#import <OpenUXKit/UXBar+Internal.h>


@implementation UXNavigationBar

void _UXDrawChevronFlipped(BOOL flipped) {
    if (flipped) {
        CGContextRef context = NSGraphicsContext.currentContext.CGContext;
        CGContextConcatCTM(context, CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, 12.0, 0.0));
    }
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:CGPointMake(8.5, 16.0)];
    [path lineToPoint:CGPointMake(1.5, 9.0)];
    [path lineToPoint:CGPointMake(8.5, 2.0)];
    [[NSColor blackColor] setStroke];
    [path setLineWidth:1.5];
    [path stroke];
}


NSImage * _UXImageRightChevron(void) {
    static dispatch_once_t onceToken;
    static NSImage *rightChevron = nil;
    dispatch_once(&onceToken, ^{
        rightChevron = [NSImage imageWithSize:NSMakeSize(12.0, 18.0) flipped:YES drawingHandler:^BOOL(NSRect dstRect) {
            _UXDrawChevronFlipped(YES);
            return YES;
        }];
        rightChevron.template = YES;
    });
    return rightChevron;
}

NSImage * _UXImageLeftChevron(void) {
    static dispatch_once_t onceToken;
    static NSImage *leftChevron = nil;
    dispatch_once(&onceToken, ^{
        leftChevron = [NSImage imageWithSize:NSMakeSize(12.0, 18.0) flipped:YES drawingHandler:^BOOL(NSRect dstRect) {
            _UXDrawChevronFlipped(NO);
            return YES;
        }];
        leftChevron.template = YES;
    });
    return leftChevron;
}

NSImage * _UXImageBackChevron(void) {
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        return _UXImageRightChevron();
    } else {
        return _UXImageLeftChevron();
    }
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.backgroundColor = [NSColor clearColor];
        self.blurEnabled = YES;
        _edgeInsets.left = 10;
        _edgeInsets.right = 10;
        _rightInteritemSpacing = self.interitemSpacing;
        _leftInteritemSpacing = self.interitemSpacing;
        _backIndicatorImage = _UXImageBackChevron();
        _internalItems = [NSMutableArray array];
    }
    return self;
}

- (UXBarPosition)barPosition {
    return UXBarPositionTop;
}

- (void)setEdgeInsets:(NSEdgeInsets)edgeInsets {
    if (!NSEdgeInsetsEqual(_edgeInsets, edgeInsets)) {
        _edgeInsets = edgeInsets;
        self.topItemContainer.frame = self.bounds;
        [self.topItemContainer setNeedsUpdateConstraints:YES];
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    [self.topItemContainer updateConstraints];
}

- (void)setTitleCenteringTrackedView:(NSView *)titleCenteringTrackedView {
    if (_titleCenteringTrackedView != titleCenteringTrackedView) {
        _titleCenteringTrackedView = titleCenteringTrackedView;
        self.topItemContainer.titleCenteringTrackedView = titleCenteringTrackedView;
    }
}

- (void)layout {
    [super layout];
    if (_needsRecalculateWindowKeyViewLoop) {
        _needsRecalculateWindowKeyViewLoop = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self recalculateKeyViewLoop];
        });
    }
}

- (void)recalculateKeyViewLoop {
    if (!_recalculatingKeyViewLoop) {
        _recalculatingKeyViewLoop = YES;
        NSView *view = self;
        do {
            if ([view isKindOfClass:NSClassFromString(@"NSToolbarView")]) {
                break;
            }
            view = view.superview;
        } while (view);
        if (self.topItemContainer) {
            NSView *nextKeyView = self.nextKeyView;
            if (!nextKeyView) {
                if (view) {
                    [view viewDidChangeBackingProperties];
                }
            }
        }
        _recalculatingKeyViewLoop = NO;
    }
}

- (void)_prepareForNavigationItemTransition {
    [self.barItemsContainer prepareForTransition];
}

- (void)_pushNavigationItem:(UXNavigationItem *)item animated:(BOOL)animated duration:(NSTimeInterval)duration {
    if (animated) {
        [self.barItemsContainer prepareForTransition];
    }
    [self _pushItem:item];
    _UXNavigationItemContainerView *topItemContainer = [_UXNavigationItemContainerView layoutContainerForItem:item navigationBar:self];
    NSArray *internalItems = self.internalItems;
    NSUInteger transition = 0;
    if (internalItems.count != 0 && animated) {
        transition = 6;
    }
    [self _transitionToContainer:topItemContainer transition:transition duration:duration];
    self.topItemContainer = topItemContainer;
}

- (void)_pushItem:(UXNavigationItem *)item {
    NSParameterAssert([item isKindOfClass:[UXNavigationItem class]]);
    [self.internalItems addObject:item];
    [self _addObserversForItem:item];
}

- (void)_addObserversForItem:(UXNavigationItem *)item {
    for (NSString *keyPath in UXNavigationItem.keyPathsToObserve) {
        [item addObserver:self forKeyPath:keyPath options:(NSKeyValueObservingOptionNew) context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([self.topItem isEqual:object]) {
        if ([@[
            @"title",
            @"titleView",
            @"condensedTitleView",
            @"hidesAlternateTitleView",
        ] containsObject:keyPath]) {
            [self _updateTitleView];
            return;
        }
        NSMutableArray<NSString *> *keyPaths = [NSMutableArray array];
        if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
            [keyPaths addObject:@"rightBarButtonItems"];
        } else {
            [keyPaths addObject:@"leftBarButtonItems"];
        }
        [keyPaths addObjectsFromArray:@[@"hidesBackButton", @"backBarButtonItem"]];
        if ([keyPaths containsObject:keyPath]) {
            [self.topItemContainer updateLeftItemViewsAnimated:YES];
        } else {
            NSLog(@"%s WARNING - dynamic update of (%@) NOT IMPLEMENTED, PLEASE FILE A RADAR IF NEEDED", "-[UXNavigationBar observeValueForKeyPath:ofObject:change:context:]", keyPath);
        }
        [self setNeedsRecalcuateWindowKeyViewLoop];
    }
}

- (UXNavigationItem *)topItem {
    return self.internalItems.lastObject;
}

- (void)setNeedsRecalcuateWindowKeyViewLoop {
    _needsRecalculateWindowKeyViewLoop = YES;
}

- (void)setAlternateTitleView:(NSView *)alternateTitleView {
    _alternateTitleView = alternateTitleView;
    [self _updateTitleView];
}

- (void)_updateTitleView {
    [self.topItemContainer _updateTitleView];
}

- (void)setAlternateTitleEnabled:(BOOL)alternateTitleEnabled {
    _alternateTitleEnabled = alternateTitleEnabled;
    [self _updateTitleView];
}

- (void)_updateItemContainer {
    _UXNavigationItemContainerView *topItemContainer = [_UXNavigationItemContainerView layoutContainerForItem:self.topItem navigationBar:self];
    [self _transitionToContainer:topItemContainer transition:0 duration:0.0];
    self.topItemContainer = topItemContainer;
}

- (void)_completeInteractiveTransition:(BOOL)completeInteractiveTransition duration:(NSTimeInterval)duration {
    [self _finishInteractiveTransition:completeInteractiveTransition duration:duration completion:^{
        _UXNavigationItemContainerView *prevTopItemContainer = self.topItemContainer;
        self.topItemContainer = cast(_UXNavigationItemContainerView *, self.barItemsContainer);
        if (!completeInteractiveTransition) {
            [prevTopItemContainer prepareForTransition];
            [self.topItemContainer cancelTransistion];
            [self.topItemContainer _updateStateForWindow:self.topItemContainer.window];
            if (self.currentOperation == UXNavigationControllerOperationPush) {
                [self _popNavigationItem];
            } else {
                [self _pushItem:self.transitioningItem];
            }
        }
        self.currentOperation = UXNavigationControllerOperationNone;
        self.transitioningItem = nil;
    }];
}

- (void)beginInteractivePop {
    NSParameterAssert(self.internalItems.count > 1);
    [self.barItemsContainer prepareForTransition];
    self.currentOperation = UXNavigationControllerOperationPop;
    self.transitioningItem = self._popNavigationItem;
    _UXNavigationItemContainerView *topItemContainer = [_UXNavigationItemContainerView layoutContainerForItem:self.topItem navigationBar:self];
    [self _beginInteractiveTransitionToItemContainer:topItemContainer];
    self.topItemContainer = topItemContainer;
}

- (void)beginInteractivePushToItem:(UXNavigationItem *)item {
    NSParameterAssert(item);
    [self.barItemsContainer prepareForTransition];
    [self _pushItem:item];
    self.currentOperation = UXNavigationControllerOperationPush;
    self.transitioningItem = item;
    _UXNavigationItemContainerView *topItemContainer = [_UXNavigationItemContainerView layoutContainerForItem:item navigationBar:self];
    [self _beginInteractiveTransitionToItemContainer:topItemContainer];
    self.topItemContainer = topItemContainer;
}

- (void)_snapshot {
    [self.barItemsContainer prepareForTransition];
}

- (UXNavigationItem *)_popNavigationItemAnimated:(BOOL)animated duration:(NSTimeInterval)duration {
    NSUInteger transition = 0;
    if (animated) {
        [self.barItemsContainer prepareForTransition];
        transition = 6;
    }
    UXNavigationItem *result = [self _popNavigationItem];
    _UXNavigationItemContainerView *topItemContainer = [_UXNavigationItemContainerView layoutContainerForItem:self.topItem navigationBar:self];
    [self _transitionToContainer:topItemContainer transition:transition duration:duration];
    self.topItemContainer = topItemContainer;
    return result;
}

- (UXNavigationItem *)_popNavigationItem {
    UXNavigationItem *topItem = self.topItem;
    [self _removeItem:topItem];
    return topItem;
}

- (void)_removeItem:(UXNavigationItem *)item {
    if ([self.internalItems containsObject:item]) {
        NSIndexSet *indexes = [self.internalItems indexesOfObjectsPassingTest:^BOOL(UXNavigationItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [item isEqualTo:obj];
        }];
        [self.internalItems removeObjectAtIndex:indexes.lastIndex];
        [self _removeObserversForItem:item];
    }
}

- (void)_removeObserversForItem:(UXNavigationItem *)item {
    for (NSString *keyPath in UXNavigationItem.keyPathsToObserve) {
        [item removeObserver:self forKeyPath:keyPath];
    }
}

- (UXNavigationItem *)popNavigationItemAnimated:(BOOL)animated {
    return [self _popNavigationItemAnimated:animated duration:0.33];
}

- (void)pushNavigationItem:(UXNavigationItem *)navigationItem animated:(BOOL)animated {
    [self _pushNavigationItem:navigationItem animated:animated duration:0.33];
}

- (NSArray *)items {
    return self.internalItems.copy;
}

- (UXNavigationItem *)backItem {
    NSUInteger internalItemsCount = self.internalItems.count;
    NSUInteger index = internalItemsCount - 2;
    if (internalItemsCount < 2) {
        return nil;
    } else {
        return [self.internalItems objectAtIndex:index];
    }
}

- (void)mouseDown:(NSEvent *)event {
    if (_detached) {
        [super mouseDown:event];
    }
}

- (void)setInteritemSpacing:(CGFloat)interitemSpacing {
    [super setInteritemSpacing:interitemSpacing];
    self.leftInteritemSpacing = interitemSpacing;
    self.rightInteritemSpacing = interitemSpacing;
}

- (void)dealloc {
    for (UXNavigationItem *item in self.internalItems) {
        [self _removeObserversForItem:item];
    }
}

@end
