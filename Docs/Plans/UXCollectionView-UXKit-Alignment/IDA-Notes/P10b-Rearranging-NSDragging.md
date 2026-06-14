# P10b 反编译笔记：Rearranging NSDraggingSession 拓扑重写

> P10b phase — 把 `_UXCollectionViewRearrangingCoordinator` 从"手势全态自驱 + 平行 session"重写为 UXKit 26.4 的 **NSDraggingSession 驱动**拓扑：gesture 仅 Began/Changed 启动会话，会话的 NSDraggingSource 回调驱动状态机。
>
> **反编译来源**：`/Volumes/RE/Dyld-Shared-Cache/macOS/26.4/UXKit.i64`。本笔记是 `P10-Rearranging.md`（P10a 状态机）的 NSDragging 粘合层补全 + 待移植项落地依据。
>
> **状态：已完整反编译 + 重写已应用（用户选 A：增量忠实重写）。** 反编译发现 faithful rearranging 是一个**多组件、dataSource 契约复杂、含多处死分支、且只能交互验证**的子系统（§3.1 契约 + §3.2 死分支）。重写已落地：协调器 NSDragging 拓扑 + finish §2.4 + 契约层（协议 + CV 转发 + layout dropPosition）+ gating 方法修正（§3.2b）+ 接线修复（`setRearrangingEnabled_` 此前根本未接线，§3.4）。**重要发现**：旧 OpenUXKit 的 rearranging 因 `setRearrangingEnabled_:` 用 `init`（nil CV、不 setEnabled）而**从未安装手势识别器、根本不工作**——所以重写没有"可工作功能"会被破坏。
>
> **运行验证**：拖放为交互行为，无法在无头环境验证。已验证：build 0/0 ｜ 35 既有测试 ｜ 对抗式反编译审查 ｜ **用户在 `Drag-to-rearrange` showcase 手测确认拖动重排提交**（修正计时常量后，运行日志显示完整提交链 `update committed → finish dropPosition=4 initialEqTarget=0 implMove=1`，dataSource 的 `moveItemsAtIndexPaths:toIndexPath:dropPosition:` 被调用）。修复关键见 §3.2c：`_rearrangingInitialDelay`/`_rearrangingPreviewDelay` 初次移植误填 0.5/0.25，真实值 0.33/0.1，其中 0.25 的 preview-delay 防抖太长是"能拖不重排"的病根。未移植（降级）：live-drag gap 视觉（layout proxy，relayout 替代 → showcase 的 dataSource 在 move 后 `reloadData`）。

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
  _updateDragSourceIdentifier; setDraggingFormation:(flag bit9 ? [delegate preferredDraggingFormationForCollectionView:] : 2/*Pile=2 in AppKit's NSDraggingFormation*/)
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

### 3.2b gating 方法（旧 OpenUXKit 把它们误实现为"选区检查"）

| 方法 | UXKit 真实实现 | 旧 OpenUXKit（错误） |
|---|---|---|
| `_allowRearranging` (0x1dbbcde74) | `now > _dragStartTime + _rearrangingInitialDelay`（**纯时间门控**：初始延迟过后才允许 live reorder） | 要求有选区 + canMove |
| `gestureRecognizerShouldBegin:` (0x1dbbce094) | `![collectionView isBusy]`（仅在 CV 更新/动画中才拦截；逐项资格在 `_gestureRecognized:` 决定） | 要求有选区 |

→ 这是 showcase 无选区拖动能工作的关键：`_gestureRecognized:` 用 `allowsSelection ? selected : @[ip]`，无选区时拖点击项；`gestureRecognizerShouldBegin:` 不再要求选区。注意 `_updateRearrangingStateForLocation:`（live preview）只在 `_allowRearranging`（即拖动超过 `_rearrangingInitialDelay`）后才跑，故快速拖放需拖够该延迟才会重排（finish 用 `_targetIndexPaths`，未更新则 == initial → 取消）。

### 3.2c 计时常量与 preview-delay 防抖（init 0x1dbbce444 实测，**初次移植填错**）

`initWithCollectionView:` 在 ivar 偏移 `0xa0` 写入一个 OWORD `{_rearrangingInitialDelay = 0.33, _rearrangingPreviewDelay = 0.1}`（`xmmword_1DBC16CD0` = `0x3FD51EB851EB851F`, `0x3FB999999999999A`）。**初次移植误填 0.5 / 0.25**，其中 `_rearrangingPreviewDelay = 0.25` 是 P10b 落地后"能拖动但不重排"的真正病根：

