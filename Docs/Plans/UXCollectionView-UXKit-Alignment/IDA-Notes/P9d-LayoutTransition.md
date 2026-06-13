# P9d 反编译笔记：动画跨布局 transition 移植

> P9d phase — 移植 `-[UXCollectionView _setCollectionViewLayout:animated:isInteractive:completion:]`（0x1dbbdac28）的 **visible && doneFirstLayout** 动画/同步分支主链，对齐 UXKit 26.4。此前（P9c）仅对齐了非可见快路径，动画分支记录为 spec 未移植（见 `P9-MainClass.md` §7.3）。
>
> **结论**：动画分支完整移植到 `UXCollectionView+Layout.m` 的 `_performLayoutTransitionToLayout:animated:fromBounds:completion:`，并把 `-[UXCollectionViewLayout _animateView:withAction:fromLayoutAttributes:toLayoutAttributes:fromLayout:withCompletionHandler:`（0x1dbbe9a20）从隐式动画近似版重写为 UXKit 的显式 CABasicAnimation 版本。新增 5 个端到端 end-state 测试（`LayoutTransitionTests.swift`）。
>
> **代码改动**：`UXCollectionView+Layout.m`（transition 主链）、`UXCollectionViewLayout.m`（`_animateView:` + QuartzCore import）、`UXCollectionView+Internal.h`（`_createPrepared*` 的 `withLayoutAttributes:` 标 nullable）、`Tests/.../LayoutTransitionTests.swift`（新建）。

---

## 1. ivar / flag 偏移（本阶段用到）

| UXKit offset / 位 | 含义 | OpenUXKit 对应 |
|---|---|---|
| `result[147]` (1176) | `_layout` | `_layout` |
| `result[154]` (1232) | `_allVisibleViewsDict` | `_allVisibleViewsDict` |
| `result[159]` (1272) | `_collectionViewData` | `_collectionViewData` |
| `result[193]` (1544) | transition finalize 计数器 | `_layoutTransitionAnimationCount`（原已声明、未用，正是为此预留） |
| `result[152]` (1216) | reload 挂起计数器 | `_reloadingSuspendedCount`（gate `layoutSubviews`，**transition 不碰**） |
| `v9[220]` qword @1760，bit32 `0x100000000` | `updatingLayout` | `_collectionViewFlags.updatingLayout` |
| byte 1764 `& 0x40` | `doneFirstLayout` | `_collectionViewFlags.doneFirstLayout` |
| byte 1762 `& 0x10` | delegate respondsTo `_collectionView:targetContentOffsetForProposedContentOffset:` | `_collectionViewFlags.delegateTargetContentOffsetForProposedContentOffset` |

**关键校准**：spec 误写 @1544 为 `_reloadingSuspendedCount`，实测 reload 挂起计数器在 @1216（`_suspendReloads`/`_resumeReloads` 0x1dbbe241c/0x1dbbe23dc），@1544 是独立的 transition 计数器（`_layoutTransitionAnimationCount`）。transition 通过 `updatingLayout`（bit32）抑制 `layoutSubviews`（`layoutSubviews` 0x1dbbdd92c：`if (byte1764 & 9) return`，bit32=updatingLayout / bit35=skipLayoutDuringSnapshotting），**不**增减 `_reloadingSuspendedCount`。

---

## 2. 主方法算法（0x1dbbdac28，0x930）

