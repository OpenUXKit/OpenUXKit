#import <AppKit/AppKit.h>
#import "UXToolbar.h"

@class NSLayoutConstraint;

@interface UXSubtoolbar: UXToolbar

+ (CGFloat)defaultHeight;

@property(readonly, nonatomic) NSLayoutConstraint *heightConstraint; // @synthesize heightConstraint=_heightConstraint;
- (void)setHeight:(CGFloat)height;

@end

