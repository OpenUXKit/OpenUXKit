# P10b 反编译笔记：Rearranging NSDraggingSession 拓扑重写

> P10b phase — 把 `_UXCollectionViewRearrangingCoordinator` 从"手势全态自驱 + 平行 session"重写为 UXKit 26.4 的 **NSDraggingSession 驱动**拓扑：gesture 仅 Began/Changed 启动会话，会话的 NSDraggingSource 回调驱动状态机。
>
> **反编译来源**：`/Volumes/RE/Dyld-Shared-Cache/macOS/26.4/UXKit.i64`。本笔记是 `P10-Rearranging.md`（P10a 状态机）的 NSDragging 粘合层补全 + 待移植项落地依据。
>
> **状态：已完整反编译（spec），代码重写未应用。** 反编译后发现 faithful rearranging 不是"重写协调器一个类"，而是一个**多组件、dataSource 契约复杂、含多处死分支、且只能交互验证**的子系统（见 §3.1 契约 + §3.2 死分支）。盲改会用不可运行验证的代码替换当前**可工作**的近似实现（现版用 `moveItemsAtIndexPaths:toIndexPath:` 确实能 reorder）。因此本阶段先完成反编译 spec + `Drag-to-rearrange` showcase（基线手测入口），重写待用户在 showcase 中验证基线 + 确认契约变更后增量推进。
>
> **运行验证限制**：拖放为交互行为，无法在无头环境验证。可验证项：build / 35 既有测试 / `_indexPathsFromRange` + drop-index 调整纯函数单测 / 对抗式反编译审查；不可验证项：实际拖放重排、live-drag gap 视觉、autoscroll、跨 OS 拖放。

---

## 1. 拓扑对照

| 环节 | UXKit 26.4 | OpenUXKit P10b（本次） |
|---|---|---|
| gesture | `_gestureRecognized:` 仅 state 1/2(Began/Changed)，translation≥3 阈值，`uxCancel`，→ `_beginDraggingSessionForIndexPaths:` | 同 |
| 启动 | `_beginDraggingSessionForIndexPaths:` 建 NSDraggingItem(每项写 `com.apple.UXCollectionView.draggingitem` plist + image + frame) → `documentView beginDraggingSessionWithItems:event:source:` | 同（补 plist 写入） |
| 进行 | NSDraggingSource 回调驱动：`willBeginAtPoint:`→收集 indexPaths→`_beginRearrangingItemsWithIndexPaths:`；`movedToPoint:`→convert→`_updateRearrangingStateForLocation:`(NSValue) 或 previewDelay perform；`endedAtPoint:operation:`→`_finishRearrangingForLocation:shouldComplete:` + 合成 mouseUp | 同 |
| 提交 | `_finishRearrangingForLocation:shouldComplete:`（§2.4） | 落地（替换空 stub） |

---

## 2. 各方法精确反编译

### 2.1 `_gestureRecognized:` (0x1dbbcdeac)
```
if (state != 1 && state != 2) return;
loc = [gesture locationInView:cv.contentView]
ip = [cv indexPathForItemAtPoint:loc]; hit = [cv.documentView hitTest:loc]
if (!cv.rearrangingEnabled) return;
if (!ip || ![hit ux_enclosingViewOfClass:UXCollectionReusableView]) return;
indexPaths = cv.allowsSelection ? cv.indexPathsForSelectedItems : @[ip]
shouldBegin = indexPaths.count ? (flag bit4 ? [delegate shouldBeginDraggingSessionWithClickedItemAtIndexPath:ip] : YES) : NO
if ([gesture isKindOfClass:NSPanGestureRecognizer]) {
   t = [gesture translationInView:cv]
   if (fabs(t.x) >= 3) { if (!shouldBegin) return; }
   else if (!((fabs(t.y) >= 3) && shouldBegin)) return;
   if ([gesture isKindOfClass:UXCollectionViewPanGestureRecognizer]) { _mouseDownEvent = retain(gesture.mouseDownEvent); [gesture uxCancel]; }
}
[self _beginDraggingSessionForIndexPaths:indexPaths]
```

### 2.2 `_beginRearrangingItemsWithIndexPaths:` (0x1dbbcddec)
```
_isRearranging=YES; _dragStartTime=now; _initialIndexPathsAreContiguous=YES (无条件)
_initialIndexPaths = [indexPaths sortedArrayUsingSelector:@selector(compare:)]
_movedIndexPaths = _targetIndexPaths = indexPaths (原序)
[cv.collectionViewLayout invalidateLayout]
```
※ 不启动 session（由 willBegin 回调调用）。

