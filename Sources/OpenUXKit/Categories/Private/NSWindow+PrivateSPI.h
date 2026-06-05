//
//  NSWindow+PrivateSPI.h
//  OpenUXKit
//
//  Created by JH on 2024/5/18.
//

#import <Cocoa/Cocoa.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@protocol NSSplitViewItemSeparatorTrackingAdapter;

@interface NSWindow (PrivateSPI)
- (void)unregisterSplitViewItemSeparatorTrackingAdapter:(id<NSSplitViewItemSeparatorTrackingAdapter>)adapter;
- (void)registerSplitViewItemSeparatorTrackingAdapter:(id<NSSplitViewItemSeparatorTrackingAdapter>)adapter;
- (void)_sidebarProviderWillRemoveFromWindow:(NSView *)sidebarProvider;
- (void)_sidebarAdapterWasAddedToWindow:(NSView *)sidebarAdapter;
- (NSRect)contentRectForFrameRect:(NSRect)rect styleMask:(NSWindowStyleMask)styleMask;
- (BOOL)_hasActiveAppearanceIgnoringKeyFocus;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
