#import "UXCollectionViewUpdateGap.h"
#import "UXCollectionViewUpdateItem+Internal.h"
#import "UXKitPrivateUtilites.h"

@interface UXCollectionViewUpdateGap () {
    UXCollectionViewUpdateItem *_firstUpdateItem;
    UXCollectionViewUpdateItem *_lastUpdateItem;
    NSMutableArray<UXCollectionViewUpdateItem *> *_deleteItems;
    NSMutableArray<UXCollectionViewUpdateItem *> *_insertItems;
    CGRect _beginningRect;
    CGRect _endingRect;
}
@end

@implementation UXCollectionViewUpdateGap

@synthesize firstUpdateItem = _firstUpdateItem;
@synthesize lastUpdateItem = _lastUpdateItem;
@synthesize deleteItems = _deleteItems;
@synthesize insertItems = _insertItems;
@synthesize beginningRect = _beginningRect;
@synthesize endingRect = _endingRect;

+ (instancetype)gapWithUpdateItem:(UXCollectionViewUpdateItem *)updateItem {
    UXCollectionViewUpdateGap *gap = [[UXCollectionViewUpdateGap alloc] init];
    [gap setFirstUpdateItem:updateItem];
    [gap setLastUpdateItem:updateItem];
    [gap addUpdateItem:updateItem];
    return gap;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _deleteItems = [[NSMutableArray alloc] init];
        _insertItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addUpdateItem:(UXCollectionViewUpdateItem *)updateItem {
    if ([updateItem _action] == UXCollectionUpdateActionDelete) {
        [_deleteItems addObject:updateItem];
    } else if ([updateItem _action] == UXCollectionUpdateActionInsert) {
        [_insertItems addObject:updateItem];
    } else {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                            object:self
                                                              file:@"UXCollectionViewUpdate.m"
                                                        lineNumber:57
                                                       description:@"attempt to add an update item that is neither an insert or delete to a UXCollectionViewUpdateGap"];
    }
}

- (NSArray<UXCollectionViewUpdateItem *> *)updateItems {
    return [_deleteItems arrayByAddingObjectsFromArray:_insertItems];
}

- (BOOL)hasInserts {
    return [_insertItems count] != 0;
}

- (BOOL)isDeleteBasedGap {
    return [_deleteItems count] != 0;
}

- (BOOL)isSectionBasedGap {
    return [_firstUpdateItem _isSectionOperation];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ first item: %@, last item: %@, deleteBased: %@, hasInserts: %@",
            [super description], _firstUpdateItem, _lastUpdateItem,
            self.isDeleteBasedGap ? @"YES" : @"NO",
            self.hasInserts ? @"YES" : @"NO"];
}

@end
