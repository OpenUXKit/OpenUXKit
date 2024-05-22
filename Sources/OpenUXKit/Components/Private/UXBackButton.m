#import <OpenUXKit/UXBackButton.h>

@interface UXBackButton ()
{
    BOOL _hidesTitle;    // 108 = 0x6c
    NSString *_title;    // 112 = 0x70
    NSImage *_image;    // 120 = 0x78
}

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

@end
