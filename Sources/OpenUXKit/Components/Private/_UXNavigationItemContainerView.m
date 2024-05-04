#import <OpenUXKit/_UXNavigationItemContainerView.h>
#import <OpenUXKit/NSView-UXKit.h>
#import <OpenUXKit/UXBar+Internal.h>
#import <OpenUXKit/UXBarButtonItem+Internal.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXNavigationBar+Internal.h>
#import <OpenUXKit/UXNavigationItem.h>

@interface _UXNavigationItemContainerView () {
    UXImageView *_snaphotView;  // 112 = 0x70
    BOOL _hidesGlobalTrailingView;      // 120 = 0x78
    UXNavigationItem *_item;    // 128 = 0x80
    __weak UXNavigationBar *_navigationBar;    // 136 = 0x88
    NSUInteger _state;  // 144 = 0x90
    CGFloat _minimumWidthForExpandedTitle;      // 152 = 0x98
    CGFloat _minimumWidthForExpandedItems;      // 160 = 0xa0
    NSView *_leftView;  // 168 = 0xa8
    NSMutableArray *_leftItemViews;     // 176 = 0xb0
    NSView *_titleView; // 184 = 0xb8
    NSMutableArray *_rightItemViews;    // 192 = 0xc0
    NSView *_rightView; // 200 = 0xc8
    NSMutableArray<UXBarButtonItem *> *_itemsSortedByPriority;     // 208 = 0xd0
    NSMutableDictionary *_overflowItemsByMinimumWidth;  // 216 = 0xd8
    NSMutableArray *_addedConstraints;  // 224 = 0xe0
    NSLayoutConstraint *_titleCenteringConstraint;      // 232 = 0xe8
    __weak NSView *_titleCenteringConstrainedTitleView;        // 240 = 0xf0
    __weak NSView *_titleCenteringTrackedView; // 248 = 0xf8
    __weak NSView *_titleCenteringConstraintOwnerView; // 256 = 0x100
}

@end

@implementation _UXNavigationItemContainerView

+ (instancetype)layoutContainerForItem:(UXNavigationItem *)item navigationBar:(UXNavigationBar *)navigationBar {
    _UXNavigationItemContainerView *container = [_UXNavigationItemContainerView new];

    container->_item = item;
    container->_navigationBar = navigationBar;
    container.titleCenteringTrackedView = navigationBar.titleCenteringTrackedView;
    return container;
}

- (instancetype)init {
    if (self = [super init]) {
        _leftItemViews = [NSMutableArray array];
        _rightItemViews = [NSMutableArray array];
        _addedConstraints = [NSMutableArray array];
        _itemsSortedByPriority = [NSMutableArray array];
        _overflowItemsByMinimumWidth = [NSMutableDictionary dictionary];
        self.backgroundColor = [NSColor clearColor];
    }

    return self;
}

- (void)setTitleCenteringTrackedView:(NSView *)titleCenteringTrackedView {
    [self setTitleCenteringTrackedView:titleCenteringTrackedView updateConstraints:YES];
}

- (void)setTitleCenteringTrackedView:(NSView *)trackedView updateConstraints:(BOOL)updateConstraints {
    if (_titleCenteringTrackedView != trackedView) {
        _titleCenteringTrackedView = trackedView;

        if (updateConstraints) {
            [self setNeedsUpdateConstraints:YES];
        }
    }
}

- (BOOL)hidesGlobalTrailingView {
    return [self.item hidesGlobalTrailingView];
}

