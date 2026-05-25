#import <OpenUXKit/_UXSinglePixelLine.h>
#import <OpenUXKit/NSView+UXKit.h>


@interface _UXSinglePixelLine () {
    NSColor *_color;
}

@end

@implementation _UXSinglePixelLine

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.wantsLayer = YES;
        self.color = [NSColor quaternaryLabelColor];
    }

    return self;
}

- (void)setColor:(NSColor *)color {
    _color = color;
    self.layer.backgroundColor = color.CGColor;
}

- (NSColor *)color {
    return _color;
}

- (void)viewDidChangeBackingProperties {
    [super viewDidChangeBackingProperties];
    [self updateHeight];
}

- (void)viewDidMoveToSuperview {
    [super viewDidMoveToSuperview];
    [self updateHeight];
}

- (void)updateHeight {
    CGRect frame = self.frame;
    CGFloat backingScaleFactor = self.ux_backingScaleFactor;
    NSAutoresizingMaskOptions autoresizingMask = self.autoresizingMask;
    CGFloat height = 1.0 / backingScaleFactor;
    CGFloat yOffset = frame.size.height - height;

    if (!(autoresizingMask & NSViewMinYMargin)) {
        yOffset = -0.0;
    }

    CGFloat y = frame.origin.y + yOffset;
    CGRect newRect = CGRectMake(frame.origin.x, y, frame.size.width, height);

    if (!CGRectEqualToRect(self.frame, newRect)) {
        self.frame = newRect;
        [self setNeedsDisplay:YES];
    }
}

@end
