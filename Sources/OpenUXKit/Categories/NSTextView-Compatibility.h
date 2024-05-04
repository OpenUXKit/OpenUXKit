

#import <AppKit/NSTextView.h>

#import <OpenUXKit/UITextInputTraits-Protocol.h>

@class NSString;

@interface NSTextView (Compatibility) <UITextInputTraits>
@property(nonatomic) NSInteger textAlignment;
- (CGSize)sizeThatFits:(CGSize)arg1;
@property(copy, nonatomic) NSString *text;

// Remaining properties
@property(nonatomic) NSInteger autocapitalizationType;
@property(nonatomic) NSInteger autocorrectionType;
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(nonatomic) BOOL enablesReturnKeyAutomatically;
@property(readonly) NSUInteger hash;
@property(nonatomic) NSInteger keyboardAppearance;
@property(nonatomic) NSInteger keyboardType;
@property(nonatomic) NSInteger returnKeyType;
@property(nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;
@property(nonatomic) NSInteger spellCheckingType;
@property(readonly) Class superclass;
@end

