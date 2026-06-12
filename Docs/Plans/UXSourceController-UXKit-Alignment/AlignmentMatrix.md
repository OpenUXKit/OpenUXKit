# UXSourceController 对齐 UXKit 26.4 — 差异矩阵

## 基准

| 项 | 值 |
|---|---|
| 对齐目标 | `/System/Library/PrivateFrameworks/UXKit.framework` (macOS 26.4) |
| ObjCHeaders | `/Volumes/Code/Dump/DyldSharedCaches/macOS/26.4/UXKit/ObjCHeaders/UXSourceController.h` |
| IDA 数据库 | `/Volumes/Code/Dump/DyldSharedCaches/macOS/26.4/UXKit.i64` |
| 现状文件 | `Sources/OpenUXKit/Components/Public/UXSourceController.{h,m}`、`Components/Private/UXSourceController+Internal.h` |

接口层（`.h` / `+Internal.h`）此前已对齐，ivar 集合、方法签名、属性 readonly/strong/copy 修饰均与 26.4 一致。本轮聚焦 `.m` 实现的**语义对齐**。逐方法（约 70 个）做了 `decompile` + 关键路径 `disasm` 双路验证。

## 结论：5 处实现差异，已全部修正

| # | 方法 | 26.4 行为 | OpenUXKit 原状 | 严重度 |
|---|---|---|---|---|
| D1 | `navigationController`（override） | `return self.selectedNavigationController;`（`B _objc_msgSend$selectedNavigationController` 尾调用） | `return nil;` | 高（功能缺失） |
| D2 | `navigateToDestination:animated:completion:` | operation block 内 `dispatch_async` 到 **main queue** 执行 `_navigateToDestination:`，再 `dispatch_semaphore_wait` 阻塞 operation 直到完成 | 直接在 operation block（后台线程）调用 `_navigateToDestination:` | 高（线程语义错误） |
| D3 | `navigateToDestination:animated:useFallbackDestinationIfNeeded:completion:` | operation block 内 `dispatch_block_create` + `dispatch_async` main + `dispatch_block_wait` | 直接在后台线程调用 | 高（线程语义错误） |
| D4 | `removeDestination:animated:completion:` | operation block 内 semaphore + `dispatch_async` main + `dispatch_semaphore_wait` | 直接在后台线程调用 | 高（线程语义错误） |
| D5 | `_leadingContentInsetForWantsCollapsed:` | 顶部多一个 `_UXSolariumEnabled()` 闸门：Solarium 启用时 inset 恒为 0 | 缺少 Solarium 检查 | 中（26.4 布局偏移） |

另有 1 处**语义等价**的细节，为忠实复刻一并对齐：

| # | 方法 | 说明 |
|---|---|---|
| D6 | `observeValueForKeyPath:` 的 `kCollapsedObserverContext` 异步 block | 26.4：`[sidebarSplitViewItem setCollapsed:self.wantsSourceListCollapsed]`；原状硬编码 `setCollapsed:NO`。进入该 block 的前置条件已保证 `wantsSourceListCollapsed == NO`，故行为等价，但改为读取属性更贴合反编译。 |

## 关键算法笔记

### D2/D4 队列同步模式（navigate / remove）

`_viewControllerOperations` 是 `maxConcurrentOperationCount = 1` 的**后台** NSOperationQueue。26.4 用「后台串行 operation + 主线程派发 + 信号量回灌」三段式保证：

1. 导航请求串行（前一个完成才执行下一个）——由 operation queue 串行性提供；
2. 真正的 `_navigateToDestination:` / `_removeDestination:`（操作视图层级、KVO、约束）在 **main thread** 执行——由 `dispatch_async(main)` 提供；
3. operation 不提前结束——由 `dispatch_semaphore_wait(FOREVER)` 提供，信号量在 `_navigateToDestination:` 的 completion 回调里 `signal`。

