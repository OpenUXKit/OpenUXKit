#import "UXLabel.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXLabel () {
    NSTextField *_concreteTextField;
    NSArray<NSLayoutConstraint *> *_verticalDefaultConstraints;
    NSArray<NSLayoutConstraint *> *_verticalCenteringConstraints;
}

@end

NS_HEADER_AUDIT_END(nullability, sendability)
