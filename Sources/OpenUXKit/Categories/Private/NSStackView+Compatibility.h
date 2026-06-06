#import <AppKit/NSStackView.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSStackView (Compatibility)

@property (nonatomic) NSInteger axis;

+ (instancetype)stackViewWithArrangedSubviews:(NSArray<NSView *> *)arrangedSubviews;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
