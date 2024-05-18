#import <OpenUXKit/_UXSourceSplitViewShadowView.h>

@implementation _UXSourceSplitViewShadowView

- (NSImage *)makeShadowImage {
    CGFloat shadowRevealAmount = self.shadowRevealAmount;
    NSUInteger shadowEdge = self.shadowEdge;
    CGFloat width = 1.0;
    CGFloat height = 1.0;
    if (shadowEdge & 13) {
        width = 1.0;
    } else {
        width = 12.0;
    }
    if (shadowEdge & 13) {
        height = 12.0;
    }
    return [NSImage imageWithSize:CGSizeMake(width, height) flipped:YES drawingHandler:^BOOL(NSRect dstRect) {
        CGFloat width = 0.0;
        CGFloat height = 0.0;
        if (!(shadowEdge & 13)) {
            width = 12.0;
            height = 1.0;
        } else {
            width = 1.0;
            height = 12.0;
        }
        CGContextRef context = NSGraphicsContext.currentContext.CGContext;
        CGRect rect = CGRectMake(0.0, 0.0, width, height);
        CGContextClearRect(context, rect);
        NSShadow *shadow = [NSShadow new];
        shadow.shadowOffset = CGSizeMake(0.0, 0.0);
        shadow.shadowBlurRadius = shadowRevealAmount * 12.0;
        shadow.shadowColor = [NSColor colorWithWhite:0.0 alpha:shadowRevealAmount * 0.6];
        [shadow set];
        [[NSColor blackColor] set];
        CGFloat x = 0.0;
        CGFloat y = 0.0;
        
        if (shadowEdge) {
            x = 12.0;
        } else {
            x = -12.0;
        }
        
        if (shadowEdge == 1) {
            y = -12.0;
        } else {
            y = 12.0;
        }
        
        if (!(shadowEdge & 13)) {
            y = 0.0;
        } else {
            x = 0.0;
        }
        
        NSRectFillUsingOperation(CGRectMake(x, y, 12.0, 12.0), NSCompositingOperationCopy);
        return YES;
    }];
    
}

- (NSSize)intrinsicContentSize {
    CGFloat width = 0.0;
    CGFloat height = 0.0;
    switch (self.shadowEdge) {
        case 0:
        case 2:
            width = 12.0;
            height = -1.0;
            break;
        case 1:
        case 3:
            width = -1.0;
            height = 12.0;
        default:
            break;
    }
    return CGSizeMake(width, height);
}

- (void)setShadowRevealAmount:(CGFloat)shadowRevealAmount {
    if (_shadowRevealAmount != shadowRevealAmount) {
        _shadowRevealAmount = shadowRevealAmount;
        [self setNeedsDisplay:YES];
        BOOL allowsImplicitAnimation =  NSAnimationContext.currentContext.allowsImplicitAnimation;
        if (allowsImplicitAnimation) {
            [self updateLayer];
        }
    }
}

- (void)setFrameOrigin:(NSPoint)newOrigin {
    [super setFrameOrigin:newOrigin];
    CGFloat shadowRevealAmount = 0.0;
    switch (self.shadowEdge) {
        case 0:
            shadowRevealAmount = fmin(fmax(newOrigin.x / 20.0, 0.0), 1.0);
            break;
        case 1:
            shadowRevealAmount = fmin(fmax(newOrigin.y / 20.0, 0.0), 1.0);
            break;
        case 2: {
            CGRect bounds = self.superview.bounds;
            CGRect frame = self.frame;
            shadowRevealAmount = fmin(fmax((bounds.origin.x + bounds.size.width - frame.origin.x + frame.size.width) / 20.0, 0.0), 1.0);
            break;
        }
        case 3: {
            CGRect bounds = self.superview.bounds;
            CGRect frame = self.frame;
            shadowRevealAmount = fmin(fmax((bounds.origin.y + bounds.size.height - frame.origin.y + frame.size.height) / 20.0, 0.0), 1.0);
            break;
        }
        default:
            break;
    }
    
    self.shadowRevealAmount = shadowRevealAmount;
}

- (void)updateLayer {
    [super updateLayer];
    NSImage *shadowImage = [self makeShadowImage];
    id layerContents = [shadowImage layerContentsForContentsScale:self.layer.contentsScale];
    self.layer.contents = layerContents;
    [self.layer setValue:@(self.shadowRevealAmount) forKey:@"NSShadowReveal"];
    [self.layer setValue:@(self.shadowEdge) forKey:@"NSShadowEdge"];
    
}

- (BOOL)wantsUpdateLayer {
    return YES;
}

- (NSView *)hitTest:(NSPoint)point {
    return nil;
}

@end
