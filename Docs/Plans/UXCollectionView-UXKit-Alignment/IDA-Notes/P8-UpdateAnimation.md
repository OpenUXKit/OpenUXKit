# P8 阶段反编译笔记：Update/Gap 增量 + Animation 子系统对齐

> P8 phase — verify S3b（`UXCollectionViewUpdateGap` 全类 + `_computeGaps` 两个内嵌 block 复核）与 S5（`UXCollectionViewAnimation` / `UXCollectionViewAnimationContext` 全部方法）对齐 UXKit 26.4。这是 batchUpdates 痛点的算法收尾：P0 已验证 4 个 `_compute*` 主体，本阶段补上 P0 遗留的 contiguous 判定与 indexPath 调整两个 block 的细节验证。
>
> **结论**：发现并修复 **2 处真 bug + 1 处行为差异**——`_computeGaps` 的两个方向性错误（contiguous 几何判定反向、insert 并入 delete-gap 的区间判定反向）会导致 gap 合并几乎完全失效，正是"batchUpdates 动画行为与 UXKit 不一样"痛点的直接根源之一；Animation 的默认 timingFunction 用错（Default → Linear）。其余 60+ 个比对点（UpdateGap 全类 9 函数、Animation 全类 13 函数、AnimationContext 全部、`updateItemsSortedByIndexPaths`、`_frameForUpdateItem:usingData:`、`_adjustedIndexPathForGapMergeUsingIndexPath:`）全部一致。**P0 笔记的区间判定伪代码亦记错（有符号/无符号混淆），已修正**。
>
> **P8 阶段代码改动**：
> - `Sources/OpenUXKit/Components/Private/UXCollectionViewUpdate.m`：3 处（contiguous 方向 + min/max 选择、merge 区间判定、删 1 行冗余 `sawInsert`）
> - `Sources/OpenUXKit/Components/Private/UXCollectionViewAnimation.m`：1 处（timingFunction Linear）
> - `Tests/OpenUXKitTests/Collection/UpdateGapAlgorithmTests.swift`：3 个 XCTSkip stub 替换为真实测试（红绿验证两处 bug 修复均被覆盖）

> 反编译来源：`/Volumes/Code/Dump/DyldSharedCaches/macOS/26.4/UXKit.i64`（session `uxkit_26_4`；`/Volumes/RE` 卷本次未挂载，使用 CLAUDE.md 第 2 优先级路径，地址与 P0 笔记完全一致，确认同一 cache 版本）。

---

## 1. ivar 矩阵（P8 冻结）

### 1.1 UXCollectionViewUpdateGap

来源：导出头 + `init` (0x1dbc082f8) 反编译。

| UXKit offset | UXKit ivar | OpenUXKit | 对齐 |
|---|---|---|---|
| 8 | `_firstUpdateItem` | 同名同型 | ✅ |
| 16 | `_lastUpdateItem` | 同名同型 | ✅ |
| 24 | `_deleteItems`（NSMutableArray，init 分配） | 同 | ✅ |
| 32 | `_insertItems`（NSMutableArray，init 分配） | 同 | ✅ |
| 40 | `_beginningRect`（CGRect） | 同 | ✅ |
| 72 | `_endingRect`（CGRect） | 同 | ✅ |

### 1.2 UXCollectionViewAnimation

来源：导出头 + `init` (0x1dbbd1888) 反编译。导出头只列出 offset 48 起的 3 个 ivar + 位段；前 5 个为 @synthesize 隐式 ivar，由 init 写入顺序确认。

| UXKit offset | UXKit ivar | OpenUXKit | 对齐 |
|---|---|---|---|
| 8 | `_view`（id，可能是 NSView 的 layer） | 同 | ✅ |
| 16 | `_finalLayoutAttributes` | 同 | ✅ |
| 24 | `_startFraction`（double） | 同 | ✅ |
| 32 | `_endFraction`（double） | 同 | ✅ |
| 40 | `_viewType`（unsigned long long） | 同 | ✅ |
| 48 | `_completionHandlers`（NSMutableArray） | 同 | ✅ |
| 56 | `_startupHandlers`（NSMutableArray） | 同 | ✅ |
| 64 | `_animationBlock` | 同 | ✅ |
| 72 | `_collectionViewAnimationFlags` 位段：bit0 `animateFromCurrentPosition` / bit1 `deleteAterAnimation`（UXKit 原始拼写，缺 f） / bit2 `rasterizeAfterAnimation` / bit3 `resetRasterizationAfterAnimation` | 同名（含拼写）同序 | ✅ |

`init` 写 flags：`byte72 = (deleteAfterAnimation ? 2 : 0) | animateFromCurrentPosition | (old & 0xFC)`——bit0/bit1 一次写入，bit2/bit3 仅经属性 setter 写。OpenUXKit 位段赋值等价。✅

