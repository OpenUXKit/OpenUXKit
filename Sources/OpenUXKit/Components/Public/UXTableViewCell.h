#import <OpenUXKit/UXCollectionViewCell.h>

@class UXLabel, UXImageView, NSColor, UXView, _UXButton;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSInteger, UXTableViewCellStyle) {
    UXTableViewCellStyleDefault = 0,
    UXTableViewCellStyleValue1,
    UXTableViewCellStyleValue2,
    UXTableViewCellStyleSubtitle,
} NS_SWIFT_NAME(UXTableViewCell.CellStyle);

typedef NS_ENUM(NSInteger, UXTableViewCellEditingStyle) {
    UXTableViewCellEditingStyleNone   = 0,
    UXTableViewCellEditingStyleDelete = 1,
    UXTableViewCellEditingStyleInsert = 2,
} NS_SWIFT_NAME(UXTableViewCell.EditingStyle);

typedef NS_ENUM(NSInteger, UXTableViewCellAccessoryType) {
    UXTableViewCellAccessoryNone = 0,
    UXTableViewCellAccessoryDisclosureIndicator,
    UXTableViewCellAccessoryDetailDisclosureButton,
    UXTableViewCellAccessoryCheckmark,
    UXTableViewCellAccessoryDetailButton,
} NS_SWIFT_NAME(UXTableViewCell.AccessoryType);

typedef NS_ENUM(NSInteger, UXTableViewCellSelectionStyle) {
    UXTableViewCellSelectionStyleNone = 0,
    UXTableViewCellSelectionStyleBlue,
    UXTableViewCellSelectionStyleGray,
    UXTableViewCellSelectionStyleDefault,
} NS_SWIFT_NAME(UXTableViewCell.SelectionStyle);

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXTableViewCell : UXCollectionViewCell

- (instancetype)initWithStyle:(UXTableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier;

@property (nonatomic) UXTableViewCellStyle style;
@property (nonatomic, strong, nullable) UXLabel *textLabel;
@property (nonatomic, strong, nullable) UXLabel *detailTextLabel;
@property (nonatomic, readonly, nullable) UXImageView *imageView;

@property (nonatomic, strong, nullable) UXView *backgroundView;
@property (nonatomic, strong, nullable) UXView *selectedBackgroundView;
@property (nonatomic, readonly, nullable) UXView *defaultSelectedBackgroundView;
@property (nonatomic, readonly, nullable) UXView *internalHighlightedBackgroundView;
@property (nonatomic, readonly, nullable) _UXButton *internalAccessoryView;
@property (nonatomic, readonly, nullable) UXView *upperSpace;
@property (nonatomic, readonly, nullable) UXView *lowerSpace;

@property (nonatomic) UXTableViewCellAccessoryType accessoryType;
@property (nonatomic, strong, nullable) UXView *accessoryView;
@property (nonatomic) UXTableViewCellSelectionStyle selectionStyle;

@property (nonatomic) NSEdgeInsets separatorInset;
@property (nonatomic, strong, nullable) NSColor *highlightColor;

@property (nonatomic) NSInteger indentationLevel;
@property (nonatomic) CGFloat indentationWidth;

@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSString *detailText;
@property (nonatomic, copy, nullable) NSImage *image;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
