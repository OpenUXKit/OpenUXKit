#import "_UXButtonCell.h"
#import "UXKitDefines.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation _UXButtonCell

- (UXControlState)_controlState {
    if (self.isEnabled) {
        return self.isHighlighted ? UXControlStateHighlighted : UXControlStateNormal;
    } else {
        return UXControlStateDisabled;
    }
}
- (void)drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(_UXButton *)controlView {
    
    if (image.isTemplate && !controlView.isBordered) {
        CGContextRef context = [NSGraphicsContext currentContext].CGContext;
        CGContextSaveGState(context);
        CGSize size = image.size;
        CGContextTranslateCTM(context, 0.0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        [image drawInRect:frame fromRect:CGRectMake(0, 0, size.width, size.height) operation:(NSCompositingOperationSourceOver) fraction:1.0];
        CGContextSetBlendMode(context, kCGBlendModeSourceIn);
        [[NSColor redColor] set];
        NSColor *textColor = [controlView _textColorForState:self._controlState];
        if (textColor) {
            [textColor set];
            CGContextFillRect(context, frame);
        }
        CGContextRestoreGState(context);
    } else {
        [super drawImage:image withFrame:frame inView:controlView];
    }
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(_UXButton *)controlView {
    NSAttributedString *attributedString = [controlView _attributedStringForState:self._controlState];
    self.attributedTitle = attributedString;
    return [super drawTitle:title withFrame:frame inView:controlView];
}


@end
