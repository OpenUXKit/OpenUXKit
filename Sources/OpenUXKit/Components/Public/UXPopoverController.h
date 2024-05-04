#import <AppKit/AppKit.h>
#import <OpenUXKit/UXViewController.h>

@class UXBarButtonItem, UXView;

typedef NS_OPTIONS(NSUInteger, UXPopoverArrowDirection) {
    UXPopoverArrowDirectionUp = 1UL << 0,
    UXPopoverArrowDirectionDown = 1UL << 1,
    UXPopoverArrowDirectionLeft = 1UL << 2,
    UXPopoverArrowDirectionRight = 1UL << 3,
    UXPopoverArrowDirectionAny = UXPopoverArrowDirectionUp | UXPopoverArrowDirectionDown | UXPopoverArrowDirectionLeft | UXPopoverArrowDirectionRight,
    UXPopoverArrowDirectionUnknown = NSUIntegerMax
};

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXPopover, UXViewController, UXPopoverController;

@protocol UXPopoverControllerDelegate <NSObject>
- (BOOL)popoverControllerShouldDismissPopover:(UXPopoverController *)popoverController;
- (void)popoverControllerDidDismissPopover:(UXPopoverController *)popoverController;
@end

@interface UXPopoverController : UXViewController <NSPopoverDelegate>

@property (nonatomic, weak, nullable) id <UXPopoverControllerDelegate> delegate;
@property (nonatomic, copy) NSArray *passthroughViews;
@property (nonatomic, strong) UXViewController *contentViewController;
@property (nonatomic) CGSize popoverContentSize;
@property (nonatomic) NSPopoverBehavior popoverBehavior;
@property (nonatomic, readonly, getter = isPopoverVisible) BOOL popoverVisible;
@property (nonatomic, readonly) UXPopover *popover;

- (instancetype)initWithContentViewController:(UXViewController *)viewController;
- (void)dismissPopoverAnimated:(BOOL)animated;
- (void)dismissPopover;
- (void)presentPopoverFromBarButtonItem:(UXBarButtonItem *)item permittedArrowDirections:(UXPopoverArrowDirection)arrowDirections animated:(BOOL)animated;
- (void)presentPopoverFromRect:(CGRect)rect inView:(UXView *)view preferredEdge:(NSRectEdge)preferredEdge;
- (void)setPopoverContentSize:(CGSize)size animated:(BOOL)animated;
- (void)_updateContentSize;
@end


NS_HEADER_AUDIT_END(nullability, sendability)
