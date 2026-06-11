#import "UXCollectionReusableView.h"
#import "UXCollectionReusableView+Internal.h"
#import "UXCollectionView.h"
#import "UXCollectionViewLayout.h"
#import "UXCollectionViewLayout+Internal.h"
#import "UXCollectionViewLayoutAccessibility.h"
#import "UXCollectionViewLayoutSectionAccessibility.h"
#import "UXCollectionViewLayoutAttributes.h"
#import "UXCollectionViewLayoutAttributes+Internal.h"
#import <QuartzCore/QuartzCore.h>

@interface UXCollectionReusableView () {
    UXCollectionViewLayoutAttributes *_layoutAttributes;
    NSString *_reuseIdentifier;
    // UXKit 26.4 stores a non-retaining raw pointer (plain assign, no weak
    // registration); the owning collection view always outlives its views.
    __unsafe_unretained UXCollectionView *_collectionView;
    struct {
        uint32_t updateAnimationCount : 5;
        uint32_t wasDequeued : 1;
    } _reusableViewFlags;
    BOOL _isFloatingPinned;
}

@end

@implementation UXCollectionReusableView

- (instancetype)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.autoresizingMask = NSViewNotSizable;
        self.translatesAutoresizingMaskIntoConstraints = YES;
        self.wantsLayer = YES;
        self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
        self.accessibilityElement = YES;
        _layoutAttributes = nil;
        _reuseIdentifier = nil;
        _collectionView = nil;
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        _reuseIdentifier = [coder decodeObjectForKey:@"NSReuseIdentifier"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];

    if (_reuseIdentifier) {
        [coder encodeObject:_reuseIdentifier forKey:@"NSReuseIdentifier"];
    }
}

- (void)dealloc {
    [self.layer removeAllAnimations];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; frame = %@, reuseIdentifier = %@>", [self class], self, NSStringFromRect(self.frame), _reuseIdentifier];
}

- (BOOL)wantsUpdateLayer {
    return YES;
}

- (NSString *)reuseIdentifier {
    return _reuseIdentifier;
}

- (void)_setReuseIdentifier:(NSString *)reuseIdentifier {
    if (_reuseIdentifier != reuseIdentifier) {
        _reuseIdentifier = reuseIdentifier.copy;
    }
}

- (UXCollectionView *)_collectionView {
    return _collectionView;
}

- (void)_setCollectionView:(UXCollectionView *)collectionView {
    _collectionView = collectionView;
}

- (UXCollectionViewLayoutAttributes *)_layoutAttributes {
    return _layoutAttributes;
}

- (void)_setLayoutAttributes:(UXCollectionViewLayoutAttributes *)layoutAttributes {
    if (![_layoutAttributes isEqual:layoutAttributes]) {
        _layoutAttributes = layoutAttributes.copy;

        if (_layoutAttributes) {
            if (layoutAttributes._reuseIdentifier) {
                [self _setReuseIdentifier:layoutAttributes._reuseIdentifier];
            }

            if (layoutAttributes.isFloating && _isFloatingPinned) {
                self.frame = layoutAttributes.floatingFrame;
            } else {
                self.frame = layoutAttributes.frame;
            }

            self.alphaValue = layoutAttributes.alpha;
            [self applyLayoutAttributes:layoutAttributes];
        }
    }
}

- (void)_setBaseLayoutAttributes:(UXCollectionViewLayoutAttributes *)baseLayoutAttributes {
    if (![_layoutAttributes isEqual:baseLayoutAttributes]) {
        _layoutAttributes = baseLayoutAttributes.copy;

        if (_layoutAttributes._reuseIdentifier) {
            [self _setReuseIdentifier:baseLayoutAttributes._reuseIdentifier];
        }
    }
}

- (void)setIsFloatingPinned:(BOOL)isFloatingPinned {
    if (_isFloatingPinned != isFloatingPinned) {
        _isFloatingPinned = isFloatingPinned;

        if (_layoutAttributes.isFloating && _isFloatingPinned) {
            self.frame = _layoutAttributes.floatingFrame;
        } else {
            self.frame = _layoutAttributes.frame;
        }
    }
}

- (BOOL)isFloatingPinned {
    return _isFloatingPinned;
}

