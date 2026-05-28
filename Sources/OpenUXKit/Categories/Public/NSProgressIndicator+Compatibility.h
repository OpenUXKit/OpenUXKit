#import <AppKit/NSProgressIndicator.h>

@class NSColor;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSProgressIndicator (Compatibility)

- (instancetype)initWithProgressViewStyle:(NSInteger)progressViewStyle;
- (instancetype)initWithActivityIndicatorStyle:(NSInteger)activityIndicatorStyle;

@property (nonatomic) NSInteger progressViewStyle;
@property (nonatomic) CGFloat progress;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@property (nonatomic) NSInteger activityIndicatorViewStyle;
@property (nonatomic) BOOL hidesWhenStopped;
@property (nonatomic, strong, nullable) NSColor *color;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
