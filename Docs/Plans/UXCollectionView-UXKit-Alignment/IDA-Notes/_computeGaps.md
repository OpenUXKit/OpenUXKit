# `-[UXCollectionViewUpdate _computeGaps]` 反编译笔记

> 反编译来源：`/Volumes/RE/Dyld-Shared-Cache/macOS/26.4/UXKit.i64`（session `uxkit_26_4`）
> 方法地址：`0x1dbc086b4`，大小 0x3bc (956 bytes)
> 关联方法：`-[UXCollectionViewUpdateGap gapWithUpdateItem:]`、`-[UXCollectionViewUpdateGap addUpdateItem:]`、`-[UXCollectionViewUpdateGap isDeleteBasedGap]`、`-[UXCollectionViewUpdateGap setFirstUpdateItem:]`、`-[UXCollectionViewUpdateGap setLastUpdateItem:]`、`-[UXCollectionViewUpdateGap insertItems]`、`-[UXCollectionViewUpdateGap firstUpdateItem]`、`-[UXCollectionViewUpdateGap lastUpdateItem]`、`-[UXCollectionViewUpdateItem _setGap:]`、`-[UXCollectionViewUpdateItem _action]`、`-[UXCollectionViewUpdateItem _indexPath]`
> 内嵌 block：
>   - `block_invoke` (0x1dbc08a70)：签名 `BOOL (UXCollectionViewUpdateItem*, UXCollectionViewUpdateItem*)` —— contiguous 判定
>   - `block_invoke.87` (0x1dbc08b30)：签名 `NSIndexPath* (NSIndexPath*)` —— index path 调整（gap merge 时的偏移）

## 调用上下文

唯一调用点：`-[UXCollectionViewUpdate initWithCollectionView:updateItems:oldModel:newModel:oldVisibleBounds:newVisibleBounds:]`，在 `_computeSectionUpdates` → `_computeItemUpdates` 之后第 3 步调用。

**关键发现**：
- `_computeSupplementaryUpdates` 不在 init 调用链中（IDA xrefs 仅显示 ObjC method list data ref，无代码调用点）
- `newIndexPathForSupplementaryElementOfKind:oldIndexPath:` 与 `oldIndexPathForSupplementaryElementOfKind:newIndexPath:` 也仅有 method list ref，UXKit 内部代码不主动调用 → 由外部消费者通过 ObjC dispatch 动态调用

## 算法（伪代码 / 精炼）

```
- (void)_computeGaps {
    _gaps = [NSMutableArray new]
    UXCollectionViewUpdateGap *currentGap = nil
    BOOL sawInsert = NO  // v4 in IDA

    for (UXCollectionViewUpdateItem *item in _updateItems) {
        action = [item _action]

        if (action == 1) {  // DELETE
            if (currentGap && contiguous(item, currentGap.firstUpdateItem)) {
                currentGap.firstUpdateItem = item
                [currentGap addUpdateItem:item]
            } else {
                currentGap = [UXCollectionViewUpdateGap gapWithUpdateItem:item]
                [_gaps addObject:currentGap]
            }
        }
        else if (action == 0) {  // INSERT
            if (currentGap && sawInsert
                && contiguous(item, [currentGap.insertItems lastObject])) {
                currentGap.lastUpdateItem = item
                [currentGap addUpdateItem:item]
            } else {
                // 遍历已有 gaps，找一个 isDeleteBasedGap 且 item 的 indexPath 在 gap 范围内
                BOOL merged = NO
                for (gap in _gaps) {
                    currentGap = gap
                    if (!gap.isDeleteBasedGap) break
                    adjustedIndexPath = adjustIndexPathForGapMerge(item._indexPath)
                    cmpFirst = [adjustedIndexPath compare:gap.firstUpdateItem._indexPath]
                    cmpLast  = [adjustedIndexPath compare:gap.lastUpdateItem._indexPath]
                    if (cmpFirst <= NSOrderedSame && cmpLast + 1 < 2) {
                        [gap addUpdateItem:item]
                        sawInsert = YES
                        merged = YES
                        break
                    }
                }
                if (!merged) {
                    currentGap = [UXCollectionViewUpdateGap gapWithUpdateItem:item]
                    [_gaps addObject:currentGap]
                    sawInsert = YES
                }
            }
        }
        // reload (action == 2) / move (action == 3) 在此方法中不处理；
        // 它们由 _computeItemUpdates 处理为 delete+insert pair

        [item _setGap:currentGap]
    }
}
```

