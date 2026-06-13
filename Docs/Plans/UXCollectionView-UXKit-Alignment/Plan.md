# UXCollectionView 家族 1:1 对齐 UXKit 重构方案

## Context

OpenUXKit 当前 `UXCollectionView*` 家族已有 50+ 个 .h/.m（公共 5,297 行 + 私有 3,652 行 ≈ 9,000 行），类名与 UXKit 私有框架的 37 个相关类已基本对齐，关键 ivar（`_collectionViewDataFlags` / `_invalidatedSupplementaryViews` / `_globalItems` / `_screenPageMap` / `_currentUpdate`）也都存在。问题不在"形"，在"神"——内部算法、状态机、隐藏数据结构（如 `_UXFlowLayoutInfo`）与 UXKit 真实实现差距很大，git log 上最近的 commits 还在修 `flow layout` 与 `dataSource calls` 的功能性 bug。

用户要求 **1:1 复刻包括内部数据结构和状态机**，方式为 **分子系统增量替换**（每替换完一个子系统，仓库保持可编译、6 个 Examples Showcase 可跑）。4 大痛点全部命中：Flow Layout 几何 / batchUpdates 行为 / Selection（含 lasso / painting） / Rearranging 拖放协调器。

本方案的预期产出：一份按子系统拆分、12 周可执行、有验证手段和回滚策略的实施蓝图，使 OpenUXKit 的 UXCollectionView 子系统行为与 macOS 26.4 上的 UXKit 私有框架在语义/状态机层面对齐。

---

## 基准版本

| 项 | 值 |
|---|---|
| 对齐目标 | `/System/Library/PrivateFrameworks/UXKit.framework` (macOS 26.4) |
| ObjCHeaders | `/Volumes/RE/Dyld-Shared-Cache/macOS/26.4/UXKit/ObjCHeaders/` （37 个相关 .h） |
| IDA 数据库 | `/Volumes/RE/Dyld-Shared-Cache/macOS/26.4/UXKit.i64` |
| 反编译工具 | `mcp__plugin_ida-pro_idalib__*` MCP 工具系列 |

校准说明：用户原话提到 macOS 26.5，但 26.5 目录下没有 UXKit 导出材料；26.4 是最新的"完整可对齐"基准。OpenUXKit 是独立实现（不链 UXKit ABI），跨 OS 版本对 OpenUXKit target 无影响；UXKit target（TBD 桥接）会在运行时做 ivar 存在性 sanity check。

---

## 子系统划分（8 组）

| ID | 子系统 | 代表类 | 当前文件数 | 痛点对应 |
|---|---|---|---|---|
| **S1a** | 叶子 token | UpdateItem / _UXCollectionViewItemKey / SectionItemIndexes / Animation（单项） | 4 | — |
| **S1b** | ReusableView 生命周期 | UXCollectionReusableView / UXCollectionViewCell / _UXCollectionSnapshotView | 3 | — |
| **S2** | Layout 几何与失效化 | UXCollectionViewLayout / FlowLayout / LayoutAttributes / InvalidationContext / FlowLayoutInvCtx / _UXFlowLayoutInfo(**新增**) / _UXCollectionViewLayoutProxy | 7 | Flow Layout |
| **S3a** | Data 缓存 | UXCollectionViewData | 1 | Flow Layout |
| **S3b** | Update / Gap 增量 | UXCollectionViewUpdate / UpdateGap / UpdateItem._gap | 3 | batchUpdates |
| **S4** | IndexPathsSet 选区数据 | IndexPathsSet / MutableIndexPathsSet / SectionItemIndexes | 3 | Selection |
| **S5** | Animation 整体 | UXCollectionViewAnimation / AnimationContext | 2 | batchUpdates |
| **S6** | Rearranging 拖放 | _UXCollectionViewRearrangingCoordinator / LayoutProxy / PanGestureRecognizer / FilePromiseProvider | 4 | Rearranging |
| **S7** | Accessibility | LayoutAccessibility / LayoutSectionAccessibility | 2 | — |
| **S8** | 主类粘合层 | UXCollectionView / _UXCollectionView / DocumentView / _UXCollectionDocumentView / ClipView | 5 | Flow Layout / batchUpdates / Selection |

