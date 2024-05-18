//
//  ViewController.m
//  UXKit-Example
//
//  Created by JH on 2024/2/2.
//

#import "ViewController.h"
#import "UXKit.h"
#import <objc/runtime.h>
#import "UXViewAnimationContext.h"
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
static int globalIndex = 0;
// 递归函数，打印类及其父类的ivar，包括名称和全局索引
void printIvarsOfClassRecursively(Class cls) {
    // 基线条件：当到达根类NSObject时停止，这次我们不在NSObject停止，而是在其之后处理
    if (cls == nil) {
        return;
    }
    
    // 首先递归调用父类，确保从根类开始
    printIvarsOfClassRecursively(class_getSuperclass(cls));
    
    // 获取当前类的ivar列表
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList(cls, &count);
    for (unsigned int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        const char *name = ivar_getName(ivar);
        printf("Class %s: ivar[%d][offset: %"PRIdPTR"]: %s\n", class_getName(cls), globalIndex++, ivar_getOffset(ivar), name);
    }
    free(ivarList);
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.contentBox.contentView addSubview:self.contentNavigationController.view];
    self.viewControllers = @[
        self.firstViewController,
        self.secondViewController,
        self.thirdViewController,
    ].mutableCopy;
    printIvarsOfClassRecursively([_UXSourceSplitItemView class]);
    NSView *itemView = [NSView new];
    [itemView performSelector:NSSelectorFromString(@"_setSemanticContext:") withObject:@(7)];
    NSLog(@"%@", [itemView performSelector:NSSelectorFromString(@"_semanticContext")]);
//    NSLog(@"%@", [UXNavigationController topViewControllerObservationKeyPathsByContext]);
//    _UXLayoutSpacer *spacer = [_UXLayoutSpacer _verticalLayoutSpacer];
//    NSLog(@"%@", spacer);
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
