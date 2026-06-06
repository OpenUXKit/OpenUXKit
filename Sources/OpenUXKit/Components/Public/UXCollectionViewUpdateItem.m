#import "UXCollectionViewUpdateItem+Internal.h"
#import "NSIndexPath+UXCollectionViewAdditions.h"
#import "UXKitPrivateUtilites.h"

@interface UXCollectionViewUpdateItem () {
    NSIndexPath *_initialIndexPath;
    NSIndexPath *_finalIndexPath;
    UXCollectionUpdateAction _updateAction;
    __unsafe_unretained UXCollectionViewUpdateGap *_gap;
}
@end

@implementation UXCollectionViewUpdateItem

- (instancetype)initWithInitialIndexPath:(NSIndexPath *)initialIndexPath finalIndexPath:(NSIndexPath *)finalIndexPath updateAction:(UXCollectionUpdateAction)updateAction {
    self = [super init];
    if (self) {
        _initialIndexPath = initialIndexPath;
        _finalIndexPath = finalIndexPath;
        _updateAction = updateAction;
    }
    return self;
}

- (instancetype)initWithAction:(UXCollectionUpdateAction)action forIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *initialIndexPath = (action == UXCollectionUpdateActionInsert) ? nil : indexPath;
    NSIndexPath *finalIndexPath = (action == UXCollectionUpdateActionInsert) ? indexPath : nil;
    return [self initWithInitialIndexPath:initialIndexPath finalIndexPath:finalIndexPath updateAction:action];
}

- (instancetype)initWithOldIndexPath:(NSIndexPath *)oldIndexPath newIndexPath:(NSIndexPath *)newIndexPath {
    return [self initWithInitialIndexPath:oldIndexPath finalIndexPath:newIndexPath updateAction:UXCollectionUpdateActionMove];
}

- (NSIndexPath *)indexPathBeforeUpdate {
    return _initialIndexPath;
}

- (NSIndexPath *)indexPathAfterUpdate {
    return _finalIndexPath;
}

- (UXCollectionUpdateAction)updateAction {
    return _updateAction;
}

- (UXCollectionUpdateAction)_action {
    return _updateAction;
}

- (NSIndexPath *)_indexPath {
    if (_updateAction != UXCollectionUpdateActionInsert) {
        return _initialIndexPath;
    }
    return _finalIndexPath;
}

- (NSIndexPath *)_newIndexPath {
    return _finalIndexPath;
}

- (void)_setNewIndexPath:(NSIndexPath *)newIndexPath {
    if (_finalIndexPath != newIndexPath) {
        _finalIndexPath = newIndexPath;
    }
}

- (BOOL)_isSectionOperation {
    return [[self _indexPath] item] == NSNotFound;
}

- (NSComparisonResult)compareIndexPaths:(UXCollectionViewUpdateItem *)other {
    return [[self _indexPath] compare:[other _indexPath]];
}

- (NSComparisonResult)inverseCompareIndexPaths:(UXCollectionViewUpdateItem *)other {
    return [[other _indexPath] compare:[self _indexPath]];
}

- (UXCollectionViewUpdateGap *)_gap {
    return _gap;
}

- (void)_setGap:(UXCollectionViewUpdateGap *)gap {
    _gap = gap;
}

- (NSString *)description {
    static NSString *const actionStrings[] = {@"insert", @"delete", @"", @"move"};
    NSString *actionString = (_updateAction <= UXCollectionUpdateActionMove) ? actionStrings[_updateAction] : @"";
    return [[super description] stringByAppendingFormat:@" index path before update (%@) index path after update (%@) action (%@)", _initialIndexPath, _finalIndexPath, actionString];
}

@end