---

## 依赖关系图

```
                        [S0 协议/常量层]
                              │
              ┌───────────────┴────────────────┐
              ▼                                ▼
        [S1a 叶子 token]                [S1b ReusableView]
              │                                │
              ▼                                │
    ┌────────────────────────┐                │
    │ S2 Layout / Attributes │◄───[S2.5 LayoutProxy]
    │   FlowLayout            │
    │   _UXFlowLayoutInfo(新) │
    └─────────┬──────────────┘
              │
              ▼
       [S3a Data 缓存]
              │
              ▼
       [S3b Update / Gap]
              │
              ▼
       [S4 IndexPathsSet]
              │
              ▼
       [S5 AnimationContext]
              │
              ▼
       ┌──────────────────────────────┐
       │ S8 主类 UXCollectionView      │◄──── S1b reuse
       │   + DocumentView / ClipView   │
       └──────────────┬───────────────┘
                      ▼
       ┌──────────────────────────────┐
       │ S6 RearrangingCoordinator     │
       └──────────────┬───────────────┘
                      ▼
       ┌──────────────────────────────┐
       │ S7 Accessibility (末班车)      │
       └──────────────────────────────┘
```

**最大 fan-out 节点**：`UXCollectionViewLayoutAttributes`（S2）的 ivar 牵连 ReusableView 的 `_setBaseLayoutAttributes:`、Data 的缓存、Animation 的 finalLayoutAttributes、Layout 的 initialLayoutAttributesFor*、Rearranging 的 layoutAttributesForElementsInRect:withIndexPaths: → 必须在 P2 阶段（最早）冻结。

**双向闭环**：Layout ↔ Data 之间 Layout 的 `_finalizeCollectionViewItemAnimations` 写回 Data 的 `_invalidatedSupplementaryViews`，Data 的 `prepareLayout` 又调 Layout → **必须在同一 phase（P3-P5 串联）一次性切换**。

---

## 12 阶段时间线

> **实施进度**（逐方法验证状态以 [`AlignmentMatrix.md`](./AlignmentMatrix.md) 的「Phase 完成总览」为准）：
> P0/P1/P5/P6/P7/P8/P9d/P11 已完全反编译验证；P4/P9/P10 主体对齐留明确余量；P2/P3 形式对齐。
> 反编译笔记见 `IDA-Notes/P{5,6,7,8,9,9d,10,11}-*.md`。状态：✅ 验证 ｜ 🟡 部分（有余量）｜ 🟢 形式对齐。

| Phase | 子系统 | 内容 | 状态 | 关键产物 |
|---|---|---|---|---|
| **P0** | — | 反编译笔记 + 37 类对照矩阵 + Tests 脚手架（30 用例） | ✅ | T7 视觉基线待用户 |
| **P1** | S1a | UpdateItem / ItemKey / SectionItemIndexes / Animation 单项 | ✅ | compare / `_action` 对齐 |
| **P2** | S2 (Attrs) | LayoutAttributes + LayoutInvalidationContext | 🟢 | ivar 矩阵已冻结，未逐句 verify |
| **P3** | S2 (Layout 基类) | UXCollectionViewLayout + 13 个 ivar | 🟢 | transition 字段形式对齐 |
| **P4** | S2 (FlowLayout) | FlowLayout + FlowLayoutInvCtx + `_UXFlowLayout*` 4 类 | 🟡 | 算法已对齐，保留 2 处简化 |
| **P5** | S3a | UXCollectionViewData | ✅ | `P5-Data.md`，51 方法 + screen-page |
| **P6** | S1b | ReusableView + Cell + SnapshotView | ✅ | `P6-ReusableView.md` |
| **P7** | S4 | IndexPathsSet + Mutable + adjust* | ✅ | `P7-IndexPathsSet.md`，60 方法 |
| **P8** | S3b + S5 | Update + Gap + Animation + AnimationContext | ✅ | `P8-UpdateAnimation.md`，`_computeGaps` 修复 |
| **P9** | S8 | UXCollectionView 主类 + 视图层次 | 🟡 | P9a/b/c/d（batchUpdates / 可见视图 / Selection / reuse / scroll / 事件路由 / **动画跨布局 transition**）已对齐；余量：动画插值视觉效果不可无头验证（`P9d-LayoutTransition.md`） |
| **P10** | S6 | Rearranging 拖放 | 🟡 | P10a 状态机已反编译；余量 P10b：NSDragging 重写（需交互验证） |
| **P11** | S7 | Accessibility | ✅ | `P11-Accessibility.md`，2 类 52 方法 |

