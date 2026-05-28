#import <OpenUXKit/_UXCollectionDocumentView.h>

@implementation _UXCollectionDocumentView

- (void)prepareContentInRect:(CGRect)rect {
    if (!_overdrawEnabled) {
        rect = self.visibleRect;
    }
    [super prepareContentInRect:rect];
}

@end
