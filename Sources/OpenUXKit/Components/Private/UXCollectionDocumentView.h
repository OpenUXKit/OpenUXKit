#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXCollectionView;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXCollectionDocumentView : NSView

@property (nonatomic, weak, nullable) UXCollectionView *collectionView;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