- (void)updateConstraints {
    UXNavigationBar *navigationBar = self.navigationBar;
    NSEdgeInsets navigationBarEdgeInsets = navigationBar.edgeInsets;
    CGFloat navigationBarCenterYOffset = navigationBar.centerYOffset;
    CGFloat navigationBarLeftInteritemSpacing = navigationBar.leftInteritemSpacing;
    CGFloat navigationBarRightInteritemSpacing = navigationBar.rightInteritemSpacing;

    [self removeConstraints:self.addedConstraints];
    [self.addedConstraints removeAllObjects];
    NSWindow *window = nil;

    if (self.state == 1 && (window = self.window)) {
        _leftView = nil;
        _rightView = nil;
        NSArray<NSView *> *leftItemViews = [self subviewsIntersectedWithViews:self.leftItemViews excludingHidden:YES];
        BOOL isSetupLeftItemView = YES;
        NSView *lastLeftItemView = self;

        for (NSView *leftItemView in leftItemViews) {
            NSLayoutAttribute attribute = NSLayoutAttributeNotAnAttribute;
            CGFloat constant = 0;

            if (isSetupLeftItemView) {
                attribute = NSLayoutAttributeLeft;
                constant = navigationBarEdgeInsets.left;
            } else {
                attribute = NSLayoutAttributeRight;
                constant = navigationBarRightInteritemSpacing;
            }

            [self.addedConstraints addObject:[NSLayoutConstraint constraintWithItem:leftItemView attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:lastLeftItemView attribute:attribute multiplier:1.0 constant:constant]];
            [self.addedConstraints addObject:[NSLayoutConstraint constraintWithItem:leftItemView attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeCenterY) multiplier:1.0 constant:navigationBarCenterYOffset]];
            [self.addedConstraints addObject:[NSLayoutConstraint constraintWithItem:leftItemView attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationGreaterThanOrEqual) toItem:nil attribute:(NSLayoutAttributeNotAnAttribute) multiplier:1.0 constant:0.0]];

            if (isSetupLeftItemView) {
                _leftView = leftItemView;
            }

            lastLeftItemView = leftItemView;
            isSetupLeftItemView = NO;
        }

        NSArray<NSView *> *rightItemViews = [self subviewsIntersectedWithViews:self.rightItemViews excludingHidden:YES];
        BOOL isSetupRightItemView = YES;
        NSView *lastRightItemView = self;

        for (NSView *rightItemView in rightItemViews) {
            NSLayoutAttribute attribute = NSLayoutAttributeNotAnAttribute;

            if (lastRightItemView == self) {
                attribute = NSLayoutAttributeRight;
            } else {
                attribute = NSLayoutAttributeLeft;
            }

            CGFloat constant = 0;

            if (isSetupRightItemView) {
                constant = navigationBarEdgeInsets.right;
            } else {
                constant = navigationBarRightInteritemSpacing;
            }

            [self.addedConstraints addObject:[NSLayoutConstraint constraintWithItem:rightItemView attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:lastRightItemView attribute:(attribute) multiplier:1.0 constant:-constant]];
            [self.addedConstraints addObject:[NSLayoutConstraint constraintWithItem:rightItemView attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeCenterY) multiplier:1.0 constant:navigationBarCenterYOffset]];
            [self.addedConstraints addObject:[NSLayoutConstraint constraintWithItem:rightItemView attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationGreaterThanOrEqual) toItem:nil attribute:(NSLayoutAttributeNotAnAttribute) multiplier:1.0 constant:0.0]];
            isSetupRightItemView = NO;
            lastRightItemView = rightItemView;
        }

        for (NSLayoutConstraint *addedConstraint in self.addedConstraints) {
            addedConstraint.priority = 470;
        }

        NSView *titleView = self.titleView;

        if (titleView) {
            if (titleView.superview == self) {
                NSView *titleCenteringTrackedView = self.titleCenteringTrackedView;
                NSView *ancestorShared = nil;
                NSView *titleViewEqualToView = nil;

                if (titleCenteringTrackedView) {
                    ancestorShared = [self ancestorSharedWithView:titleCenteringTrackedView];
                    titleViewEqualToView = titleCenteringTrackedView;
                } else {
                    ancestorShared = nil;
                    titleViewEqualToView = self;
                }

                NSView *view = nil;

                if (ancestorShared) {
                    view = ancestorShared;
                } else {
                    view = self;
                }

                [self.titleCenteringConstraintOwnerView removeConstraint:self.titleCenteringConstraint];
                self.titleCenteringConstraintOwnerView = nil;
                self.titleCenteringConstraint = nil;
                self.titleCenteringTrackedView = nil;
                self.titleCenteringConstrainedTitleView = nil;
                self.titleCenteringConstraint = [self.titleView.centerXAnchor constraintEqualToAnchor:titleViewEqualToView.centerXAnchor constant:0.0];
                self.titleCenteringConstraint.priority = NSLayoutPriorityDefaultLow;
                [view addConstraint:self.titleCenteringConstraint];
                self.titleCenteringConstraintOwnerView = view;
                self.titleCenteringConstrainedTitleView = self.titleView;
                [self setTitleCenteringTrackedView:titleViewEqualToView updateConstraints:NO];
                [self.addedConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleView attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeCenterY) multiplier:1.0 constant:navigationBarCenterYOffset]];
                [self.addedConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleView attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationGreaterThanOrEqual) toItem:nil attribute:(NSLayoutAttributeNotAnAttribute) multiplier:1.0 constant:0.0]];
                CGFloat leftConstant = 0;

                if (lastLeftItemView == self) {
                    leftConstant = navigationBarEdgeInsets.left;
                } else {
                    leftConstant = navigationBarLeftInteritemSpacing;
                }

                NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.titleView attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationGreaterThanOrEqual) toItem:lastLeftItemView attribute:(lastLeftItemView != self ? NSLayoutAttributeRight : NSLayoutAttributeLeft) multiplier:1.0 constant:leftConstant];
                leftConstraint.priority = 480;
                [self.addedConstraints addObject:leftConstraint];
                NSLayoutAttribute rightAttribute = NSLayoutAttributeNotAnAttribute;
                CGFloat rightConstant = 0;

                if (lastRightItemView == self) {
                    rightAttribute = NSLayoutAttributeRight;
                    rightConstant = navigationBarEdgeInsets.right;
                } else {
                    rightAttribute = NSLayoutAttributeLeft;
                    rightConstant = navigationBarRightInteritemSpacing;
                }

                NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.titleView attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationLessThanOrEqual) toItem:lastRightItemView attribute:rightAttribute multiplier:1.0 constant:-rightConstant];
                rightConstraint.priority = 480;
                [self.addedConstraints addObject:rightConstraint];

                if (!_leftView) {
                    _leftView = self.titleView;
                }
            }
        }

        [self addConstraints:self.addedConstraints];
        [super updateConstraints];
    } else {
        if (self.titleCenteringConstraintOwnerView) {
            if (self.titleCenteringConstraint) {
                [self.titleCenteringConstraintOwnerView removeConstraint:self.titleCenteringConstraint];
            }
        }

        [super updateConstraints];
    }
}

