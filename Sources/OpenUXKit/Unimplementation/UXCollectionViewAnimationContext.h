

#import <objc/NSObject.h>

@class NSArray;

@interface UXCollectionViewAnimationContext : NSObject
{
    NSArray *_viewAnimations;	// 8 = 0x8
    NSInteger _animationCount;	// 16 = 0x10
    id _completionHandler;	// 24 = 0x18
}

@property(readonly, copy, nonatomic) id completionHandler; // @synthesize completionHandler=_completionHandler;
@property(nonatomic) NSInteger animationCount; // @synthesize animationCount=_animationCount;
@property(strong, nonatomic) NSArray *viewAnimations; // @synthesize viewAnimations=_viewAnimations;
- (void)dealloc;
- (id)initWithCompletionHandler:(id)arg1;

@end

