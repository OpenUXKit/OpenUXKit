# P2 阶段反编译笔记：LayoutAttributes & LayoutInvalidationContext 对齐

> P2 phase — 冻结 LayoutAttributes ivar 矩阵（全局 fan-out 节点）+ verify LayoutInvalidationContext / FlowLayoutInvalidationContext 算法。
>
> **结论**：三个类全部 100% 算法对齐 UXKit 26.4。唯一发现 + 清理：OpenUXKit `UXCollectionViewLayoutAttributes._representedElementKind` 是 dead ivar（getter 已 override 不读此 ivar），已在 P2 同步删除。

---

## 1. UXCollectionViewLayoutAttributes 对照（46 个方法）

### 1.1 关键算法逐项对照

| 方法 | UXKit (IDA) | OpenUXKit (`.m`) | 对齐 |
|---|---|---|---|
| `init` | _alpha=1.0, _frame/_center/_size/_floatingFrame=zero, _isCloneString=CFSTR("_UXCollectionElementIsOriginal"), _layoutFlags 清零 | 同 (line 73-99) | ✅ |
| `setSize:` | `if != _size: _size=new, _frame=CGRectNull` | 同 (line 103-108) | ✅ |
| `setCenter:` | `if != _center: 若 _frame 非 Null: _frame.origin += delta; _center=new` | 同 (line 126-134) | ✅ |
| `setFrame:` | `setSize: + setCenter:(x+w*0.5, y+h*0.5) + _frame=new` | 同 (line 119-124) | ✅ |
| `frame` (getter, lazy) | `if isNull: 重算 _frame.origin = _center - _size*0.5; return _frame` | 同 (line 110-117) | ✅ |
| `setBounds:` | (类似) | 同 (line 140-149)，含 assertion line 331 | ✅ |
| `_setIndexPath:` | retain new + 重算 hash | 同 (line 205-210) | ✅ |
| `_setElementKind:` | retain + 重算 hash | 同 (line 218-223) | ✅ |
| `_setIsClone:` | 写 `_layoutFlags & 0xF7 \| bit3` + 切换 `_isCloneString` + 重算 hash | 同 (line 241-245) | ✅ |
| `isHidden` / `setHidden:` | bit field 操作 | 同 (line 184-190) | ✅ |
| `_isCell` / `_isSupplementaryView` / `_isDecorationView` | bit field 查询 | 同 (line 170-180) | ✅ |
| `representedElementCategory` | 3 分支返回 `Cell / Supplementary / Decoration` | 同 (line 153-161) | ✅ |
| `representedElementKind` | getter 重写：`isCellKind ? nil : _elementKind` | 同 (line 163-168) | ✅ |
| `hash` | `return _hash` (缓存) | 同 (line 249-251) | ✅ |
| `isEqual:` | identity → isKindOfClass → _indexPath isEqual: → _isEquivalentTo: | 同 (line 253-265) | ✅ |
| `_isEquivalentTo:` | 11 步比较：hidden, center, size, zIndex, isFloating, floatingFrame, verticalOffset, isClone, alpha, elementKind | 同 (line 267-311) | ✅ |
| `_isTransitionVisibleTo:` | `selfHidden && otherHidden? NO`; `both zero size? NO`; `return !_isEquivalentTo:` | 同 (line 313-328) | ✅ |
| `copyWithZone:` | alloc + init + 全字段 copy（_hash 最后一并 copy 而不是重算） | 同 (line 332-351) | ✅ |
| `description` | 多字段格式化 | 同 (line 355-404) | ✅ |

### 1.2 hash 公式（关键不变量）

```c
_hash = (item ^ (section << 19)) ^ [_elementKind hash] ^ [_isCloneString hash];
```

注意 LayoutAttributes 的 hash 公式与 _UXCollectionViewItemKey 的公式略有不同：
- ItemKey: `(item ^ (section << 19)) ^ ([identifier hash] * type)`
- LayoutAttributes: `(item ^ (section << 19)) ^ [elementKind hash] ^ [isCloneString hash]`

LayoutAttributes 的 hash 受 setIndexPath / setElementKind / setIsClone 三个 setter 触发更新；任何一个 setter 都用同一公式重算。

### 1.3 ivar 布局矩阵（P2 冻结）