### 2.3 `_updateRearrangingStateForLocation:` (0x1dbbcdb40) —— 入参 NSValue*(pointValue)
```
loc = value.pointValue
locInView = [cv convertPoint:loc fromView:cv.documentView]
_isRearranging = CGRectContainsPoint(cv.bounds, locInView)
ip = [layout layoutAttributesForElementsInRect:{loc,1,1}].firstObject.indexPath ?: [layout proposedDropIndexPathForDraggingPoint:loc]
if (!ip || ip.item==NSNotFound) { dropTargetCell=nil; dropOperation=0; if (updatesLayoutOnDrag && continuouslyUpdate) reload; return; }
range = _indexPathsFromRange(ip.item, _initialIndexPaths.count, ip.section)
_shouldExchange = NO
if (contiguous && flag bit1 && (_shouldExchange = [dataSource shouldExchangeItemsAtIndexPaths:initial withProposedIndexPaths:range])) {
   target = range
   if ([_exchangedIndexPaths containsObject:ip] && ip.item==_initialIndexRange.location) ip = [NSIndexPath indexPathForItem:ip.item inSection:0]
} else {
   target = @[ip]
   if ([layout dropPositionForPoint:loc withIndexPaths:initial movedToIndexPath:ip] == 4 /*ON*/) {
       dropTargetCell = [cv cellForItemAtIndexPath:ip]
       dropOperation = [cv dragOperationForItemsAtIndexPaths:initial movedOntoItemAtIndexPath:ip]
   } else { dropTargetCell=nil; dropOperation=0; }
}
if (updatesLayoutOnDrag && (continuouslyUpdate || ![_targetIndexPaths containsObject:ip])) { _targetIndexPaths = target; [self _reloadCollectionViewWithAnimation]; }
```

### 2.4 `_finishRearrangingForLocation:shouldComplete:` (0x1dbbcd678)
```
cancelPreviousPerformRequestsWithTarget:self; dropTargetCell=nil; if (!_isRearranging) return;
if (shouldComplete || !_updatesLayoutOnDrag) {
   if (shouldExchange) goto CANCEL                                   // (A) 拦截：exchange 提交分支不可达（死代码）
   dropPos = [layout dropPositionForPoint:loc withIndexPaths:initial movedToIndexPath:_targetIndexPaths.firstObject]
   if (!dropPos) goto CANCEL
   if ([initial isEqualToArray:_targetIndexPaths]) goto CANCEL
   if (shouldExchange) { if (flag bit1) [dataSource exchangeItemsAtIndexPaths:initial withIndexPaths:target]; goto COMMIT }   // (B) 死分支（A 已拦）
   else if (flag bit2 /*dataSourceMove*/) { [dataSource collectionView:moveItemsAtIndexPaths:initial toIndexPath:target.first dropPosition:dropPos]; goto COMMIT }
   CANCEL: _isRearranging=0; goto INVALIDATE
   COMMIT: _isRearranging=0
       if (shouldExchange) { reloadItemsAtIndexPaths:(initial+target) }   // 死分支
       else if (dropPos==8/*after*/ || dropPos==2/*before*/) {
           base = target.first.item + (dropPos==8 ? 1 : 0)
           adjusted = base - Σ[ip∈initial, ip.section==target.section, ip.item<base]
           [self _moveItemsAtIndexPaths:initial toIndexPaths:_indexPathsFromRange(adjusted, initial.count, target.section)]
       } else INVALIDATE
   INVALIDATE: [layout invalidateLayout]
   cleanup: release initial/target/moved=nil; [_gestureRecognizer setState:Cancelled(3)]; return
} else {  // !shouldComplete && updatesLayoutOnDrag
   _isRearranging=0; cancelPreviousPerform(_reloadCollectionViewWithAnimation); [cv performBatchUpdates:^{} completion:nil]
}
```
**死分支说明**：(A) `if (shouldExchange) goto CANCEL` 在前，使所有 exchange 提交代码（(B) + COMMIT 的 `if(shouldExchange) reload`）不可达。OpenUXKit 按二进制 1:1 移植（保留死分支结构 + 注释标注），exchange 的实际提交由 `_updateRearrangingStateForLocation:` 的 live reload 承担。

### 2.5 `_indexPathsFromRange(from, count, section)` (static, 0x1dbbcd9fc)
```
result=[]; for (i=from; i < from+count; i++) result.add([NSIndexPath indexPathForItem:i inSection:section]); return result
```

