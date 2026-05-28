#import <OpenUXKit/_UXWindow.h>

@implementation _UXWindow

- (instancetype)initWithContentRect:(CGRect)contentRect {
    NSWindowStyleMask styleMask = NSWindowStyleMaskTitled
        | NSWindowStyleMaskClosable
        | NSWindowStyleMaskMiniaturizable
        | NSWindowStyleMaskResizable
        | NSWindowStyleMaskFullSizeContentView;
    self = [super initWithContentRect:contentRect
                            styleMask:styleMask
                              backing:NSBackingStoreBuffered
                                defer:NO];
    if (self) {
        [self setMinSize:contentRect.size];
        self.titleVisibility = NSWindowTitleHidden;
        self.toolbarStyle = NSWindowToolbarStyleUnifiedCompact;
        self.collectionBehavior = NSWindowCollectionBehaviorFullScreenPrimary;
    }
    return self;
}

@end
