#import <Foundation/Foundation.h>
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class _UXFlowLayoutInfo, _UXFlowLayoutItem, _UXFlowLayoutRow;

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXFlowLayoutSection : NSObject

@property (nonatomic, readonly) NSMutableArray<_UXFlowLayoutItem *> *items;
@property (nonatomic, readonly) NSMutableArray<_UXFlowLayoutRow *> *rows;
@property (nonatomic) CGFloat verticalInterstice;
@property (nonatomic) CGFloat horizontalInterstice;
@property (nonatomic) NSEdgeInsets sectionMargins;
@property (nonatomic) CGRect frame;
@property (nonatomic) CGRect headerFrame;
@property (nonatomic) CGRect footerFrame;
@property (nonatomic) CGFloat headerDimension;
@property (nonatomic) CGFloat footerDimension;
@property (nonatomic, assign, nullable) _UXFlowLayoutInfo *layoutInfo;
@property (nonatomic, strong, nullable) NSDictionary *rowAlignmentOptions;
@property (nonatomic) BOOL fixedItemSize;
@property (nonatomic) CGSize itemSize;
@property (nonatomic, readonly) CGFloat otherMargin;
@property (nonatomic, readonly) CGFloat beginMargin;
@property (nonatomic, readonly) CGFloat endMargin;
@property (nonatomic, readonly) CGFloat actualGap;
@property (nonatomic, readonly) CGFloat lastRowBeginMargin;
@property (nonatomic, readonly) CGFloat lastRowEndMargin;
@property (nonatomic, readonly) CGFloat lastRowActualGap;
@property (nonatomic, readonly) BOOL lastRowIncomplete;
@property (nonatomic) NSInteger itemsCount;
@property (nonatomic, readonly) NSInteger itemsByRowCount;
@property (nonatomic, readonly) NSInteger indexOfImcompleteRow;

- (_UXFlowLayoutItem *)addItem;
- (_UXFlowLayoutRow *)addRow;
- (void)computeLayout;
- (void)recomputeFromIndex:(NSInteger)index;
- (void)invalidate;
- (_UXFlowLayoutSection *)snapshot;
- (_UXFlowLayoutSection *)copyFromLayoutInfo:(nullable _UXFlowLayoutInfo *)layoutInfo;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