### 2.6 NSDraggingSource 回调
```
draggingSession:willBeginAtPoint: (0x1dbbcc724)
  _autoscrolling=NO; _screenPoint=pt
  indexPaths=[]; enumerateDraggingItemsWithOptions:0 forView:documentView classes:@[NSPasteboardItem] usingBlock:{ // block (0x1dbbcc888)
     plist = [item.item propertyListForType:@"com.apple.UXCollectionView.draggingitem"]; if isArray plist=plist.firstObject;
     if isDictionary { itemIdx = plist[@"item"].unsignedIntegerValue; if (itemIdx != NSNotFound) indexPaths.add([NSIndexPath indexPathForItem:itemIdx inSection:plist[@"section"].unsignedIntegerValue]); }
  }
  if (flag2 bit0 /*delegate willBegin*/) [delegate collectionView:cv draggingSession:session willBeginAtPoint:pt]
  [self _beginRearrangingItemsWithIndexPaths:indexPaths]

draggingSession:movedToPoint: (0x1dbbcc5b0)
  _screenPoint=pt; if (flag2 bit1) [delegate ...movedToPoint:]
  if ([self _allowRearranging] && !_autoscrolling) {
     locWindow = [cv.window convertRectFromScreen:{pt, .zero}].origin; locDoc = [cv.documentView convertPoint:locWindow fromView:nil]
     value = [NSValue valueWithPoint:locDoc]
     if (_rearrangingPreviewDelay <= 0) [self _updateRearrangingStateForLocation:value]
     else { cancelPreviousPerformRequestsWithTarget:self; [self performSelector:@selector(_updateRearrangingStateForLocation:) withObject:value afterDelay:_rearrangingPreviewDelay]; }
  }

draggingSession:endedAtPoint:operation: (0x1dbbcc3d8)
  _autoscrolling=NO; _screenPoint=pt
  locWindow = [cv.window convertRectFromScreen:{pt,.zero}].origin; locDoc = [cv.documentView convertPoint:locWindow fromView:nil]
  locInCV = [cv convertPoint:locDoc fromView:cv.documentView]
  shouldComplete = (operation != 0) && NSPointInRect(locInCV, cv.bounds)
  [self _finishRearrangingForLocation:locDoc shouldComplete:shouldComplete]
  if (flag2 bit2) [delegate ...endedAtPoint:dragOperation:]
  // 合成 mouseUp 终止 UXCollectionViewPanGestureRecognizer 的同步事件循环：
  locInWindow = [cv.window convertRectFromScreen:{pt, .zero(NSZeroSize? CGSizeZero)}].origin
  [cv mouseUp:[NSEvent mouseEventWithType:NSEventTypeLeftMouseUp location:locInWindow modifierFlags:0 timestamp:processInfo.systemUptime windowNumber:0 context:nil eventNumber:0 clickCount:1 pressure:1.0]]
  [session.draggingPasteboard ux_setSourceIdentifier:nil]; release _mouseDownEvent; _mouseDownEvent=nil
```

### 2.7 NSDraggingDestination
```
draggingEntered: (0x1dbbcc060)
  _updateDragSourceIdentifier; setDraggingFormation:(flag bit9 ? [delegate preferredDraggingFormationForCollectionView:] : 2/*stack*/)
  validCount=0; enumerateDraggingItemsWithOptions:1 forView:documentView classes:@[NSPasteboardItem] usingBlock:{ validCount++ } (block 0x1dbbcc230)
  if (validCount) [sender setNumberOfValidItemsForDrop:validCount]
  _dragEnteredTime=now
  return (_shouldHandleExternalDrop:sender && flag2 bit5 /*0x20 delegate draggingEntered*/) ? [delegate draggingEntered:] : NSDragOperationGeneric/*16*/

draggingUpdated: (0x1dbbcbf78)
  external = _shouldHandleExternalDrop:sender
  if ([self _allowAutoscrollForDraggingInfo:sender]) { if (!(external && now <= _dragEnteredTime+0.33)) [self _autoscrollWithWindowLocation:sender.draggingLocation]; }
  if (external && flag2 bit6 /*0x40*/) return [delegate draggingUpdated:]
  if (!_isRearranging) return 16; return (dropOperation==1 ? 1 : 16)

performDragOperation: (0x1dbbcbdf4)
  return (_shouldHandleExternalDrop:sender && flag2 bit4 /*0x10*/) ? [delegate performDragOperation:] : YES
```
注：`preferredDraggingFormationForCollectionView:` 是 entered 用的委托方法（与协议的 `preferredDraggingFormationForIndexPaths:` 不同；entered 用前者）。flag bit9(0x200) 在 UXKit 是 `delegatePreferredDraggingFormation`。

---

## 3. 重写依赖与发现（重写前必须解决）

### 3.1 dataSource 契约（与旧 OpenUXKit/showcase 不同）

