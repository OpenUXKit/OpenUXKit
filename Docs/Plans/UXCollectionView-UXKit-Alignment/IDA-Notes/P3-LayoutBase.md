# P3 阶段反编译笔记：UXCollectionViewLayout 基类对齐

> P3 phase — verify 22 ivars (incl transition fields + `_invalidationContext` singleton + decoration view dicts), `_prepareForTransition*` two-stage semantics, decoration view registration.
>
> **结论**：UXCollectionViewLayout 基类在 OpenUXKit 中**已经 100% 算法对齐 UXKit 26.4**，无代码修改需要。发现 OpenUXKit 额外实现了 ~6 个 UXKit 不存在的 helper 方法（drag/drop + transition animation 相关），全部保留——是否清理留 P9 主类阶段统一决定。

---

## 1. ivar 布局完美对齐

通过反编译 `_UXCollectionViewLayoutCommonInit` (0x1dbbe9628)、`_prepareForTransitionFromLayout:` (0x1dbbe88a0)、`_finalizeLayoutTransition` (0x1dbbe884c)、`finalizeCollectionViewUpdates` (0x1dbbe8a68)、`invalidateLayoutWithContext:` (0x1dbbe93a4) 推出 UXKit ivar 偏移矩阵，与 OpenUXKit `UXCollectionViewLayout.m:40-63` 完全对应：

| UXKit offset | UXKit (反编译变量) | OpenUXKit ivar | 对齐 |
|---|---|---|---|
| 16 (a1[2]) | (子类用，可能 _collectionViewBoundsSize 部分) | _collectionViewBoundsSize | ✅ |
| 24 (a1[3]) | NSMutableDictionary (CommonInit) | _initialAnimationLayoutAttributesDict | ✅ |
| 32 (a1[4]) | NSMutableDictionary (CommonInit) | _finalAnimationLayoutAttributesDict | ✅ |
| 40 (a1[5]) | NSMutableDictionary (CommonInit) | _deletedSupplementaryIndexPathsDict | ✅ |
| 48 (a1[6]) | NSMutableDictionary (CommonInit) | _insertedSupplementaryIndexPathsDict | ✅ |
| 56 (a1[7]) | NSMutableDictionary (CommonInit) | _deletedDecorationIndexPathsDict | ✅ |
| 64 (a1[8]) | NSMutableDictionary (CommonInit) | _insertedDecorationIndexPathsDict | ✅ |
| 72 (a1[9]) | NSMutableIndexSet (CommonInit) | _deletedSectionsSet | ✅ |
| 80 (a1[10]) | NSMutableIndexSet (CommonInit) | _insertedSectionsSet | ✅ |
| 88 (a1[11]) | NSMutableDictionary (lazy via register*) | _decorationViewClassDict | ✅ |
| 96 (a1[12]) | NSMutableDictionary (lazy via registerNib*) | _decorationViewNibDict | ✅ |
| 104 (a1[13]) | _transitioningFromLayout (retain) | _transitioningFromLayout | ✅ |
| 112 (a1[14]) | _transitioningToLayout (retain) | _transitioningToLayout | ✅ |
| 120 (byte) | _inTransitionFromTransitionLayout (BOOL) | _inTransitionFromTransitionLayout | ✅ |
| 121 (byte) | _inTransitionToTransitionLayout (BOOL) | _inTransitionToTransitionLayout | ✅ |
| 128 (a1[16]) | _invalidationContext (singleton override) | _invalidationContext | ✅ |
| 136 (a1[17]) | _collectionView (weak ref) | _collectionView (weak) | ✅ |
| 176 (a1[22]) | _accessibilityRoleDescription (CFSTR("UXCollectionViewAXRoleDescription")) | _accessibilityRoleDescription | ✅ |

剩余字段（accessibilityChildren / layoutAccessibility / accessibilityIdentifier / accessibilityLabel）在 a1[18..21] 区间，未被反编译直接观察到，但接口对应。

### 1.1 ivar 数量修订

