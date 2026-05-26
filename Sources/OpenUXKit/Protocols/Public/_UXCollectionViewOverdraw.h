#import <Foundation/Foundation.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

NS_SWIFT_UI_ACTOR
@protocol _UXCollectionViewOverdraw <NSObject>

@required
@property (nonatomic) BOOL overdrawEnabled;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
