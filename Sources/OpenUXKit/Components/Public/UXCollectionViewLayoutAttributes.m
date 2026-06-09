#import "UXCollectionViewLayoutAttributes+Internal.h"
#import "UXKitPrivateUtilites.h"

static NSString *const UXCollectionViewElementKindCell = @"UXCollectionViewElementKindCell";
static NSString *const UXCollectionElementIsOriginal = @"_UXCollectionElementIsOriginal";
static NSString *const UXCollectionElementIsClone = @"_UXCollectionElementIsClone";

static NSIndexPath *sharedNotFoundPath = nil;

@interface UXCollectionViewLayoutAttributes () {
    NSUInteger _hash;
    NSString *_elementKind;
    NSString *_reuseIdentifier;
    CGRect _frame;
    CGPoint _center;
    CGSize _size;
    CGFloat _alpha;
    NSInteger _zIndex;
    BOOL _isFloating;
    CGRect _floatingFrame;
    NSIndexPath *_indexPath;
    NSString *_isCloneString;
    struct {
        unsigned int isCellKind : 1;
        unsigned int isDecorationView : 1;
        unsigned int isHidden : 1;
        unsigned int isClone : 1;
    } _layoutFlags;
    BOOL _isPushing;
    CGFloat _verticalOffsetFromFloatingPosition;
}
@end

@implementation UXCollectionViewLayoutAttributes

@synthesize indexPath = _indexPath;
@synthesize alpha = _alpha;
@synthesize zIndex = _zIndex;
@synthesize size = _size;
@synthesize center = _center;
@synthesize frame = _frame;
@synthesize isFloating = _isFloating;
@synthesize floatingFrame = _floatingFrame;
@synthesize verticalOffsetFromFloatingPosition = _verticalOffsetFromFloatingPosition;
@synthesize isPushing = _isPushing;

+ (instancetype)layoutAttributesForCellWithIndexPath:(NSIndexPath *)indexPath {
    UXCollectionViewLayoutAttributes *attributes = [[self alloc] init];
    attributes->_layoutFlags.isCellKind = 1;
    attributes->_elementKind = [UXCollectionViewElementKindCell copy];
    attributes->_indexPath = indexPath;
    return attributes;
}

+ (instancetype)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind withIndexPath:(NSIndexPath *)indexPath {
    UXCollectionViewLayoutAttributes *attributes = [[self alloc] init];
    attributes->_elementKind = [elementKind copy];
    attributes->_indexPath = indexPath;
    return attributes;
}

+ (instancetype)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind withIndexPath:(NSIndexPath *)indexPath {
    UXCollectionViewLayoutAttributes *attributes = [[self alloc] init];
    attributes->_indexPath = indexPath;
    attributes->_elementKind = [elementKind copy];
    attributes->_reuseIdentifier = [elementKind copy];
    attributes->_layoutFlags.isDecorationView = 1;
    return attributes;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedNotFoundPath = [NSIndexPath indexPathForItem:NSNotFound inSection:NSNotFound];
        });
        _frame = CGRectZero;
        _center = CGPointZero;
        _size = CGSizeZero;
        _alpha = 1.0;
        _zIndex = 0;
        _isFloating = NO;
        _floatingFrame = CGRectZero;
        _verticalOffsetFromFloatingPosition = 0;
        _indexPath = nil;
        _layoutFlags.isCellKind = 0;
        _layoutFlags.isDecorationView = 0;
        _layoutFlags.isHidden = 0;
        _layoutFlags.isClone = 0;
        _isCloneString = UXCollectionElementIsOriginal;
        _elementKind = nil;
        _reuseIdentifier = nil;
    }
    return self;
}

#pragma mark - Geometry

- (void)setSize:(CGSize)size {
    if (size.width != _size.width || size.height != _size.height) {
        _size = size;
        _frame = CGRectNull;
    }
}

- (CGRect)frame {
    if (CGRectIsNull(_frame)) {
        _frame.size = _size;
        _frame.origin.x = _center.x - _size.width * 0.5;
        _frame.origin.y = _center.y - _size.height * 0.5;
    }
    return _frame;
}

- (void)setFrame:(CGRect)frame {
    [self setSize:frame.size];
    [self setCenter:CGPointMake(CGRectGetMinX(frame) + CGRectGetWidth(frame) * 0.5,
                                CGRectGetMinY(frame) + CGRectGetHeight(frame) * 0.5)];
    _frame = frame;
}

