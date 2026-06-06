#import "_UXCollectionViewLayoutProxy.h"
#import "UXCollectionViewLayout.h"
#import <objc/runtime.h>

@interface _UXCollectionViewLayoutProxy () {
    __unsafe_unretained id<UXCollectionViewLayoutProxyDelegate> _delegate;
    UXCollectionViewLayout *_layout;
}
@end

@implementation _UXCollectionViewLayoutProxy

@synthesize layout = _layout;

+ (Class)layoutAttributesClass {
    return [UXCollectionViewLayout layoutAttributesClass];
}

+ (Class)invalidationContextClass {
    return [UXCollectionViewLayout invalidationContextClass];
}

+ (Class)class {
    return [UXCollectionViewLayout class];
}

- (instancetype)initWithLayout:(UXCollectionViewLayout *)layout {
    self = [super init];
    if (self) {
        _layout = layout;
    }
    return self;
}

- (id<UXCollectionViewLayoutProxyDelegate>)delegate {
    return _delegate;
}

- (void)setDelegate:(id<UXCollectionViewLayoutProxyDelegate>)delegate {
    _delegate = delegate;
}

- (NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<UXCollectionViewLayoutAttributes *> *attributes = [_delegate layoutAttributesForElementsInRect:rect];
    if (!attributes) {
        return [_layout layoutAttributesForElementsInRect:rect];
    }
    return attributes;
}

- (id)forwardingTargetForSelector:(SEL)selector {
    return _layout;
}

- (Class)class {
    return object_getClass(_layout);
}

@end
