#import "UXNavigationItem.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXNavigationItem () {
    NSArray *_leftBarButtonItems;
    NSArray *_rightBarButtonItems;
    NSTextField *_internalTitleView;
    NSTextField *_internalTitleLabel;
    NSTextField *_internalSubtitleLabel;
}

@property (nonatomic, readonly, nullable) NSTextField *internalTitleView;
@property (nonatomic, readonly, nullable) NSTextField *internalTitleLabel;
@property (nonatomic, readonly, nullable) NSTextField *internalSubtitleLabel;
@property (nonatomic, strong, nullable) NSView *condensedTitleView;
@property (nonatomic) BOOL leftItemsSupplementBackButton;
@property (nonatomic) BOOL hidesAlternateTitleView;
@property (nonatomic) NSEdgeInsets layoutMargins;
@property (nonatomic, copy, nullable) NSString *subtitle;
@property (nonatomic) BOOL useWindowForTitleOutput;

+ (NSArray<NSString *> *)keyPathsToObserve;
- (void)_updateInternalTitleView;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
