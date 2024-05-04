

@class NSMutableArray, UXLabel, UXView;

@interface UXTableViewHeaderFooterView
{
    NSMutableArray *_constraints;	// 112 = 0x70
    UXLabel *_textLabel;	// 120 = 0x78
    UXLabel *_detailTextLabel;	// 128 = 0x80
    UXView *_contentView;	// 136 = 0x88
    UXView *_backgroundView;	// 144 = 0x90
}


@property(strong, nonatomic) UXView *backgroundView; // @synthesize backgroundView=_backgroundView;
@property(strong, nonatomic) UXView *contentView; // @synthesize contentView=_contentView;
@property(strong, nonatomic) UXLabel *detailTextLabel; // @synthesize detailTextLabel=_detailTextLabel;
@property(strong, nonatomic) UXLabel *textLabel; // @synthesize textLabel=_textLabel;
- (void)prepareForReuse;
- (void)updateConstraints;
- (id)initWithReuseIdentifier:(id)arg1;
- (id)initWithCoder:(id)arg1;
- (id)initWithFrame:(CGRect)arg1;

@end