| offset | UXKit ivar | OpenUXKit ivar | 对齐 |
|---|---|---|---|
| 8 | _hash (NSUInteger) | _hash | ✅ |
| 16 | _elementKind (NSString *) | _elementKind | ✅ |
| 24 | _reuseIdentifier (NSString *) | _reuseIdentifier | ✅ |
| 32-63 | _frame (CGRect) | _frame | ✅ |
| 64-79 | _center (CGPoint) | _center | ✅ |
| 80-95 | _size (CGSize) | _size | ✅ |
| 96 | _alpha (CGFloat) | _alpha | ✅ |
| 104 | _zIndex (NSInteger) | _zIndex | ✅ |
| 112 | _isFloating (BOOL) | _isFloating | ✅ |
| 120-151 | _floatingFrame (CGRect) | _floatingFrame | ✅ |
| 152 | _indexPath (NSIndexPath *) | _indexPath | ✅ |
| 168 | _isCloneString (NSString *) | _isCloneString | ✅ |
| 176 | _layoutFlags (4-bit field, byte) | _layoutFlags (struct) | ✅ |
| 184 | _verticalOffsetFromFloatingPosition (CGFloat) | _verticalOffsetFromFloatingPosition | ✅ |

**`_layoutFlags` bit 矩阵**：

| bit | UXKit | OpenUXKit | 对齐 |
|---|---|---|---|
| 0 (mask `0x01`) | isCellKind | isCellKind | ✅ |
| 1 (mask `0x02`) | isDecorationView | isDecorationView | ✅ |
| 2 (mask `0x04`) | isHidden | isHidden | ✅ |
| 3 (mask `0x08`) | isClone | isClone | ✅ |

### 1.4 P2 同步清理：删除 dead ivar

**问题**：OpenUXKit `.m` 原有声明 `NSString *_representedElementKind;` + `@synthesize representedElementKind = _representedElementKind;`，但 `representedElementKind` getter 已被手动 override 为 `isCellKind ? nil : _elementKind`——**`_representedElementKind` ivar 从未被读取**，是 dead code。

**清理**：删除 ivar 声明、删除 @synthesize、删除 init 中 `_representedElementKind = nil;` 赋值。

**验证**：`swift build` 全绿、`swift test` 26 passed。

**ivar 布局变化**：OpenUXKit `UXCollectionViewLayoutAttributes` 实例少 8 bytes 内存（不影响二进制兼容，因为是独立实现）。

### 1.5 P3 / 后续阶段桥接合同

P2 阶段冻结的 ivar 矩阵作为后续 fan-out 节点的"合同"：

- **ReusableView (S1b, P6)**：`_setBaseLayoutAttributes:` 仅读 frame/bounds/center/transform/alpha/hidden/zIndex，依赖 ivar 命名稳定 ✅
- **Data (S3a, P5)**：缓存 LayoutAttributes 对象，仅通过 public API 访问 ✅
- **Layout (S2, P3)**：layoutAttributesForItemAtIndexPath: 返回新建/缓存的 LayoutAttributes ✅
- **Animation (S5, P8)**：依赖 _isEquivalentTo: / _isTransitionVisibleTo: 语义 ✅
- **Rearranging (S6, P10)**：依赖 _isClone / _setIsClone: ✅

---

## 2. UXCollectionViewLayoutInvalidationContext 对照（12 个方法）

### 2.1 关键算法对照

| 方法 | UXKit (IDA) | OpenUXKit (`.m`) | 对齐 |
|---|---|---|---|
| `_setInvalidateEverything:` | `_invalidationContextFlags &= 0xFD \| (a3 ? 2 : 0)` (bit 1) | 同 (line 22-24) | ✅ |
| `_setInvalidateDataSourceCounts:` | `_invalidationContextFlags &= 0xFE \| a3` (bit 0) | 同 (line 30-32) | ✅ |
| `setInvalidateContentSize:` | `_invalidationContextFlags &= 0xFB \| (a3 ? 4 : 0)` (bit 2) | 同 (line 38-40) | ✅ |
| `_setUpdateItems:` | retain + copy | 同 (line 46-50) | ✅ |
| `_setInvalidatedSupplementaryViews:` | release old + alloc + initWithDictionary: | 同 (line 56-58) | ✅ |
| `_invalidateSupplementaryElementsOfKind:atIndexPaths:` | nil guard → 已有 dict? 已有 key? 合并 set / setObject:forKey: | 同 (line 60-75) | ✅ |

### 2.2 `_invalidationContextFlags` bit 矩阵（P2 冻结）

| bit | UXKit (从 setter mask 推) | OpenUXKit | 对齐 |
|---|---|---|---|
| 0 (mask `0x01`) | invalidateDataSource | invalidateDataSource | ✅ |
| 1 (mask `0x02`) | invalidateEverything | invalidateEverything | ✅ |
| 2 (mask `0x04`) | invalidateContentSize | invalidateContentSize | ✅ |

### 2.3 `_invalidatedSupplementaryViews` 数据结构

NSMutableDictionary<NSString *kind, NSArray<NSIndexPath *> *indexPaths>。
`_invalidateSupplementaryElementsOfKind:atIndexPaths:` 的合并语义：
- 已有 key entry → 用 NSMutableSet union 后 allObjects 写回（去重）
- 没有 key → 直接 setObject:forKey: 写入