`_finishRearrangingForLocation:shouldComplete:` 的提交门控链：
```
dropPos = [layout dropPositionForPoint:loc withIndexPaths:initial movedToIndexPath:target.first]
        = [cv allowedDropPositionsForItemsAtIndexPaths:initial movedToIndexPath:target.first] & 4   // 0x1dbbeaf88
[cv allowedDropPositionsForItemsAtIndexPaths:movedToIndexPath:] = (flag@1762&0x40) ? [dataSource collectionView:allowedDropPositionsForItemsAtIndexPaths:movedToIndexPath:] : 0   // 0x1dbbe52b4
[cv dragOperationForItemsAtIndexPaths:movedOntoItemAtIndexPath:] = (flag@1762&0x80) ? [dataSource collectionView:dragOperationForItemsAtIndexPaths:movedOntoItemAtIndexPath:] : 0   // 0x1dbbe5248
if (!dropPos) goto CANCEL                                  // dataSource 不实现 allowedDropPositions(含 ON=4) → 永远取消
else if (flag bit2 move) [dataSource collectionView:moveItemsAtIndexPaths:initial toIndexPath:target.first dropPosition:dropPos]   // 模型提交
```
**契约结论**：UXKit faithful rearranging 的 dataSource 需实现 **`collectionView:allowedDropPositionsForItemsAtIndexPaths:movedToIndexPath:`（返回含 ON=4 的掩码）** + **`collectionView:moveItemsAtIndexPaths:toIndexPath:dropPosition:`**。这与旧 OpenUXKit 协议（`moveItemsAtIndexPaths:toIndexPath:` 无 dropPosition、无 allowedDropPositions）**不同**——重写需改协议 + showcase 的 dataSource 方法。`allowedDropPositionsForItemsAtIndexPaths:movedToIndexPath:` / `dragOperationForItemsAtIndexPaths:movedOntoItemAtIndexPath:` 是 UXCollectionView(Rearranging) 的公开方法（已在 OpenUXKit `UXCollectionView.h` 的 Drag-and-drop 段），但当前转发逻辑/flag 门控需对齐。

### 3.2 死分支清单（按二进制 1:1 移植但实际不可达）

| 死分支 | 原因 |
|---|---|
| finish 的 exchange 提交（§2.4 (B) + COMMIT 的 `if(shouldExchange) reload`） | 开头 `if (shouldExchange) goto CANCEL` 拦截 |
| finish COMMIT 的 `if (dropPos==8 \|\| dropPos==2)` → `_moveItemsAtIndexPaths:toIndexPaths:`（动画 move + drop-index 调整） | `dropPos = allowedDropPositions & 4 ∈ {0,4}`，永不等于 8/2；实际视觉更新走 COMMIT 末尾的 `invalidateLayout`（dataSource 已改模型 → relayout 显示新序） |

→ 含义：faithful 提交路径实为 **`moveItemsAtIndexPaths:toIndexPath:dropPosition:`（模型）+ `invalidateLayout`（视觉 relayout）**；`_moveItemsAtIndexPaths:toIndexPaths:`（performBatchUpdates 动画 move）+ drop-index 调整在此 dataSource 契约下是死代码（仅当 `dropPositionForPoint:` 能返回 2/8 时活，而其被 `& 4` 钳制）。移植时保留结构 + 注释，避免误以为是活路径。

### 3.3 其它依赖
- live-drag gap 视觉由 `_UXCollectionViewLayoutProxy.layoutAttributesForElementsInRect:withIndexPaths:movedToIndexPath:atPoint:` 承担（当前 OpenUXKit stub 返回 base）——重写为忠实 gap 需 P10c 级别工作；本阶段可降级为 `invalidateLayout` relayout（reorder 仍生效，仅无平滑 gap 动画）。
- `_beginDraggingSessionForIndexPaths:` 必须写 `com.apple.UXCollectionView.draggingitem` plist（item/section），否则 willBegin 回调取不到 indexPath。
- 合成 mouseUp（endedAt）必须，否则 `UXCollectionViewPanGestureRecognizer` 的同步 `nextEventMatchingMask` 事件循环不退出。

---

## 4. 状态与后续

**已完成**：整个 rearranging 流程反编译（协调器 14 方法 + NSDragging source/destination 回调 + `_beginDraggingSession` + dropPosition/allowedDropPositions/dragOperation 几何 + dataSource 契约 + 死分支辨识）；`Drag-to-rearrange` showcase（当前近似版基线，可手测）。

**未应用**：协调器 NSDragging 拓扑重写 + 协议 dropPosition 变更 + dropPosition/allowedDropPositions 门控对齐。原因：(1) 多组件、契约复杂、含多处死分支；(2) 完全不可无头验证；(3) 会替换当前可工作的 reorder 近似版。需用户先在 showcase 手测基线 + 确认契约变更（协议加 `allowedDropPositionsForItemsAtIndexPaths:movedToIndexPath:` + `moveItemsAtIndexPaths:toIndexPath:dropPosition:`），再增量推进并逐步交互验证。

**重写时的验证手段**：build 0/0 ｜ 35 既有测试 ｜ `_indexPathsFromRange` + drop-index 调整纯函数单测 ｜ 对抗式反编译审查 ｜ 用户在 showcase 手测（拖动重排 / before-after / autoscroll）。
