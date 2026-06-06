#import <OpenUXKit/UXViewAnimationContext.h>
#import <math.h>

static void parametersOfSpringAnimation(
        CGFloat *stiffnessRef,
        CGFloat *dampingRef,
        NSTimeInterval duration,
        CGFloat damping,
        CGFloat mass,
        CGFloat velocity,
        CGFloat threshold);

@implementation UXViewAnimationContext

- (void)generateSpringPropertiesForDuration:(NSTimeInterval)duration damping:(CGFloat)damping velocity:(CGFloat)velocity {
    _mass = 1.0;
    _velocity = velocity;
    parametersOfSpringAnimation(&_stiffness, &_damping, duration, damping, 1.0, velocity, 0.001);
}

static void parametersOfSpringAnimation(
        CGFloat *stiffnessRef,
        CGFloat *dampingRef,
        NSTimeInterval duration,
        CGFloat damping,
        CGFloat mass,
        CGFloat velocity,
        CGFloat threshold) {

    CGFloat validDamping = fmin(fmax(damping, 0.00000011920929), 1.0);
    CGFloat validDuration = fmin(fmax(duration, 0.01), 10.0);
    CGFloat (^newtonNumerator)(CGFloat);
    CGFloat (^newtonDenominator)(CGFloat);

    if (validDamping >= 1.0) {
        // Critically/over-damped envelope solves:
        //   ((s - v) * t + 1) * exp(-t * s) = ±threshold
        // where s is the natural frequency we are root-finding.
        newtonNumerator = ^CGFloat(CGFloat stiffness) {
            CGFloat velocityDelta = stiffness - velocity;
            CGFloat envelope = velocityDelta * validDuration + 1.0;
            CGFloat decay = expf((float)(-(validDuration * stiffness)));
            CGFloat signedThreshold = (velocityDelta < 0.0) ? threshold : -threshold;
            return signedThreshold + envelope * decay;
        };
        newtonDenominator = ^CGFloat(CGFloat stiffness) {
            CGFloat numerator = (validDuration * validDuration) * (velocity - stiffness);
            CGFloat decay = expf((float)(stiffness * validDuration));
            return numerator / decay;
        };
    } else {
        // Underdamped envelope solves:
        //   threshold = |((d * s - v) / (sqrt(1 - d²) * s)) * exp(-d * t * s)|
        CGFloat sqrtDampingFactor = sqrtf((float)(1.0 - validDamping * validDamping));
        CGFloat dampingVelocityProduct = velocity * (validDuration * validDamping);

        CGFloat (^sqrtStiffness)(CGFloat) = ^CGFloat(CGFloat stiffness) {
            return sqrtDampingFactor * stiffness;
        };
        CGFloat (^velocityRatio)(CGFloat) = ^CGFloat(CGFloat stiffness) {
            CGFloat numerator = -(velocity - validDamping * stiffness);
            return numerator / sqrtStiffness(stiffness);
        };
        newtonNumerator = ^CGFloat(CGFloat stiffness) {
            CGFloat decay = expf((float)(-(validDuration * validDamping * stiffness)));
            return threshold - fabs(velocityRatio(stiffness) * decay);
        };
        newtonDenominator = ^CGFloat(CGFloat stiffness) {
            CGFloat stiffnessSquared = stiffness * stiffness;
            CGFloat decayDouble = exp(-(validDuration * validDamping * stiffness));
            CGFloat ratio = velocityRatio(stiffness);
            CGFloat dampingDurationSquared = validDuration * (validDamping * validDamping);
            CGFloat envelope = velocity + dampingVelocityProduct * stiffness;
            CGFloat termA = envelope - dampingDurationSquared * stiffnessSquared;
            CGFloat termB = dampingDurationSquared * stiffnessSquared - envelope;
            CGFloat numerator = (decayDouble * ratio <= 0.0) ? termA : termB;
            CGFloat decayInverse = expf((float)(stiffness * validDuration * validDamping));
            return numerator / (stiffnessSquared * sqrtDampingFactor * decayInverse);
        };
    }

    CGFloat stiffness = (1.0 / validDuration) * 5.0;
    for (NSInteger iteration = 12; iteration > 0; --iteration) {
        CGFloat fValue = newtonNumerator(stiffness);
        CGFloat fDerivative = newtonDenominator(stiffness);
        stiffness -= fValue / fDerivative;
    }

    if (stiffnessRef) {
        *stiffnessRef = stiffness * (mass * stiffness);
    }
    if (dampingRef) {
        CGFloat sqrtStiffnessMass = sqrt(stiffness * (mass * mass * stiffness));
        *dampingRef = validDamping * (sqrtStiffnessMass + sqrtStiffnessMass);
    }
}

@end
