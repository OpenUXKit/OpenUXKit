#import <OpenUXKit/UXViewAnimationContext.h>

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

    CGFloat clampedDamping = fmin(fmax(damping, 0.00000011920929), 1.0);
    CGFloat clampedDuration = fmin(fmax(duration, 0.01), 10.0);
    CGFloat(^calculateStiffness)(CGFloat);
    CGFloat(^calculateDampingCoefficient)(CGFloat);
    if (clampedDamping >= 1.0) {
        calculateStiffness = ^CGFloat(CGFloat stiffness) {
            CGFloat velocityDifference = stiffness - velocity;
            CGFloat thresholdValue = threshold;
            CGFloat durationValue = clampedDuration;
            CGFloat stiffnessTerm = velocityDifference * durationValue + 1.0;
            durationValue = -durationValue * stiffness;
            CGFloat stiffnessFactor = (float)durationValue;
            CGFloat thresholdFactor = -thresholdValue;
            if (velocityDifference < 0.0) {
                thresholdFactor = thresholdValue;
            }
            return thresholdFactor + stiffnessTerm * stiffnessFactor;
        };
        calculateDampingCoefficient = ^CGFloat(CGFloat stiffness) {
            CGFloat durationSquared = clampedDuration * clampedDuration * (velocity - stiffness);
            CGFloat stiffnessDurationProduct = clampedDuration * stiffness;
            return durationSquared / (float)stiffnessDurationProduct;
        };
    } else {
        CGFloat dampingFactor = 1.0 - clampedDamping * clampedDamping;
        CGFloat sqrtDampingFactor = sqrt(dampingFactor);
        CGFloat dampingVelocityProduct = clampedDuration * clampedDamping * velocity;
        __auto_type calculateSqrtStiffness = ^CGFloat(CGFloat stiffness) {
            return sqrtDampingFactor * stiffness;
        };
        __auto_type calculateVelocityRatio = ^CGFloat(CGFloat stiffness){
            CGFloat velocityDifference = -(velocity - clampedDamping * stiffness);
            return velocityDifference / calculateSqrtStiffness(stiffness);
        };
        calculateStiffness = ^CGFloat(CGFloat stiffness){
            CGFloat thresholdValue = threshold;
            CGFloat dampingDurationProduct = clampedDamping * clampedDuration * stiffness;
            CGFloat stiffnessFactor = (float)dampingDurationProduct;
            return thresholdValue - fabs(calculateVelocityRatio(stiffness) * stiffnessFactor);
        };
        calculateDampingCoefficient = ^CGFloat(CGFloat stiffness){
            CGFloat stiffnessSquared = stiffness * stiffness;
            CGFloat dampingDurationProduct = -(clampedDuration * clampedDamping) * stiffness;
            CGFloat velocityRatio = calculateVelocityRatio(stiffness);
            CGFloat dampingDurationSquared = clampedDuration * (clampedDamping * clampedDamping);
            CGFloat velocityTerm = velocity + dampingVelocityProduct * stiffness;
            CGFloat dampingTerm = -dampingDurationSquared;
            CGFloat velocityDifference1 = velocityTerm - dampingTerm * stiffnessSquared;
            CGFloat velocityDifference2 = -(velocityTerm + dampingTerm * stiffnessSquared);
            CGFloat velocityDifference;
            if (dampingDurationProduct * velocityRatio <= 0.0) {
                velocityDifference = velocityDifference1;
            } else {
                velocityDifference = velocityDifference2;
            }
            CGFloat stiffnessDampingProduct = clampedDuration * clampedDamping * stiffness;
            return velocityDifference / (stiffnessSquared * sqrtDampingFactor * stiffnessDampingProduct);
        };
    }
    CGFloat stiffness = 1.0 / clampedDuration * 5.0;
    NSInteger iterationCount = 12;
    do {
        CGFloat stiffnessDifference = calculateStiffness(stiffness);
        stiffness = stiffness - stiffnessDifference / calculateDampingCoefficient(stiffness);
        --iterationCount;
    } while (iterationCount);
    if (stiffnessRef) {
        *stiffnessRef = stiffness * (stiffness * mass);
    }
    if (dampingRef) {
        CGFloat stiffnessMassProduct = sqrt(stiffness * (mass * mass * stiffness));
        *dampingRef = clampedDamping * (stiffnessMassProduct + stiffnessMassProduct);
    }
}