- `draggingSession:movedToPoint:` 对 `_updateRearrangingStateForLocation:` 做 `cancelPreviousPerformRequestsWithTarget: + performSelector:withObject:afterDelay:_rearrangingPreviewDelay` 防抖。
- 连续拖动时每个 move 事件（约 16–50ms 一个）都取消上一个挂起请求并重排到 +delay，**delay 内攒不满就永不触发**；松手时 `_finishRearrangingForLocation:` 开头的 `cancelPreviousPerformRequestsWithTarget:` 又把最后一个挂起请求取消。
- delay=0.25 太长，接不住"减速松手前"的自然停顿 → `_updateRearrangingStateForLocation:` 全程不跑 → `_targetIndexPaths` 一直 == initial → finish `![initial isEqualToArray:target]` 为假 → 不提交。改回二进制的 **0.1** 后，落点处的自然停顿即可触发更新并提交（运行日志确认：`update committed target=[0,4]` → `finish dropPosition=4 initialEqTarget=0 implMove=1`）。
- **拓扑确认**：`beginDraggingSessionWithItems:event:source:` 的返回值在 `_beginDraggingSessionForIndexPaths:` 末尾**立即**传给 `_createdDraggingSession:forItemsAtIndexPaths:` → begin 非阻塞、拖动在主 run loop 异步跟踪，故 default-mode 的 `performSelector:afterDelay:` 在 move 间隙能正常触发（无需 `inModes:`，与二进制一致）。

**其它 init 默认值**（offset/语义，供后续对齐；与 reorder bug 无关但当前 OpenUXKit 未完全匹配）：`_enabled`(0x89)=YES、`_updatesLayoutOnDrag`(0x70)=YES、`_allowAutoscroll`(0x8d)=YES，且 init 内直接调 `reloadLayout` + `createGestureRecognizer`。OpenUXKit 改用 §3.4 的"懒 getter + setEnabled 装手势"拓扑（功能等价，手势确认可用），未照搬 init-内建手势 + enabled 默认 YES。

### 3.3 其它依赖
- live-drag gap 视觉由 `_UXCollectionViewLayoutProxy.layoutAttributesForElementsInRect:withIndexPaths:movedToIndexPath:atPoint:` 承担（当前 OpenUXKit stub 返回 base）——重写为忠实 gap 需 P10c 级别工作；本阶段可降级为 `invalidateLayout` relayout（reorder 仍生效，仅无平滑 gap 动画）。
- `_beginDraggingSessionForIndexPaths:` 必须写 `com.apple.UXCollectionView.draggingitem` plist（item/section），否则 willBegin 回调取不到 indexPath。
- 合成 mouseUp（endedAt → `[collectionView mouseUp:]`）：`_gestureRecognized:` 里 `uxCancel` + `beginDraggingSession` 后，原始 mouseDown 已被吞、配对的 mouseUp 进了拖动机制而非 CV，CV/手势的事件状态失衡；endedAt 合成一个 mouseUp 回灌给 CV 以平衡。（注：`UXCollectionViewPanGestureRecognizer` 仅覆写 `mouseDown:`/`uxCancel`/`dealloc`，**无** `nextEventMatchingMask` 嵌套循环——早期笔记的"同步事件循环"说法已纠正。）

### 3.4 接线修复（旧 OpenUXKit 的 rearranging 根本未启用）

UXKit：`_rearrangingCoordinator` getter（0x1dbbe55c0）**懒创建** `initWithCollectionView:self` 并存到 @1744；`setRearrangingEnabled_:`（0x1dbbe5578）→ `[[self _rearrangingCoordinator] setEnabled:]`（安装/移除手势）。旧 OpenUXKit 的 `setRearrangingEnabled_:` 用 `[[... alloc] init]`（= `initWithCollectionView:nil`）且从不 `setEnabled:` → 协调器无 collectionView、无手势识别器 → 设 `rearrangingEnabled_=YES` 实际什么都没接。已修复为 UXKit 拓扑（懒 getter + setEnabled）。

---

## 4. 状态与后续

**已完成**：整个 rearranging 流程反编译（协调器 14 方法 + NSDragging source/destination 回调 + `_beginDraggingSession` + dropPosition/allowedDropPositions/dragOperation 几何 + dataSource 契约 + 死分支辨识）；`Drag-to-rearrange` showcase（当前近似版基线，可手测）。

**未应用**：协调器 NSDragging 拓扑重写 + 协议 dropPosition 变更 + dropPosition/allowedDropPositions 门控对齐。原因：(1) 多组件、契约复杂、含多处死分支；(2) 完全不可无头验证；(3) 会替换当前可工作的 reorder 近似版。需用户先在 showcase 手测基线 + 确认契约变更（协议加 `allowedDropPositionsForItemsAtIndexPaths:movedToIndexPath:` + `moveItemsAtIndexPaths:toIndexPath:dropPosition:`），再增量推进并逐步交互验证。

**重写时的验证手段**：build 0/0 ｜ 35 既有测试 ｜ `_indexPathsFromRange` + drop-index 调整纯函数单测 ｜ 对抗式反编译审查 ｜ 用户在 showcase 手测（拖动重排 / before-after / autoscroll）。