### 里程碑
- **M1 (P3 末)** ✅ 达成：Layout 基类形式对齐（ivar/transition 字段冻结）
- **M2 (P5 末)** ✅ 达成：Flow Layout + Data 痛点主体清除（P4 留 2 处简化）
- **M3 (P9 末)** ✅ 达成：痛点 1-3（Flow / batchUpdates / Selection）清除；P9a/b/c/d 全部对齐（含动画跨布局 transition，`P9d-LayoutTransition.md`）
- **M4 (P11 末)** 🟡 接近：仅余 P10b 拖放（需交互拖放手测）+ 各阶段不可无头验证的视觉/交互效果（动画插值、拖放）

---

## 首批要动（P0 + P1 + P2，第 1 周）

**为什么不直接攻击痛点**：4 大痛点都依赖更底层的 LayoutAttributes / Data / IndexPathsSet。如果先动 FlowLayout 或 batchUpdates，会发现底层 ivar/接口不稳，被迫回头改 → 双重工作。自下而上不会比痛点优先慢，但风险显著低。

### P0 必做项（0.5 周）

1. **反编译笔记**：用 `mcp__plugin_ida-pro_idalib__open_file` 打开 26.4 UXKit.i64，对下列 9 个核心方法逐个用 `decompile` + `disasm` 双路验证，写笔记到 `.claude/plans/uxcollection-ida-notes/`：
   - `_computeGaps` / `_computeItemUpdates` / `_computeSectionUpdates` / `_computeSupplementaryUpdates`（S3b 痛点根源）
   - `_fetchItemsInfo` / `_getSizingInfos` / `_updateItemsLayout` / `_frameForItemAtSection:andRow:usingData:`（S2 FlowLayout 痛点根源）
   - `_loadEverything` / `_validateContentSize`（S3a）

2. **37 类对照矩阵**：写 `.claude/plans/uxcollection-alignment-matrix.md`，每行：UXKit 类名 / OpenUXKit 文件路径 / ivar 对照（√/×/部分） / 方法对照（计数）/ 状态（待重写/已对齐/桥接中）。

3. **Tests 脚手架** ：在 `Tests/OpenUXKitTests/Collection/` 下新建 6 个 swift 测试文件（IndexPathsSet / UpdateGapAlgorithm / FlowLayoutGeometry / PerformBatchUpdates / SelectionAlgorithm / **UXKitParity**），前 5 个先放 stub 测试，UXKitParity 写跨 OpenUXKit/UXKit target 的对比框架（伪代码 OK）。

4. **Showcase 视觉基线**：手工录 6 个 Showcase 截图 + 30s 交互视频，存 `.claude/plans/snapshots/P0-baseline/`，作为后续 phase 对照。

5. **公开符号合同**：grep Examples 引用的 13 个公开符号（UXCollectionView / FlowLayout / FlowLayoutInvalidationContext / Cell / ReusableView / DataSource / Delegate / DelegateFlowLayout / ElementKindSectionHeader / Footer 等），写入对照矩阵的 "公开 API 合同" 章节——这些只能扩展不能改名。

### P1 内容（0.5 周）

按 9 步工作流（D/A/M/C/B/R/V/G/L 见第 5 节）重写：
- `UXCollectionViewUpdateItem` 的 `compareIndexPaths:` / `inverseCompareIndexPaths:`（lexicographic 比较 + section vs item operation 优先级）
- `_UXCollectionViewItemKey` 的 `_hash` 缓存策略（indexPath + type + identifier 组合）
- `_UXCollectionViewSectionItemIndexes` 暂仅对齐接口（adjust* 算法留到 P7 与 S4 一起做）
- `UXCollectionViewAnimation` 仅单项 init / fraction 字段（handlers 数组留到 P8）