- (void)setCenter:(CGPoint)center {
    if (center.x != _center.x || center.y != _center.y) {
        if (!CGRectIsNull(_frame)) {
            _frame.origin.x += center.x - _center.x;
            _frame.origin.y += center.y - _center.y;
        }
        _center = center;
    }
}

- (CGRect)bounds {
    return CGRectMake(0.0, 0.0, _size.width, _size.height);
}

- (void)setBounds:(CGRect)bounds {
    if (bounds.origin.x != 0.0 || bounds.origin.y != 0.0) {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                            object:self
                                                              file:@"UXCollectionViewLayout.m"
                                                        lineNumber:331
                                                       description:@"UXCollectionViewLayoutAttributes bounds must be set with a (0,0) origin %@ - %@", self, NSStringFromRect(bounds)];
    }
    [self setSize:bounds.size];
}

#pragma mark - Category / Kind

- (UXCollectionElementCategory)representedElementCategory {
    if (_layoutFlags.isCellKind) {
        return UXCollectionElementCategoryCell;
    }
    if (_layoutFlags.isDecorationView) {
        return UXCollectionElementCategoryDecorationView;
    }
    return UXCollectionElementCategorySupplementaryView;
}

- (NSString *)representedElementKind {
    if (_layoutFlags.isCellKind) {
        return nil;
    }
    return _elementKind;
}

- (BOOL)_isCell {
    return _layoutFlags.isCellKind;
}

- (BOOL)_isSupplementaryView {
    return (_layoutFlags.isCellKind == 0) && (_layoutFlags.isDecorationView == 0);
}

- (BOOL)_isDecorationView {
    return _layoutFlags.isDecorationView;
}

#pragma mark - Hidden

- (BOOL)isHidden {
    return _layoutFlags.isHidden;
}

- (void)setHidden:(BOOL)hidden {
    _layoutFlags.isHidden = hidden ? 1 : 0;
}

#pragma mark - Index Path

- (NSIndexPath *)indexPath {
    if (!_indexPath) {
        return sharedNotFoundPath;
    }
    return _indexPath;
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    [self _setIndexPath:indexPath];
}

- (void)_setIndexPath:(NSIndexPath *)indexPath {
    if (_indexPath != indexPath) {
        _indexPath = indexPath;
        _hash = ([_indexPath item] ^ ([_indexPath section] << 19)) ^ [_elementKind hash] ^ [_isCloneString hash];
    }
}

#pragma mark - Element Kind / Reuse Identifier (private)

- (NSString *)_elementKind {
    return _elementKind;
}

- (void)_setElementKind:(NSString *)elementKind {
    if (_elementKind != elementKind) {
        _elementKind = elementKind;
        _hash = ([_indexPath item] ^ ([_indexPath section] << 19)) ^ [_elementKind hash] ^ [_isCloneString hash];
    }
}

- (NSString *)_reuseIdentifier {
    return _reuseIdentifier;
}

- (void)_setReuseIdentifier:(NSString *)reuseIdentifier {
    if (_reuseIdentifier != reuseIdentifier) {
        _reuseIdentifier = [reuseIdentifier copy];
    }
}

#pragma mark - Clone

- (BOOL)_isClone {
    return _layoutFlags.isClone;
}

- (void)_setIsClone:(BOOL)isClone {
    _layoutFlags.isClone = isClone ? 1 : 0;
    _isCloneString = isClone ? UXCollectionElementIsClone : UXCollectionElementIsOriginal;
    _hash = ([_indexPath item] ^ ([_indexPath section] << 19)) ^ [_elementKind hash] ^ [_isCloneString hash];
}

#pragma mark - Equality

- (NSUInteger)hash {
    return _hash;
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:[UXCollectionViewLayoutAttributes class]]) {
        return NO;
    }
    UXCollectionViewLayoutAttributes *other = object;
    if (![_indexPath isEqual:other->_indexPath]) {
        return NO;
    }
    return [self _isEquivalentTo:other];
}