```
_setCollectionViewLayout:(L) animated:(animated) isInteractive:(_) completion:(completion)
 1. if (L == _layout) return;                       // 不调 completion
 2. bounds = self.contentView.bounds;               // 在任何 geometry 变更前捕获
 3. ctx = [[L.class invalidationContextClass] new]; _setInvalidateEverything:YES + _setInvalidateDataSourceCounts:YES; [L _invalidateLayoutUsingContext:ctx];
 4. 快路径 if (![self _visible] || !(flags bit38 doneFirstLayout)):
      [L _setCollectionView:self]; [_layout _setCollectionView:nil]; _layout=L;
      _collectionViewData = new UXCollectionViewData(self, L);
      [self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:YES];
      completion(YES); return;
 // 动画/同步可见分支（visible && doneFirstLayout）:
 5. oldLayout = _layout;
 6. newData = new UXCollectionViewData(self, L); [newData _prepareToLoadData];   // 暂不赋给 _collectionViewData
 7. [oldLayout _prepareForTransitionToLayout:L]; [L _prepareForTransitionFromLayout:oldLayout];
 8. flags bit32 updatingLayout = YES;
 9. selectedKeys = { collectionItemKeyForCellWithIndexPath: ip | ip ∈ indexPathsForSelectedItems };
10. onscreenKeys(v27) = { key | key,view ∈ _allVisibleViewsDict, CGRectIntersectsRect(view.frame, bounds) };
11. anchorCandidates(v30) = NSMutableSet(onscreenKeys);
    if ([NSSet(onscreenKeys) intersectsSet:selectedKeys]) [anchorCandidates intersectSet:selectedKeys];
    anchorCandidateCount(v79) = anchorCandidates.count;   // 在 count==1 判定前取
12. anchorKey(v33):
      if (anchorCandidates.count == 1) anchorKey = anchorCandidates.anyObject;
      else { nearest = FLT_MAX; for (key in anchorCandidates) if (key.type==1/*cell*/) {
               f = [_collectionViewData layoutAttributesForItemAtIndexPath:key.indexPath].frame;   // 旧 data
               d = sqrtf((midY - (f.y+f.h/2))^2 + (midX - (f.x+f.w/2))^2);  // midX/Y = bounds 中心
               if (nearest > d) { nearest = d; anchorKey = key; } } }
13. proposed(v11/v61):
      if (anchorKey) { f = [newData layoutAttributesForItemAtIndexPath:anchorKey.indexPath].frame;   // 新 data
                       proposedX = f.x + f.w/2 - bounds.w/2; proposedY = f.y + f.h/2 - bounds.h/2; }
      else { proposedX = bounds.x; proposedY = bounds.y; }
14. clamp 到 newContentSize=[L collectionViewContentSize]:
      contentRect={0,0,cw,ch}; proposedRect={proposedX,proposedY,bounds.w,bounds.h}; clampedX=0;
      if CGRectContainsRect(contentRect, proposedRect): clampedX = proposedX;
      else { inter = CGRectIntersection(contentRect, proposedRect);
             if (cw > bounds.w) { if (inter.w >= bounds.w) clampedX = proposedX;
                                  else clampedX = proposedX + (inter.x <= proposedX ? -(bounds.w-inter.w) : (bounds.w-inter.w)); }
             if (ch > bounds.h) { if (inter.h < bounds.h) proposedY += (inter.y <= proposedY ? -(bounds.h-inter.h) : (bounds.h-inter.h)); }
             else proposedY = 0; }
      if (anchorCandidateCount == 0) { clampedX = 0; proposedY = 0; }
15. targetOffset = [L transitionContentOffsetForProposedContentOffset:{clampedX,proposedY} keyItemIndexPath:anchorKey.indexPath];
    targetOffset = [L targetContentOffsetForProposedContentOffset:targetOffset];
    if (flags bit delegateTargetContentOffset) targetOffset = [delegate _collectionView:self targetContentOffsetForProposedContentOffset:targetOffset];
16. for (key,view ∈ _allVisibleViewsDict) [view willTransitionFromLayout:oldLayout toLayout:L];   // block_435
17. ++_layoutTransitionAnimationCount;     // 父级 +1（与 block_465/同步 finalize 的 -1 配平）
18. if (animated) [NSAnimationContext runAnimationGroup:^(ctx){
         ctx.allowsImplicitAnimation=YES; ctx.duration=0.25; ctx.timingFunction=EaseInEaseOut;
         if (NSEvent.modifierFlags & shift) ctx.duration*=10;   // block_461
         animationBody(YES);   // block_440
       } completionHandler:^{ finalize(); flags bit32 updatingLayout=NO; }];  // block_465
    else { animationBody(NO); finalize(); flags bit32 updatingLayout=NO; }
```

### 2.1 animationBody（block_440，参数 = animated）

