#import <AppKit/AppKit.h>

@interface UXViewAnimationContext : NSObject

@property (nonatomic) CGFloat velocity;
@property (nonatomic) CGFloat damping;
@property (nonatomic) CGFloat stiffness;
@property (nonatomic) CGFloat mass;
- (void)generateSpringPropertiesForDuration:(NSTimeInterval)duration damping:(CGFloat)damping velocity:(CGFloat)velocity;

@end
