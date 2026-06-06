#import <OpenUXKit/UXControl.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXControl () {
    BOOL _highlighted;
    BOOL _selected;
    BOOL _enabled;
    BOOL _ignoresMultiClick;
    BOOL _sendsActionOnMouseDown;
    __weak id _target;
    SEL _action;
}

@end

NS_HEADER_AUDIT_END(nullability, sendability)
