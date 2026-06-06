#import <OpenUXKit/NSProgressIndicator+Compatibility.h>

@implementation NSProgressIndicator (Compatibility)

- (instancetype)initWithProgressViewStyle:(NSInteger)progressViewStyle {
    self = [super init];
    if (self) {
        self.style = (NSProgressIndicatorStyle)progressViewStyle;
        self.controlSize = NSControlSizeSmall;
        self.indeterminate = NO;
        self.minValue = 0.0;
        self.maxValue = 1.0;
    }
    return self;
}

- (instancetype)initWithActivityIndicatorStyle:(NSInteger)activityIndicatorStyle {
    self = [super init];
    if (self) {
        self.style = NSProgressIndicatorStyleSpinning;
        self.displayedWhenStopped = NO;
        BOOL useSmall = ((NSUInteger)(activityIndicatorStyle - 1) < 2) || (activityIndicatorStyle == 100);
        self.controlSize = useSmall ? NSControlSizeSmall : NSControlSizeRegular;
    }
    return self;
}

- (NSInteger)progressViewStyle {
    return (NSInteger)self.style;
}

- (void)setProgressViewStyle:(NSInteger)progressViewStyle {
    self.style = (NSProgressIndicatorStyle)progressViewStyle;
}

- (CGFloat)progress {
    return self.doubleValue;
}

- (void)setProgress:(CGFloat)progress {
    self.doubleValue = progress;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    [self setProgress:progress];
}

- (NSInteger)activityIndicatorViewStyle {
    return (NSInteger)self.style;
}

- (void)setActivityIndicatorViewStyle:(NSInteger)activityIndicatorViewStyle {
    self.style = (NSProgressIndicatorStyle)activityIndicatorViewStyle;
}

- (BOOL)hidesWhenStopped {
    return !self.displayedWhenStopped;
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped {
    self.displayedWhenStopped = !hidesWhenStopped;
}

- (NSColor *)color {
    NSLog(@"%s not implemented", "-[NSProgressIndicator(Compatibility) color]");
    return nil;
}

- (void)setColor:(NSColor *)color {
    NSLog(@"%s not implemented", "-[NSProgressIndicator(Compatibility) setColor:]");
}

- (void)startAnimating {
    [self startAnimation:nil];
}

- (void)stopAnimating {
    [self stopAnimation:nil];
}

- (BOOL)isAnimating {
    return NO;
}

@end
