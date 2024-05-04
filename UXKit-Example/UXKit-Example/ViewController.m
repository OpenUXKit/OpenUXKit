//
//  ViewController.m
//  UXKit-Example
//
//  Created by JH on 2024/2/2.
//

#import "ViewController.h"
#import <OpenUXKit/OpenUXKit.h>

@interface ViewController () <UXNavigationControllerDelegate>
@property (strong) IBOutlet NSButton *pushButton;
@property (strong) IBOutlet NSButton *popButton;
@property (strong) IBOutlet NSBox *contentBox;
@property (nonatomic, strong) UXNavigationController *contentNavigationController;
@property (nonatomic, strong) UXViewController *rootViewController;
@property (nonatomic, strong) UXViewController *firstViewController;
@property (nonatomic, strong) UXViewController *secondViewController;
@property (nonatomic, strong) UXViewController *thirdViewController;
@property (nonatomic, strong) NSMutableArray<UXViewController *> *viewControllers;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.contentBox.contentView addSubview:self.contentNavigationController.view];
    self.viewControllers = @[
        self.firstViewController,
        self.secondViewController,
        self.thirdViewController,
    ].mutableCopy;
}



- (void)viewWillAppear {
    [super viewWillAppear];
    
    self.contentNavigationController.view.frame = self.contentBox.bounds;
}

- (IBAction)pushButtonAction:(NSButton *)sender {
    if (self.contentNavigationController.viewControllers.count > self.viewControllers.count) {
        
    } else {
        [self.contentNavigationController pushViewController:self.viewControllers[self.contentNavigationController.viewControllers.count - 1] animated:YES];
    }
    [self checkButtonEnabled];
}
- (IBAction)popButtonAction:(NSButton *)sender {
    [self.contentNavigationController popViewControllerAnimated:YES];
    [self checkButtonEnabled];
}


- (void)checkButtonEnabled {
    self.pushButton.enabled = self.contentNavigationController.viewControllers.count <= self.viewControllers.count;
    self.popButton.enabled = self.contentNavigationController.viewControllers.count > 1;
}


- (void)navigationController:(UXNavigationController *)navigationController willShowViewController:(UXViewController *)viewController {
    [self checkButtonEnabled];
}


- (UXNavigationController *)contentNavigationController {
    if (_contentNavigationController == nil) {
        _contentNavigationController = [[UXNavigationController alloc] initWithRootViewController:self.rootViewController];
        _contentNavigationController.delegate = self;
    }
    return _contentNavigationController;
}

- (UXViewController *)rootViewController {
    if (_rootViewController == nil) {
        _rootViewController = [[UXViewController alloc] initWithNibName:nil bundle:nil];
        [_rootViewController.uxView setBackgroundColor:NSColor.blackColor];
    }
    return _rootViewController;
}

- (UXViewController *)firstViewController {
    if (_firstViewController == nil) {
        _firstViewController = [[UXViewController alloc] initWithNibName:nil bundle:nil];
        [_firstViewController.uxView setBackgroundColor:NSColor.systemRedColor];
    }
    return _firstViewController;
}

- (UXViewController *)secondViewController {
    if (_secondViewController == nil) {
        _secondViewController = [[UXViewController alloc] initWithNibName:nil bundle:nil];
        [_secondViewController.uxView setBackgroundColor:NSColor.systemBlueColor];
    }
    return _secondViewController;
}


- (UXViewController *)thirdViewController {
    if (_thirdViewController == nil) {
        _thirdViewController = [[UXViewController alloc] initWithNibName:nil bundle:nil];
        [_thirdViewController.uxView setBackgroundColor:NSColor.systemCyanColor];
    }
    return _thirdViewController;
}


@end
