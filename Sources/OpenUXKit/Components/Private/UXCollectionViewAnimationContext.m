#import "UXCollectionViewAnimationContext.h"

@interface UXCollectionViewAnimationContext () {
    NSArray<UXCollectionViewAnimation *> *_viewAnimations;
    NSInteger _animationCount;
    void (^_completionHandler)(BOOL finished);
}
@end

@implementation UXCollectionViewAnimationContext

@synthesize viewAnimations = _viewAnimations;
@synthesize animationCount = _animationCount;
@synthesize completionHandler = _completionHandler;

- (instancetype)initWithCompletionHandler:(void (^)(BOOL finished))completionHandler {
    self = [super init];
    if (self) {
        _completionHandler = [completionHandler copy];
    }
    return self;
}

@end
