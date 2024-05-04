#import <Foundation/Foundation.h>

@interface UIMutableIndexPath : NSIndexPath
{
    NSUInteger *_mutableIndexes;	// 32 = 0x20
    BOOL _locked;	// 40 = 0x28
}

+ (void)setIndex:(NSUInteger)arg1 atPosition:(NSUInteger)arg2 forIndexPath:(id *)arg3;
- (id)strong;
- (id)description;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (NSInteger)compare:(id)arg1;
- (void)getIndexes:(NSUInteger *)arg1;
- (NSUInteger)indexAtPosition:(NSUInteger)arg1;
- (void)dealloc;
- (id)initWithIndexes:(const NSUInteger *)arg1 length:(NSUInteger)arg2;

@end

