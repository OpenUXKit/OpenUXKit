#import <OpenUXKit/UXTableViewHeaderFooterView.h>
#import <OpenUXKit/UXLabel.h>

@interface UXTableViewHeaderFooterView () {
    NSString *_text;
    NSString *_detailText;
    UXLabel *_textLabel;
    UXLabel *_detailTextLabel;
    NSView *_contentView;
    NSView *_backgroundView;
}
@end

@implementation UXTableViewHeaderFooterView

@synthesize text = _text;
@synthesize detailText = _detailText;
@synthesize contentView = _contentView;
@synthesize backgroundView = _backgroundView;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setValue:reuseIdentifier forKey:@"reuseIdentifier"];
    }
    return self;
}

- (NSView *)contentView {
    if (!_contentView) {
        _contentView = [[NSView alloc] init];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UXLabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UXLabel alloc] init];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_textLabel];
    }
    return _textLabel;
}

- (UXLabel *)detailTextLabel {
    if (!_detailTextLabel) {
        _detailTextLabel = [[UXLabel alloc] init];
        _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_detailTextLabel];
    }
    return _detailTextLabel;
}

- (void)setText:(NSString *)text {
    _text = [text copy];
    self.textLabel.text = text;
}

- (void)setTextLabel:(UXLabel *)textLabel {
    if (_textLabel != textLabel) {
        [_textLabel removeFromSuperview];
        _textLabel = textLabel;
        if (textLabel) {
            textLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:textLabel];
        }
    }
}

- (void)setDetailTextLabel:(UXLabel *)detailTextLabel {
    if (_detailTextLabel != detailTextLabel) {
        [_detailTextLabel removeFromSuperview];
        _detailTextLabel = detailTextLabel;
        if (detailTextLabel) {
            detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:detailTextLabel];
        }
    }
}

- (void)setDetailText:(NSString *)detailText {
    _detailText = [detailText copy];
    self.detailTextLabel.text = detailText;
}

- (void)setBackgroundView:(NSView *)backgroundView {
    [_backgroundView removeFromSuperview];
    _backgroundView = backgroundView;
    if (backgroundView) {
        backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:backgroundView positioned:NSWindowBelow relativeTo:nil];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _textLabel.text = nil;
    _detailTextLabel.text = nil;
}

@end
