#import <OpenUXKit/UXSubtoolbar.h>
#import <OpenUXKit/UXBar+Internal.h>

@interface UXSubtoolbar ()
@end

@implementation UXSubtoolbar

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _heightConstraint = [self.heightAnchor constraintEqualToConstant:self.height];
        _heightConstraint.active = YES;
    }
    return self;
}

- (void)setHeight:(CGFloat)height {
    [super setHeight:height];
    
    self.heightConstraint.constant = height;
}

+ (CGFloat)defaultHeight {
    return 40.0;
}

@end
