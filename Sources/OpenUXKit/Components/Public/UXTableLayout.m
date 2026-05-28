#import <OpenUXKit/UXTableLayout.h>
#import <OpenUXKit/UXCollectionView.h>

@interface UXTableLayout () {
    BOOL _floatingHeadersDisabled;
    BOOL _showsSectionHeaderForSingleSection;
    BOOL _showsSectionFooterForSingleSection;
    NSMutableArray *_layoutAttributesArray;
    NSMutableDictionary *_headerAttributesByIndexPath;
}
@end

@implementation UXTableLayout

@synthesize floatingHeadersDisabled = _floatingHeadersDisabled;
@synthesize showsSectionHeaderForSingleSection = _showsSectionHeaderForSingleSection;
@synthesize showsSectionFooterForSingleSection = _showsSectionFooterForSingleSection;

- (instancetype)init {
    self = [super init];
    if (self) {
        _layoutAttributesArray = [[NSMutableArray alloc] init];
        _headerAttributesByIndexPath = [[NSMutableDictionary alloc] init];
        self.scrollDirection = UXCollectionViewScrollDirectionVertical;
    }
    return self;
}

- (BOOL)_wantsHeaderForSection:(NSUInteger)section {
    if (_showsSectionHeaderForSingleSection) {
        return YES;
    }
    return [self.collectionView numberOfSections] > 1;
}

- (NSEdgeInsets)insetForSection:(NSInteger)section {
    return self.sectionInset;
}

@end