//void parametersOfSpringAnimation(
//        CGFloat *stiffnessRef,
//        CGFloat *dampingRef,
//        NSTimeInterval duration,
//        CGFloat damping,
//        CGFloat mass,
//        CGFloat velocity,
//        CGFloat threshold) {
//
//    CGFloat validDamping = fmin(fmax(damping, 0.00000011920929), 1.0);
//    CGFloat validDuration = fmin(fmax(duration, 0.01), 10.0);
//    CGFloat(^calculateStiffness)(CGFloat);
//    CGFloat(^calculateDampingCoefficient)(CGFloat);
//    if (validDamping >= 1.0) {
//        calculateStiffness = ^CGFloat(CGFloat stiffness){
//            CGFloat v4 = stiffness - velocity;
//            CGFloat v6 = threshold;
//            CGFloat v5 = validDuration;
//            CGFloat v7 = v4 * v5 + 1.0;
//            v5 = -v5 * stiffness;
//            CGFloat v8 = (float)v5;
//            CGFloat v9 = -v6;
//            if (v4 < 0.0) {
//                v9 = v6;
//            }
//            return v9 + v7 * v8;
//        };
//        calculateDampingCoefficient = ^CGFloat(CGFloat arg0){
//            CGFloat v2 = validDuration * validDuration * (velocity - arg0);
//            CGFloat v3 = validDuration * arg0;
//            return v2 / (float)v3;
//        };
//    } else {
//        CGFloat v14 = 1.0 - validDamping * validDamping;
//        CGFloat v15 = sqrt(v14);
//        CGFloat v26 = validDuration * validDamping * velocity;
//        __auto_type v44 = ^CGFloat(CGFloat arg0) {
//            return v15 * arg0;
//        };
//        __auto_type v42 = ^CGFloat(CGFloat arg0){
//            CGFloat v2 = -(velocity - validDamping * arg0);
//            return v2 / v44(arg0);
//        };
//        calculateStiffness = ^CGFloat(CGFloat arg0){
//            CGFloat v4 = threshold;
//            CGFloat v5 = validDamping * validDuration * arg0;
//            CGFloat v6 = (float)v5;
//            return v4 - fabs(v42(arg0) * v6);
//        };
//        calculateDampingCoefficient = ^CGFloat(CGFloat arg0){
//            CGFloat v4 = arg0 * arg0;
//            CGFloat v5 = -(validDuration * validDamping) * arg0;
//            CGFloat v6 = v42(arg0);
//            CGFloat v7 = validDuration * (validDamping * validDamping);
//            CGFloat v8 = velocity + v26 * arg0;
//            CGFloat v9 = -v7;
//            CGFloat v10 = v8 - v7 * v4;
//            CGFloat v11 = -(v8 + v9 * v4);
//            CGFloat v12;
//            if (v5 * v6 <= 0.0) {
//                v12 = v10;
//            } else {
//                v12 = v11;
//            }
//            CGFloat v13 = validDuration * validDamping * arg0;
//            return v12 / (v4 * v15 * v13);
//        };
//    }
//    CGFloat v22 = 1.0 / validDuration * 5.0;
//    CGFloat v23 = 12;
//    do {
//        CGFloat v24 = calculateStiffness(v22);
//        v22 = v22 - v24 / calculateDampingCoefficient(v22);
//        --v23;
//    } while (v23);
//    if (stiffnessRef) {
//        *stiffnessRef = v22 * (v22 * mass);
//    }
//    if (dampingRef) {
//        CGFloat v25 = sqrt(v22 * (mass * mass * v22));
//        *dampingRef = validDamping * (v25 + v25);
//    }
//}

@end