- (BOOL)_isEquivalentTo:(UXCollectionViewLayoutAttributes *)attributes {
    BOOL selfHidden = (self.alpha == 0.0) ? YES : self.isHidden;
    BOOL otherHidden = (attributes.alpha == 0.0) ? YES : attributes.isHidden;
    if (selfHidden != otherHidden) {
        return NO;
    }

    CGPoint selfCenter = self.center;
    CGPoint otherCenter = attributes.center;
    if (selfCenter.x != otherCenter.x || selfCenter.y != otherCenter.y) {
        return NO;
    }

    CGSize selfSize = self.size;
    CGSize otherSize = attributes.size;
    if (selfSize.width != otherSize.width || selfSize.height != otherSize.height) {
        return NO;
    }

    if (self.zIndex != attributes.zIndex) {
        return NO;
    }

    if (self.isFloating != attributes.isFloating) {
        return NO;
    }

    if (!CGRectEqualToRect(self.floatingFrame, attributes.floatingFrame)) {
        return NO;
    }

    if (self.verticalOffsetFromFloatingPosition != attributes.verticalOffsetFromFloatingPosition) {
        return NO;
    }

    if ([self _isClone] != [attributes _isClone]) {
        return NO;
    }

    if (self.alpha != attributes.alpha) {
        return NO;
    }

    return [[self _elementKind] isEqualToString:[attributes _elementKind]];
}

- (BOOL)_isTransitionVisibleTo:(UXCollectionViewLayoutAttributes *)attributes {
    BOOL selfHidden = (self.alpha == 0.0) ? YES : self.isHidden;
    BOOL otherHidden = (attributes.alpha == 0.0) ? YES : attributes.isHidden;
    if (selfHidden && otherHidden) {
        return NO;
    }

    CGSize selfSize = self.size;
    CGSize otherSize = attributes.size;
    if (selfSize.width == 0.0 && selfSize.height == 0.0 &&
        otherSize.width == 0.0 && otherSize.height == 0.0) {
        return NO;
    }

    return ![self _isEquivalentTo:attributes];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    UXCollectionViewLayoutAttributes *copy = [[[self class] alloc] init];
    copy->_alpha = _alpha;
    copy->_layoutFlags.isClone = _layoutFlags.isClone;
    copy->_indexPath = _indexPath;
    copy->_reuseIdentifier = [_reuseIdentifier copy];
    copy->_elementKind = [_elementKind copy];
    copy->_zIndex = _zIndex;
    copy->_isFloating = _isFloating;
    copy->_floatingFrame = _floatingFrame;
    copy->_verticalOffsetFromFloatingPosition = _verticalOffsetFromFloatingPosition;
    copy->_layoutFlags.isCellKind = _layoutFlags.isCellKind;
    copy->_layoutFlags.isDecorationView = _layoutFlags.isDecorationView;
    copy->_layoutFlags.isHidden = _layoutFlags.isHidden;
    copy->_center = _center;
    copy->_size = _size;
    copy->_frame = _frame;
    copy->_hash = _hash;
    return copy;
}

#pragma mark - Description

- (NSString *)description {
    NSMutableString *result = [NSMutableString stringWithFormat:@"%@ ", [super description]];

    NSString *indexPathString;
    if (_indexPath) {
        NSUInteger length = [_indexPath length];
        NSMutableString *pathString = [NSMutableString stringWithCapacity:4 * length];
        for (NSUInteger position = 0; position < length; position++) {
            if (position) {
                [pathString appendString:@"."];
            }
            [pathString appendFormat:@"%ld", (long)[_indexPath indexAtPosition:position]];
        }
        indexPathString = pathString;
    } else {
        indexPathString = @"nil";
    }
    [result appendFormat:@"index path: (%@); ", indexPathString];

    if (!_layoutFlags.isCellKind) {
        [result appendFormat:@"element kind: (%@); ", _elementKind];
    }

    CGRect frame = self.frame;
    [result appendFormat:@"frame = (%g %g; %g %g); ", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height];

    if (self.isHidden) {
        [result appendFormat:@"hidden = YES; "];
    }

    if (self.alpha != 1.0) {
        [result appendFormat:@"alpha = %g; ", self.alpha];
    }

    if (_zIndex) {
        [result appendFormat:@"zIndex = %ld; ", (long)_zIndex];
    }

    if (_isFloating) {
        [result appendFormat:@"IS FLOATING; "];
        CGRect floatingFrame = self.floatingFrame;
        [result appendFormat:@"floatingFrame = (%g %g; %g %g); ", floatingFrame.origin.x, floatingFrame.origin.y, floatingFrame.size.width, floatingFrame.size.height];
    }

    if (_layoutFlags.isClone) {
        [result appendFormat:@"IS CLONE; "];
    }

    return result;
}

@end
