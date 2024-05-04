#import <AppKit/AppKit.h>

@protocol UITextInputTraits <NSObject>

@optional

@property (nonatomic, getter = isSecureTextEntry) BOOL secureTextEntry;
@property (nonatomic) BOOL enablesReturnKeyAutomatically;
@property (nonatomic) NSInteger returnKeyType;
@property (nonatomic) NSInteger keyboardAppearance;
@property (nonatomic) NSInteger keyboardType;
@property (nonatomic) NSInteger spellCheckingType;
@property (nonatomic) NSInteger autocorrectionType;
@property (nonatomic) NSInteger autocapitalizationType;

@end
