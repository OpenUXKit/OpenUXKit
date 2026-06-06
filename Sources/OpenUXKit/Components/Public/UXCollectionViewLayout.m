#import "UXCollectionViewLayout+Internal.h"
#import "UXCollectionViewLayoutAttributes+Internal.h"
#import "UXCollectionViewLayoutInvalidationContext.h"
#import "UXCollectionViewLayoutAccessibility.h"
#import "UXCollectionViewUpdate+Internal.h"
#import "UXCollectionViewUpdateItem+Internal.h"
#import "UXCollectionView.h"
#import "UXCollectionViewData.h"
#import "UXCollectionReusableView.h"
#import "UXCollectionReusableView+Internal.h"
#import "_UXCollectionViewItemKey.h"
#import "NSIndexPath+UXCollectionViewAdditions.h"
#import "UXKitPrivateUtilites.h"

// SPI on UXCollectionView / UXCollectionViewData / UXCollectionReusableView owned by the view layer.
@interface NSObject (UXCollectionViewLayoutSPI)
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (nullable NSIndexPath *)nextIndexPath:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)previousIndexPath:(NSIndexPath *)indexPath;
- (BOOL)selectableItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSUserInterfaceLayoutDirection)userInterfaceLayoutDirection;
- (nullable id)_currentUpdate;
- (nullable NSArray *)_insertedSupplementaryIndexesSectionArray;
- (nullable NSArray *)_deletedSupplementaryIndexesSectionArray;
- (nullable id)_collectionViewData;
- (nullable NSDictionary *)_visibleViewsDict;
- (CGRect)documentContentRect;
- (nullable id)cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable UXCollectionViewLayoutAttributes *)_layoutAttributes;
- (nullable id)_visibleSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath isDecorationView:(BOOL)isDecorationView;
- (nullable NSString *)_retrieveAccessibiltyRoleDescriptionFromAXDelegate;
- (void)_setLayoutAttributes:(nullable UXCollectionViewLayoutAttributes *)layoutAttributes;
- (void)_setReuseIdentifier:(nullable NSString *)reuseIdentifier;
- (void)_markAsDequeued;
- (void)_invalidateLayoutWithContext:(nullable UXCollectionViewLayoutInvalidationContext *)context;
- (NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect;
@end

@interface UXCollectionViewLayout () {
    CGSize _collectionViewBoundsSize;
    NSMutableDictionary *_initialAnimationLayoutAttributesDict;
    NSMutableDictionary *_finalAnimationLayoutAttributesDict;
    NSMutableDictionary *_deletedSupplementaryIndexPathsDict;
    NSMutableDictionary *_insertedSupplementaryIndexPathsDict;
    NSMutableDictionary *_deletedDecorationIndexPathsDict;
    NSMutableDictionary *_insertedDecorationIndexPathsDict;
    NSMutableIndexSet *_deletedSectionsSet;
    NSMutableIndexSet *_insertedSectionsSet;
    NSMutableDictionary *_decorationViewClassDict;
    NSMutableDictionary *_decorationViewNibDict;
    UXCollectionViewLayout *_transitioningFromLayout;
    UXCollectionViewLayout *_transitioningToLayout;
    BOOL _inTransitionFromTransitionLayout;
    BOOL _inTransitionToTransitionLayout;
    UXCollectionViewLayoutInvalidationContext *_invalidationContext;
    NSArray *_accessibilityChildren;
    UXCollectionViewLayoutAccessibility *_layoutAccessibility;
    NSString *_accessibilityIdentifier;
    NSString *_accessibilityLabel;
    NSString *_accessibilityRoleDescription;
    __weak UXCollectionView *_collectionView;
}
@end

@implementation UXCollectionViewLayout

@synthesize layoutAccessibility = _layoutAccessibility;
@synthesize accessibilityChildren = _accessibilityChildren;

- (NSString *)accessibilityIdentifier {
    return _accessibilityIdentifier;
}

- (void)setAccessibilityIdentifier:(NSString *)accessibilityIdentifier {
    _accessibilityIdentifier = [accessibilityIdentifier copy];
}

- (NSString *)accessibilityLabel {
    return _accessibilityLabel;
}

- (void)setAccessibilityLabel:(NSString *)accessibilityLabel {
    _accessibilityLabel = [accessibilityLabel copy];
}

+ (Class)layoutAttributesClass {
    return [UXCollectionViewLayoutAttributes class];
}

+ (Class)invalidationContextClass {
    return [UXCollectionViewLayoutInvalidationContext class];
}

+ (Class)layoutAccessibilityClass {
    return [UXCollectionViewLayoutAccessibility class];
}

- (void)_commonInit {
    _initialAnimationLayoutAttributesDict = [[NSMutableDictionary alloc] init];
    _finalAnimationLayoutAttributesDict = [[NSMutableDictionary alloc] init];
    _deletedSupplementaryIndexPathsDict = [[NSMutableDictionary alloc] init];
    _insertedSupplementaryIndexPathsDict = [[NSMutableDictionary alloc] init];
    _deletedDecorationIndexPathsDict = [[NSMutableDictionary alloc] init];
    _insertedDecorationIndexPathsDict = [[NSMutableDictionary alloc] init];
    _deletedSectionsSet = [[NSMutableIndexSet alloc] init];
    _insertedSectionsSet = [[NSMutableIndexSet alloc] init];
    _accessibilityRoleDescription = NSLocalizedStringFromTable(@"UXCollectionViewAXRoleDescription", @"UXKit", @"");
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _decorationViewNibDict = [coder decodeObjectForKey:@"UXCollectionViewDecorationViewNibDict"];
        [self _commonInit];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if ([_decorationViewNibDict count]) {
        [coder encodeObject:_decorationViewNibDict forKey:@"UXCollectionViewDecorationViewNibDict"];
    }
}

#pragma mark - Collection View

- (UXCollectionView *)collectionView {
    return _collectionView;
}

- (void)_setCollectionView:(UXCollectionView *)collectionView {
    _collectionView = collectionView;
}

- (void)_setCollectionViewBoundsSize:(CGSize)boundsSize {
    _collectionViewBoundsSize = boundsSize;
}

#pragma mark - Invalidation

- (void)invalidateLayout {
    UXCollectionViewLayoutInvalidationContext *context = _invalidationContext;
    if (!context) {
        context = [[[[self class] invalidationContextClass] alloc] init];
    }
    [self invalidateLayoutWithContext:context];
}

- (void)invalidateLayoutWithContext:(UXCollectionViewLayoutInvalidationContext *)context {
    [(id)_collectionView _invalidateLayoutWithContext:context];
    [[self layoutAccessibility] accessibilityInvalidateLayout];
}

- (void)_invalidateLayoutUsingContext:(UXCollectionViewLayoutInvalidationContext *)context {
    _invalidationContext = context;
    [self invalidateLayout];
    _invalidationContext = nil;
}

- (UXCollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds {
    return [[[[self class] invalidationContextClass] alloc] init];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}

- (BOOL)shouldInvalidateLayoutForScaleFactorChangeFrom:(CGFloat)fromScaleFactor to:(CGFloat)toScaleFactor {
    return YES;
}

#pragma mark - Layout

- (void)prepareLayout {
    [[self layoutAccessibility] accessibilityPrepareLayout];
}

- (nullable NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return nil;
}

- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (nullable UXCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGSize)collectionViewContentSize {
    return CGSizeZero;
}

- (CGRect)bounds {
    CGSize contentSize = [self collectionViewContentSize];
    return CGRectMake(0.0, 0.0, contentSize.width, contentSize.height);
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    return proposedContentOffset;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    return proposedContentOffset;
}

#pragma mark - Decoration View Registration

- (void)registerClass:(Class)viewClass forDecorationViewOfKind:(NSString *)elementKind {
    if (!_decorationViewClassDict) {
        _decorationViewClassDict = [[NSMutableDictionary alloc] init];
    }
    [_decorationViewNibDict removeObjectForKey:elementKind];
    if (viewClass) {
        [_decorationViewClassDict setValue:viewClass forKey:elementKind];
    } else {
        [_decorationViewClassDict removeObjectForKey:elementKind];
    }
}

- (void)registerNib:(NSNib *)nib forDecorationViewOfKind:(NSString *)elementKind {
    if (!_decorationViewNibDict) {
        _decorationViewNibDict = [[NSMutableDictionary alloc] init];
    }
    [_decorationViewClassDict removeObjectForKey:elementKind];
    if (nib) {
        [_decorationViewNibDict setValue:nib forKey:elementKind];
    } else {
        [_decorationViewNibDict removeObjectForKey:elementKind];
    }
}

- (UXCollectionReusableView *)_decorationViewForLayoutAttributes:(UXCollectionViewLayoutAttributes *)layoutAttributes {
    NSString *elementKind = [layoutAttributes _elementKind];
    Class viewClass = [_decorationViewClassDict valueForKey:elementKind];
    UXCollectionReusableView *view = [[viewClass alloc] initWithFrame:layoutAttributes.frame];
    if (!view) {
        [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                            object:self
                                                              file:@"UXCollectionViewLayout.m"
                                                        lineNumber:1645
                                                       description:@"could not dequeue a decoration view of kind: %@ - must register as a class or nib or connect a prototype in a storyboard", [layoutAttributes _elementKind]];
    }
    [view _setReuseIdentifier:elementKind];
    [view _setLayoutAttributes:layoutAttributes];
    [view setAutoresizingMask:NSViewNotSizable];
    [view setTranslatesAutoresizingMaskIntoConstraints:YES];
    [view _markAsDequeued];
    return view;
}

#pragma mark - Transitions

- (void)prepareForTransitionToLayout:(UXCollectionViewLayout *)newLayout {
}

- (void)prepareForTransitionFromLayout:(UXCollectionViewLayout *)oldLayout {
}

- (void)finalizeLayoutTransition {
}

- (void)_prepareForTransitionFromLayout:(UXCollectionViewLayout *)oldLayout {
    _transitioningFromLayout = oldLayout;
    [self prepareForTransitionFromLayout:oldLayout];
}

- (void)_prepareForTransitionToLayout:(UXCollectionViewLayout *)newLayout {
    _transitioningToLayout = newLayout;
    [self prepareForTransitionToLayout:newLayout];
}

- (void)_finalizeLayoutTransition {
    _transitioningFromLayout = nil;
    _inTransitionFromTransitionLayout = NO;
    _transitioningToLayout = nil;
    _inTransitionToTransitionLayout = NO;
    [self finalizeLayoutTransition];
}

- (void)_didFinishLayoutTransitionAnimations:(BOOL)finished {
}

- (BOOL)_supportsAdvancedTransitionAnimations {
    return NO;
}

#pragma mark - Animated Bounds Change

- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds {
}

- (void)finalizeAnimatedBoundsChange {
}

#pragma mark - Collection View Updates

- (void)finalizeCollectionViewUpdates {
    [_initialAnimationLayoutAttributesDict removeAllObjects];
    [_finalAnimationLayoutAttributesDict removeAllObjects];
    [_deletedSupplementaryIndexPathsDict removeAllObjects];
    [_insertedSupplementaryIndexPathsDict removeAllObjects];
    [_deletedDecorationIndexPathsDict removeAllObjects];
    [_insertedDecorationIndexPathsDict removeAllObjects];
    [_deletedSectionsSet removeAllIndexes];
    [_insertedSectionsSet removeAllIndexes];
}

- (void)_finalizeCollectionViewItemAnimations {
    [_initialAnimationLayoutAttributesDict removeAllObjects];
    [_finalAnimationLayoutAttributesDict removeAllObjects];
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    UXCollectionView *collectionView = _collectionView;
    UXCollectionViewUpdate *currentUpdate = [(id)collectionView _currentUpdate];

    for (id view in [[(id)collectionView _visibleViewsDict] objectEnumerator]) {
        UXCollectionViewLayoutAttributes *attributes = [[view _layoutAttributes] copy];
        if (!attributes) {
            [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                                object:self
                                                                  file:@"UXCollectionViewLayout.m"
                                                            lineNumber:805
                                                           description:@"failed to make a copy of the layout attributes %@ for %@", [view _layoutAttributes], view];
        }
        if ([attributes _isCell]) {
            NSInteger globalIndex = [[currentUpdate _oldModel] globalIndexForItemAtIndexPath:attributes.indexPath];
            if (globalIndex != NSNotFound && [currentUpdate _oldGlobalItemMapValueAtIndex:globalIndex] != NSNotFound) {
                NSIndexPath *newIndexPath = [[currentUpdate _newModel] indexPathForItemAtGlobalIndex:[currentUpdate _oldGlobalItemMapValueAtIndex:globalIndex]];
                [attributes setIndexPath:newIndexPath];
                [_initialAnimationLayoutAttributesDict setObject:attributes forKey:[_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:attributes]];
            }
        } else {
            NSIndexPath *newIndexPath = [currentUpdate newIndexPathForSupplementaryElementOfKind:[attributes _elementKind] oldIndexPath:attributes.indexPath];
            if (newIndexPath) {
                [attributes setIndexPath:newIndexPath];
                [_initialAnimationLayoutAttributesDict setObject:attributes forKey:[_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:attributes]];
            }
        }
    }

    id collectionViewData = [(id)collectionView _collectionViewData];
    NSArray<UXCollectionViewLayoutAttributes *> *comingOnScreen = (NSArray<UXCollectionViewLayoutAttributes *> *)[collectionViewData layoutAttributesForElementsInRect:[(id)collectionView documentContentRect]];
    for (UXCollectionViewLayoutAttributes *attributes in comingOnScreen) {
        UXCollectionViewLayoutAttributes *copy = [attributes copy];
        if (!copy) {
            [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd
                                                                object:self
                                                                  file:@"UXCollectionViewLayout.m"
                                                            lineNumber:835
                                                           description:@"failed to make a copy of the coming on screen attributes for %@", attributes];
        }
        if ([attributes _isCell]) {
            NSInteger globalIndex = [[currentUpdate _newModel] globalIndexForItemAtIndexPath:copy.indexPath];
            if (globalIndex != NSNotFound && [currentUpdate _newGlobalItemMapValueAtIndex:globalIndex] != NSNotFound) {
                NSIndexPath *oldIndexPath = [[currentUpdate _oldModel] indexPathForItemAtGlobalIndex:[currentUpdate _newGlobalItemMapValueAtIndex:globalIndex]];
                [copy setIndexPath:oldIndexPath];
                [_finalAnimationLayoutAttributesDict setObject:copy forKey:[_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:copy]];
            }
        } else {
            NSIndexPath *oldIndexPath = [currentUpdate oldIndexPathForSupplementaryElementOfKind:[copy _elementKind] newIndexPath:copy.indexPath];
            if (oldIndexPath) {
                [copy setIndexPath:oldIndexPath];
                [_finalAnimationLayoutAttributesDict setObject:copy forKey:[_UXCollectionViewItemKey collectionItemKeyForLayoutAttributes:copy]];
            }
        }
    }

    for (UXCollectionViewUpdateItem *updateItem in updateItems) {
        NSInteger updateAction = [updateItem updateAction];
        if ([updateItem _isSectionOperation]) {
            if (updateAction == UXCollectionUpdateActionInsert) {
                [_insertedSectionsSet addIndex:[[updateItem _indexPath] section]];
            } else if (updateAction == UXCollectionUpdateActionDelete) {
                [_deletedSectionsSet addIndex:[[updateItem _indexPath] section]];
            } else if (updateAction == UXCollectionUpdateActionReload) {
                [_deletedSectionsSet addIndex:[[updateItem indexPathBeforeUpdate] section]];
                [_insertedSectionsSet addIndex:[[updateItem indexPathAfterUpdate] section]];
            }
        } else {
            if (updateAction == UXCollectionUpdateActionInsert) {
                NSIndexPath *indexPath = [updateItem indexPathAfterUpdate];
                _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForCellWithIndexPath:indexPath];
                UXCollectionViewLayoutAttributes *attributes = [[self layoutAttributesForItemAtIndexPath:indexPath] copy];
                if (attributes) {
                    [attributes setAlpha:0.0];
                    [_initialAnimationLayoutAttributesDict setObject:attributes forKey:key];
                }
            } else if (updateAction == UXCollectionUpdateActionDelete || updateAction == UXCollectionUpdateActionReload) {
                _UXCollectionViewItemKey *key = [_UXCollectionViewItemKey collectionItemKeyForCellWithIndexPath:[updateItem indexPathBeforeUpdate]];
                UXCollectionViewLayoutAttributes *attributes = [[[[(id)collectionView _visibleViewsDict] objectForKey:key] _layoutAttributes] copy];
                if (attributes) {
                    [attributes setAlpha:0.0];
                    [_finalAnimationLayoutAttributesDict setObject:attributes forKey:key];
                }
            }
        }
    }

    for (NSUInteger section = [_insertedSectionsSet firstIndex]; section != NSNotFound; section = [_insertedSectionsSet indexGreaterThanIndex:section]) {
        NSArray<UXCollectionViewLayoutAttributes *> *supplementaryAttributes = [[[(id)collectionView _currentUpdate] _oldModel] existingSupplementaryLayoutAttributesInSection:section];
        for (UXCollectionViewLayoutAttributes *attributes in supplementaryAttributes) {
            NSMutableDictionary *targetDict = [attributes _isDecorationView] ? _deletedDecorationIndexPathsDict : _deletedSupplementaryIndexPathsDict;
            NSMutableArray *indexPaths = [targetDict objectForKeyedSubscript:[attributes _elementKind]];
            if (!indexPaths) {
                indexPaths = [[NSMutableArray alloc] init];
                [targetDict setObject:indexPaths forKeyedSubscript:[attributes _elementKind]];
            }
            [indexPaths addObject:attributes.indexPath];
        }
    }

    for (NSUInteger section = [_deletedSectionsSet firstIndex]; section != NSNotFound; section = [_deletedSectionsSet indexGreaterThanIndex:section]) {
        NSArray<UXCollectionViewLayoutAttributes *> *supplementaryAttributes = [[[(id)collectionView _currentUpdate] _newModel] existingSupplementaryLayoutAttributesInSection:section];
        for (UXCollectionViewLayoutAttributes *attributes in supplementaryAttributes) {
            NSMutableDictionary *targetDict = [attributes _isDecorationView] ? _insertedDecorationIndexPathsDict : _insertedSupplementaryIndexPathsDict;
            NSMutableArray *indexPaths = [targetDict objectForKeyedSubscript:[attributes _elementKind]];
            if (!indexPaths) {
                indexPaths = [[NSMutableArray alloc] init];
                [targetDict setObject:indexPaths forKeyedSubscript:[attributes _elementKind]];
            }
            [indexPaths addObject:attributes.indexPath];
        }
    }

    [[self layoutAccessibility] accessibilityPrepareForCollectionViewUpdates:updateItems];
}

#pragma mark - Appearance / Disappearance Attributes

- (UXCollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UXCollectionViewLayoutAttributes *attributes = [_initialAnimationLayoutAttributesDict objectForKey:[_UXCollectionViewItemKey collectionItemKeyForCellWithIndexPath:itemIndexPath]];
    UXCollectionView *collectionView = _collectionView;
    if (!attributes) {
        if ([itemIndexPath section] >= [collectionView numberOfSections] || [itemIndexPath item] >= [collectionView numberOfItemsInSection:[itemIndexPath section]]) {
            attributes = nil;
        } else {
            id source = (_transitioningFromLayout && !_inTransitionFromTransitionLayout) ? _transitioningFromLayout : self;
            attributes = (UXCollectionViewLayoutAttributes *)[source layoutAttributesForItemAtIndexPath:itemIndexPath];
        }
    }
    if ((![(id)collectionView _currentUpdate] || [_insertedSectionsSet containsIndex:[itemIndexPath section]]) && !_transitioningFromLayout) {
        attributes = [attributes copy];
        [attributes setAlpha:0.0];
    }
    return attributes;
}

- (UXCollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UXCollectionViewLayoutAttributes *attributes = [_finalAnimationLayoutAttributesDict objectForKey:[_UXCollectionViewItemKey collectionItemKeyForCellWithIndexPath:itemIndexPath]];
    UXCollectionView *collectionView = _collectionView;
    if (!attributes) {
        if (_transitioningToLayout && !_inTransitionToTransitionLayout) {
            attributes = [_transitioningToLayout layoutAttributesForItemAtIndexPath:itemIndexPath];
        } else {
            attributes = [(id)[(id)collectionView cellForItemAtIndexPath:itemIndexPath] _layoutAttributes];
        }
    }
    if ((![(id)collectionView _currentUpdate] || [_deletedSectionsSet containsIndex:[itemIndexPath section]]) && !_transitioningToLayout) {
        attributes = [attributes copy];
        [attributes setAlpha:0.0];
    }
    return attributes;
}

- (UXCollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
    UXCollectionViewLayoutAttributes *attributes = [_initialAnimationLayoutAttributesDict objectForKey:[_UXCollectionViewItemKey collectionItemKeyForSupplementaryViewOfKind:elementKind andIndexPath:elementIndexPath]];
    UXCollectionView *collectionView = _collectionView;
    if (!attributes) {
        if ([elementIndexPath length] == 1 || [elementIndexPath section] < [collectionView numberOfSections]) {
            id source = (_transitioningFromLayout && !_inTransitionFromTransitionLayout) ? _transitioningFromLayout : self;
            attributes = (UXCollectionViewLayoutAttributes *)[source layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath];
        } else {
            attributes = nil;
        }
    }
    id currentUpdate = [(id)collectionView _currentUpdate];
    BOOL shouldFade = !currentUpdate;
    if (!shouldFade && [elementIndexPath section] != NSNotFound) {
        shouldFade = [_insertedSectionsSet containsIndex:[elementIndexPath section]] ||
                     [[[[currentUpdate _insertedSupplementaryIndexesSectionArray] objectAtIndexedSubscript:[elementIndexPath section]] valueForKey:elementKind] containsIndex:[elementIndexPath item]];
    }
    if (shouldFade && !_transitioningFromLayout) {
        attributes = [attributes copy];
        [attributes setAlpha:0.0];
    }
    return attributes;
}

- (UXCollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
    UXCollectionViewLayoutAttributes *attributes = [_finalAnimationLayoutAttributesDict objectForKey:[_UXCollectionViewItemKey collectionItemKeyForSupplementaryViewOfKind:elementKind andIndexPath:elementIndexPath]];
    UXCollectionView *collectionView = _collectionView;
    if (!attributes) {
        if (_transitioningToLayout && !_inTransitionToTransitionLayout) {
            attributes = [_transitioningToLayout layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath];
        } else {
            attributes = [[(id)collectionView _visibleSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath isDecorationView:NO] _layoutAttributes];
        }
    }
    id currentUpdate = [(id)collectionView _currentUpdate];
    BOOL shouldFade = !currentUpdate;
    if (!shouldFade && [elementIndexPath section] != NSNotFound) {
        shouldFade = [_deletedSectionsSet containsIndex:[elementIndexPath section]] ||
                     [[[[currentUpdate _deletedSupplementaryIndexesSectionArray] objectAtIndexedSubscript:[elementIndexPath section]] valueForKey:elementKind] containsIndex:[elementIndexPath item]];
    }
    if (shouldFade && !_transitioningToLayout) {
        attributes = [attributes copy];
        [attributes setAlpha:0.0];
    }
    return attributes;
}

- (UXCollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath {
    UXCollectionViewLayoutAttributes *attributes = [_initialAnimationLayoutAttributesDict objectForKey:[_UXCollectionViewItemKey collectionItemKeyForDecorationViewOfKind:elementKind andIndexPath:decorationIndexPath]];
    UXCollectionView *collectionView = _collectionView;
    if (!attributes) {
        if ([decorationIndexPath length] == 1 || [decorationIndexPath section] < [collectionView numberOfSections]) {
            id source = (_transitioningFromLayout && !_inTransitionFromTransitionLayout) ? _transitioningFromLayout : self;
            attributes = (UXCollectionViewLayoutAttributes *)[source layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:decorationIndexPath];
        } else {
            attributes = nil;
        }
    }
    id currentUpdate = [(id)collectionView _currentUpdate];
    BOOL shouldFade = !currentUpdate;
    if (!shouldFade && [decorationIndexPath section] != NSNotFound) {
        shouldFade = [_insertedSectionsSet containsIndex:[decorationIndexPath section]] ||
                     [[[[currentUpdate _insertedSupplementaryIndexesSectionArray] objectAtIndexedSubscript:[decorationIndexPath section]] valueForKey:elementKind] containsIndex:[decorationIndexPath item]];
    }
    if (shouldFade && !_transitioningFromLayout) {
        attributes = [attributes copy];
        [attributes setAlpha:0.0];
    }
    return attributes;
}

- (UXCollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath {
    UXCollectionViewLayoutAttributes *attributes = [_finalAnimationLayoutAttributesDict objectForKey:[_UXCollectionViewItemKey collectionItemKeyForDecorationViewOfKind:elementKind andIndexPath:decorationIndexPath]];
    UXCollectionView *collectionView = _collectionView;
    if (!attributes) {
        if (_transitioningToLayout && !_inTransitionToTransitionLayout) {
            attributes = [_transitioningToLayout layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:decorationIndexPath];
        } else {
            attributes = [[(id)collectionView _visibleSupplementaryViewOfKind:elementKind atIndexPath:decorationIndexPath isDecorationView:YES] _layoutAttributes];
        }
    }
    id currentUpdate = [(id)collectionView _currentUpdate];
    BOOL shouldFade = !currentUpdate;
    if (!shouldFade && [decorationIndexPath section] != NSNotFound) {
        shouldFade = [_deletedSectionsSet containsIndex:[decorationIndexPath section]] ||
                     [[[[currentUpdate _deletedSupplementaryIndexesSectionArray] objectAtIndexedSubscript:[decorationIndexPath section]] valueForKey:elementKind] containsIndex:[decorationIndexPath item]];
    }
    if (shouldFade && !_transitioningToLayout) {
        attributes = [attributes copy];
        [attributes setAlpha:0.0];
    }
    return attributes;
}

#pragma mark - Index Paths To Insert / Delete

- (NSArray<NSIndexPath *> *)_indexPathsToInsertForSupplementaryViewOfKind:(NSString *)elementKind {
    NSArray<NSIndexPath *> *result = [_insertedSupplementaryIndexPathsDict objectForKeyedSubscript:elementKind];
    if (!result) {
        return [NSArray array];
    }
    return result;
}

- (NSArray<NSIndexPath *> *)_indexPathsToInsertForDecorationViewOfKind:(NSString *)elementKind {
    NSArray<NSIndexPath *> *result = [_insertedDecorationIndexPathsDict objectForKeyedSubscript:elementKind];
    if (!result) {
        return [NSArray array];
    }
    return result;
}

- (NSArray<NSIndexPath *> *)_indexPathsToDeleteForSupplementaryViewOfKind:(NSString *)elementKind {
    NSArray<NSIndexPath *> *result = [_deletedSupplementaryIndexPathsDict objectForKeyedSubscript:elementKind];
    if (!result) {
        return [NSArray array];
    }
    return result;
}

- (NSArray<NSIndexPath *> *)_indexPathsToDeleteForDecorationViewOfKind:(NSString *)elementKind {
    NSArray<NSIndexPath *> *result = [_deletedDecorationIndexPathsDict objectForKeyedSubscript:elementKind];
    if (!result) {
        return [NSArray array];
    }
    return result;
}

- (NSArray<NSIndexPath *> *)indexPathsToInsertForSupplementaryViewOfKind:(NSString *)elementKind {
    return [self _indexPathsToInsertForSupplementaryViewOfKind:elementKind];
}

- (NSArray<NSIndexPath *> *)indexPathsToInsertForDecorationViewOfKind:(NSString *)elementKind {
    return [self _indexPathsToInsertForDecorationViewOfKind:elementKind];
}

- (NSArray<NSIndexPath *> *)indexPathsToDeleteForSupplementaryViewOfKind:(NSString *)elementKind {
    return [self _indexPathsToDeleteForSupplementaryViewOfKind:elementKind];
}

- (NSArray<NSIndexPath *> *)indexPathsToDeleteForDecorationViewOfKind:(NSString *)elementKind {
    return [self _indexPathsToDeleteForDecorationViewOfKind:elementKind];
}

#pragma mark - Keyboard Navigation

- (BOOL)_isValidSection:(NSInteger)section item:(NSInteger)item {
    if ((section | item) < 0) {
        return NO;
    }
    UXCollectionView *collectionView = _collectionView;
    return section < [collectionView numberOfSections] && item < [collectionView numberOfItemsInSection:section];
}

- (BOOL)_selectableItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![self layoutAttributesForItemAtIndexPath:indexPath]) {
        return NO;
    }
    return [(id)_collectionView selectableItemAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathOfItemAbove:(NSIndexPath *)indexPath {
    return nil;
}

- (NSIndexPath *)indexPathOfItemBelow:(NSIndexPath *)indexPath {
    return nil;
}

- (NSIndexPath *)indexPathOfItemAfter:(NSIndexPath *)indexPath {
    return [(id)_collectionView nextIndexPath:indexPath];
}

- (NSIndexPath *)indexPathOfItemBefore:(NSIndexPath *)indexPath {
    return [(id)_collectionView previousIndexPath:indexPath];
}

- (NSIndexPath *)firstSelectableItemIndexPath {
    UXCollectionView *collectionView = _collectionView;
    if ([collectionView numberOfSections] < 1) {
        return nil;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    if (![collectionView numberOfItemsInSection:[indexPath section]]) {
        indexPath = [(id)collectionView nextIndexPath:indexPath];
    }
    for (; indexPath; indexPath = [(id)collectionView nextIndexPath:indexPath]) {
        if ([self _selectableItemAtIndexPath:indexPath]) {
            break;
        }
    }
    return indexPath;
}

- (NSIndexPath *)lastSelectableItemIndexPath {
    UXCollectionView *collectionView = _collectionView;
    NSInteger sectionCount = [collectionView numberOfSections];
    if (sectionCount < 1) {
        return nil;
    }
    NSInteger lastSection = sectionCount - 1;
    NSInteger itemCount = [collectionView numberOfItemsInSection:lastSection];
    if (itemCount < 1) {
        return nil;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemCount - 1 inSection:lastSection];
    for (; ; indexPath = [(id)collectionView previousIndexPath:indexPath]) {
        if (!indexPath || [self _selectableItemAtIndexPath:indexPath]) {
            break;
        }
    }
    return indexPath;
}

- (NSArray<NSIndexPath *> *)indexPathsForItemRangeSelectionFrom:(NSIndexPath *)fromIndexPath to:(NSIndexPath *)toIndexPath {
    if (!fromIndexPath || !toIndexPath) {
        return [NSArray array];
    }
    NSMutableArray<NSIndexPath *> *result = [NSMutableArray array];
    NSComparisonResult comparison = [fromIndexPath compare:toIndexPath];
    NSInteger toSection = [toIndexPath section];
    NSInteger toItem = [toIndexPath item];
    if (![self _isValidSection:toSection item:toItem]) {
        return [NSArray array];
    }
    NSInteger currentSection = [fromIndexPath section];
    NSInteger currentItem = [fromIndexPath item];
    if (![self _isValidSection:currentSection item:currentItem]) {
        return [NSArray array];
    }
    UXCollectionView *collectionView = _collectionView;
    NSInteger step = (comparison == NSOrderedDescending) ? -1 : 1;
    while (YES) {
        if (currentItem < 0 || currentItem >= [collectionView numberOfItemsInSection:currentSection]) {
            if (comparison == NSOrderedDescending) {
                currentSection--;
                if (currentSection < 0) {
                    return result;
                }
                NSInteger sectionItemCount = [collectionView numberOfItemsInSection:currentSection];
                currentItem = sectionItemCount - 1;
                if (sectionItemCount < 1) {
                    goto advance;
                }
            } else {
                currentSection++;
                if (currentSection >= [collectionView numberOfSections]) {
                    return result;
                }
                currentItem = 0;
            }
        }
        if (currentSection >= 0 && currentItem < [collectionView numberOfItemsInSection:currentSection] && currentSection < [collectionView numberOfSections]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentItem inSection:currentSection];
            if ([self layoutAttributesForItemAtIndexPath:indexPath]) {
                [result addObject:indexPath];
            }
        }
    advance:
        if (currentItem == toItem && currentSection == toSection) {
            return result;
        }
        currentItem += step;
    }
}

#pragma mark - Misc

- (NSUserInterfaceLayoutDirection)userInterfaceLayoutDirection {
    return [(id)_collectionView userInterfaceLayoutDirection];
}

- (NSEdgeInsets)insetsForScrollingItemAtIndexPath:(NSIndexPath *)indexPath toScrollPosition:(NSUInteger)scrollPosition {
    return NSEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

- (CGRect)backingAlignedRect:(CGRect)rect options:(NSAlignmentOptions)options {
    @autoreleasepool {
        NSView *documentView = [(id)[self collectionView] documentView];
        if (documentView) {
            NSAlignmentOptions resolvedOptions = options & ~NSAlignRectFlipped;
            if ([documentView isFlipped]) {
                resolvedOptions |= NSAlignRectFlipped;
            }
            rect = [documentView backingAlignedRect:rect options:resolvedOptions];
        }
    }
    return rect;
}

- (id)_animationForReusableView:(id)reusableView toLayoutAttributes:(UXCollectionViewLayoutAttributes *)layoutAttributes {
    return nil;
}

- (id)_animationForReusableView:(id)reusableView toLayoutAttributes:(UXCollectionViewLayoutAttributes *)layoutAttributes type:(NSUInteger)type {
    return [self _animationForReusableView:reusableView toLayoutAttributes:layoutAttributes];
}

- (id)snapshottedLayoutAttributeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - Transition animation private

- (void)_animateView:(UXCollectionReusableView *)view
          withAction:(NSInteger)action
fromLayoutAttributes:(UXCollectionViewLayoutAttributes *)fromAttributes
  toLayoutAttributes:(UXCollectionViewLayoutAttributes *)toAttributes
          fromLayout:(UXCollectionViewLayout *)fromLayout
withCompletionHandler:(void (^)(BOOL finished))completion {
    if (!view) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    if (fromAttributes) {
        [(id)view _setLayoutAttributes:fromAttributes];
    }
    UXCollectionViewLayoutAttributes *target = toAttributes ?: fromAttributes;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.25;
        context.allowsImplicitAnimation = YES;
        [(id)view _setLayoutAttributes:target];
    } completionHandler:^{
        if (completion) {
            completion(YES);
        }
    }];
}

- (void)_prepareToAnimateFromCollectionViewItems:(NSArray *)fromItems
                                 atContentOffset:(CGPoint)fromContentOffset
                                         toItems:(NSArray *)toItems
                                 atContentOffset:(CGPoint)toContentOffset {
    // Capture starting positions for cross-layout interpolation. Subclasses may override
    // to populate per-view animation bookkeeping; the base path keeps the current
    // attributes dictionaries intact.
    (void)fromItems;
    (void)fromContentOffset;
    (void)toItems;
    (void)toContentOffset;
}

- (CGPoint)transitionContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
                                          keyItemIndexPath:(NSIndexPath *)keyItemIndexPath {
    if (!keyItemIndexPath) {
        return proposedContentOffset;
    }
    UXCollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:keyItemIndexPath];
    if (!attributes) {
        return proposedContentOffset;
    }
    CGRect frame = attributes.frame;
    CGFloat clampedY = CGRectGetMinY(frame);
    CGFloat clampedX = CGRectGetMinX(frame);
    return CGPointMake(clampedX, clampedY);
}

- (CGPoint)updatesContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    CGSize contentSize = [self collectionViewContentSize];
    CGFloat maxX = MAX(0.0, contentSize.width);
    CGFloat maxY = MAX(0.0, contentSize.height);
    CGFloat clampedX = MIN(MAX(0.0, proposedContentOffset.x), maxX);
    CGFloat clampedY = MIN(MAX(0.0, proposedContentOffset.y), maxY);
    return CGPointMake(clampedX, clampedY);
}