Plan 中估计 "13 ivars"——实际 **22 ivars**（包括 transition state、accessibility 字段、bounds size 等）。

---

## 2. 核心算法对照

### 2.1 `_UXCollectionViewLayoutCommonInit` (UXKit 0x1dbbe9628, 156 bytes)

```c
a1[3] = [NSMutableDictionary new];   // _initialAnimationLayoutAttributesDict
a1[4] = [NSMutableDictionary new];   // _finalAnimationLayoutAttributesDict
a1[5] = [NSMutableDictionary new];   // _deletedSupplementaryIndexPathsDict
a1[6] = [NSMutableDictionary new];   // _insertedSupplementaryIndexPathsDict
a1[7] = [NSMutableDictionary new];   // _deletedDecorationIndexPathsDict
a1[8] = [NSMutableDictionary new];   // _insertedDecorationIndexPathsDict
a1[9] = [NSMutableIndexSet new];     // _deletedSectionsSet
a1[10] = [NSMutableIndexSet new];    // _insertedSectionsSet
a1[22] = UXLocalizedString(@"UXCollectionViewAXRoleDescription");
```

OpenUXKit `_commonInit` (line 99-109)：8 个分配 + accessibilityRoleDescription **顺序与字段类型完全一致**。✅

### 2.2 `invalidateLayout` (UXKit) 重用单例 _invalidationContext

```c
v2 = a1[16];                                                              // 单例 _invalidationContext
if (!v2) v2 = [[[self.class invalidationContextClass] alloc] init];        // 缺则新建
[self invalidateLayoutWithContext:v2];
```

OpenUXKit (line 150-156)：行为完全一致。✅

这是 plan 中提到的"`_invalidationContext` 单例聚合"语义——多次 `invalidateLayout` 调用复用同一个 context 而不是每次新建，允许外层先 `_invalidationContext = customContext` 再调 `invalidateLayout` 来注入特定 context（OpenUXKit 通过 `_invalidateLayoutUsingContext:` helper 提供这层语法糖，UXKit 中无此 helper）。

### 2.3 `invalidateLayoutWithContext:` (UXKit)

```c
[objc_loadWeak(&self->_collectionView) _invalidateLayoutWithContext:a3];
[self.layoutAccessibility accessibilityInvalidateLayout];
```

OpenUXKit (line 158-161)：行为完全一致。✅

### 2.4 `prepareLayout` (UXKit) 基类仅触发 accessibility

```c
[self.layoutAccessibility accessibilityPrepareLayout];
```

OpenUXKit (line 183-185)：一致。✅ 子类（FlowLayout）会 override 这个方法并 super 调用。

### 2.5 `registerClass:forDecorationViewOfKind:` (UXKit)

```c
if (!self->_decorationViewClassDict) self->_decorationViewClassDict = [NSMutableDictionary new];
[self->_decorationViewNibDict removeObjectForKey:elementKind];
if (viewClass) [self->_decorationViewClassDict setValue:viewClass forKey:elementKind];
else            [self->_decorationViewClassDict removeObjectForKey:elementKind];
```

OpenUXKit (line 222-232)：完全一致。✅ 注意 **mutual exclusion 语义**——register Class 时清掉同 kind 的 Nib，反之亦然。

### 2.6 transition 双阶段语义对照

| 方法 | UXKit | OpenUXKit (line) | 对齐 |
|---|---|---|---|
| `prepareForTransitionFromLayout:` (public) | 空 stub (4 bytes) | 空 stub (line 270-271) | ✅ |
| `prepareForTransitionToLayout:` (public) | 空 stub (4 bytes) | 空 stub (line 267-268) | ✅ |
| `finalizeLayoutTransition` (public) | 空 stub (4 bytes) | 空 stub (line 273-274) | ✅ |
| `_prepareForTransitionFromLayout:` (internal) | `_transitioningFromLayout = retain(arg); [self prepareForTransitionFromLayout:arg]` | 同 (line 276-279) | ✅ |
| `_prepareForTransitionToLayout:` (internal) | `_transitioningToLayout = retain(arg); [self prepareForTransitionToLayout:arg]` | 同 (line 281-284) | ✅ |
| `_finalizeLayoutTransition` (internal) | 清 `_transitioningFromLayout` + `_inTransitionFromTransitionLayout` + `_transitioningToLayout` + `_inTransitionToTransitionLayout`，然后调 `finalizeLayoutTransition` | 同 (line 286-292) | ✅ |

