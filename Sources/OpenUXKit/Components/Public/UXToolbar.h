#import <AppKit/AppKit.h>
#import <OpenUXKit/UXBar.h>
#import <OpenUXKit/UXBarButtonItem.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXToolbar;
NS_SWIFT_UI_ACTOR
@protocol UXToolbarDelegate <UXBarPositioningDelegate>
@end

NS_SWIFT_UI_ACTOR
@protocol UXToolbarDelegatePrivate <UXToolbarDelegate>

@required
- (nullable NSResponder *)nextResponderForToolbar:(UXToolbar *)toolbar;

@end

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXToolbar : UXBar

@property (nonatomic, readonly) CGFloat visibleHeight;
@property (nonatomic, copy, nullable) NSArray<UXBarButtonItem *> *items;
@property (nonatomic, weak, nullable) id <UXToolbarDelegate> delegate;

- (void)setItems:(nullable NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated;

@end


NS_HEADER_AUDIT_END(nullability, sendability)
