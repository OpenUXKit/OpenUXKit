#import <AppKit/AppKit.h>
#import <OpenUXKit/UXBar.h>
#import <OpenUXKit/UXBarButtonItem.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXToolbar;

@protocol UXToolbarDelegate <UXBarPositioningDelegate>

@optional
- (nullable NSResponder *)nextResponderForToolbar:(UXToolbar *)toolbar;

@end

@interface UXToolbar : UXBar

@property (nonatomic, copy, nullable) NSArray<UXBarButtonItem *> *items;
@property (nonatomic, weak, nullable) id <UXToolbarDelegate> delegate;

- (void)setItems:(nullable NSArray<UXBarButtonItem *> *)items animated:(BOOL)animated;

@end


NS_HEADER_AUDIT_END(nullability, sendability)
