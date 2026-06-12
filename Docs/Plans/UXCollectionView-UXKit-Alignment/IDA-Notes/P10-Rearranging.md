# P10 阶段反编译笔记：Rearranging 拖放协调器（S6）

> P10 phase — `_UXCollectionViewRearrangingCoordinator`（痛点 4）。本笔记记录 UXKit 26.4 的真实状态机,作为完整重写的依据。
>
> 反编译来源：`/Volumes/Code/Dump/DyldSharedCaches/macOS/26.4/UXKit.i64`（session `uxkit_26_4`）。
> 导出头：`/Volumes/Code/Dump/DyldSharedCaches/macOS/26.4/UXKit/ObjCHeaders/_UXCollectionViewRearrangingCoordinator.h`。

---

## 0. 架构差异（核心结论）

| | UXKit 26.4 | OpenUXKit 现状 |
|---|---|---|
| 拖放载体 | **NSDraggingSession**（gesture → `_beginDraggingSessionForIndexPaths:` 启动真实拖放会话 → NSDraggingSource/Destination 协议驱动） | 手势直驱：gesture Began→`_beginRearrangingItemsWithIndexPaths:`(自身启动 session)、Changed→`_updateRearrangingStateForLocation:`(直改 dataSource)、Ended→`_finishRearrangingForLocation:` |
| state 入口 | `_gestureRecognized:` 仅 Began(1)/Changed(2) 两态 → 启动 NSDraggingSession;后续全由拖放协议回调推进 | gesture 全态(Began/Changed/Ended/Cancelled)自驱 |
| 提交时机 | `_finishRearrangingForLocation:shouldComplete:`(由拖放结束回调触发) | `_finishRearrangingForLocation:`(gesture Ended) |

**OpenUXKit 已有 NSDragging 脚手架**（`_beginDraggingSessionForIndexPaths:`、Source/Destination 方法、`_imageForItemAtIndexPath:`、`_shouldHandleExternalDrop:` 等），但与 gesture 近似流并存、未完全按 UXKit 拓扑整合。`_finishRearrangingForLocation:shouldComplete:`(@662) 与 `_moveItemsAtIndexPaths:toIndexPaths:`(@665) 为**空 stub**。

## 1. ivar 矩阵（已对齐）

OpenUXKit class extension 与导出头逐一对应:22-bit `_collectionViewFlags`(dataSource 4 + delegate 18,注意导出头第 15 项 `delegateImplementsDraggingSessionSourceOperationMaskForDraggingContext` 误写为 `unsigned int`(非 :1),OpenUXKit 修正为 :1)、`_initialIndexPaths`@24/`_targetIndexPaths`@32/`_movedIndexPaths`@40/`_exchangedIndexPaths`@48、`_screenPoint`@56、`_initialIndexPathsAreContiguous`@72、`_gestureRecognizer`@80、`_dragStartTime`@88/`_collectionViewReloadLastCallTime`@96/`_dragEnteredTime`@104、`_updatesLayoutOnDrag`@112/`_autoscrolling`@113、`_sequenceNumber`@120、`_mouseDownEvent`@128,加 4 组 NSRange + shouldExchange/dropTargetCell/dropOperation/dragSourceIdentifier 等 @synthesize。✅

flag 位掩码（`_collectionViewFlags` 低 22 bit,小端）：bit4(0x10)=delegateShouldBeginDraggingSession、bit1(0x2)=dataSourceShouldExchange、bit2(0x4)=dataSourceMove、bit3(0x8)=dataSourceExchange、bit9(0x200)=delegatePreferredDraggingFormation;高半字（`+4` 字节偏移）bit4(0x10)=performDragOperation、bit5(0x20)=draggingEntered、bit6(0x40)=draggingUpdated。

## 2. 核心状态机（反编译）

### 2.1 `_gestureRecognized:` (0x1dbbcdeac)
```
仅 state==1(Began) || state==2(Changed):
  loc = [gesture locationInView:cv.contentView]；ip = [cv indexPathForItemAtPoint:loc]；hit = [cv.documentView hitTest:loc]
  if (cv.rearrangingEnabled && ip && [hit ux_enclosingViewOfClass:UXCollectionReusableView]):
    indexPaths = cv.allowsSelection ? cv.indexPathsForSelectedItems : @[ip]
    shouldBegin = (count>0) ? (flag bit4 ? [delegate shouldBeginDraggingSessionWithClickedItemAtIndexPath:ip] : YES) : NO
    if (NSPanGestureRecognizer): t=[gesture translationInView:cv]；
       if (|t.x|>=3) { if (!shouldBegin) return; } else if (!(|t.y|>=3 && shouldBegin)) return;
       if (UXCollectionViewPanGestureRecognizer): _mouseDownEvent = gesture.mouseDownEvent；[gesture uxCancel]
    [self _beginDraggingSessionForIndexPaths:indexPaths]   ← 启动真实拖放会话
```