### 关键状态字段
- `v4` (sawInsert)：跨越循环迭代保留——只有遇到 insert 后才会与下一个 insert 合并；纯 delete 之间不参考
- `currentGap`：跨迭代保留——allow 一个 delete 序列后紧跟一个 insert 序列时把它们合并到同一个 gap
- `_action` 编码：0=INSERT, 1=DELETE（与 OpenUXKit 当前 `UXCollectionUpdateActionInsert`=0 / `UXCollectionUpdateActionDelete`=1 一致；reload/move 由 `_computeItemUpdates` 拆解，不在此处出现）

### 关键不变量
- 每个 updateItem 最终会被 `_setGap:` 设置一次（即使是单独的 delete/insert 也会被装进一个新 gap）
- `_gaps` 中元素顺序与 `_updateItems` 遍历顺序对齐
- delete-based gap 后跟随 insert 可被吸收进同一个 gap（这是减少动画数量的核心优化）

## 与 OpenUXKit 当前实现对照

文件：`Sources/OpenUXKit/Components/Private/UXCollectionViewUpdate.m:428-473`

| 维度 | UXKit | OpenUXKit 当前 | 一致性 |
|---|---|---|---|
| 主循环结构 | for-in 遍历 `_updateItems` | for-in 遍历 `_updateItems` | ✅ |
| DELETE 分支 | currentGap+contiguous→扩展 / else 新 gap | 同 | ✅ |
| INSERT-fast 分支 | currentGap+sawInsert+contiguous→扩展 | 同（`sawInsert = YES` 在此处略冗余但语义一致） | ✅ |
| INSERT-slow 分支（遍历已有 gaps） | 找 isDeleteBasedGap 且 indexPath 在 range 内 | 同 | ✅ |
| `_setGap:` 调用 | 循环末尾每 item 一次 | 同 | ✅ |
| contiguous 判定 | block_invoke (0x1dbc08a70) | `_updateItem:isContiguousWith:` 方法 | ✅ 语义一致（实现位置不同） |
| index path 调整 | block_invoke.87 (0x1dbc08b30) | `_adjustedIndexPathForGapMergeUsingIndexPath:` 方法 | ✅ 语义一致（实现位置不同） |

**结论**：`_computeGaps` 在 OpenUXKit 已经事实上对齐 UXKit。需要在 P8 阶段验证的细节：
1. `_updateItem:isContiguousWith:` 内部实现是否与 UXKit block_invoke (0x1dbc08a70) 完全一致（待反编译验证）
2. `_adjustedIndexPathForGapMergeUsingIndexPath:` 内部是否与 UXKit block_invoke.87 (0x1dbc08b30) 完全一致（待反编译验证）
3. 单测覆盖：3 种典型场景（pure-delete-then-insert / mixed / section-based）

## 调用顺序对照

| 顺序 | UXKit init | OpenUXKit init |
|---|---|---|
| 1 | `_computeSectionUpdates` | `_computeSectionUpdates` ✅ |
| 2 | `_computeItemUpdates` | `_computeItemUpdates` ✅ |
| 3 | `_computeGaps` | `_computeGaps` ✅ |
| —— | （`_computeSupplementaryUpdates` 不在 init 中） | （`_computeSupplementaryUpdates` 已定义但 init 不调用）✅ |

**重要修正**：plan 中"OpenUXKit 主调用链漏掉了 `_computeSupplementaryUpdates`"这个早期假设**不成立**。UXKit init 同样不调用此方法。该方法应由 UXCollectionView 主类在 `_setupCellAnimations` 等阶段按需调用（待 P9 反编译验证主类调用路径）。

## 待办（后续 phase）

- [ ] P8：反编译 `block_invoke (0x1dbc08a70)` 验证 contiguous 判定细节
- [ ] P8：反编译 `block_invoke.87 (0x1dbc08b30)` 验证 indexPath 调整细节
- [ ] P9：反编译 UXCollectionView 主类，确认 `_computeSupplementaryUpdates` / `_deletedSupplementaryIndexesSectionArray` 在哪里被触发
- [ ] P8：编写 `UpdateGapAlgorithmTests` 覆盖 3 种 gap 合并模式
