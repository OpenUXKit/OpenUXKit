//
//  AppDelegate.m
//  Example
//
//  Created by JH on 2024/2/26.
//

#import "AppDelegate.h"
@import OpenUXKit;
@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    UXViewController *viewController = [[UXViewController alloc] init];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
