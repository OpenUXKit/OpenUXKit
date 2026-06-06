#import "_UXFlowLayoutInfo.h"
#import "_UXFlowLayoutSection.h"
#import "_UXFlowLayoutItem.h"
#import "NSIndexPath+UXCollectionViewAdditions.h"
#import "UXKitPrivateUtilites.h"

@interface _UXFlowLayoutInfo () {
    NSMutableArray<_UXFlowLayoutSection *> *_sections;
    BOOL _usesFloatingHeaderFooter;
    BOOL _horizontal;
    BOOL _leftToRight;
    CGRect _visibleBounds;
    CGSize _layoutSize;
    CGFloat _dimension;
    BOOL _isValid;
    CGSize _contentSize;
    NSDictionary *_rowAlignmentOptions;
}
@end

@implementation _UXFlowLayoutInfo

@synthesize sections = _sections;
@synthesize usesFloatingHeaderFooter = _usesFloatingHeaderFooter;
@synthesize dimension = _dimension;
@synthesize horizontal = _horizontal;
@synthesize leftToRight = _leftToRight;
@synthesize contentSize = _contentSize;
@synthesize rowAlignmentOptions = _rowAlignmentOptions;

- (instancetype)init {
    self = [super init];
    if (self) {
        _horizontal = NO;
        _leftToRight = YES;
        _sections = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (_UXFlowLayoutSection *)addSection {
    _UXFlowLayoutSection *section = [[_UXFlowLayoutSection alloc] init];
    [section setLayoutInfo:self];
    [[self sections] addObject:section];
    return section;
}

- (void)invalidate:(BOOL)keepSections {
    _isValid = NO;
    if (!keepSections) {
        [_sections removeAllObjects];
    }
}

- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath {
    _UXFlowLayoutSection *section = [[self sections] objectAtIndex:[indexPath section]];
    CGRect sectionFrame = [section frame];
    CGRect itemFrame = [[[section items] objectAtIndex:[indexPath item]] itemFrame];
    return CGRectMake(sectionFrame.origin.x + itemFrame.origin.x,
                      sectionFrame.origin.y + itemFrame.origin.y,
                      itemFrame.size.width,
                      itemFrame.size.height);
}

- (id)copy {
    _UXFlowLayoutInfo *copy = [[_UXFlowLayoutInfo alloc] init];
    if (copy) {
        copy->_usesFloatingHeaderFooter = _usesFloatingHeaderFooter;
        copy->_horizontal = _horizontal;
        copy->_leftToRight = _leftToRight;
        copy->_visibleBounds = _visibleBounds;
        copy->_layoutSize = _layoutSize;
        copy->_dimension = _dimension;
        copy->_isValid = _isValid;
        copy->_rowAlignmentOptions = [_rowAlignmentOptions copy];
        for (_UXFlowLayoutSection *section in [self sections]) {
            _UXFlowLayoutSection *sectionCopy = [section copyFromLayoutInfo:copy];
            [sectionCopy setLayoutInfo:copy];
            [[copy sections] addObject:sectionCopy];
        }
    }
    return copy;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self copy];
}

- (_UXFlowLayoutInfo *)snapshot {
    _UXFlowLayoutInfo *snapshot = [[_UXFlowLayoutInfo alloc] init];
    for (_UXFlowLayoutSection *section in [self sections]) {
        [[snapshot sections] addObject:[section snapshot]];
    }
    [snapshot setContentSize:[self contentSize]];
    return snapshot;
}

@end
