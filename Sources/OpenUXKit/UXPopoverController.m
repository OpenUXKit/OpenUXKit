//
//  UXPopoverController.m
//  
//
//  Created by JH on 2024/4/21.
//

#import <Foundation/Foundation.h>
#import "UXPopoverController.h"

@interface UXPopoverController ()
{
    UXPopover *_popover;    // 16 = 0x10
    __weak id <UXPopoverControllerDelegate> _delegate;    // 24 = 0x18
    NSArray *_passthroughViews;    // 32 = 0x20
}
@end


@implementation UXPopoverController



@end
