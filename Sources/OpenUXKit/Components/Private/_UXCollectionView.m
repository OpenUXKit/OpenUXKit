#import <OpenUXKit/_UXCollectionView.h>
#import <OpenUXKit/_UXCollectionDocumentView.h>

@implementation _UXCollectionView

+ (Class)documentClass {
    return [_UXCollectionDocumentView class];
}

- (BOOL)overdrawEnabled {
    return [(_UXCollectionDocumentView *)self.documentView overdrawEnabled];
}

- (void)setOverdrawEnabled:(BOOL)overdrawEnabled {
    [(_UXCollectionDocumentView *)self.documentView setOverdrawEnabled:overdrawEnabled];
}

@end
