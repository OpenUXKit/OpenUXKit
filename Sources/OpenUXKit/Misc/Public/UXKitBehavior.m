#import <OpenUXKit/UXKitBehavior.h>
#import <OpenUXKit/UXBackButton.h>

@implementation UXKitBehavior {
    Class _backButtonClass;
}

+ (UXKitBehavior *)sharedBehavior {
    static UXKitBehavior *sharedBehavior = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBehavior = [[UXKitBehavior alloc] init];
    });
    return sharedBehavior;
}

- (instancetype)init {
    if (self = [super init]) {
        _recalculatesKeyViewLoopAfterTransition = YES;
    }
    return self;
}

- (Class)backButtonClass {
    return _backButtonClass ?: [UXBackButton class];
}

- (void)setBackButtonClass:(Class)backButtonClass {
    _backButtonClass = backButtonClass;
}

@end