### P2 内容（0.5 周）

- `UXCollectionViewLayoutAttributes`：重点是 `_isEquivalentTo:`（减少重复 apply）和 `_isTransitionVisibleTo:`（决定 transition 期间是否触发动画）的语义
- `UXCollectionViewLayoutInvalidationContext`：重点是 `_setInvalidateEverything:` / `_invalidatedSupplementaryViews` 的写入路径
- **冻结 ivar 矩阵**：把 LayoutAttributes 的 22 个 ivar + 8 个内部方法的命名定稿，后续 phase 只能扩展

---

## 每个子系统的「对齐重点」（核心算法/状态机）

### S1a 叶子 token (P1)
- `compareIndexPaths:`：lexicographic 比较，section 操作优先于 item 操作
- `_UXCollectionViewItemKey._hash`：indexPath+type+identifier 组合缓存

### S2 Layout (P2-P4)
- LayoutAttributes：`_isEquivalentTo:` / `_isTransitionVisibleTo:` 语义
- Layout 基类：`_invalidationContext` 单例字段（多次 invalidate 聚合而非新建）；`prepareForTransition*` 双阶段（_prepareFor* 建字典，再正式 prepareFor*）
- **FlowLayout 三连**：`_fetchItemsInfo`（拉 delegate sizes 写入 `_UXFlowLayoutInfo`）→ `_getSizingInfos`（汇总 section header/footer 几何）→ `_updateItemsLayout`（按 line wrap 计算 frame）
- **layoutDataIsValid + delegateInfoIsValid** 双 flag 失效组合矩阵（delegate 失效强制 data 失效，反之不行）
- **`_UXFlowLayoutInfo`（新增）**：UXKit 头文件未暴露但 ivar offset 288 真实存在的内部数据结构，从反编译反推字段

### S3a Data (P5)
- `_loadEverything` 5 步：清缓存 → pull counts → 建 `_sectionItemCounts` C 数组 → 建 `_globalItems` C 数组 → 触发 layout.prepareLayout → 标 layoutIsPrepared=YES
- 4 个 flag 状态机：`contentSizeIsValid` / `itemCountsAreValid` / `layoutIsPrepared` / `layoutLocked`
- `_setupMutableIndexPath:forGlobalItemIndex:`：性能关键，写入预分配 mutable indexPath

### S1b ReusableView (P6)
- `applyLayoutAttributes:` 分两阶段：`_setBaseLayoutAttributes:`（frame/bounds/center/transform/alpha/hidden/zIndex）+ 子类 hook
- `wasDequeued` 1 bit + `updateAnimationCount` 5 bit 位段

### S4 IndexPathsSet (P7)
- 双层结构：`NSMutableIndexSet * _sectionIndexes` + `NSMutableDictionary<NSNumber*, _UXCollectionViewSectionItemIndexes*>`
- `intersectIndexPathsSet:`：先 section 求交，再 item indexes 求交
- `adjustForDeletionOfSection:`：删 sectionIndexes 项 + 把 section > deleted 的 key 向下 shift

### S3b Update / Gap + S5 (P8)
- **`_computeGaps`（最关键算法）**：扫描已排序 updateItems，把"删一段、插一段"合并成单个 UpdateGap（gap 持 firstUpdateItem/lastUpdateItem/deleteItems/insertItems）—— UXKit 用此优化减少动画数量，**也是用户感觉 batchUpdates 行为"不一样"的根本原因**
- `_computeItemUpdates`：构建 N×1 全局映射数组 `_oldGlobalItemMap`/`_newGlobalItemMap`；Move 拆成 delete+insert pair（标 _isMove 在 UpdateItem._gap）
- `_computeSupplementaryUpdates`：对每个 known supplementary kind 单独算 deleted/inserted 数组
- Animation 4 flag 控制 startup/completion handler 副作用顺序

