#import <OpenUXKit/UXNavigationItem+Internal.h>

@implementation UXNavigationItem {
    NSTextField *_internalTitleLabel;
    NSTextField *_internalSubtitleLabel;
}

@synthesize identifier;

- (instancetype)init {
    return [self initWithTitle:@""];
}

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        _hidesAlternateTitleView = NO;
        _title = title;
    }
    return self;
}

- (NSArray *)leadingBarButtonItems {
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        return self.rightBarButtonItems;
    } else {
        return self.leftBarButtonItems;
    }
}

- (NSArray *)leftBarButtonItems {
    NSMutableArray *leftBarButtonItems = [NSMutableArray arrayWithArray:_leftBarButtonItems];
    if (NSApp.userInterfaceLayoutDirection != NSUserInterfaceLayoutDirectionRightToLeft) {
        if (self.switchLibraryButtonItem) {
            [leftBarButtonItems insertObject:self.switchLibraryButtonItem atIndex:0];
        }
    }
    if (NSApp.userInterfaceLayoutDirection != NSUserInterfaceLayoutDirectionRightToLeft) {
        if (self.backBarButtonItem) {
            if (!self.hidesBackButton) {
                [leftBarButtonItems insertObject:self.backBarButtonItem atIndex:0];
            }
        }
    }
    return leftBarButtonItems;
}

- (void)setLeadingBarButtonItems:(NSArray *)leadingBarButtonItems {
    [self setLeftBarButtonItems:leadingBarButtonItems animated:NO];
}

- (void)setLeadingBarButtonItems:(NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated {
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        [self setRightBarButtonItems:items animated:animated];
    } else {
        [self setLeftBarButtonItems:items animated:animated];
    }
}

- (void)setLeftBarButtonItems:(NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated {
    [self willChangeValueForKey:NSStringFromSelector(@selector(leftBarButtonItems))];
    _leftBarButtonItems = items;
    [self didChangeValueForKey:NSStringFromSelector(@selector(leftBarButtonItems))];
}

- (NSArray *)trailingBarButtonItems {
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        return self.leftBarButtonItems;
    } else {
        return self.rightBarButtonItems;
    }
}

- (NSArray *)rightBarButtonItems {
    NSMutableArray *rightBarButtonItems = [NSMutableArray arrayWithArray:_rightBarButtonItems];
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        if (self.switchLibraryButtonItem) {
            [rightBarButtonItems insertObject:self.switchLibraryButtonItem atIndex:0];
        }
    }
    
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        if (self.backBarButtonItem) {
            if (!self.hidesBackButton) {
                [rightBarButtonItems insertObject:self.backBarButtonItem atIndex:0];
            }
        }
    }
    return rightBarButtonItems;
}

- (void)setTrailingBarButtonItems:(NSArray *)trailingBarButtonItems {
    [self setTrailingBarButtonItems:trailingBarButtonItems animated:NO];
}

- (void)setTrailingBarButtonItems:(NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated {
    if (NSApp.userInterfaceLayoutDirection == NSUserInterfaceLayoutDirectionRightToLeft) {
        [self setLeftBarButtonItems:items animated:animated];
    } else {
        [self setRightBarButtonItems:items animated:animated];
    }
}

- (void)setRightBarButtonItems:(NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated {
    [self willChangeValueForKey:NSStringFromSelector(@selector(rightBarButtonItems))];
    _rightBarButtonItems = items;
    [self didChangeValueForKey:NSStringFromSelector(@selector(rightBarButtonItems))];
}

- (void)setLeftBarButtonItems:(NSArray *)leftBarButtonItems {
    [self setLeftBarButtonItems:leftBarButtonItems animated:NO];
}

- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems {
    [self setRightBarButtonItems:rightBarButtonItems animated:NO];
}

- (NSView *)titleView {
    if (_titleView) {
        _titleView.translatesAutoresizingMaskIntoConstraints = NO;
    } else {
        _titleView = self.internalTitleView;
    }
    return _titleView;
}

- (UXBarButtonItem *)rightBarButtonItem {
    return _rightBarButtonItems.firstObject;
}

- (void)setRightBarButtonItem:(UXBarButtonItem *)rightBarButtonItem {
    [self setRightBarButtonItem:rightBarButtonItem animated:NO];
}

- (UXBarButtonItem *)leftBarButtonItem {
    return _leftBarButtonItems.firstObject;
}

- (void)setLeftBarButtonItem:(UXBarButtonItem *)leftBarButtonItem {
    [self setLeftBarButtonItem:leftBarButtonItem animated:NO];
}

- (void)_updateInternalTitleView {
    _internalTitleLabel.stringValue = self.title ?: @"";
    _internalSubtitleLabel.stringValue = self.subtitle ?: @"";
    _internalSubtitleLabel.hidden = (self.subtitle.length == 0);
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self _updateInternalTitleView];
}

- (NSTextField *)internalTitleLabel {
    return _internalTitleLabel;
}

- (NSTextField *)internalSubtitleLabel {
    return _internalSubtitleLabel;
}

- (NSView *)internalTitleView {
    if (!_internalTitleView) {
        _internalTitleLabel = [NSTextField labelWithString:@""];
        _internalTitleLabel.alignment = NSTextAlignmentCenter;
        _internalTitleLabel.textColor = NSColor.windowFrameTextColor;
        _internalTitleLabel.font = [NSFont titleBarFontOfSize:NSFont.systemFontSize];
        _internalTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _internalTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_internalTitleLabel setContentCompressionResistancePriority:300 forOrientation:(NSLayoutConstraintOrientationHorizontal)];

        _internalSubtitleLabel = [NSTextField labelWithString:@""];
        _internalSubtitleLabel.alignment = NSTextAlignmentCenter;
        _internalSubtitleLabel.textColor = NSColor.secondaryLabelColor;
        _internalSubtitleLabel.font = [NSFont systemFontOfSize:NSFont.smallSystemFontSize];
        _internalSubtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _internalSubtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _internalSubtitleLabel.hidden = YES;

        _internalTitleView = [NSStackView stackViewWithViews:@[_internalTitleLabel, _internalSubtitleLabel]];
        _internalTitleView.orientation = NSUserInterfaceLayoutOrientationVertical;
        _internalTitleView.alignment = NSLayoutAttributeCenterX;
        _internalTitleView.spacing = 0;
        _internalTitleView.translatesAutoresizingMaskIntoConstraints = NO;
        [_internalTitleView setContentCompressionResistancePriority:300 forOrientation:(NSLayoutConstraintOrientationHorizontal)];
        [self _updateInternalTitleView];
    }
    return _internalTitleView;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = [subtitle copy];
    [self _updateInternalTitleView];
}

- (void)setRightBarButtonItem:(UXBarButtonItem *)item animated:(BOOL)animated {
    [self setRightBarButtonItems:@[item] animated:animated];
}

- (void)setLeftBarButtonItem:(UXBarButtonItem *)item animated:(BOOL)animated {
    [self setLeftBarButtonItems:@[item] animated:animated];
}

+ (NSArray<NSString *> *)keyPathsToObserve {
    static dispatch_once_t onceToken;
    static NSArray<NSString *> *keyPaths = nil;
    dispatch_once(&onceToken, ^{
        keyPaths = @[
            @"title",
            @"titleView",
            @"switchLibraryButtonItem",
            @"leftBarButtonItems",
            @"rightBarButtonItems",
            @"hidesBackButton",
            @"backBarButtonItem",
            @"hidesAlternateTitleView",
            @"searchField",
        ];
    });
    return keyPaths;
}


@end
