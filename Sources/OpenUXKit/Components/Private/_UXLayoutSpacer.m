#import <OpenUXKit/_UXLayoutSpacer.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXKitPrivateUtilites.h>

@interface _UXLayoutSpacer () {
    NSLayoutConstraint *_counterDimensionConstraint;
    NSLayoutConstraint *_dimensionConstraint;
}

@end

@implementation _UXLayoutSpacer

+ (instancetype)_horizontalLayoutSpacer {
    _UXLayoutSpacer *spacer = [[self alloc] init];

    spacer->_horizontal = YES;
    [spacer _setUpCounterDimensionConstraint];
    [spacer _setUpDimensionConstraintWithLength:0.0];
    return spacer;
}

+ (instancetype)_verticalLayoutSpacer {
    _UXLayoutSpacer *spacer = [[self alloc] init];

    [spacer _setUpCounterDimensionConstraint];
    [spacer _setUpDimensionConstraintWithLength:0.0];
    return spacer;
}

- (void)_setUpCounterDimensionConstraint {
    if (!_counterDimensionConstraint) {
        NSLayoutDimension *layoutDimension = nil;

        if (self.horizontal) {
            layoutDimension = self.heightAnchor;
        } else {
            layoutDimension = self.widthAnchor;
        }

        _counterDimensionConstraint = [layoutDimension constraintEqualToConstant:0.0];
        _counterDimensionConstraint.priority = 999;
    }
}

- (void)_setUpDimensionConstraintWithLength:(CGFloat)length {
    if (_dimensionConstraint) {
        if (_dimensionConstraint.constant == length) {
            return;
        }

        _dimensionConstraint.constant = length;
    } else {
        NSLayoutDimension *layoutDimension = nil;

        if (self.horizontal) {
            layoutDimension = self.widthAnchor;
        } else {
            layoutDimension = self.heightAnchor;
        }

        _dimensionConstraint = [layoutDimension constraintEqualToConstant:length];
        _dimensionConstraint.priority = 999;
    }

    auto lengthUpdateBlock = self.lengthUpdateBlock;

    if (lengthUpdateBlock) {
        lengthUpdateBlock();
    }
}

- (void)_activate {
    _counterDimensionConstraint.active = YES;
    _dimensionConstraint.active = YES;
}

- (void)setLength:(CGFloat)length {
    [self _setUpDimensionConstraintWithLength:length];
}

- (CGFloat)length {
    return _dimensionConstraint.constant;
}

@end