### 1.3 UXCollectionViewAnimationContext

| UXKit offset | UXKit ivar | OpenUXKit | 对齐 |
|---|---|---|---|
| 8 | `_viewAnimations`（NSArray，strong） | 同 | ✅ |
| 16 | `_animationCount`（long long） | 同 | ✅ |
| 24 | `_completionHandler`（copy，init 写入） | 同 | ✅ |

### 1.4 UXCollectionViewUpdate（增量发现）

`_updateItemsSortedByIndexPaths` ivar @ **0xD8 (216)**（`_gaps` @208 之后）——26.4 导出头 ivar 列表漏列（只标了 @synthesize 属性），由 getter (0x1dbc08674) 汇编 `LDR X0, [X0,#0xD8]` 确认。OpenUXKit class extension 已有同位置声明。✅

---

## 2. 方法算法对照

### 2.1 UXCollectionViewUpdateGap（9 个函数全部反编译）

| 方法 | 地址 | UXKit 关键算法 | 对齐 |
|---|---|---|---|
| `+gapWithUpdateItem:` | 0x1dbc08360 | alloc/init → `setFirstUpdateItem:` → `setLastUpdateItem:` → `addUpdateItem:`（顺序敏感） | ✅ |
| `init` | 0x1dbc082f8 | 分配 `_deleteItems` / `_insertItems` 两个数组 | ✅ |
| `addUpdateItem:` | 0x1dbc0818c | `_action`==1 → deleteItems；==0 → insertItems；否则 NSAssertionHandler（**file "UXCollectionViewUpdate.m" line 57**，文件名/行号/文本一致） | ✅ |
| `updateItems` | 0x1dbc080d4 | `[deleteItems arrayByAddingObjectsFromArray:insertItems]` | ✅ |
| `hasInserts` / `isDeleteBasedGap` | 0x1dbc080e0 / 0x1dbc08104 | 对应数组 `count != 0` | ✅ |
| `isSectionBasedGap` | 0x1dbc080cc | `firstUpdateItem._isSectionOperation` 转发 | ✅ |
| `description` | 0x1dbc08240 | `%@ first item: %@, last item: %@, deleteBased: %@, hasInserts: %@` 格式一致 | ✅ |
| `set/get` first/last/beginningRect/endingRect | — | 纯 @synthesize 存取 | ✅ |

### 2.2 `_computeGaps` (0x1dbc086b4) 复核 + 两个内嵌 block（P0 待办收尾）

主循环结构与 P0 笔记一致（DELETE 降序链扩展 first / INSERT fast 扩展 last / INSERT slow 遍历 gaps 找 merge / 每 item `_setGap:`）。本阶段新验证：

**(a) contiguous 判定 block (0x1dbc08a70)** —— 汇编逐句验证（CSEL/FCMP）：

```
BOOL contiguous(itemA, itemB):
    if (itemA._action != itemB._action) return NO
    cmp = [itemA compareIndexPaths:itemB]
    max = (cmp == NSOrderedAscending) ? itemB : itemA     // CSEL X22, X21, X20, EQ
    min = (cmp == NSOrderedAscending) ? itemA : itemB     // CSEL X21, X20, X21, EQ
    model = (itemA._action == 0/*INSERT*/) ? _newModel@32 : _oldModel@24
    return CGRectGetMaxY(rect(min, model)) == CGRectGetMinY(rect(max, model))
```

**核心语义是纯几何**：较小 indexPath 的包围盒底边 恰好等于 较大 indexPath 的包围盒顶边（只看 Y 轴，水平 flow 无特判）。
❌ **OpenUXKit `_updateItem:isContiguousWith:` 原实现为 `MaxY(upper) == MinY(lower)`，方向相反**——除单行重叠外恒为 NO，使 DELETE 降序链与 INSERT fast 路径的 gap 合并完全失效。已修复（含 min/max 选择条件改为与 UXKit 相同的 `NSOrderedAscending` 判定；NSOrderedSame 时两实现 rect 相同，语义不受影响）。

**(b) rect 提取 helper (0x1dbc08cc0)** —— 对应 OpenUXKit `_frameForUpdateItem:usingData:`：

- 非 section 操作：`data.layoutAttributesForItemAtIndexPath:.frame`
- section 操作：`CGRectNull` 起步，`globalIndexForItemAtIndexPath:(item 0)` 为 NSNotFound 直接返回 Null；否则 union 该 section 全部 item frame，再 union `layoutAttributesForElementsInSection:`（supplementary）的 frame

✅ OpenUXKit 逐句一致（含 NSNotFound 防护与双重 union）。

**(c) indexPath 调整 block (0x1dbc08b30)** —— 对应 `_adjustedIndexPathForGapMergeUsingIndexPath:`：