- (NSCollectionViewDropOperation)dropPositionForPoint:(CGPoint)point {
    UXCollectionView *collectionView = _collectionView;
    NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:point];
    if (!indexPath) {
        return NSCollectionViewDropBefore;
    }
    UXCollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    if (!attributes) {
        return NSCollectionViewDropBefore;
    }
    CGRect frame = attributes.frame;
    CGFloat centerY = CGRectGetMidY(frame);
    return (point.y >= centerY) ? NSCollectionViewDropOn : NSCollectionViewDropBefore;
}

- (NSIndexPath *)proposedDropIndexPathForDraggingPoint:(CGPoint)point {
    UXCollectionView *collectionView = _collectionView;
    NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:point];
    if (indexPath) {
        return indexPath;
    }
    NSInteger sectionCount = [collectionView numberOfSections];
    if (sectionCount == 0) {
        return [NSIndexPath indexPathForItem:0 inSection:0];
    }
    NSInteger lastSection = sectionCount - 1;
    NSInteger itemCount = [collectionView numberOfItemsInSection:lastSection];
    return [NSIndexPath indexPathForItem:itemCount inSection:lastSection];
}

#pragma mark - Accessibility

- (NSArray *)accessibilityChildren {
    if (!_accessibilityChildren) {
        if (!_layoutAccessibility) {
            _layoutAccessibility = [[[[self class] layoutAccessibilityClass] alloc] initWithLayout:self];
        }
        if (_layoutAccessibility) {
            _accessibilityChildren = [[NSArray alloc] initWithObjects:_layoutAccessibility, nil];
        }
    }
    return _accessibilityChildren;
}

- (NSString *)accessibilityRoleDescription {
    NSString *delegateRoleDescription = [(id)[self collectionView] _retrieveAccessibiltyRoleDescriptionFromAXDelegate];
    if (!delegateRoleDescription) {
        return _accessibilityRoleDescription;
    }
    return delegateRoleDescription;
}

- (void)setAccessibilityRoleDescription:(NSString *)accessibilityRoleDescription {
    _accessibilityRoleDescription = accessibilityRoleDescription;
}

#pragma mark - Rearranging helpers

- (NSInteger)dropPositionForPoint:(CGPoint)point withIndexPaths:(NSArray<NSIndexPath *> *)indexPaths movedToIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect withIndexPaths:(NSArray<NSIndexPath *> *)indexPaths exchangedWithIndexPaths:(NSArray<NSIndexPath *> *)exchangedIndexPaths {
    return [self layoutAttributesForElementsInRect:rect];
}

- (NSArray<UXCollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect withIndexPaths:(NSArray<NSIndexPath *> *)indexPaths movedToIndexPath:(NSIndexPath *)indexPath atPoint:(CGPoint)point {
    return [self layoutAttributesForElementsInRect:rect];
}

@end
