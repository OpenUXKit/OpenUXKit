#import <AppKit/AppKit.h>
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXView;

typedef NS_OPTIONS(NSUInteger, _UXContentUnavailableVibrantOptions) {
    _UXContentUnavailableVibrantNone   = 0,
    _UXContentUnavailableVibrantText   = 1 << 0,
    _UXContentUnavailableVibrantButton = 1 << 1,
};

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXContentUnavailableView : NSView

- (instancetype)initWithFrame:(NSRect)frame;

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *message;
@property (nonatomic, copy, nullable) NSAttributedString *attributedMessage;
@property (nonatomic, copy, nullable) NSString *buttonTitle;
@property (nonatomic, copy, nullable) NSString *symbolName;
@property (nonatomic, copy, nullable) void (^buttonAction)(void);
@property (nonatomic) BOOL showProgress;
@property (nonatomic) NSProgressIndicatorStyle progressIndicatorStyle;
@property (nonatomic) _UXContentUnavailableVibrantOptions vibrantOptions;

@property (nonatomic, strong, nullable) NSImageView *imageView;
@property (nonatomic, strong, nullable) NSTextField *titleLabel;
@property (nonatomic, strong, nullable) NSTextField *messageLabel;
@property (nonatomic, strong, nullable) NSButton *actionButton;
@property (nonatomic, strong, nullable) NSProgressIndicator *progressIndicator;
@property (nonatomic, strong) NSView *containerView;
@property (nonatomic, strong, nullable) NSMutableArray<NSLayoutConstraint *> *containerViewContraints;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