遍历 `updateItemsSortedByIndexPaths`（含正在处理的 insert 自身），`delta = (_action == DELETE) ? +1 : -1`；section 操作且 `.section < section` → `section += delta`；随后 `itemIndexPath.section == section`（用调整后的 section 比较）且 `.item < item` → `item += delta`。✅ OpenUXKit 逐句一致（注意第二个 if 不是 else-if，两段可同轮命中）。

**(d) merge 区间判定（_computeGaps 主体内）** —— CCMP 链汇编验证（`CMP X27,#1` + `CCMP X8,#2,#2,LS` + `B.CC`）：

```
cmpFirst = [adjusted compare:gap.firstUpdateItem._indexPath]
cmpLast  = [adjusted compare:gap.lastUpdateItem._indexPath]
merge ⇔ (unsigned)cmpFirst <= 1 && (unsigned)(cmpLast + 1) < 2
      ⇔ cmpFirst ∈ {Same, Descending} && cmpLast ∈ {Ascending, Same}
      ⇔ first <= adjusted <= last（闭区间）
```

❌ **OpenUXKit 原实现 `compareFirst <= NSOrderedSame` 是有符号比较，语义为 `adjusted <= first`，方向相反**——落在 gap 区间内的 insert 不被吸收，而位于 first 之前的 insert 反被错误吸收。已修复为 `compareFirst != NSOrderedAscending && compareLast != NSOrderedDescending`。
⚠️ **P0 笔记 `_computeGaps.md` 的伪代码同样记错**（照抄了反编译器输出的 `<=` 而未注意 unsigned），已同步修正。

**(e) 冗余 `sawInsert`**：INSERT fast 分支进入前提即 `sawInsert == YES`，UXKit 该分支不再写标志；OpenUXKit 原有的冗余 `sawInsert = YES;` 已删除（无语义影响，纯 1:1 形态对齐）。

### 2.3 `updateItemsSortedByIndexPaths` (0x1dbc08674)

Lazy getter：`_updateItems sortedArrayUsingSelector:` 排序后缓存到 ivar @0xD8。✅ OpenUXKit 一致。
限制说明：selector 字面量位于 cache selector 区 0x1FA0BE260，本 i64 未映射该数据段，无法直读字符串；按消费方（block (c) 的扫描语义）与 P0 全类验证推定为 `compareIndexPaths:`，与 OpenUXKit 现实现相同。

### 2.4 UXCollectionViewAnimation（13 个函数全部反编译）

| 方法 | 地址 | UXKit 关键算法 | 对齐 |
|---|---|---|---|
| `initWithView:viewType:...customAnimations:` | 0x1dbbd1888 | nil view → NSAssertionHandler（**"UXCollectionView.m" line 403**）；NSView 且非 UXCollectionReusableView → 改存 `view.layer`；customAnimations `copy` | ✅ |
| `start` | 0x1dbbd0f7c | duration = `CATransaction.disableActions ? 0 : 0.25`；fraction 区间缩放（endFraction < startFraction → assert **line 479** 后重读）；startupHandlers 全调 + removeAll；非 ReusableView → assert **line 489**；custom 路径：`_setBaseLayoutAttributes:` → block(completion) → `applyLayoutAttributes:`；默认路径 `runAnimationGroup:completionHandler:` | ✅ |
| `start` 动画 block | 0x1dbbd1384 | `allowsImplicitAnimation = YES`；timingFunction 为 nil 时取 **`kCAMediaTimingFunctionLinear`** 并无条件回写；3 个 CABasicAnimation（frameOrigin / bounds / alphaValue）：fromValue 仅 `!animateFromCurrentPosition` 时设（取 `view._layoutAttributes`），bounds 用 `(0, 0, size)`，`removedOnCompletion = YES`；`view.animations` 字典；`_setLayoutAttributes:final` | ✅（timingFunction 已修复，见 §3） |
| `start` 两个 completion block | 0x1dbbd1274 / 0x1dbbd1650 | 同一逻辑：遍历 `_completionHandlers` 调用 + removeAll；custom 路径 completion **忽略 finished 参数** | ✅ |
| `addStartupHandler:` / `addCompletionHandler:` | 0x1dbbd0ee4 / 0x1dbbd0f30 | nil 检查 + `copy` + addObject | ✅ |
| `view` / `description` | 0x1dbbd0edc / 0x1dbbd17c4 | 直返 ivar / `[super.description stringByAppendingFormat:@" view: %@"]` | ✅ |
| 4 个 flag 属性存取 | — | 位段读写（bit0-bit3，见 §1.2） | ✅ |

flag 副作用顺序结论（plan 关注点）：`animateFromCurrentPosition` 只影响动画 block 内 3 个 fromValue 是否设置；`deleteAfterAnimation` / `rasterizeAfterAnimation` / `resetRasterizationAfterAnimation` 在 Animation 类内部**只存不取**——消费者是主类的动画启动/清理循环（P9 接线验证）。