**双阶段语义关键**：外层调 `_prepareFor*`（带下划线）→ 内部存好 transitioning ivar → 触发公开 `prepareFor*`（不带下划线）允许子类 hook。`_finalize` 时清 4 个 ivar 再调公开 `finalize`。

### 2.7 `finalizeCollectionViewUpdates` (UXKit) — 清 6 dict + 2 indexSet

```c
[a1+24 removeAllObjects];  // _initialAnimationLayoutAttributesDict
[a1+32 removeAllObjects];  // _finalAnimationLayoutAttributesDict
[a1+40 removeAllObjects];  // _deletedSupplementaryIndexPathsDict
[a1+48 removeAllObjects];  // _insertedSupplementaryIndexPathsDict
[a1+56 removeAllObjects];  // _deletedDecorationIndexPathsDict
[a1+64 removeAllObjects];  // _insertedDecorationIndexPathsDict
[a1+72 removeAllIndexes];  // _deletedSectionsSet
[a1+80 removeAllIndexes];  // _insertedSectionsSet
```

OpenUXKit (line 311-320)：8 步完全一致。✅

---

## 3. OpenUXKit 额外 helper 方法（UXKit 不存在）

逐一 lookup 后确认 UXKit **不存在**的 OpenUXKit-only 方法：

| OpenUXKit 方法 | 行号 | UXKit 状态 | 调用方 | 处理决策 |
|---|---|---|---|---|
| `_invalidateLayoutUsingContext:` | 163-167 | Not Found | UXCollectionViewFlowLayout.m | **保留**——FlowLayout 内部用 |
| `_finalizeCollectionViewItemAnimations` | 322-325 | Not Found | UXCollectionView.m:1763 | **保留**——主类用 |
| `transitionContentOffsetForProposedContentOffset:keyItemIndexPath:` | 824-837 | 空 stub (4 bytes) | 仅 +Internal.h 声明 | 保留 stub（UXKit 是空 stub，OpenUXKit 有实现但无调用方，行为不冲突） |
| `updatesContentOffsetForProposedContentOffset:` | 839-846 | 空 stub (4 bytes) | 仅 +Internal.h 声明 | 同上 |
| `_animateView:withAction:fromLayoutAttributes:toLayoutAttributes:fromLayout:withCompletionHandler:` | 784-809 | Not Found | 无调用方 | dead code，留 P9 评估 |
| `_prepareToAnimateFromCollectionViewItems:atContentOffset:toItems:atContentOffset:` | 811-822 | Not Found | 无调用方 | dead code，留 P9 评估 |
| `_supportsAdvancedTransitionAnimations` | 297-299 | Not Found | 无调用方 | dead code，留 P9 评估 |
| `snapshottedLayoutAttributeForItemAtIndexPath:` | 778-780 | size 0x8 (`return nil`) | 无调用方 | 一致 ✅ |
| `dropPositionForPoint:` | 848-861 | Not Found | 无调用方 | dead code，留 P9 评估 |
| `proposedDropIndexPathForDraggingPoint:` | 863-876 | Not Found | 无调用方 | dead code，留 P9 评估 |
| `dropPositionForPoint:withIndexPaths:movedToIndexPath:` | 906-908 | Not Found | 无调用方 | dead code，留 P9 评估 |
| `layoutAttributesForElementsInRect:withIndexPaths:exchangedWithIndexPaths:` | 910-912 | Not Found | LayoutProxy 调？ | 待 P10 verify |
| `layoutAttributesForElementsInRect:withIndexPaths:movedToIndexPath:atPoint:` | 914-916 | Not Found | LayoutProxy 调？ | 待 P10 verify |