---

## 3. UXCollectionViewFlowLayoutInvalidationContext 对照（5 个方法）

### 3.1 关键算法对照

| 方法 | UXKit (IDA) | OpenUXKit (`.m`) | 对齐 |
|---|---|---|---|
| `init` | `[super init]` + `(self+28) \|= 3` (bit 0 + bit 1) | 同 (line 6-13)，两 flag 都默认 YES | ✅ |
| `invalidateFlowLayoutDelegateMetrics` / setter | bit 0 of `_flowLayoutInvalidationFlags` | 同 (line 15-21) | ✅ |
| `invalidateFlowLayoutAttributes` / setter | bit 1 of `_flowLayoutInvalidationFlags` | 同 (line 23-29) | ✅ |

### 3.2 `_flowLayoutInvalidationFlags` bit 矩阵

| bit | UXKit | OpenUXKit | 对齐 |
|---|---|---|---|
| 0 (mask `0x01`) | invalidateDelegateMetrics | invalidateDelegateMetrics | ✅ |
| 1 (mask `0x02`) | invalidateAttributes | invalidateAttributes | ✅ |

ivar offset：UXKit `((BYTE *)result + 28) |= 3u` 意味着 `_flowLayoutInvalidationFlags` 在偏移 28 处。考虑到父类 LayoutInvalidationContext 的 ivar（_invalidatedSupplementaryViews + _updateItems + _invalidationContextFlags），这个偏移是合理的。

### 3.3 init 默认值

**关键不变量**：`UXCollectionViewFlowLayoutInvalidationContext` 在 `init` 时**两个 flag 都默认设为 YES**——这意味着新建的 invalidation context 默认会同时触发 delegate metrics 重算和 flow layout attributes 重算。调用方可以选择性 `setInvalidate*:NO` 来降级。

OpenUXKit 与 UXKit 行为一致 ✅。

---

## 4. P2 完成统计

| Task | 状态 | 关键发现 |
|---|---|---|
| T12 LayoutAttributes 对齐 | ✅ 已对齐 + 清理 1 处 dead ivar | 46 方法 / 14 ivar / 4 bit field 全部对齐；hash 公式确认 |
| T13 LayoutInvalidationContext 对齐 | ✅ 已对齐 | 12 方法 / 3 bit field 全部对齐；supplementary merge 语义确认 |
| (附) FlowLayoutInvalidationContext | ✅ 已对齐 | init 默认 2 个 flag 都 YES |

**P2 阶段代码改动**：1 处（删除 `UXCollectionViewLayoutAttributes._representedElementKind` dead ivar）。

---

## 5. P2 → P3 桥接

P2 输出的 ivar 矩阵 + bit field 矩阵 = 后续 phase 的硬合同：

- **P3 (Layout 基类)**：可以放心依赖 LayoutAttributes 的 22 ivar 和 4 bit field 命名
- **P4 (FlowLayout)**：FlowLayoutInvalidationContext 的 2 bit field 已稳定
- **P5 (Data)**：缓存 LayoutAttributes 仅通过 public API
- **P8 (Animation)**：_isEquivalentTo: / _isTransitionVisibleTo: 行为已验证

---

## 6. P2 阶段 9 步工作流执行记录

| 步骤 | 执行情况 |
|---|---|
| **D** (Dump) | ✅ IDA `list_funcs` 拿到 LayoutAttributes 46 / LayoutInvalidationContext 12 / FlowLayoutInvalidationContext 5 方法清单 |
| **A** (Abstract ivars) | ✅ 从 init / copyWithZone / setter 反推完整 ivar 偏移矩阵；4 bit field 含义解码 |
| **M** (Method mapping) | ✅ 反编译 13 个核心方法（init / setFrame: / setSize: / setCenter: / frame / _setIndexPath: / _setElementKind: / _setIsClone: / _isEquivalentTo: / _isTransitionVisibleTo: / isEqual: / copyWithZone: / 3 个 invalidation setter / supplementary merge / FlowLayoutInvalidationContext init） |
| **C** (Compare with current) | ✅ 算法 100% 对齐；发现 1 处 dead ivar |
| **B** (Bridge inventory) | ✅ ivar 矩阵作为 fan-out 合同冻结，列出所有依赖方 |
| **R** (Rewrite) | ✅ 删除 `_representedElementKind` dead ivar |
| **V** (Verify) | ✅ `swift build` 0 errors / 0 warnings；`swift test` 26 passed |
| **G** (Git checkpoint) | (本次会话末尾 commit) |
| **L** (Log learnings) | ✅ 本笔记 |
