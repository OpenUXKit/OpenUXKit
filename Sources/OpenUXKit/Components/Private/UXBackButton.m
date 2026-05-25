#import <OpenUXKit/UXBackButton.h>

@interface UXBackButton ()
@end

@implementation UXBackButton

- (instancetype)init {
    if (self = [super init]) {
        self.identifier = NSStringFromClass([UXBackButton class]);
        self.segmentStyle = NSSegmentStyleTexturedSquare;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.font = [NSFont systemFontOfSize:NSFont.systemFontSize];
        self.ignoresMultiClick = YES;
        self.segmentCount = 1;
    }
    return self;
}

- (BOOL)accessibilityPerformPress {
    return [NSApp sendAction:self.action to:self.target from:self];
}

- (NSAccessibilityRole)accessibilityRole {
    return NSAccessibilityButtonRole;
}

- (id)accessibilityHitTest:(NSPoint)point {
    return self;
}

- (void)setImage:(NSImage *)image {
    _image = image;
    [self setImage:image forSegment:0];
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    if (_hidesTitle) {
        self.toolTip = title;
    }
}

- (void)setHidesTitle:(BOOL)hidesTitle {
    if (hidesTitle) {
        [self setLabel:@"" forSegment:0];
        [self setWidth:19.0 forSegment:0];
        if (_hidesTitle != hidesTitle) {
            self.toolTip = self.title;
        }
    } else {
        [self setLabel:self.title forSegment:0];
        [self setWidth:0.0 forSegment:0];
        if (_hidesTitle) {
            self.toolTip = nil;
        }
    }
}

/// Routes the supplied menu to segment 0 so the back chevron's long-press
/// menu works regardless of whether callers use the segmented `setMenu:forSegment:`
/// API directly or the `UXBackButtonProtocol`-defined `menu` property.
- (void)setMenu:(NSMenu *)menu {
    [super setMenu:menu];
    [self setMenu:menu forSegment:0];
}

@end
