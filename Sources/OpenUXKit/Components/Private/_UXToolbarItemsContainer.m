#import <OpenUXKit/_UXToolbarItemsContainer.h>
#import <OpenUXKit/UXBar+Internal.h>
#import <OpenUXKit/UXBarButtonItem+Internal.h>
#import <OpenUXKit/UXImageView.h>
#import <OpenUXKit/UXToolbar.h>

@interface _UXToolbarItemsContainer () {
    NSMutableArray *__addedConstraints;
    BOOL _singleItemMode;
    BOOL _isTransitioning;
}

@end

@implementation _UXToolbarItemsContainer

+ (instancetype)toolbarItemsContainerForToolbar:(UXToolbar *)toolbar items:(NSArray<UXBarButtonItem *> *)items {
    _UXToolbarItemsContainer *container = [self new];

    container.baselineOffsetFromBottom = toolbar.baselineOffsetFromBottom;
    container.interitemSpacing = toolbar.interitemSpacing;
    container.layoutMargins = toolbar.layoutMargins;
    container->_items = items;

    if (items.count == 1) {
        if (items.firstObject.contentViewController) {
            container->_singleItemMode = YES;
        }
    }

    NSArray<UXView *> *views = [items valueForKeyPath:@"_view"];

    for (UXView *view in views) {
        [view removeFromSuperview];
        [container addSubview:view];
    }

    return container;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        __addedConstraints = [NSMutableArray array];
        self.wantsLayer = YES;
        self.layer.masksToBounds = NO;
    }

    return self;
}

- (BOOL)hidesGlobalTrailingView {
    return NO;
}

- (void)updateConstraints {
    if (_isTransitioning) {
        [super updateConstraints];
    } else {
        [NSLayoutConstraint deactivateConstraints:__addedConstraints];
        [__addedConstraints removeAllObjects];
        __auto_type block = ^(UXBarButtonItem *item, NSView *view) {
            if (item.baselineAnchor) {
                [self->__addedConstraints addObject:[item.baselineAnchor constraintEqualToAnchor:self.lastBaselineAnchor]];
            } else {
                [self->__addedConstraints addObject:[view.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]];
            }
        };

        if (_singleItemMode) {
            UXBarButtonItem *firstItem = self.items.firstObject;
            NSView *firstSubview = self.subviews.firstObject;

            if (firstSubview) {
                firstSubview.translatesAutoresizingMaskIntoConstraints = NO;
                [__addedConstraints addObject:[firstSubview.centerXAnchor constraintEqualToAnchor:self.centerXAnchor]];
                block(firstItem, firstSubview);
                [__addedConstraints addObject:[firstSubview.widthAnchor constraintEqualToAnchor:self.widthAnchor]];
                [__addedConstraints addObject:[firstSubview.heightAnchor constraintEqualToAnchor:self.heightAnchor]];
            }
        } else {
            __block BOOL isFirstItem = YES;
            __block NSView *currentView = nil;
            __block NSView *lastWidthConstrainingView = nil;
            __block UXBarButtonItem *prevItem = nil;
            __block NSView *prevView = self;
            __auto_type preferredSpacingToItem = ^CGFloat (UXBarButtonItem *item1, UXBarButtonItem *item2) {
                CGFloat interitemSpacing = self.interitemSpacing;
                CGFloat result = interitemSpacing;

                if (item1) {
                    result = [item1 preferredSpacingToItem:item2 proposedSpacing:interitemSpacing];
                }

                if (item2) {
                    result = [item2 preferredSpacingToItem:item1 proposedSpacing:result];
                }

                return result;
            };
            [self.items enumerateObjectsUsingBlock:^(UXBarButtonItem *_Nonnull currentItem, NSUInteger index, BOOL *_Nonnull stop) {
                currentView = currentItem._view;

                if ([self.subviews containsObject:currentView]) {
                    currentView.translatesAutoresizingMaskIntoConstraints = NO;
                    NSLayoutXAxisAnchor *xAxisAnchor = nil;

                    if (isFirstItem) {
                        xAxisAnchor = prevView.leadingAnchor;
                    } else {
                        xAxisAnchor = prevView.trailingAnchor;
                    }

                    [self->__addedConstraints addObject:[currentView.leadingAnchor constraintEqualToAnchor:xAxisAnchor
                                                                                                  constant:preferredSpacingToItem(prevItem, currentItem)]];
                    block(currentItem, currentView);
                    [self->__addedConstraints addObject:[currentView.widthAnchor constraintGreaterThanOrEqualToConstant:0.0]];

                    if (!currentItem.systemItem) {
                        NSLayoutConstraint *widthConstraint = [currentView.widthAnchor constraintEqualToAnchor:self.widthAnchor];
                        widthConstraint.priority = NSLayoutPriorityDragThatCannotResizeWindow - 1;
                        [self->__addedConstraints addObject:widthConstraint];

                        if (lastWidthConstrainingView) {
                            [self->__addedConstraints addObject:[currentView.widthAnchor constraintEqualToAnchor:lastWidthConstrainingView.widthAnchor]];
                        }

                        lastWidthConstrainingView = currentView;
                    }

                    prevItem = currentItem;
                    prevView = currentView;
                    isFirstItem = NO;
                    UXBarButtonItem *widthConstrainingItem = currentItem._widthConstrainingItem;
                    NSView *widthConstrainingItemView = widthConstrainingItem._view;

                    if (widthConstrainingItem) {
                        if ([self.subviews containsObject:widthConstrainingItemView]) {
                            [self->__addedConstraints addObject:[currentView.widthAnchor constraintEqualToAnchor:widthConstrainingItemView.widthAnchor]];
                        }
                    }
                }
            }];

            if (prevItem) {
                CGFloat layoutMarginsRight = self.layoutMargins.right;

                if (layoutMarginsRight == 0.0) {
                    CGFloat constant = preferredSpacingToItem(prevItem, nil);
                    NSLayoutConstraint *trailingConstraint = [self.trailingAnchor constraintEqualToAnchor:prevView.trailingAnchor constant:constant];
                    trailingConstraint.priority = NSLayoutPriorityDragThatCannotResizeWindow - 2;
                    [__addedConstraints addObject:trailingConstraint];
                    [__addedConstraints addObject:[self.trailingAnchor constraintEqualToAnchor:prevView.trailingAnchor constant:constant]];
                }
            }
        }

        [NSLayoutConstraint activateConstraints:__addedConstraints];
        [super updateConstraints];
    }
}

- (CGFloat)lastBaselineOffsetFromBottom {
    return self.baselineOffsetFromBottom;
}

- (void)prepareForTransition {
    if (self.items.count) {
        UXImageView *snapshotView = self.snapshotView;
        CGSize snapshotImageSize = snapshotView.image.size;
        snapshotView.bounds = self.bounds;
        CGRect bounds = self.bounds;
        [snapshotView setFrameOrigin:CGPointMake(0.0, bounds.origin.x + bounds.size.width * 0.5 - snapshotImageSize.height * 0.5)];
        snapshotView.autoresizingMask = NSViewMinYMargin | NSViewMaxYMargin | NSViewWidthSizable;
        self.subviews = @[snapshotView];
    }

    _isTransitioning = YES;
}

@end
