

#import <objc/NSObject.h>

@class UXCollectionViewLayout;
@protocol UXCollectionViewLayoutProxyDelegate;

@interface _UXCollectionViewLayoutProxy : NSObject
{
    id <UXCollectionViewLayoutProxyDelegate> _delegate;	// 8 = 0x8
    UXCollectionViewLayout *_layout;	// 16 = 0x10
}

+ (Class)invalidationContextClass;
+ (Class)layoutAttributesClass;
+ (Class)class;
@property(readonly, nonatomic) UXCollectionViewLayout *layout; // @synthesize layout=_layout;
@property(nonatomic) id <UXCollectionViewLayoutProxyDelegate> delegate; // @synthesize delegate=_delegate;
- (id)forwardingTargetForSelector:(SEL)arg1;
- (id)layoutAttributesForElementsInRect:(CGRect)arg1;
- (Class)class;
- (void)dealloc;
- (id)initWithLayout:(id)arg1;

@end

