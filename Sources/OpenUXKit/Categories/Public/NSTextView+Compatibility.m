#import <OpenUXKit/NSTextView+Compatibility.h>

@implementation NSTextView (Compatibility)

@dynamic textAlignment;
@dynamic text;

- (NSString *)text {
    return self.string;
}

- (void)setText:(NSString *)text {
    self.string = text ?: @"";
}

- (NSInteger)textAlignment {
    return (NSInteger)self.alignment;
}

- (void)setTextAlignment:(NSInteger)textAlignment {
    self.alignment = (NSTextAlignment)textAlignment;
}

- (CGSize)sizeThatFits:(CGSize)size {
    NSTextContainer *container = self.textContainer;
    NSLayoutManager *layoutManager = self.layoutManager;
    if (!container || !layoutManager) {
        return CGSizeZero;
    }
    CGSize originalContainerSize = container.size;
    container.size = CGSizeMake(size.width, CGFLOAT_MAX);
    [layoutManager ensureLayoutForTextContainer:container];
    CGRect usedRect = [layoutManager usedRectForTextContainer:container];
    container.size = originalContainerSize;
    return CGSizeMake(ceil(CGRectGetWidth(usedRect)), ceil(CGRectGetHeight(usedRect)));
}

@end
