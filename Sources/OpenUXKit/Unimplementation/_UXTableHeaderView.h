

@class NSBox, UXLabel, UXView;

@interface _UXTableHeaderView
{
    BOOL _floating;	// 108 = 0x6c
    UXView *_contentView;	// 112 = 0x70
    UXLabel *_titleLabel;	// 120 = 0x78
    NSBox *_separator;	// 128 = 0x80
}


@property(readonly, nonatomic) NSBox *separator; // @synthesize separator=_separator;
@property(readonly, nonatomic) UXLabel *titleLabel; // @synthesize titleLabel=_titleLabel;
@property(readonly, nonatomic) UXView *contentView; // @synthesize contentView=_contentView;
@property(nonatomic, getter=isFloating) BOOL floating; // @synthesize floating=_floating;
- (void)mouseDown:(id)arg1;
- (void)prepareForReuse;
- (id)initWithFrame:(CGRect)arg1;

@end

