#import <AppKit/AppKit.h>
#import "_UXContainerView.h"
#import "UXKitDefines.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

NS_SWIFT_UI_ACTOR
@protocol NSSplitViewItemSeparatorTrackingAdapter <NSObject>

@property (readonly) CGRect splitFrame;
@property (readonly) NSTitlebarSeparatorStyle titlebarSeparatorStyle;
@property (readonly) BOOL isSidebar;

@optional
@property (readonly) BOOL isTrailingSidebar;

@end

UXKIT_PRIVATE NS_SWIFT_UI_ACTOR
@interface _UXSourceSplitItemView : _UXContainerView <NSSplitViewItemSeparatorTrackingAdapter>

@property (nonatomic) BOOL isRegisteredWithTitlebar;
@property (nonatomic) CGFloat dividerPosition;
@property (readonly) BOOL isTrailingSidebar;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
