//
//  UXBase.m
//  OpenUXKit
//
//  Created by JH on 2026/5/26.
//

#import "UXBase.h"

@interface UXBundleClass : NSObject
@end

@implementation UXBundleClass
@end

NSString * UXLocalizedString(NSString *key) {
    NSBundle *currentBundle = [NSBundle bundleForClass:[UXBundleClass class]];

    return [currentBundle localizedStringForKey:key value:nil table:nil];
}
