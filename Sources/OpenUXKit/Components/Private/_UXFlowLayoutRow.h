#import <Foundation/Foundation.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class _UXFlowLayoutSection, _UXFlowLayoutItem;

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXFlowLayoutRow : NSObject

@property (nonatomic, assign, nullable) _UXFlowLayoutSection *section;
@property (nonatomic) CGSize rowSize;
@property (nonatomic) CGRect rowFrame;
@property (nonatomic) NSInteger index;
@property (nonatomic, readonly) NSMutableArray<_UXFlowLayoutItem *> *items;
@property (nonatomic) BOOL complete;
@property (nonatomic) BOOL fixedItemSize;

- (void)addItem:(_UXFlowLayoutItem *)item;
- (void)layoutRow;
- (void)invalidate;
- (_UXFlowLayoutRow *)snapshot;
- (_UXFlowLayoutRow *)copyFromSection:(nullable _UXFlowLayoutSection *)section;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
