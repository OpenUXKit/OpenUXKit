#import <AppKit/AppKit.h>
#import <OpenUXKit/_UXBarItemsContainer-Protocol.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXView.h>

@class UXToolbar, UXBarButtonItem;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXToolbarItemsContainer : UXView <_UXBarItemsContainer>

@property (nonatomic) CGFloat baselineOffsetFromBottom;
@property (nonatomic) CGFloat interitemSpacing;
@property (nonatomic, readonly, nullable) NSArray<UXBarButtonItem *> *items;
@property (nonatomic, readonly) BOOL hidesGlobalTrailingView;
@property (nonatomic) NSEdgeInsets layoutMargins;

+ (instancetype)toolbarItemsContainerForToolbar:(UXToolbar *)toolbar items:(NSArray<UXBarButtonItem *> *)items;
- (CGFloat)lastBaselineOffsetFromBottom;
- (void)updateConstraints;
- (void)prepareForTransition;

@end


NS_HEADER_AUDIT_END(nullability, sendability)