- (void)_addUpdateAnimation {
    if (_reusableViewFlags.updateAnimationCount == 0x1F) {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd object:self file:@"UXCollectionViewCell.m" lineNumber:209 description:@"too many update animations on one view - limit is 31 in flight at a time (%@)", self];
    }

    _reusableViewFlags.updateAnimationCount = (_reusableViewFlags.updateAnimationCount + 1) & 0x1F;
}

- (void)_clearUpdateAnimation {
    if ((_reusableViewFlags.updateAnimationCount & 0x1F) == 0) {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd object:self file:@"UXCollectionViewCell.m" lineNumber:215 description:@"unbalanced ending to update animation which apparently never began for this view (%@)", self];
    }

    _reusableViewFlags.updateAnimationCount = (_reusableViewFlags.updateAnimationCount - 1) & 0x1F;
}

- (BOOL)_isInUpdateAnimation {
    return _reusableViewFlags.updateAnimationCount != 0;
}

- (BOOL)_wasDequeued {
    return _reusableViewFlags.wasDequeued;
}

- (void)_markAsDequeued {
    _reusableViewFlags.wasDequeued = 1;
}

- (void)prepareForReuse {
    [self.layer removeAllAnimations];
    _isFloatingPinned = NO;
}

- (void)applyLayoutAttributes:(UXCollectionViewLayoutAttributes *)layoutAttributes {
}

- (void)didTransitionFromLayout:(UXCollectionViewLayout *)layout toLayout:(UXCollectionViewLayout *)toLayout {
}

- (void)willTransitionFromLayout:(UXCollectionViewLayout *)layout toLayout:(UXCollectionViewLayout *)toLayout {
}

#pragma mark - Accessibility

- (id)_layoutSectionAccessibility {
    id accessibilityParent = self.accessibilityParent;
    if ([accessibilityParent isKindOfClass:[UXCollectionViewLayoutSectionAccessibility class]]) {
        return accessibilityParent;
    }
    return nil;
}

- (NSIndexPath *)_accessibilityIndexPath {
    return [[self _collectionView] indexPathForSupplementaryView:self];
}

- (NSString *)_accessibilityDefaultRole {
    return NSAccessibilityGroupRole;
}

- (id)_dynamicAccessibilityParent {
    return [[[self _collectionView].collectionViewLayout layoutAccessibility] accessibilityParentForReusableView:self];
}

- (NSAccessibilityRole)accessibilityRole {
    NSAccessibilityRole role = [super accessibilityRole];
    if (!role || [role isEqualToString:NSAccessibilityUnknownRole]) {
        role = [self _accessibilityDefaultRole];
    }
    return role;
}

- (id)accessibilityParent {
    id accessibilityParent = [super accessibilityParent];
    UXCollectionView *collectionView = [self _collectionView];
    if (!accessibilityParent || accessibilityParent == collectionView) {
        accessibilityParent = [self _dynamicAccessibilityParent];
    }
    return accessibilityParent;
}

- (BOOL)accessibilityPerformScrollToVisible {
    // UXKit passes raw scroll position 64 — an SPI "nearest" mode handled by
    // -_scrollAmountForMovingRect:toScrollPosition:inDestinationRect: that
    // scrolls only when the item is not already fully visible (P9 scope).
    [[self _collectionView] scrollToItemAtIndexPath:[self _accessibilityIndexPath]
                                   atScrollPosition:(UXCollectionViewScrollPosition)64
                                           animated:YES];
    return YES;
}

- (CGImageRef)_snapshot:(BOOL)flipped {
    static CGColorSpaceRef colorSpace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorSpace = CGColorSpaceCreateDeviceRGB();
    });

    CGRect bounds = self.layer.bounds;
    CGContextRef context = CGBitmapContextCreate(NULL, (size_t)CGRectGetWidth(bounds), (size_t)CGRectGetHeight(bounds), 8, 4 * (size_t)CGRectGetWidth(bounds), colorSpace, flipped ? (kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host) : (kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host));

    if (!context) {
        return NULL;
    }

    if (self.layer.presentationLayer.contentsAreFlipped) {
        CGAffineTransform transform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, CGRectGetHeight(bounds));
        CGContextConcatCTM(context, transform);
    }

    [self.layer.presentationLayer renderInContext:context];
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    return image;
}

@end