```
[self setContentSize:[L collectionViewContentSize]];
[self.contentView setBoundsOrigin:targetOffset];
newAttrs = [L layoutAttributesForElementsInRect:{targetOffset, bounds.size}];
disappearing(v4) = [_allVisibleViewsDict mutableCopy];
appearing(obj) = []; persisting(v47) = [];
for (attr in newAttrs) { key = collectionItemKeyForLayoutAttributes:attr;
    if (existing = _allVisibleViewsDict[key]) { persisting += existing; [disappearing removeObjectForKey:key]; }
    else appearing += attr; }

// 消失（block_2_441，对每个 disappearing key,view）:
[_allVisibleViewsDict removeObjectForKey:key]; type = key.type;
reuse = ^{ type==2 ? [self _reuseSupplementaryView:view] : type==1 ? [self _reuseCell:view] : nil };  // block_3_442
if (!animated || ![onscreenKeys containsObject:key]) { [self performWithoutAnimation:reuse]; continue; }   // block_448
final = type==2 ? [L finalLayoutAttributesForDisappearingSupplementaryElementOfKind:key.identifier atIndexPath:key.indexPath]
      : type==1 ? [L finalLayoutAttributesForDisappearingItemAtIndexPath:key.indexPath] : nil;
if (!final) { final = [view._layoutAttributes copy]; final.alpha = 0; }
++_layoutTransitionAnimationCount;
[L _animateView:view withAction:1 fromLayoutAttributes:view._layoutAttributes toLayoutAttributes:final fromLayout:oldLayout
   withCompletionHandler:^(finished){ [view _setLayoutAttributes:final]; reuse(); finalize(); }];   // block_445

// 出现（对每个 appearing attr）:
key = collectionItemKeyForLayoutAttributes:attr; view = nil;
if (animated) {
   initial = attr._isCell ? [L initialLayoutAttributesForAppearingItemAtIndexPath:key.indexPath]
           : attr._isDecorationView ? nil
           : [L initialLayoutAttributesForAppearingSupplementaryElementOfKind:key.identifier atIndexPath:key.indexPath];
   if (!initial) { initial = [attr copy]; initial.alpha = 0; }
   if (!initial.isHidden || !attr.isHidden) {
       view = attr._isCell ? [self _createPreparedCellForItemAtIndexPath:key.indexPath withLayoutAttributes:initial applyAttributes:YES]
            : [self _createPreparedSupplementaryViewForElementOfKind:key.identifier atIndexPath:key.indexPath withLayoutAttributes:initial applyAttributes:YES];
       ++_layoutTransitionAnimationCount;
       [L _animateView:view withAction:0 fromLayoutAttributes:initial toLayoutAttributes:attr fromLayout:oldLayout
          withCompletionHandler:^(finished){ [view _setLayoutAttributes:attr]; finalize(); }];   // block_449
   }
} else if (!attr.isHidden) {
   [self performWithoutAnimation:^{   // block_450
       view = attr._isCell ? [self _createPreparedCellForItemAtIndexPath:key.indexPath withLayoutAttributes:nil applyAttributes:YES]
            : [self _createPreparedSupplementaryViewForElementOfKind:key.identifier atIndexPath:key.indexPath withLayoutAttributes:nil applyAttributes:NO];
   }];
}
if (view) _allVisibleViewsDict[key] = view;

// 持久（对每个 persisting view）:
key = collectionItemKeyForLayoutAttributes:view._layoutAttributes;
target = key.type==1 ? [L layoutAttributesForItemAtIndexPath:key.indexPath]
       : key.type==2 ? [L layoutAttributesForSupplementaryViewOfKind:key.identifier atIndexPath:key.indexPath] : nil;
if (!target) target = [view._layoutAttributes copy];
if (target.zIndex != view._layoutAttributes.zIndex) [self performWithoutAnimation:^{ [self _addControlled:YES subview:view atZIndex:target.zIndex]; }];   // block_451
if (animated) { ++_layoutTransitionAnimationCount;
    [L _animateView:view withAction:3 fromLayoutAttributes:view._layoutAttributes toLayoutAttributes:target fromLayout:oldLayout
       withCompletionHandler:^(finished){ [view _setLayoutAttributes:target]; finalize(); }]; }   // block_2_452
else if (target.isHidden) [self performWithoutAnimation:^{ [_allVisibleViewsDict removeObjectForKey:key]; target._isCell ? [self _reuseCell:view] : [self _reuseSupplementaryView:view]; }];  // block_455
else [self performWithoutAnimation:^{ [view _setLayoutAttributes:target]; }];   // block_458
```