### 2.2 `_beginRearrangingItemsWithIndexPaths:` (0x1dbbcddec)
```
_isRearranging=YES；_dragStartTime=now；_initialIndexPathsAreContiguous=YES（无条件！）
_initialIndexPaths = [indexPaths sortedArrayUsingSelector:SEL@0x1FA172460]   // compare: 推定
_movedIndexPaths = _targetIndexPaths = indexPaths（原序）
[self.collectionViewLayout invalidateLayout]
```
※ 不启动 session、不算 contiguous（直接置 YES）。由拖放会话生命周期回调调用。

### 2.3 `_updateRearrangingStateForLocation:` (0x1dbbcdb40) —— 入参是 `NSValue*`(pointValue)
```
loc = value.pointValue；locInView = [cv convertPoint:loc fromView:cv.documentView]
_isRearranging = CGRectContainsPoint(cv.bounds, locInView)
ip = [layout layoutAttributesForElementsInRect:{loc,1,1}].firstObject.indexPath ?: [layout proposedDropIndexPathForDraggingPoint:loc]
if (!ip || ip.item==NSNotFound): dropTargetCell=nil；dropOperation=0；if (updatesLayoutOnDrag && continuouslyUpdate) reload；return
range = _indexPathsFromRange(ip.item, _initialIndexPaths.count, ip.section)
_shouldExchange=NO
if (contiguous && flag bit1 && (shouldExchange=[dataSource shouldExchangeItemsAtIndexPaths:initial withProposedIndexPaths:range])):
    if ([_exchangedIndexPaths containsObject:ip] && ip.item==_initialIndexRange.location) ip=[NSIndexPath indexPathForItem:ip.item inSection:0]
    target = range
else:
    target = @[ip]
    if ([layout dropPositionForPoint:loc withIndexPaths:initial movedToIndexPath:ip] == 4 /*ON*/):
        dropTargetCell=[cv cellForItemAtIndexPath:ip]；dropOperation=[cv dragOperationForItemsAtIndexPaths:initial movedOntoItemAtIndexPath:ip]
    else: dropTargetCell=nil；dropOperation=0
if (updatesLayoutOnDrag && (continuouslyUpdate || ![_targetIndexPaths containsObject:ip])):
    _targetIndexPaths = target；[self _reloadCollectionViewWithAnimation]
```

### 2.4 `_finishRearrangingForLocation:shouldComplete:` (0x1dbbcd678)
```
[NSObject cancelPreviousPerformRequestsWithTarget:self]；dropTargetCell=nil；if (!_isRearranging) return
if (shouldComplete || !_updatesLayoutOnDrag):
    if (shouldExchange) goto CANCEL          // ← (A) shouldExchange 时直接取消
    dropPos = [layout dropPositionForPoint:loc withIndexPaths:initial movedToIndexPath:_targetIndexPaths.firstObject]
    if (!dropPos) goto CANCEL
    if ([initial isEqualToArray:target]) goto CANCEL
    if (shouldExchange) { if (bit1) [dataSource exchangeItemsAtIndexPaths:initial withIndexPaths:target]; goto COMMIT }   // ← (B) 不可达（A 已拦）
    else if (bit2 move) { [dataSource moveItemsAtIndexPaths:initial toIndexPath:target.firstObject dropPosition:dropPos]; goto COMMIT }
    CANCEL: _isRearranging=0; [layout invalidateLayout]; (落入 cleanup)
    COMMIT: _isRearranging=0
        if (shouldExchange): reload(initial+target)              // 死分支（同 B）
        else if (dropPos∈{8 after, 2 before}):
            base = target.first.item + (dropPos==8 ? 1 : 0)
            adjusted = base - Σ[ip∈initial, ip.section==target.section, ip.item<base]   // 扣除目标前被移走的项
            [self _moveItemsAtIndexPaths:initial toIndexPaths:_indexPathsFromRange(adjusted, initial.count, target.section)]
        else: [layout invalidateLayout]
    cleanup: nil initial/target/moved；[_gestureRecognizer setState:Cancelled(3)]
else:   // !shouldComplete && updatesLayoutOnDrag：取消但保留 live 布局
    _isRearranging=0；cancelPreviousPerform(_reloadCollectionViewWithAnimation)；[cv performBatchUpdates:^{} completion:nil]
```
**⚠️ 待验证语义**：(A) `if (shouldExchange) goto CANCEL` 在前,使 (B)/COMMIT 的 exchange 提交分支**不可达**——说明 exchange 的提交不在 finish 里（疑由 `_updateRearrangingStateForLocation:` 的 live reload 承担,finish 仅清状态）。完整重写前需交互拖放验证此分支,避免照抄死代码。

