

#import <objc/NSObject.h>

@class NSDictionary, NSMutableArray;

@interface _UXFlowLayoutInfo : NSObject
{
    NSMutableArray *_sections;	// 8 = 0x8
    BOOL _useFloatingHeaderFooter;	// 16 = 0x10
    BOOL _horizontal;	// 17 = 0x11
    BOOL _leftToRight;	// 18 = 0x12
    CGRect _visibleBounds;	// 24 = 0x18
    CGSize _layoutSize;	// 56 = 0x38
    CGFloat _dimension;	// 72 = 0x48
    BOOL _isValid;	// 80 = 0x50
    NSDictionary *_rowAlignmentOptions;	// 88 = 0x58
    BOOL _usesFloatingHeaderFooter;	// 96 = 0x60
    CGSize _contentSize;	// 104 = 0x68
}

@property(strong, nonatomic) NSDictionary *rowAlignmentOptions; // @synthesize rowAlignmentOptions=_rowAlignmentOptions;
@property(nonatomic) CGSize contentSize; // @synthesize contentSize=_contentSize;
@property(nonatomic) BOOL leftToRight; // @synthesize leftToRight=_leftToRight;
@property(nonatomic) BOOL horizontal; // @synthesize horizontal=_horizontal;
@property(nonatomic) CGFloat dimension; // @synthesize dimension=_dimension;
@property(nonatomic) BOOL usesFloatingHeaderFooter; // @synthesize usesFloatingHeaderFooter=_usesFloatingHeaderFooter;
@property(readonly, nonatomic) NSMutableArray *sections; // @synthesize sections=_sections;
- (id)copy;
- (id)snapshot;
- (CGRect)frameForItemAtIndexPath:(id)arg1;
- (void)dealloc;
- (id)addSection;
- (void)invalidate:(BOOL)arg1;
- (id)init;

@end

