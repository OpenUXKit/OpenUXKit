

#import <AppKit/AppKit.h>

@class NSIndexPath, NSString;

@interface UXCollectionViewLayoutAttributes : NSObject <NSCopying>
{
    NSUInteger _hash;	// 8 = 0x8
    NSString *_elementKind;	// 16 = 0x10
    NSString *_reuseIdentifier;	// 24 = 0x18
    CGRect _frame;	// 32 = 0x20
    CGPoint _center;	// 64 = 0x40
    CGSize _size;	// 80 = 0x50
    CGFloat _alpha;	// 96 = 0x60
    NSInteger _zIndex;	// 104 = 0x68
    BOOL _isFloating;	// 112 = 0x70
    CGRect _floatingFrame;	// 120 = 0x78
    NSIndexPath *_indexPath;	// 152 = 0x98
    NSString *_representedElementKind;	// 160 = 0xa0
    NSString *_isCloneString;	// 168 = 0xa8
    struct {
        unsigned int isCellKind:1;
        unsigned int isDecorationView:1;
        unsigned int isHidden:1;
        unsigned int isClone:1;
    } _layoutFlags;	// 176 = 0xb0
    BOOL _isPushing;	// 180 = 0xb4
    CGFloat _verticalOffsetFromFloatingPosition;	// 184 = 0xb8
}

+ (id)layoutAttributesForDecorationViewOfKind:(id)arg1 withIndexPath:(id)arg2;
+ (id)layoutAttributesForSupplementaryViewOfKind:(id)arg1 withIndexPath:(id)arg2;
+ (id)layoutAttributesForCellWithIndexPath:(id)arg1;
@property(nonatomic) CGFloat verticalOffsetFromFloatingPosition; // @synthesize verticalOffsetFromFloatingPosition=_verticalOffsetFromFloatingPosition;
@property(strong, nonatomic) NSIndexPath *indexPath; // @synthesize indexPath=_indexPath;
@property(nonatomic) BOOL isPushing; // @synthesize isPushing=_isPushing;
@property(nonatomic) CGRect floatingFrame; // @synthesize floatingFrame=_floatingFrame;
@property(nonatomic) BOOL isFloating; // @synthesize isFloating=_isFloating;
@property(nonatomic) NSInteger zIndex; // @synthesize zIndex=_zIndex;
@property(nonatomic) CGFloat alpha; // @synthesize alpha=_alpha;
@property(nonatomic) CGSize size; // @synthesize size=_size;
@property(nonatomic) CGPoint center; // @synthesize center=_center;
@property(readonly, nonatomic) NSString *representedElementKind; // @synthesize representedElementKind=_representedElementKind;
@property(readonly, nonatomic) NSUInteger representedElementCategory;
- (BOOL)_isSupplementaryView;
- (BOOL)_isDecorationView;
- (BOOL)_isCell;
- (NSUInteger)hash;
- (BOOL)_isTransitionVisibleTo:(id)arg1;
- (BOOL)_isEquivalentTo:(id)arg1;
- (BOOL)isEqual:(id)arg1;
- (id)description;
@property(nonatomic) CGRect frame; // @synthesize frame=_frame;
@property(nonatomic) CGRect bounds;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (void)_setIndexPath:(id)arg1;
- (id)_reuseIdentifier;
- (void)_setReuseIdentifier:(id)arg1;
- (id)_elementKind;
- (void)_setElementKind:(id)arg1;
- (BOOL)_isClone;
- (void)_setIsClone:(BOOL)arg1;
@property(nonatomic, getter=isHidden) BOOL hidden;
- (void)dealloc;
- (id)init;

@end