### 2.5 UXCollectionViewAnimationContext（全部函数）

| 方法 | 地址 | UXKit 关键算法 | 对齐 |
|---|---|---|---|
| `initWithCompletionHandler:` | 0x1dbbd0658 | `copy` 写 @24，无其他副作用 | ✅ |
| `viewAnimations` / `animationCount` / `completionHandler` 存取 | — | 纯 @synthesize | ✅ |

纯数据袋，无算法。`viewAnimations` 数组与 `animationCount` 由主类 `_setupCellAnimations` 驱动（P9）。

---

## 3. 本阶段代码修复汇总

| # | 文件 | 修复 | 性质 |
|---|---|---|---|
| 1 | `UXCollectionViewUpdate.m` `_updateItem:isContiguousWith:` | `MaxY(upper)==MinY(lower)` → `MaxY(lower)==MinY(upper)`；min/max 选择条件 `NSOrderedDescending` → `NSOrderedAscending`（与 UXKit CSEL 完全一致） | **真 bug**：gap 链合并几乎全灭 |
| 2 | `UXCollectionViewUpdate.m` `_computeGaps` merge 判定 | `compareFirst <= NSOrderedSame && (compareLast+1) < 2` → `compareFirst != NSOrderedAscending && compareLast != NSOrderedDescending` | **真 bug**：区间方向反 |
| 3 | `UXCollectionViewUpdate.m` `_computeGaps` INSERT fast 分支 | 删冗余 `sawInsert = YES;` | 形态对齐（无语义差） |
| 4 | `UXCollectionViewAnimation.m` `start` | timingFunction 缺省 `kCAMediaTimingFunctionDefault` → `kCAMediaTimingFunctionLinear` | 行为差异（动画手感） |

## 4. 测试

`Tests/OpenUXKitTests/Collection/UpdateGapAlgorithmTests.swift` 3 个 stub 转正（单列 fixture：item 宽 == 容器宽，使 indexPath 相邻 ⇔ 几何相邻；私有类经 @objc 协议镜像 + `unsafeBitCast` 驱动完整 `UXCollectionViewUpdate` init 管线）：

1. `test_pureDeleteThenInsert_mergesIntoSingleGap`：DELETE 降序链合并 + 区间内 insert 吸收 → 1 gap（修复 #1 前：3+ gaps）
2. `test_nonContiguousOperations_formSeparateGaps`：不相邻 delete 断链 + 区间外 insert 自立门户 + 相邻 insert fast 合并 → 3 gaps（修复 #1 或 #2 前均失败，红绿已验证）
3. `test_sectionBasedOperations_groupSeparatelyFromItemOperations`：section delete 经 union-rect 相邻合并、item delete 不并入 section gap → 2 gaps

全量 `swift test` 26/26 通过；`OpenUXKit-Example-Swift` Debug 构建通过。

## 5. 调用面合同（P9 接线依据）

- `_computeSupplementaryUpdates` 仍无 UXKit 内部代码调用点（P0 结论维持）；`UpdateGap.beginningRect/endingRect` 的 setter 在 Update/Gap/Animation 三类内部均无调用——两者的消费者都在主类 batchUpdates 流程（`_setupCellAnimations` / `_endUpdates`），P9 反编译主类时验证。
- `UXCollectionViewAnimation` 的 `deleteAfterAnimation` / `rasterize*` 两组 flag 由主类在动画完成回调里消费（删除 view / 重置 rasterization），P9 接线。
- `_UXCollectionSnapshotView` 三个创建点合同见 P6 笔记 §3，P9 接线。

## 6. 待办（后续 phase）

- [x] P9：反编译主类 `_setupCellAnimations` / `_endUpdates`，验证 AnimationContext.viewAnimations 组装、UpdateGap.beginningRect/endingRect 写入点、`_computeSupplementaryUpdates` 触发点 → **viewAnimations 组装 = `_updateWithItems:` 零时长嵌套动画组内 `_viewAnimationsForCurrentUpdate`；`_computeSupplementaryUpdates` 触发 = `_updateWithItems:`；beginningRect/endingRect 在 batchUpdates 全链中无写入点（layout transition / P9b 继续追踪）**（见 `P9-MainClass.md` §2.1/§5）
- [x] P9：验证 Animation 4 flag 在主类完成回调中的消费顺序 → **`deleteAfterAnimation` 消费点 1 = `_updateWithItems:` 动画循环（决定是否以 finalLayoutAttributes 为 key 重新登记 dict）；消费点 2 = `_updateAnimationDidStop:`（出可见区移除判定）；`resetRasterizationAfterAnimation`/`rasterizeAfterAnimation` 消费 = `_updateAnimationDidStop:` 的 `layer.shouldRasterize` 回写**（见 `P9-MainClass.md` §2.1）