### 2.5 `_moveItemsAtIndexPaths:toIndexPaths:` (0x1dbbccd84)
```
assert(a3.count == a4.count, file "UXCollectionViewRearrangingCoordinator.m" line 731, "source and destination index paths need to have the same count")
[cv performBatchUpdates:^{ for (i) [cv moveItemAtIndexPath:a3[i] toIndexPath:a4[i]] } completion:nil]
```

### 2.6 `_indexPathsFromRange(from, count, section)` (static, 0x1dbbcd9fc)
```
result = []；for (i = from; i < from+count; i++) result.add([NSIndexPath indexPathForItem:i inSection:section])；return result
```

### 2.7 NSDraggingDestination
```
draggingEntered: (0x1dbbcc060)
  _updateDragSourceIdentifier；setDraggingFormation:(bit9 ? [delegate preferredDraggingFormationForCollectionView:] : 2/*stack*/)
  enumerateDraggingItemsWithOptions:1 forView:documentView classes:@[NSPasteboardItem] → 计数有效项 → setNumberOfValidItemsForDrop:
  _dragEnteredTime=now
  return (_shouldHandleExternalDrop && bit5(高半字0x20) ? [delegate draggingEntered:] : NSDragOperationGeneric/*16*/)

draggingUpdated: (0x1dbbcbf78)
  external = _shouldHandleExternalDrop:
  if (_allowAutoscrollForDraggingInfo:): if (!(external && now<=dragEnteredTime+0.33)) [self _autoscrollWithWindowLocation:info.draggingLocation]
  if (external && bit6(高半字0x40)) return [delegate draggingUpdated:]
  if (!_isRearranging) return 16；return (dropOperation==1 ? 1 : 16)

performDragOperation: (0x1dbbcbdf4)
  return (_shouldHandleExternalDrop && bit4(高半字0x10)) ? [delegate performDragOperation:] : YES
```

## 3. 本阶段代码改动（P10a：安全子集）

| # | 文件 | 修复 | 性质 |
|---|---|---|---|
| 1 | `_UXCollectionViewRearrangingCoordinator.m` | `_moveItemsAtIndexPaths:toIndexPaths:` 空 stub → UXKit 精确实现(count assert + performBatchUpdates 逐对 `moveItemAtIndexPath:toIndexPath:`) | stub 转正 |

`_indexPathsFromRange` helper 与 finish 的目标索引调整一并留到 P10b（本轮不引入未被调用的死代码）。

## 4. P10b 余量（完整重写,需交互拖放验证）

- `_gestureRecognized:` 改为仅 Began/Changed + translation 阈值 3.0 + `uxCancel` + 直接 `_beginDraggingSessionForIndexPaths:`(去掉 gesture 全态自驱)
- `_updateRearrangingStateForLocation:` 改 NSValue 入参 + `_indexPathsFromRange` + exchange/drop-on 分支 + `dragOperationForItemsAtIndexPaths:movedOntoItemAtIndexPath:`
- `_finishRearrangingForLocation:shouldComplete:` 落地 §2.4(含 exchange 死分支的交互验证)+ 路由拖放结束回调
- `draggingEntered:/Updated:/performDragOperation:` 对齐 §2.7(`_shouldHandleExternalDrop:` 门控 + dropOperation 返回 + draggingFormation + numberOfValidItemsForDrop + 0.33s autoscroll 节流)
- `_beginRearrangingItemsWithIndexPaths:` 改 §2.2 最小版(由会话回调驱动,不自启 session)
- 删除重复的 gesture 版 `_finishRearrangingForLocation:`(@380)
- 新增 Rearranging Showcase e2e(NSDraggingSession 录制/回放或手测)
