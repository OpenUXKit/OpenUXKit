#import "UXTableViewCell.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXTableViewCell ()

@property (nonatomic, strong, nullable) NSMutableArray *_addedConstraints;

@property (nonatomic, setter=_setHighlightingForContext:) BOOL _highlightingForContext;
@property (nonatomic, setter=_setSeparatorStyle:) NSInteger _separatorStyle;
@property (nonatomic, setter=_setSeparatorHeight:) CGFloat _separatorHeight;
@property (nonatomic, strong, nullable, setter=_setSeparatorColor:) NSColor *_separatorColor;

- (void)_updateTextColor;
- (NSInteger)_detailTextAlignment;
- (void)_configureInternalAccessoryViewForType:(UXTableViewCellAccessoryType)type;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
