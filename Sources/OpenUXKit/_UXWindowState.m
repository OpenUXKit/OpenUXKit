//
//  _UXWindowState.m
//  
//
//  Created by JH on 2024/4/21.
//

#import <Foundation/Foundation.h>
#import "_UXWindowState.h"

@interface _UXWindowState ()
{
    NSWindowStyleMask _styleMask;    // 8 = 0x8
    NSWindowCollectionBehavior _collectionBehavior;    // 16 = 0x10
}
@end

@implementation _UXWindowState

+ (instancetype)windowStateWithStyleMask:(NSWindowStyleMask)styleMask collectionBehavior:(NSWindowCollectionBehavior)collectionBehavior {
    _UXWindowState *windowState = [[self alloc] init];
    windowState->_styleMask = styleMask;
    windowState->_collectionBehavior = collectionBehavior;
    return windowState;
}

- (void)applyToWindow:(NSWindow *)window {
    window.styleMask = _styleMask;
    window.collectionBehavior = _collectionBehavior;
}

@end