### S8 主类 (P9)
- `performBatchUpdates:completion:` 9 步：`_beginUpdates` → 执行 update block → `_updateWithItems:` → `_prepareLayoutForUpdates` → `_setupCellAnimations` → `_endUpdates` → 启动动画 → callback → cleanup
- Selection 算法 4 路分支组合（extending? × animated? × notify?）+ Lasso/Painting 独立路径
- `_updateVisibleCellsNow:` 核心循环：layoutAttributes 集合 - allVisibleViewsDict 集合差集 → dequeue + apply / 入 reuse / 更新 attrs
- `_collectionViewFlags` 45+ flag bit 位段（reloading / updating / needsReload / doneFirstLayout 等）必须逐位对齐

### S6 Rearranging (P10)
- Coordinator 状态机：`_isRearranging` / `_autoscrolling` / `initiationMode` 3 种模式
- `_updateRearrangingStateForLocation:` 与 `_finishRearrangingForLocation:shouldComplete:` 对偶

---

## 每子系统的 9 步工作流

1. **D** Dump UXKit 接口：IDA `open_file` + `list_funcs --filter "<ClassName>"`，同步读 `ObjCHeaders/<ClassName>.h`
2. **A** 抽取 ivar 矩阵：写 `.claude/plans/uxcollection-ida-notes/<ClassName>_ivars.md`
3. **M** 方法签名映射：用 `func_query` 反编译每个 `_xxx` 方法，整理"参数 / 返回 / 副作用"三列
4. **C** 比对现状：`rg -n "<MethodName>" Sources/OpenUXKit/`
5. **B** 桥接清单：`rg -nE "ivarName|methodName" Sources/OpenUXKit` 找跨子系统引用 surface
6. **R** 重写：先改 PrivateHeaders/.h，再 +Internal.h，最后 .m；优先必须语义对齐的方法
7. **V** 验证：`swift package update && swift build 2>&1 | xcsift` + 新增对齐测试 + 6 Showcase 启动手测
8. **G** Git checkpoint：`refactor(collection): align <Subsystem> with UXKit 26.4 — phase Pn`
9. **L** Log learnings：意外发现入 plan 文件

---

## 桥接策略（半新半旧如何编译通过）

### 三种过渡手法

**A. ivar 改名 / 新增** → 保留旧 ivar 别名 + 双向 setter。旧 `@property` 保留标 `// migration shim`，新代码读 ivar，旧代码读 property。**清理**：所有调用方迁完后一次性 rg + 改。

**B. 方法签名变** → 新建 `<Subsystem>+Migration.h` 兼容头。例如 `_oldGlobalItemMapValueAtIndex:` 改成 `_oldGlobalItemAtIndex:`，Migration.h 写 `- ... { return [self _oldGlobalItemAtIndex:idx]; }`。**清理**：phase 末 grep `+Migration.h` 引用，无引用即删。

**C. 算法大块下沉** → Adapter 工厂方法。例如 Update 临时保留 `+ legacyUpdateWithInsertItems:deleteItems:`，内部把四数组转新 updateItems 数组。**清理**：P9 末。

### 物理位置
- Migration 头 / .m 放 `Sources/OpenUXKit/Components/Private/`，不进 include/ symlink，不进 OpenUXKit.h umbrella
- 每个 Migration 实现以 `// TODO(uxkit-align): remove after Phase Pn` 标记

### Phase 末必须为真的 4 条 invariant
1. `swift package update && swift build 2>&1 | xcsift` 全绿（OpenUXKit + UXKit 两个 target）
2. `swift test 2>&1 | xcsift` 通过（含本阶段对齐测试）
3. `xcodebuild ... OpenUXKit-Example-Swift Debug build` 通过
4. 手跑 OpenUXKit-Example-Swift，6 个 Showcase 均能进入、显示 cells、能选择、能 reload

---

## 测试策略

