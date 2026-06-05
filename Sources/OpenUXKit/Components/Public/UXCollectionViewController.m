#import <OpenUXKit/UXCollectionViewController.h>
#import <OpenUXKit/UXCollectionView.h>
#import <OpenUXKit/UXCollectionViewLayout.h>

@interface UXCollectionView (UXCollectionViewControllerSPI)
- (void)setScrollViewDelegate:(nullable id)delegate;
- (void)setOverdrawEnabled:(BOOL)overdrawEnabled;
@end

@interface UXCollectionViewController () {
    UXCollectionViewLayout *_layout;
    UXCollectionView *_collectionView;
}
@end

@implementation UXCollectionViewController

@synthesize collectionView = _collectionView;

+ (Class)collectionViewClass {
    return [UXCollectionView class];
}

- (instancetype)initWithCollectionViewLayout:(UXCollectionViewLayout *)layout {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _layout = layout;
    }
    return self;
}

- (UXCollectionView *)collectionView {
    if (@available(macOS 14.0, *)) {
        [self loadViewIfNeeded];
    } else {
        (void)self.view;
    }
    return _collectionView;
}

- (void)setCollectionView:(UXCollectionView *)collectionView {
    _collectionView = collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    Class collectionViewClass = [[self class] collectionViewClass];
    NSAssert([collectionViewClass isSubclassOfClass:[UXCollectionView class]], @"Invalid parameter not satisfying: %@", @"[CollectionViewClass isSubclassOfClass:[UXCollectionView class]]");

    UXCollectionView *collectionView = [[collectionViewClass alloc] initWithFrame:self.view.bounds collectionViewLayout:_layout];
    _collectionView = collectionView;
    if ([_collectionView respondsToSelector:@selector(setScrollViewDelegate:)]) {
        [_collectionView setScrollViewDelegate:self];
    }
    _collectionView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.view addSubview:_collectionView];

    if ([_collectionView respondsToSelector:@selector(setOverdrawEnabled:)]) {
        [_collectionView setOverdrawEnabled:NO];
    }

    _collectionView.allowsSelection = YES;
    _collectionView.allowsMultipleSelection = NO;
    _collectionView.allowsContinuousSelection = NO;
    _collectionView.allowsPaintingSelection = NO;
    _collectionView.allowsLassoSelection = NO;
    _collectionView.allowsMagnification = NO;
}

- (NSResponder *)preferredFirstResponder {
    if ([self isViewLoaded]) {
        return [self collectionView];
    }
    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UXCollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UXCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UXCollectionViewCell *)collectionView:(UXCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGFloat)scrollView:(NSScrollView *)scrollView pageAlignedOriginOnAxis:(NSInteger)axis forProposedDestination:(CGFloat)destination currentOrigin:(CGFloat)current initialOrigin:(CGFloat)initial velocity:(CGFloat)velocity {
    UXCollectionView *collectionView = self.collectionView;
    UXCollectionViewLayout *layout = collectionView.collectionViewLayout;
    if (!layout) {
        return destination;
    }
    CGPoint proposed = (axis == 0)
        ? CGPointMake(destination, current)
        : CGPointMake(current, destination);
    CGPoint resolved = [layout targetContentOffsetForProposedContentOffset:proposed
                                                     withScrollingVelocity:(axis == 0 ? CGPointMake(velocity, 0.0) : CGPointMake(0.0, velocity))];
    return (axis == 0) ? resolved.x : resolved.y;
}

@end
