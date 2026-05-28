#import <OpenUXKit/UXCollectionViewCell.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSInteger, UXTableViewCellEditingStyle) {
    UXTableViewCellEditingStyleNone   = 0,
    UXTableViewCellEditingStyleDelete = 1,
    UXTableViewCellEditingStyleInsert = 2,
};

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXTableViewCell : UXCollectionViewCell

@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSString *detailText;
@property (nonatomic, copy, nullable) NSImage *image;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