### 2.2 finalize（block_invoke_2）

```
if (--_layoutTransitionAnimationCount != 0) return;
for (key,view ∈ _allVisibleViewsDict) [view didTransitionFromLayout:oldLayout toLayout:L];   // block_invoke_3
[L _setCollectionView:self]; [oldLayout _setCollectionView:nil];
_layout = L; _collectionViewData = newData;
[self _setNeedsVisibleCellsUpdate:YES withLayoutAttributes:YES];
[self resetScrollingOverdraw];
[oldLayout _finalizeLayoutTransition]; [L _finalizeLayoutTransition];
completion(NO);   // UXKit 以 finished=NO 调 completion
```

---

## 3. `_animateView:withAction:…`（0x1dbbe9a20）

UXKit 在自有 `runAnimationGroup` 内注册三条显式 CABasicAnimation 后 `[view _setLayoutAttributes:to]`：

| keyPath | from | to | 备注 |
|---|---|---|---|
| `frameOrigin` | from.frame.origin | to.frame.origin | removedOnCompletion=YES |
| `bounds` | action==3 时 {0,0,from.w,from.h}（否则不设 from） | {0,0,to.w,to.h} | removedOnCompletion=YES |
| `alphaValue` | from.alpha (float) | to.alpha (float) | action==0：timingFunction=(0.5,0,0.5,0.1)；action==1：duration=ctx.duration*0.5；removedOnCompletion=YES |

`view.animations = @{frameOrigin, bounds, alphaValue}`，随后 `[view _setLayoutAttributes:to]`，group 完成回调里 completion(YES)（内部用 byref 计数：block_invoke +1 / block_invoke_349 -1，归零调 completion）。

action 取值：**0=appearing，1=disappearing，3=persisting/move**。

---

## 4. OpenUXKit 适配差异（记录在案）

| 项 | UXKit | OpenUXKit | 理由 |
|---|---|---|---|
| newLayout 接线 collectionView | finalize（block_invoke_2）才 `_setCollectionView:` | transition 入口（建 newData 后、`_prepareToLoadData` 前）即 `[newLayout _setCollectionView:self]` | OpenUXKit `-[UXCollectionViewFlowLayout _fetchItemsInfo]` 从 `self.collectionView.bounds` 取 dimension，collectionView 为 nil 时 `dimension==0` 早退、content size 归零。必须先接线 newLayout 才能在 animationBody 计算几何。finalize 再次 `_setCollectionView:self`（幂等）+ `[oldLayout _setCollectionView:nil]`。 |
| `_animateView:` 动画 | 显式 CABasicAnimation 经 `view.animations` 驱动 | 同（结构对齐），但 `_setLayoutAttributes:` 直接写 `frame/alphaValue`，layer-backed 隐式动画也会参与 | 结构 1:1；end-state 一致；自定义 alpha timing 在 OpenUXKit 直写模型下可能被隐式动画覆盖（视觉细节差异，不可在无头测试验证） |
| 同布局早退 completion | 不调 completion | 不调 completion（之前 OpenUXKit 调 completion(YES)，本次改为不调以对齐） | 1:1 |
| 可见 transition completion | finished=NO | finished=NO | 1:1（之前不可达此路径） |

---

## 5. 验证

- `swift build`：0 errors / 0 warnings
- `swift test`：35 passed / 0 failed（30 既有非回归 + 5 新 `LayoutTransitionTests`）
- 新测试覆盖：同步 swap 端态 + 选区保留 / 持久 cell 身份 + 重定位（y=210）/ 动画 swap 经 completion 端态 + swap 延迟到 completion / 同布局 no-op 不调 completion / 不可见快路径 finished=YES
- 不可视化验证项（同 spec 处境）：动画插值曲线、跨布局 appearing/disappearing 的 initial/final attrs 视觉效果——需交互式 layout 切换 showcase（无现成触发点）