反编译路径（navigate）：
- `-[navigateToDestination:animated:completion:]` (0x1dbbf6a84) → `addOperationWithBlock:`
- block_invoke (0x1dbbf6b70)：`sema = dispatch_semaphore_create(0)` → `dispatch_async(main, block_invoke_2)` → `dispatch_semaphore_wait(sema, FOREVER)`
- block_invoke_2 (0x1dbbf6c5c)：`[self _navigateToDestination:dst animated:a completion:block_invoke_3]`
- block_invoke_3 (0x1dbbf6d24)：`if (userCompletion) userCompletion(); dispatch_semaphore_signal(sema);`（忽略 `_navigateToDestination` 回传的 `finished`，调用**无参** `UXCompletionHandler`）

remove 同构（0x1dbbf5a64 / 0x1dbbf5b50 / 0x1dbbf5c3c / 0x1dbbf5d04），用同样的 semaphore。

### D3 useFallback 的 dispatch_block 双用法

`-[...useFallbackDestinationIfNeeded:completion:]` (0x1dbbf665c) 没用裸 semaphore，而是用一个 `dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, completionBlock)` 同时承担「调用用户 completion」和「`dispatch_block_wait` 目标」两个角色：

- block_invoke_2 (0x1dbbf6760)：`completionBlock = dispatch_block_create(..., ^{ userCompletion(); })` → `dispatch_async(main, block_invoke_162)` → `dispatch_block_wait(completionBlock, FOREVER)`
- block_invoke_162 (0x1dbbf68a8)：`[self _navigateToDestination:dst animated:a completion:block_invoke_2_163]`
- block_invoke_2_163 (0x1dbbf696c)：
  ```
  if (finished || !useFallback) { completionBlock(); }
  else { [self _navigateToDestination:self.fallbackNavigationDestination animated:a completion:^(BOOL){ completionBlock(); }]; }
  ```
执行 `completionBlock()`（一个 `dispatch_block_create` 出来的块）既调用了用户 completion，又满足了 `dispatch_block_wait`。

### D5 `_UXSolariumEnabled()`

`_UXSolariumEnabled` (0x1dbbee6d8) = `os_feature_enabled(SwiftUI, Solarium)`，dispatch_once 缓存：

```c
___UXSolariumEnabled_block_invoke:
    _UXSolariumEnabled.isEnabled = _os_feature_enabled_impl("SwiftUI", "Solarium");
```

`_leadingContentInsetForWantsCollapsed:` (0x1dbbf7fc8) 顶部：
```
if ((wantsCollapsed & 1) == 0 && (Solarium & 1) == 0 && !isSourceListAutoCollapsed) { ...compute... }
return 0.0;  // 否则
```
即 macOS 26 Solarium（液态玻璃）外观下，detail 内容延伸到浮动 sidebar 之下，leading inset 恒为 0。OpenUXKit 在 26.4 上运行时应返回 0 以对齐。

## 已确认一致（无需改动）的代表方法

`initWithNibName:bundle:`（QoS=UserInitiated(25)、detail minThickness 550、accessory 500×32、inspector canCollapse=NO+collapsed=YES）、`viewWillAppear`/`viewDidAppear`/`viewWillDisappear`/`viewDidLoad`、`setSourceListViewController:`、`_preferredSourceListWidth`、`_setSelectedViewController:animated:sender:`（transition 103/102）、`_contextForTransitionOperation:...`、`_beginTransitionWithContext:operation:`（styleMask/collectionBehavior 临时清位 + 强制启用窗口按钮 + completionHandler 重建约束）、`_setupDelegateForNavigationController:...`、`navigationController:animationControllerForOperation:...`、`navigationController:interactionControllerForAnimationController:`、`navigationController:shouldBeginInteractivePop...`、`navigationController:willShowViewController:`（含两 block）、`navigationController:didShowViewController:`、`currentNavigationDestination`、`_addRootViewController:` / `_removeRootViewController:`、`_prepareTransitionToRootViewController:`、`_navigateToDestination:` / `_removeDestination:` 主体、`presentViewController:` / `dismissViewController:`、collapse 系列、`toggleSidebar:`、`validateUserInterfaceItem:`、`splitView:effectiveRect:...`（divider index 1 → CGRectZero）、`invalidateIntrinsicLayoutInsets`、`topLayoutGuide`/`bottomLayoutGuide`、`transitionCoordinator`、`contentRepresentingViewController`、`isNavigating`、`dealloc`/`setObservedWindow:`/`setObservedNavigationController:` 等。