### 三层矩阵
| 层 | 工具 | 覆盖 | 何时建 |
|---|---|---|---|
| **L1 单元（纯算法）** | XCTest | IndexPathsSet adjust*、UpdateItem compare、UpdateGap 合并、SectionItemIndexes adjust | P7 / P8 |
| **L2 集成** | XCTest + windowless view hierarchy | performBatchUpdates 完成后 visibleViews 集合（mock data source） | P9 |
| **L3 几何快照** | 自建 `UXCollectionViewFlowLayoutFixture` | FlowLayout layoutAttributesForElementsInRect: 输出 frame 数组对照 | P4 / P5 |

### Parity 测试（核心）
`Tests/OpenUXKitTests/Collection/UXKitParityTests.swift`：同一 fixture 同时跑 OpenUXKit 与 UXKit target，对比 layout frame / visible cells / selection state。提供 ground truth。

### 最小用例集（P0 建框架）
- IndexPathsSet：5 用例（empty / single / multi-section / intersect / adjust series）
- UpdateGap：3 用例（pure-delete-then-insert / mixed / section-based）
- FlowLayout：4 用例（vertical / horizontal / mixed-size / multi-metrics — 对应 Showcase 前 4 个）
- batchUpdates：6 用例（insert / delete / reload / move / insert+delete / reload+move）
- Selection：4 用例（single / multi / lasso / keyboard-range）

---

## 关键文件清单（代表性 5-10 个/子系统）

### S2 (P2-P4)
- `Sources/OpenUXKit/Components/Public/UXCollectionViewLayoutAttributes.{h,m}`
- `Sources/OpenUXKit/Components/Public/UXCollectionViewLayoutInvalidationContext.{h,m}`
- `Sources/OpenUXKit/Components/Public/UXCollectionViewLayout.{h,m}`
- `Sources/OpenUXKit/Components/Public/UXCollectionViewFlowLayout.{h,m}`
- `Sources/OpenUXKit/Components/Public/UXCollectionViewFlowLayoutInvalidationContext.{h,m}`
- **新增** `Sources/OpenUXKit/Components/Private/_UXFlowLayoutInfo.{h,m}`
- 对应 `+Internal.h` 5 个

### S3a (P5)
- `Sources/OpenUXKit/Components/Private/UXCollectionViewData.{h,m}`
- **新增/补全** `Sources/OpenUXKit/Components/Private/UXCollectionViewData+Internal.h`

### S3b + S5 (P8)
- `Sources/OpenUXKit/Components/Private/UXCollectionViewUpdate.{h,m}`
- `Sources/OpenUXKit/Components/Private/UXCollectionViewUpdateGap.{h,m}`
- `Sources/OpenUXKit/Components/Private/UXCollectionViewAnimation.{h,m}`
- `Sources/OpenUXKit/Components/Private/UXCollectionViewAnimationContext.{h,m}`

### S8 (P9)
- `Sources/OpenUXKit/Components/Public/UXCollectionView.{h,m}`（最大，2571 行）
- `Sources/OpenUXKit/Components/Private/UXCollectionView+Internal.h`
- `Sources/OpenUXKit/Components/Private/_UXCollectionView.{h,m}`
- `Sources/OpenUXKit/Components/Private/UXCollectionDocumentView.{h,m}`
- `Sources/OpenUXKit/Components/Private/_UXCollectionDocumentView.{h,m}`
- `Sources/OpenUXKit/Components/Private/UXCollectionClipView.{h,m}`

### S6 (P10)
- `Sources/OpenUXKit/Components/Private/_UXCollectionViewRearrangingCoordinator.{h,m}`
- `Sources/OpenUXKit/Components/Private/_UXCollectionViewLayoutProxy.{h,m}`
- `Sources/OpenUXKit/Components/Private/UXCollectionViewPanGestureRecognizer.{h,m}`
- `Sources/OpenUXKit/Components/Private/UXCollectionViewFilePromiseProvider.{h,m}`