- (void)layout {
    [super layout];

    if (self.state == 2) {
        return;
    }

    CGRect bounds = self.bounds;
    NSEdgeInsets edgeInsets = self.navigationBar.edgeInsets;
    auto alignmentRectForFrame = ^CGRect (NSView *view) {
        return [view alignmentRectForFrame:view.frame];
    };
    CGRect rect = CGRectMake(bounds.origin.x + edgeInsets.left, bounds.origin.y + edgeInsets.top, bounds.size.width - (edgeInsets.left + edgeInsets.right), bounds.size.height - (edgeInsets.top + edgeInsets.bottom));
    auto v55 = ^BOOL {
        BOOL v5 = NO;

        if (self.leftView) {
            v5 = self.rightView == nil;
        } else {
            v5 = YES;
        }

        if (v5) {
            return NO;
        } else {
            if (CGRectContainsRect(rect, alignmentRectForFrame(self.leftView))) {
                return CGRectContainsRect(rect, alignmentRectForFrame(self.rightView));
            } else {
                return YES;
            }
        }
    };
    __block BOOL v73 = NO;
    auto v20 = ^CGFloat {
        return CGRectGetWidth(CGRectUnion(alignmentRectForFrame(self.leftView), alignmentRectForFrame(self.rightView)));
    };
    auto v56 = ^{
        if (v73) {
            v73 = NO;
            [self setNeedsUpdateConstraints:YES];
            [self updateConstraintsForSubtreeIfNeeded];
            [super layout];
        }
    };

    if (v55()) {
        if (self.minimumWidthForExpandedTitle == 0.0) {
            self.minimumWidthForExpandedTitle = v20();
            [self _updateTitleView];
            v73 = YES;
            goto LABEL_8;
        }
    }

    CGFloat width = CGRectGetWidth(rect);
    CGFloat minimumWidthForExpandedTitle = self.minimumWidthForExpandedTitle;

    if (width >= minimumWidthForExpandedTitle) {
        if (minimumWidthForExpandedTitle > 0.0) {
            self.minimumWidthForExpandedTitle = minimumWidthForExpandedTitle;
            [self _updateTitleView];
            v73 = YES;
            goto LABEL_8;
        }
    }

 LABEL_8:
    v56();

    if (v55() && self.minimumWidthForExpandedItems == 0.0) {
        self.minimumWidthForExpandedItems = v20();

        for (UXBarButtonItem *item in _itemsSortedByPriority) {
            item.condensed = YES;
        }
    } else {
        if (CGRectGetWidth(rect) < self.minimumWidthForExpandedItems) {
            goto LABEL_28;
        }

        if (self.minimumWidthForExpandedItems <= 0.0) {
            goto LABEL_28;
        }

        self.minimumWidthForExpandedItems = 0.0;

        for (UXBarButtonItem *item in _itemsSortedByPriority) {
            item.condensed = NO;
        }
    }

    v73 = YES;
 LABEL_28:
    v56();

    for (NSNumber *minimumWidth in [_overflowItemsByMinimumWidth.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        if (CGRectGetWidth(rect) >= minimumWidth.floatValue) {
            UXBarButtonItem *item = _overflowItemsByMinimumWidth[minimumWidth];
            item._view.hidden = NO;
            [_itemsSortedByPriority insertObject:item atIndex:0];
            [_overflowItemsByMinimumWidth removeObjectForKey:minimumWidth];
            v73 = YES;
        }
    }

    v56();

    while (v55() && _leftView && _rightView && _itemsSortedByPriority.count) {
        UXBarButtonItem *firstItemsSortedByPriority = _itemsSortedByPriority.firstObject;
        firstItemsSortedByPriority._view.hidden = YES;
        CGFloat m = 0;

        for (m = v20();; m = m + -1.0) {
            UXBarButtonItem *item = [_overflowItemsByMinimumWidth objectForKey:@(m)];

            if (!item) {
                break;
            }
        }

        [_overflowItemsByMinimumWidth setObject:firstItemsSortedByPriority forKey:@(m)];
        [_itemsSortedByPriority removeObjectAtIndex:0];
        v73 = YES;
        v56();
    }
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];
    [self _updateStateForWindow:newWindow];
}

