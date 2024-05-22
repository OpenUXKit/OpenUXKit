#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXViewAnimationContext : NSObject

@property (nonatomic) CGFloat velocity;
@property (nonatomic) CGFloat damping;
@property (nonatomic) CGFloat stiffness;
@property (nonatomic) CGFloat mass;

- (void)generateSpringPropertiesForDuration:(NSTimeInterval)duration damping:(CGFloat)damping velocity:(CGFloat)velocity;

@end


NS_HEADER_AUDIT_END(nullability, sendability)
