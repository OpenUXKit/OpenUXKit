

#import <AppKit/AppKit.h>

@class NSIndexPath, NSString;

@interface _UXCollectionViewItemKey : NSObject <NSCopying>
{
    NSUInteger _hash;	// 8 = 0x8
    NSIndexPath *_indexPath;	// 16 = 0x10
    NSString *_identifier;	// 24 = 0x18
    BOOL _isClone;	// 32 = 0x20
    NSUInteger _type;	// 40 = 0x28
}

+ (id)collectionItemKeyForLayoutAttributes:(id)arg1;
+ (id)collectionItemKeyForDecorationViewOfKind:(id)arg1 andIndexPath:(id)arg2;
+ (id)collectionItemKeyForSupplementaryViewOfKind:(id)arg1 andIndexPath:(id)arg2;
+ (id)collectionItemKeyForCellWithIndexPath:(id)arg1;
@property(readonly, nonatomic) BOOL isClone; // @synthesize isClone=_isClone;
@property(readonly, nonatomic) NSUInteger type; // @synthesize type=_type;
@property(readonly, strong, nonatomic) NSString *identifier; // @synthesize identifier=_identifier;
@property(readonly, strong, nonatomic) NSIndexPath *indexPath; // @synthesize indexPath=_indexPath;
- (NSUInteger)hash;
- (void)setType:(NSUInteger)arg1;
- (void)setIdentifier:(id)arg1;
- (void)setIndexPath:(id)arg1;
- (BOOL)isEqual:(id)arg1;
- (id)copyAsClone:(BOOL)arg1;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (id)description;
- (void)dealloc;
- (id)initWithType:(NSUInteger)arg1 indexPath:(id)arg2 identifier:(id)arg3 clone:(BOOL)arg4;
- (id)initWithType:(NSUInteger)arg1 indexPath:(id)arg2 identifier:(id)arg3;

@end