- (void)setState:(NSUInteger)state {
    if (_state != state) {
        _state = state;
        [self _updateItemViews];
    }
}

- (void)_updateItemViews {
    [NSAnimationContext beginGrouping];
    switch (_state) {
        case 2:
            goto LABEL_4;
            break;

        case 1:{
            [self.leftItemViews removeAllObjects];
            NSArray<NSView *> *leftBarButtonItemViews = [self.item.leftBarButtonItems valueForKeyPath:@"_view"];

            for (NSView *leftBarButtonItemView in leftBarButtonItemViews) {
                leftBarButtonItemView.translatesAutoresizingMaskIntoConstraints = NO;
                [leftBarButtonItemView removeFromSuperview];
                [self.leftItemViews addObject:leftBarButtonItemView];
                [self addSubview:leftBarButtonItemView];
            }

            [self.rightItemViews removeAllObjects];
            NSArray<NSView *> *rightBarButtonItemViews = [self.item.rightBarButtonItems valueForKeyPath:@"_view"];

            for (NSView *rightBarButtonItemView in rightBarButtonItemViews) {
                rightBarButtonItemView.translatesAutoresizingMaskIntoConstraints = NO;
                [rightBarButtonItemView removeFromSuperview];
                [self.rightItemViews addObject:rightBarButtonItemView];
                [self addSubview:rightBarButtonItemView];
            }

            [self _updateItemsSortedByPriority];
            [self _updateTitleView];
        }
        break;

        case 0:
 LABEL_4:
            self.subviews = @[];
            break;

        default:
            break;
    }
    [NSAnimationContext endGrouping];
    [self updateConstraintsForSubtreeIfNeeded];
}

- (void)_updateItemsSortedByPriority {
    for (UXBarButtonItem *item in _overflowItemsByMinimumWidth.allValues) {
        NSView *view = item._view;
        view.hidden = NO;
        item.condensed = NO;
    }

    self.minimumWidthForExpandedItems = 0.0;
    [_overflowItemsByMinimumWidth removeAllObjects];
    [_itemsSortedByPriority removeAllObjects];
    [_itemsSortedByPriority addObjectsFromArray:self.item.leftBarButtonItems];
    [_itemsSortedByPriority addObjectsFromArray:self.item.rightBarButtonItems];
    [_itemsSortedByPriority sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(visibilityPriority)) ascending:YES]]];
}

- (void)_updateTitleView {
    if (_state != 1) {
        return;
    }

    UXNavigationBar *navigationBar = self.navigationBar;
    UXNavigationItem *navigationItem = self.item;
    NSView *alternateCondensedTitleView = nil;
    NSView *titleView = nil;

    if (self.minimumWidthForExpandedTitle > 0.0 && (alternateCondensedTitleView = navigationBar.alternateCondensedTitleView)) {
        titleView = navigationBar.alternateCondensedTitleView;
    } else {
        titleView = navigationBar.alternateTitleView;
    }

    if (!navigationItem.hidesAlternateTitleView) {
        if (navigationBar.alternateTitleEnabled) {
            if (navigationBar.alternateTitleView) {
                self.titleView = titleView;
                return;
            }
        }
    }

    if (self.minimumWidthForExpandedTitle <= 0.0 || !navigationItem.condensedTitleView) {
        self.titleView = navigationItem.titleView;
        return;
    }

    self.titleView = navigationItem.condensedTitleView;
}

