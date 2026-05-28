#import <OpenUXKit/UIMutableIndexPath.h>

@interface UIMutableIndexPath () {
    NSUInteger *_mutableIndexes;
    NSUInteger _length;
    BOOL _locked;
}
@end

@implementation UIMutableIndexPath

- (instancetype)initWithIndexes:(const NSUInteger *)indexes length:(NSUInteger)length {
    self = [super initWithIndexes:indexes length:length];
    if (self) {
        _mutableIndexes = (NSUInteger *)malloc(sizeof(NSUInteger) * length);
        memcpy(_mutableIndexes, indexes, sizeof(NSUInteger) * length);
        _length = length;
    }
    return self;
}

- (void)dealloc {
    free(_mutableIndexes);
}

- (NSUInteger)length {
    return _length;
}

- (NSUInteger)indexAtPosition:(NSUInteger)position {
    if (position >= _length) {
        return NSNotFound;
    }
    return _mutableIndexes[position];
}

- (void)getIndexes:(NSUInteger *)indexes {
    memcpy(indexes, _mutableIndexes, sizeof(NSUInteger) * _length);
}

- (NSComparisonResult)compare:(NSIndexPath *)other {
    NSUInteger lhsLength = _length;
    NSUInteger rhsLength = other.length;
    NSUInteger common = MIN(lhsLength, rhsLength);
    for (NSUInteger i = 0; i < common; i++) {
        NSUInteger lhs = _mutableIndexes[i];
        NSUInteger rhs = [other indexAtPosition:i];
        if (lhs < rhs) return NSOrderedAscending;
        if (lhs > rhs) return NSOrderedDescending;
    }
    if (lhsLength < rhsLength) return NSOrderedAscending;
    if (lhsLength > rhsLength) return NSOrderedDescending;
    return NSOrderedSame;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[UIMutableIndexPath alloc] initWithIndexes:_mutableIndexes length:_length];
}

+ (void)setIndex:(NSUInteger)index atPosition:(NSUInteger)position forIndexPath:(NSIndexPath *_Nonnull *_Nonnull)indexPath {
    NSIndexPath *current = *indexPath;
    UIMutableIndexPath *mutable;
    if ([current isKindOfClass:[UIMutableIndexPath class]] && !((UIMutableIndexPath *)current)->_locked) {
        mutable = (UIMutableIndexPath *)current;
    } else {
        mutable = [current copy];
        *indexPath = mutable;
    }
    if (position < mutable->_length) {
        mutable->_mutableIndexes[position] = index;
    }
}

- (NSString *)description {
    NSMutableString *str = [NSMutableString stringWithFormat:@"<%@ %p: ", NSStringFromClass([self class]), self];
    for (NSUInteger i = 0; i < _length; i++) {
        if (i > 0) {
            [str appendString:@", "];
        }
        [str appendFormat:@"%lu", (unsigned long)_mutableIndexes[i]];
    }
    [str appendString:@">"];
    return str;
}

@end
