#import "_UXCollectionViewItemKey.h"
#import "UXCollectionViewLayoutAttributes+Internal.h"
#import "NSIndexPath+UXCollectionViewAdditions.h"
#import "UXKitPrivateUtilites.h"

static NSString *const UXCollectionViewItemKeyCellIdentifier = @"_Cell_";

@interface _UXCollectionViewItemKey () {
    NSUInteger _hash;
    NSIndexPath *_indexPath;
    NSString *_identifier;
    BOOL _isClone;
    UXCollectionViewItemType _type;
}
@end

@implementation _UXCollectionViewItemKey

@synthesize isClone = _isClone;

+ (instancetype)collectionItemKeyForCellWithIndexPath:(NSIndexPath *)indexPath {
    return [[self alloc] initWithType:UXCollectionViewItemTypeCell indexPath:indexPath identifier:UXCollectionViewItemKeyCellIdentifier];
}

+ (instancetype)collectionItemKeyForSupplementaryViewOfKind:(NSString *)kind andIndexPath:(NSIndexPath *)indexPath {
    return [[self alloc] initWithType:UXCollectionViewItemTypeSupplementaryView indexPath:indexPath identifier:kind];
}

+ (instancetype)collectionItemKeyForDecorationViewOfKind:(NSString *)kind andIndexPath:(NSIndexPath *)indexPath {
    return [[self alloc] initWithType:UXCollectionViewItemTypeDecorationView indexPath:indexPath identifier:kind];
}

+ (instancetype)collectionItemKeyForLayoutAttributes:(UXCollectionViewLayoutAttributes *)layoutAttributes {
    UXCollectionViewItemType type;
    NSString *identifier;
    if ([layoutAttributes _isCell]) {
        identifier = UXCollectionViewItemKeyCellIdentifier;
        type = UXCollectionViewItemTypeCell;
    } else {
        if ([layoutAttributes _isSupplementaryView]) {
            type = UXCollectionViewItemTypeSupplementaryView;
        } else {
            type = UXCollectionViewItemTypeDecorationView;
        }
        identifier = [layoutAttributes _elementKind];
    }
    return [[_UXCollectionViewItemKey alloc] initWithType:type
                                                indexPath:layoutAttributes.indexPath
                                               identifier:identifier
                                                    clone:[layoutAttributes _isClone]];
}

- (instancetype)initWithType:(UXCollectionViewItemType)type indexPath:(NSIndexPath *)indexPath identifier:(NSString *)identifier {
    return [self initWithType:type indexPath:indexPath identifier:identifier clone:NO];
}

- (instancetype)initWithType:(UXCollectionViewItemType)type indexPath:(NSIndexPath *)indexPath identifier:(NSString *)identifier clone:(BOOL)clone {
    self = [super init];
    if (self) {
        _type = type;
        _indexPath = indexPath;
        _identifier = identifier;
        _isClone = clone;
        _hash = ([_indexPath item] ^ ([_indexPath section] << 19)) ^ ([_identifier hash] * _type);
    }
    return self;
}

- (UXCollectionViewItemType)type {
    return _type;
}

- (void)setType:(UXCollectionViewItemType)type {
    if (_type != type) {
        _type = type;
        _hash = ([_indexPath item] ^ ([_indexPath section] << 19)) ^ ([_identifier hash] * _type);
    }
}

- (NSIndexPath *)indexPath {
    return _indexPath;
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    if (_indexPath != indexPath) {
        _indexPath = indexPath;
        _hash = ([_indexPath item] ^ ([_indexPath section] << 19)) ^ ([_identifier hash] * _type);
    }
}

- (NSString *)identifier {
    return _identifier;
}

- (void)setIdentifier:(NSString *)identifier {
    if (_identifier != identifier) {
        _identifier = identifier;
        _hash = ([_indexPath item] ^ ([_indexPath section] << 19)) ^ ([_identifier hash] * _type);
    }
}

- (instancetype)copyAsClone:(BOOL)clone {
    if (clone == [self isClone]) {
        return self;
    }
    return [[_UXCollectionViewItemKey alloc] initWithType:[self type]
                                                indexPath:[self indexPath]
                                               identifier:[self identifier]
                                                    clone:clone];
}

- (NSUInteger)hash {
    return _hash;
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if (_hash != [object hash]) {
        return NO;
    }
    if ([self class] != [object class]) {
        return NO;
    }
    _UXCollectionViewItemKey *other = object;
    if ([self type] != [other type]) {
        return NO;
    }
    if ([[self indexPath] section] != [[other indexPath] section]) {
        return NO;
    }
    if ([[self indexPath] item] != [[other indexPath] item]) {
        return NO;
    }
    if ([self isClone] != [other isClone]) {
        return NO;
    }
    return [[self identifier] isEqualToString:[other identifier]];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (NSString *)description {
    switch ([self type]) {
        case UXCollectionViewItemTypeCell:
            return [NSString stringWithFormat:@"%@ Type = C IndexPath = %@%@", [super description], [self indexPath], _isClone ? @" (C)" : @""];
        case UXCollectionViewItemTypeSupplementaryView:
            return [NSString stringWithFormat:@"%@ Type = SV Kind = %@ IndexPath = %@%@", [super description], [self identifier], [self indexPath], _isClone ? @" (C)" : @""];
        case UXCollectionViewItemTypeDecorationView:
            return [NSString stringWithFormat:@"%@ Type = DV ReuseID = %@ IndexPath = %@%@", [super description], [self identifier], [self indexPath], _isClone ? @" (C)" : @""];
        default:
            return [super description];
    }
}

@end