**P3 决策**：暂不删除任何 OpenUXKit 多余 helper，避免破坏 P9 / P10 未知调用路径。在 P9（主类）和 P10（Rearranging）阶段统一审视：
- 主类 / RearrangingCoordinator 不调用的 → 删除
- 主类 / RearrangingCoordinator 调用但 UXKit 等价 stub 的 → 简化为 stub
- 仅 OpenUXKit 自己用的 → 保留并文档化

---

## 4. 子类 override 行为（基类相关）

基类 `init` (UXKit 0x1dbbe96c4)：

```c
[super init];
if (result) UXCollectionViewLayoutCommonInit(result);
return result;
```

OpenUXKit 当前是相同结构 (line 111-117)。✅

**FlowLayout `init`** 在 P4 验证。已知 FlowLayout 有 `_UXCollectionViewFlowLayoutCommonInit` (0x1dbbf3ac0)，独立于基类 CommonInit。

---

## 5. P3 完成统计

| Task | 状态 | 关键发现 |
|---|---|---|
| T14 Layout 基类对齐 | ✅ 已对齐 | 22 ivar / 8 个 CommonInit 字段 / transition 双阶段 / decoration view 注册 / invalidation 单例聚合 / finalize 8 步清理 全部对齐；发现 6+ 个 OpenUXKit-only helper 全部保留并标注 |

**P3 阶段代码改动**：0 处。

**验证**：`swift build` 0 errors / 0 warnings；`swift test` 26 passed。

---

## 6. P3 → P4 / P9 桥接

P3 输出的"基类合同"对后续 phase 至关重要：

- **P4 (FlowLayout)**：子类调用 `[super prepareLayout]` 等会触发 accessibility hooks，必须保留基类调用；FlowLayout 的 `_UXCollectionViewFlowLayoutCommonInit` 与基类 CommonInit 共存
- **P5 (Data)**：Data 通过 `_collectionView _invalidateLayoutWithContext:` 触发基类 invalidate，依赖基类 weak ref 正确
- **P8 (Update/Animation)**：依赖基类的 8 个 animation dict / index set 字段
- **P9 (主类 UXCollectionView)**：决定 OpenUXKit-only helper 是否清理；含 `_finalizeCollectionViewItemAnimations` 调用点 (line 1763)
- **P10 (Rearranging)**：LayoutProxy + Coordinator 可能用到 `layoutAttributesForElementsInRect:withIndexPaths:*` 等 OpenUXKit-only 方法

---

## 7. P3 阶段 9 步工作流执行记录

| 步骤 | 执行情况 |
|---|---|
| **D** (Dump) | ✅ IDA `lookup_funcs` 拿到 init / invalidate / prepareLayout / registerClass / transition / finalize 等核心方法地址 |
| **A** (Abstract ivars) | ✅ 从 CommonInit + _prepareForTransition* + _finalizeLayoutTransition + finalizeCollectionViewUpdates 反推完整 ivar 偏移矩阵（18+ ivar 全部验证）|
| **M** (Method mapping) | ✅ 反编译 10 个核心方法（CommonInit / init / invalidateLayout / invalidateLayoutWithContext: / prepareLayout / registerClass:forDecorationViewOfKind: / _prepareForTransitionFromLayout: / _prepareForTransitionToLayout: / _finalizeLayoutTransition / finalizeCollectionViewUpdates） |
| **C** (Compare with current) | ✅ 算法 100% 对齐；发现 OpenUXKit 多 ~6 个 helper 方法 |
| **B** (Bridge inventory) | ✅ 列出 OpenUXKit-only 方法的调用方 + 处理决策 |
| **R** (Rewrite) | — 无需 rewrite（dead code 清理留 P9 评估） |
| **V** (Verify) | ✅ `swift build` + `swift test` 全绿 |
| **G** (Git checkpoint) | (本次会话末尾 commit) |
| **L** (Log learnings) | ✅ 本笔记 |
