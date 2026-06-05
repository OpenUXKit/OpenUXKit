#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@protocol UXLayoutSupport <NSObject>

@property (readonly) NSLayoutDimension *heightAnchor;
@property (readonly) NSLayoutYAxisAnchor *bottomAnchor;
@property (readonly) NSLayoutYAxisAnchor *topAnchor;
@property (nonatomic) CGFloat length;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
