//
//  UXViewAnimationContext.m
//  
//
//  Created by JH on 2024/4/7.
//

#import "UXViewAnimationContext.h"
#import <QuartzCore/QuartzCore.h>
#import <AppKit/AppKit.h>

@implementation UXViewAnimationContext

- (void)generateSpringPropertiesForDuration:(NSTimeInterval)duration damping:(CGFloat)damping velocity:(CGFloat)velocity {
    _mass = 1.0;
    _velocity = velocity;
    parametersOfSpringAnimation(&_stiffness, &_damping, duration, damping, 1.0, velocity, 0.001);
}

void parametersOfSpringAnimation(
        CGFloat *stiffnessRef,
        CGFloat *dampingRef,
        NSTimeInterval duration,
        CGFloat damping,
        CGFloat mass,
        CGFloat velocity,
        CGFloat threshold) {

    CGFloat validDamping = fmin(fmax(damping, 0.00000011920929), 1.0);
    CGFloat validDuration = fmin(fmax(duration, 0.01), 10.0);
    CGFloat(^v19)(CGFloat);
    CGFloat(^v21)(CGFloat);
    if (validDamping >= 1.0) {
        v19 = ^CGFloat(CGFloat arg0){
            CGFloat v4 = arg0 - velocity;
            CGFloat v6 = threshold;
            CGFloat v5 = validDuration;
            CGFloat v7 = v4 * v5 + 1.0;
            v5 = -v5 * arg0;
            CGFloat v8 = (float)v5;
            CGFloat v9 = -v6;
            if (v4 < 0.0) {
                v9 = v6;
            }
            return v9 + v7 * v8;
        };
        v21 = ^CGFloat(CGFloat arg0){
            CGFloat v2 = validDuration * validDuration * (velocity - arg0);
            CGFloat v3 = validDuration * arg0;
            return v2 / (float)v3;
        };
    } else {
        CGFloat v14 = 1.0 - validDamping * validDamping;
        CGFloat v15 = sqrt(v14);
        CGFloat v26 = validDuration * validDamping * velocity;
        __auto_type v44 = ^CGFloat(CGFloat arg0) {
            return v15 * arg0;
        };
        __auto_type v42 = ^CGFloat(CGFloat arg0){
            CGFloat v2 = -(velocity - validDamping * arg0);
            return v2 / v44(arg0);
        };
        v19 = ^CGFloat(CGFloat arg0){
            CGFloat v4 = threshold;
            CGFloat v5 = validDamping * validDuration * arg0;
            CGFloat v6 = (float)v5;
            return v4 - fabs(v42(arg0) * v6);
        };
        v21 = ^CGFloat(CGFloat arg0){
            CGFloat v4 = arg0 * arg0;
            CGFloat v5 = -(validDuration * validDamping) * arg0;
            CGFloat v6 = v42(arg0);
            CGFloat v7 = validDuration * (validDamping * validDamping);
            CGFloat v8 = velocity + v26 * arg0;
            CGFloat v9 = -v7;
            CGFloat v10 = v8 - v7 * v4;
            CGFloat v11 = -(v8 + v9 * v4);
            CGFloat v12;
            if (v5 * v6 <= 0.0) {
                v12 = v10;
            } else {
                v12 = v11;
            }
            CGFloat v13 = validDuration * validDamping * arg0;
            return v12 / (v4 * v15 * v13);
        };
    }
    CGFloat v22 = 1.0 / validDuration * 5.0;
    CGFloat v23 = 12;
    do {
        CGFloat v24 = v19(v22);
        v22 = v22 - v24 / v21(v22);
        --v23;
    } while (v23);
    if (stiffnessRef) {
        *stiffnessRef = v22 * (v22 * mass);
    }
    if (dampingRef) {
        CGFloat v25 = sqrt(v22 * (mass * mass * v22));
        *dampingRef = validDamping * (v25 + v25);
    }
}

@end