- (void)setTitleView:(NSView *)titleView {
    if (_titleView != titleView) {
        [_titleView removeFromSuperview];
        _titleView = titleView;

        if (_titleView) {
            [titleView removeFromSuperview];
            [self addSubview:_titleView];
        }
    }

    if (!titleView.superview) {
        [self addSubview:_titleView];
    }

    [self setNeedsUpdateConstraints:YES];
}

- (void)viewDidMoveToWindow {
    if (self.window) {
        [self setNeedsUpdateConstraints:YES];
    } else {
        self.state = 0;
    }
}

- (NSArray<NSView *> *)subviewsIntersectedWithViews:(NSArray<NSView *> *)views excludingHidden:(BOOL)excludingHidden {
    NSMutableOrderedSet<NSView *> *viewsOrderedSet = [NSMutableOrderedSet orderedSetWithArray:views];
    NSOrderedSet<NSView *> *subviewsOrderedSet = [NSOrderedSet orderedSetWithArray:self.subviews];

    [viewsOrderedSet intersectOrderedSet:subviewsOrderedSet];

    if (excludingHidden) {
        NSIndexSet *indexes = [viewsOrderedSet indexesOfObjectsPassingTest:^BOOL (NSView *_Nonnull view, NSUInteger idx, BOOL *_Nonnull stop) {
            return view.isHidden;
        }];
        [viewsOrderedSet removeObjectsAtIndexes:indexes];
    }

    return viewsOrderedSet.array;
}

- (void)updateLeftItemViewsAnimated:(BOOL)animated {
    if (_state == 1) {
        NSArray<NSView *> *newViews = [self.item.leftBarButtonItems valueForKeyPath:@"_view"];
        NSArray<NSView *> *itemsViews = self.leftItemViews.copy;
        [self _updateItemsViews:itemsViews withNewViews:newViews];
        [self _updateItemsSortedByPriority];
        self.leftItemViews = [NSMutableArray arrayWithArray:newViews];
        [self setNeedsUpdateConstraints:YES];
        [self updateConstraintsForSubtreeIfNeeded];
    }
}

- (void)_updateItemsViews:(NSArray<NSView *> *)itemsViews withNewViews:(NSArray<NSView *> *)newViews {
    NSArray<NSView *> *subviews = [self subviewsIntersectedWithViews:newViews excludingHidden:NO];
    NSMutableSet<NSView *> *itemsViewsSet = [NSMutableSet setWithArray:itemsViews];
    NSSet<NSView *> *subviewsSet = [NSSet setWithArray:subviews];

    [itemsViewsSet minusSet:subviewsSet];
    [itemsViewsSet makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSMutableSet<NSView *> *newViewsSet = [NSMutableSet setWithArray:newViews];
    [newViewsSet minusSet:subviewsSet];

    for (NSView *view in newViewsSet) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
    }
}

- (void)dealloc {
    [self _updateItemsSortedByPriority];
}

- (NSView *)hitTest:(NSPoint)point {
    NSView *result = [super hitTest:point];

    if (_navigationBar.isDetached) {
        if (result == self) {
            result = _titleCenteringTrackedView;
        }
    }

    return result;
}

- (void)_updateStateForWindow:(NSWindow *)window {
    if (window) {
        self.state = 1;
    }
}

- (void)updateRightItemViewsAnimated:(BOOL)animated {
    if (_state == 1) {
        NSArray<NSView *> *rightBarButtonItemsViews = [self.item.rightBarButtonItems valueForKeyPath:@"_view"];
        NSArray<NSView *> *rightItemViews = self.rightItemViews.copy;
        [self _updateItemsViews:rightItemViews withNewViews:rightBarButtonItemsViews];
        [self _updateItemsSortedByPriority];
        self.rightItemViews = [NSMutableArray arrayWithArray:rightBarButtonItemsViews];
        [self setNeedsUpdateConstraints:YES];
        [self updateConstraintsForSubtreeIfNeeded];
    }
}

- (void)cancelTransistion {
    self.state = 0;
    [self setNeedsUpdateConstraints:YES];
}

- (void)prepareForTransition {
    if (self.leftItemViews.count) {
        self.state = 2;
        return;
    }

    if (self.rightItemViews.count) {
        self.state = 2;
        return;
    }

    self.state = 2 * (self.titleView != nil);
}

@end
