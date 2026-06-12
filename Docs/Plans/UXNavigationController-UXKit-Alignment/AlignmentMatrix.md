# UXNavigationController 对齐 UXKit 26.4 — 差异矩阵

## 基准

| 项 | 值 |
|---|---|
| 对齐目标 | `/System/Library/PrivateFrameworks/UXKit.framework` (macOS 26.4) |
| ObjCHeaders | `/Volumes/Code/Dump/DyldSharedCaches/macOS/26.4/UXKit/ObjCHeaders/UXNavigationController.h` |
| IDA 数据库 | `/Volumes/Code/Dump/DyldSharedCaches/macOS/26.4/UXKit.i64` |
| 现状文件 | `Sources/OpenUXKit/Components/Public/UXNavigationController.{h,m}`（.m 2563 行）、`Components/Private/UXNavigationController+Internal.h` |

## 核验范围与结论

`UXNavigationController` 是整个 UIKit-on-AppKit 移植的核心（~150 方法、2563 行）。逐方法 `decompile` + 关键路径 `disasm` 双路核验后，结论：

**核心导航逻辑已与 26.4 逐字一致，0 差异。** 已核验且完全对齐的 22 个核心方法：

- **导航栈状态机（8）**：`initWithNibName:bundle:`、`_performOrEnqueueNavigationRequest:`（含 hasOperation block）、`_checkinPushNavigationRequest:` / `_checkinPopNavigationRequest:` / `_checkinSetNavigationRequest:`、`_dequeueNavigationRequest`、`_performNavigationRequest:`
- **转场核心（6）**：`_pushViewController:transition:`、`_popToViewController:transition:`、`_setViewControllers:animated:`（含 block）、`_contextForTransitionOperation:...`、`_customAnimationControllerForOperation:...`
- **inset / toolbar 状态机（6）**：`_setLeadingContentInset:forViewController:`、`_intrinsicLayoutInsetsForChildViewController:`、`_toolbarLayoutInsetsForChildViewController:`、`_visibleToolbarOffset`、`_setToolbarHidden:subtoolbarHidden:scopeBarHidden:animated:duration:animateSubtree:`、`_updateToolbarVisibilityUsingTopViewController:...`

**差异集中在一个内聚子系统**：detached toolbars 布局 + scopeBar 视图集成 + macOS 26 (Solarium) liquid glass 工具栏外观。涉及 3 个方法 + 缺失的 getter，已全部对齐。

## 已修正的差异

| # | 位置 | 26.4 行为 | OpenUXKit 原状 | 修正 |
|---|---|---|---|---|
| D1 | `viewDidLoad` | `if (areToolbarsDetached)` 把 toolbar/subtoolbar/scopeBar 装进 `detachedBarsContainer` 并建 10 条约束；非 detached 分支也把 **scopeBar** 加进 view（`addSubview:positioned:below relativeTo:toolbar`） | 无 detached 分支；scopeBar 从不入视图；subtoolbar 在 viewDidLoad 手动创建 | 加 detached 分支 + scopeBar 入视图；改用 `self.subtoolbar`/`self.scopeBar` lazy getter |
| D2 | `updateViewConstraints` | toolbar 约束块由 `if (!areToolbarsDetached)` 守卫；块内含 **scopeBar** 约束（`scopeBarVerticalConstraint` = scopeBar.top==toolbar.top+`_scopeBarVerticalOffset`，scopeBar.left/right==toolbar） | 无守卫（detached 时仍加常规 toolbar 约束 → 与 detached container 冲突）；无 scopeBar 约束 | 加守卫 + scopeBar 约束；容器水平约束移到守卫外 |
| D3 | `_updateToolbarAppearanceUsingTopViewController:...` | macOS 26 liquid glass 语义：处理 **3 个 bar**（toolbar/subtoolbar/scopeBar 的 height/baseline/layoutMargins/visualEffects/blur/decoration）；style 1 与 detached 走统一 blur 块（clearColor + `blurMaterial:NSVisualEffectMaterialHeaderView` ×3 + **无边框**）；style 2 装 3 个 visual effect view；**任何 bar 都不再设 borderColor** | 旧语义：只处理 2 个 bar；style 1 设黑色边框（black 0.15）+ headerView blur；style 2 设 quaternaryLabel 边框 | 重写为 26.4 liquid glass 控制流 |
| D4 | getter 缺失 | `subtoolbar` 为 lazy getter（含 AX role/label）；`scopeBar` getter 含 AX role + `UXNavigationControllerScopeAXLabel`；`scopeBarVisualEffectsView` 为 lazy getter（`blendingMode:WithinWindow`、`material:ContentBackground`） | subtoolbar 靠合成 getter（viewDidLoad 创建）；scopeBar getter 缺 AX role/label；无 scopeBarVisualEffectsView getter | 加 subtoolbar lazy getter；补 scopeBar AX；加 scopeBarVisualEffectsView getter |

## `_updateToolbarAppearance` 的 26.4 控制流（核心算法）

反编译 0x1dbbaa3c8 还原的控制流（liquid glass）：

```
设置 3 个 bar 的 height/baseline（scopeBar 为新增）+ layoutMargins（scopeBar 为新增）

if (areToolbarsDetached):
    decorationInsets = preferredToolbarDecorationInsets
    → 统一 blur 块（v41=detached=1）
else:
    style = preferredToolbarStyle
    if (style == 0):
        extendedBg.hidden=YES; 移除 3 个 visualEffects; → 跳过颜色更新（LABEL_35）
    decorationInsets = preferredToolbarDecorationInsets
    if (style != 1):           // 即 style == 2
        if (style == 2): 安装 3 个 visualEffects; color=clear  (else color=nil)
        toolbar.blurEnabled=NO; barsBlur=0; → LABEL_34
    // style == 1 落入统一 blur 块（v41=detached=0）

统一 blur 块:
    color=clear; 移除 3 个 visualEffects
    toolbar.blurEnabled = !detached
    if (detached): barsBlur=0 → LABEL_34
    toolbar/subtoolbar/scopeBar.blurMaterial = headerView(10); barsBlur=1

LABEL_34（对 toolbar/subtoolbar/scopeBar 三者）:
    backgroundColor=color; borderColor=nil; bordered=NO; decorationInsets=insets
    subtoolbar/scopeBar.blurEnabled = barsBlur
    extendedBg.hidden = barsBlur

LABEL_35:
    if (animated && 高度变化): 动画 3 个 bar layoutSubtreeIfNeeded
```

关键差异点：26.4 **没有任何 borderColor**（全 nil / bordered=NO），改用 blur material 表达层次——这正是 macOS 26 liquid glass 的核心变化。

## 验证

- `swift build`、`swift build --target UXKit`（TBD shim）均 0 错误
- `swift test` 30 个测试全绿
