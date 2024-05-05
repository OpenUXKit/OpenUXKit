

#import <AppKit/NSProgressIndicator.h>

@class NSColor;

@interface NSProgressIndicator (Compatibility)
- (BOOL)isAnimating;
- (void)stopAnimating;
- (void)startAnimating;
@property(strong, nonatomic) NSColor *color;
@property(nonatomic) BOOL hidesWhenStopped;
@property(nonatomic) NSInteger activityIndicatorViewStyle;
- (void)setProgress:(CGFloat)arg1 animated:(BOOL)arg2;
@property(nonatomic) CGFloat progress;
@property(nonatomic) NSInteger progressViewStyle;
- (id)initWithProgressViewStyle:(NSInteger)arg1;
- (id)initWithActivityIndicatorStyle:(NSInteger)arg1;
@end

