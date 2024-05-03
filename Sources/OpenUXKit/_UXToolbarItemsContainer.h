#import <AppKit/AppKit.h>
#import "_UXBarItemsContainer-Protocol.h"
#import "UXView.h"
@class UXToolbar, UXBarButtonItem;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface _UXToolbarItemsContainer: UXView <_UXBarItemsContainer>

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
