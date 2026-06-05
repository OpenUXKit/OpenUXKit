#import <OpenUXKit/UXCollectionReusableView.h>

@class UXLabel;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXTableViewHeaderFooterView : UXCollectionReusableView

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier;

@property (nonatomic, strong, nullable) UXLabel *textLabel;
@property (nonatomic, strong, nullable) UXLabel *detailTextLabel;
@property (nonatomic, strong, nullable) NSView *contentView;
@property (nonatomic, strong, nullable) NSView *backgroundView;

@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSString *detailText;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