### 测试 + 元文档
- `Tests/OpenUXKitTests/Collection/{IndexPathsSet,UpdateGapAlgorithm,FlowLayoutGeometry,PerformBatchUpdates,SelectionAlgorithm,UXKitParity}Tests.swift`（新建）
- `Tests/OpenUXKitTests/Collection/Fixtures/UXCollectionViewFlowLayoutFixture.swift`（新建）
- `.claude/plans/uxcollection-alignment-matrix.md`（新建，37 类对照）
- `.claude/plans/uxcollection-ida-notes/{_computeGaps,_fetchItemsInfo,_updateItemsLayout,_loadEverything,...}.md`（新建，反编译笔记）
- `.claude/plans/snapshots/Pn-*/`（每 phase 视觉基线）

---

## 风险与回滚

### 主要风险
| 风险 | 概率 | 影响 | 缓解 |
|---|---|---|---|
| `_UXFlowLayoutInfo` 反推字段与真实不符 | 中 | 高 | P0 IDA 反编译 + L3 几何快照测 |
| `_computeGaps` 合并逻辑误差致动画错位 | 高 | 高 | P8 单测 + L2 集成 + L3 视觉对比 UXKit |
| 45+ flag bit 漏对齐 | 中 | 中 | P9 前抽 flag 矩阵 + 4 模式选区单测 |
| Rearranging NSDraggingDestination 漏方法 | 中 | 中 | P10 加 Rearranging Showcase 做 e2e |
| Examples 公开签名兼容意外破坏 | 低 | 高 | P0 锁定 13 符号合同 + 每 phase grep |
| 跨 macOS 版本 UXKit ABI 漂移 | 低 | 中 | UXKit target constructor sanity check |
| 重构周期长致 main 大幅漂移 | 中 | 中 | 每 3 phase rebase + tag baseline |

### Git 拓扑
```
main
 └─ feature/uxcollection-uxkit-align         <- 长寿命
     ├─ P0-prep
     ├─ P1-leaf-tokens                       <- 每 phase 一个 PR
     ├─ P2-layout-attributes
     ├─ ...
     └─ P11-accessibility
```
每完成 3 个 phase merge feature → main 一次（保留 phase 边界为可回滚点）；rebase main 时若冲突过大降级为 merge。

### 回滚触发与动作
| 触发 | 动作 |
|---|---|
| IDA 反编译显示算法与现有设计根本不同 | 当前 phase 内 revert，重做 P0 步骤 1-3 |
| Phase 完成后 Examples 视觉退化 | feature 保留代码，main 回滚到上一 phase tag，开 Pn-bis |
| 暴露上游 phase 漏 ivar | 不回滚，当前 phase 增量补，上游 hot-fix commit |

### Safety net
- 每 phase 开始 `git tag uxcollection-align-Pn-baseline`
- 每 phase 末手录 6 Showcase 截图/视频存 `.claude/plans/snapshots/Pn/`
- 每 3 phase 跑一次 60s Instruments Time Profiler 存档

---

## 验证（端到端测试）

完整重构验证（P11 末）：

```bash
# 1. 构建
cd /Volumes/Repositories/Private/Personal/Library/macOS/OpenUXKit
swift package update && swift build 2>&1 | xcsift          # 必须全绿
swift test 2>&1 | xcsift                                    # 全部 parity + 单元测试通过

# 2. Examples 跑通
xcodebuild -workspace OpenUXKit.xcworkspace \
  -scheme OpenUXKit-Example-Swift -configuration Debug build 2>&1 | xcsift
# 手动启动 Showcase，依次进入 6 个场景：
#   UXCollectionViewShowcase / Controller / Horizontal / MixedSize / MultiMetrics / EdgeCases
# 每个场景：显示 cells / 选择 / 反选 / 滚动 / reload / batchUpdate / rearrange

# 3. Parity 对比真实 UXKit
swift test --filter OpenUXKitTests.UXKitParityTests 2>&1 | xcsift
# 所有几何 / 选区 / 动画起止状态对比 OpenUXKit vs UXKit target，frame 容差 < 0.5pt
```

每个 phase 末段独立验证（缩减版）：
1. `swift build` + `swift test` 全绿
2. `OpenUXKit-Example-Swift` 启动 + 6 Showcase 进入 + 一组手动交互无 crash
3. 录截图对比上一 phase baseline，无视觉退化
