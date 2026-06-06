#import "_UXTableHeaderView.h"
#import "UXLabel.h"
#import "UXView.h"
#import "UXView+Internal.h"

@interface _UXTableHeaderView () {
    NSString *_text;
    UXView *_contentView;
    UXLabel *_titleLabel;
    NSBox *_separator;
    BOOL _floating;
}

@property (nonatomic, readonly) UXView *contentView;
@property (nonatomic, readonly) UXLabel *titleLabel;
@property (nonatomic, readonly) NSBox *separator;
@property (nonatomic, getter=isFloating) BOOL floating;

@end

@implementation _UXTableHeaderView

@synthesize text = _text;
@synthesize contentView = _contentView;
@synthesize titleLabel = _titleLabel;
@synthesize separator = _separator;
@synthesize floating = _floating;

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [[UXView alloc] initWithFrame:self.bounds];
        _contentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [self addSubview:_contentView];

        _titleLabel = [[UXLabel alloc] init];
        _titleLabel.font = [NSFont boldSystemFontOfSize:[NSFont smallSystemFontSize]];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.textColor = [NSColor labelColor];
        [_contentView addSubview:_titleLabel];

        NSDictionary *titleViews = NSDictionaryOfVariableBindings(_titleLabel);
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_titleLabel]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:titleViews]];
        [_contentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];

        _separator = [[NSBox alloc] init];
        _separator.translatesAutoresizingMaskIntoConstraints = NO;
        _separator.titlePosition = NSNoTitle;
        _separator.boxType = NSBoxSeparator;
        _separator.hidden = YES;
        [self addSubview:_separator];

        NSDictionary *separatorViews = NSDictionaryOfVariableBindings(_separator);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_separator]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:separatorViews]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_separator]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:separatorViews]];

        [self setFloating:NO];
    }
    return self;
}

- (void)setFloating:(BOOL)floating {
    _floating = floating;
    UXView *contentView = self.contentView;
    if (floating) {
        contentView.blurEnabled = YES;
        self.separator.hidden = NO;
    } else {
        contentView.blurEnabled = NO;
        self.separator.hidden = YES;
        contentView.backgroundColor = [NSColor colorWithWhite:0.0 alpha:0.031372549];
    }
}

- (void)mouseDown:(NSEvent *)event {
}

- (void)prepareForReuse {
    NSArray<NSView *> *subviews = [_contentView.subviews copy];
    for (NSView *subview in subviews) {
        if (subview == _titleLabel) {
            continue;
        }
        if (subview == _contentView._visualEffectsView) {
            continue;
        }
        [subview removeFromSuperview];
    }
    _titleLabel.text = @"";
    [self setFloating:NO];
    [super prepareForReuse];
}

- (void)setText:(NSString *)text {
    _text = [text copy];
    _titleLabel.text = text;
}

@end
