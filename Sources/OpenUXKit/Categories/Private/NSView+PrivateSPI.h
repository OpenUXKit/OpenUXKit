//
//  NSView+PrivateSPI.h
//  OpenUXKit
//
//  Created by JH on 2024/5/18.
//

#import <Cocoa/Cocoa.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSView (PrivateSPI)
@property (nonatomic, setter=_setSemanticContext:) NSInteger _semanticContext;
@property CGAffineTransform frameTransform;
- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event;
- (void)_startLiveResize;
- (void)_endLiveResize;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
