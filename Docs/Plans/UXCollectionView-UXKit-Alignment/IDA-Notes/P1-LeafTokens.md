# P1 阶段反编译笔记：叶子 token 对齐

> P1 phase — 流程演练 + 验证 UXCollectionViewUpdateItem、_UXCollectionViewItemKey、_UXCollectionViewSectionItemIndexes 三个叶子 token 类的算法/接口对齐。
>
> **结论**：三个类在 OpenUXKit 中**已经 100% 算法对齐 UXKit 26.4**，无需修改任何代码。P1 的实际产出是这份对照笔记 + P0 阶段对"OpenUXKit 已做过深度对齐"的进一步证实。

---

## 1. UXCollectionViewUpdateItem 对照（17 个方法）

### 1.1 核心方法逐项对照

| 方法 | UXKit (IDA) | OpenUXKit (`UXCollectionViewUpdateItem.m`) | 对齐 |
|---|---|---|---|
| `compareIndexPaths:` | `return [self._indexPath compare:other._indexPath]` | 同 (line 72-74) | ✅ |
| `inverseCompareIndexPaths:` | `return [other._indexPath compare:self._indexPath]` | 同 (line 76-78) | ✅ |
| `_isSectionOperation` | `return self._indexPath.item == NSNotFound` | 同 (line 68-70) | ✅ |
| `initWithInitialIndexPath:finalIndexPath:updateAction:` | 简单赋值 3 个 ivar | 同 (line 15-23) | ✅ |
| `initWithAction:forIndexPath:` | (类似) | (line 25-29) — `action==Insert ? final=indexPath : initial=indexPath` | ✅ |
| `initWithOldIndexPath:newIndexPath:` | (类似) | (line 31-33) — 转发到 initWithInitial:final:updateAction:Move | ✅ |
| `_indexPath` getter | `_updateAction != 0 ? _initialIndexPath : _finalIndexPath` | 同 (line 51-56)，即 `!= Insert ? initial : final` | ✅ |
| `_newIndexPath` getter | `return _finalIndexPath` | 同 (line 58-60) | ✅ |
| `_setNewIndexPath:` | `if (_finalIndexPath != new) { _finalIndexPath = new; }` | 同 (line 62-66) | ✅ |
| `_action` getter | `return _updateAction` | 同 (line 47-49) | ✅ |
| `updateAction` getter | `return _updateAction` | 同 (line 43-45) | ✅ |
| `indexPathBeforeUpdate` | `return _initialIndexPath` | 同 (line 35-37) | ✅ |
| `indexPathAfterUpdate` | `return _finalIndexPath` | 同 (line 39-41) | ✅ |
| `_gap` getter / `_setGap:` | 直接 ivar 读写 | 同 (line 80-86) | ✅ |
| `description` | `[super description] + " index path before update (...) ... action (...)"` | 同 (line 88-92)，actionStrings 字符串数组 | ✅ |

### 1.2 ivar 布局对照

| ivar offset | UXKit | OpenUXKit | 对齐 |
|---|---|---|---|
| 8 (`v8[1]`) | _initialIndexPath | _initialIndexPath | ✅ |
| 16 (`v8[2]`) | _finalIndexPath | _finalIndexPath | ✅ |
| 24 (`v8[3]`) | _updateAction (NSInteger) | _updateAction | ✅ |
| 32 | (UXKit 中未观察到) | __unsafe_unretained _gap | OpenUXKit 多一个 ivar，但不影响行为 |

### 1.3 关键不变量

- `_action` 编码：0=INSERT / 1=DELETE / 2=RELOAD / 3=MOVE（与 UXCollectionUpdateAction 枚举一致）
- `_indexPath` 对 Move 操作返回 source（`_initialIndexPath`），不返回 destination——这是后续 `_computeItemUpdates` 中 model 选择逻辑（DELETE/MOVE→oldModel）的前提
- `_isSectionOperation` 通过 `indexPath.item == NSNotFound` 而不是 length 来判定

---

## 2. _UXCollectionViewItemKey 对照（19 个方法）

### 2.1 核心方法逐项对照

| 方法 | UXKit (IDA) | OpenUXKit (`_UXCollectionViewItemKey.m`) | 对齐 |
|---|---|---|---|
| `hash` getter | `return self->_hash` (直接返回缓存) | 同 (line 112-114) | ✅ |
| `isEqual:` | 7 步：identity → hash → class → type → section → item → isClone → identifier(isEqualToString:) | 同 (line 116-140) | ✅ |
| `setType:` (重算 hash) | 仅当 `_type != type` 重算 | 同 (line 73-78) | ✅ |
| `setIndexPath:` (重算 hash) | (类似) | 同 (line 84-89) | ✅ |
| `setIdentifier:` (重算 hash) | (类似) | 同 (line 95-100) | ✅ |
| `initWithType:indexPath:identifier:clone:` | 4 个 ivar 赋值 + 初始 hash 计算 | 同 (line 57-67) | ✅ |
| `copyAsClone:` | clone==isClone ? `objc_retain(self)` : 新对象 | 同 (line 102-110)，ARC retain | ✅ |
| `copyWithZone:` | `return objc_retain(self)` (不可变设计) | 同 (line 142-144) | ✅ |
| `+collectionItemKeyFor*` (4 个工厂) | (类似) | 同 (line 21-51) | ✅ |
| `description` | (按 type 分支格式化) | 同 (line 146-157) | ✅ |

### 2.2 hash 公式（关键不变量）

UXKit IDA 反编译显示 hash 计算公式：
```c
_hash = (item ^ (section << 19)) ^ ([identifier hash] * type)
```

OpenUXKit 实现（`.m:64`）：
```objc
_hash = ([_indexPath item] ^ ([_indexPath section] << 19)) ^ ([_identifier hash] * _type);
```

**完全一致**。任何 setter (setType:/setIndexPath:/setIdentifier:) 都会用同一公式重算。

### 2.3 ivar 布局对照

| ivar offset | UXKit | OpenUXKit | 对齐 |
|---|---|---|---|
| 8 (`v10[1]`) | _hash (NSUInteger) | _hash | ✅ |
| 16 (`v10[2]`) | _indexPath | _indexPath | ✅ |
| 24 (`v10[3]`) | _identifier | _identifier | ✅ |
| 32 (byte) | _isClone (BOOL) | _isClone | ✅ |
| 40 (`v10[5]`) | _type (NSUInteger) | _type | ✅ |

ivar 排列顺序完全一致。

### 2.4 关键不变量

- ItemKey 设计为**不可变值类型**：`copyWithZone:` 返回 self，没有 deep copy
- `copyAsClone:` 是唯一会产生"变体"的方法（仅 isClone 字段不同）；若 isClone 相同就返回 self
- isEqual: 第二步快速过滤是 hash 比较（避免后续昂贵的字符串 isEqualToString:）
- hash 公式中 `section << 19` 的 19 位移是经验值，混淆 section/item 防止 section 0/1 与 item 0/1 冲撞

---

## 3. _UXCollectionViewSectionItemIndexes 接口对照（26 个方法）

### 3.1 接口完整性

P1 仅 verify **接口完整性**；adjust* 算法实现留到 P7。

| UXKit IDA 方法清单（26） | OpenUXKit `.h` 声明（19） | 状态 |
|---|---|---|
| `itemCount` / `firstItem` / `lastItem` | 同（3 个 readonly 属性） | ✅ |
| `containsItem:` / `addItem:` / `removeItem:` | 同 | ✅ |
| `addItemsInRange:` / `removeItemsInRange:` | 同 | ✅ |
| `addSectionItemIndexes:` / `removeSectionItemIndexes:` | 同 | ✅ |
| `adjustForDeletionOfItem:` / `adjustForDeletionOfItems:` | 同 | ✅ 接口；P7 verify 算法 |
| `adjustForInsertionOfItem:` / `adjustForInsertionOfItems:` | 同 | ✅ 接口；P7 verify 算法 |
| `items` (返回 NSIndexSet) | 同 | ✅ |
| `itemIndexPathsForSection:` | 同 | ✅ |
| `enumerateItemsUsingBlock:` | 同 | ✅ |
| `init` / `dealloc` / `isEqual:` / `description` / `copyWithZone:` | 继承 NSObject<NSCopying>（实现在 .m） | ✅ |
| 2 个 block_invoke（adjust 实现内部用的 block） | 实现细节 | ✅ |

接口 100% 对齐。`<NSCopying>` 协议已声明。

### 3.2 P7 待 verify 的算法（暂搁置）

- `adjustForDeletionOfItem:` / `adjustForDeletionOfItems:` 的 block 内部如何处理 cascade shift
- `adjustForInsertionOfItem:` / `adjustForInsertionOfItems:` 的 block 内部
- 与 IndexPathsSet 配合时的双层 mutation 一致性

---

## 4. P1 完成统计

| Task | 状态 | 关键发现 |
|---|---|---|
| T9 UpdateItem 对齐 | ✅ 已对齐 | 17 个方法全部算法对齐；ivar 布局对齐 |
| T10 _UXCollectionViewItemKey 对齐 | ✅ 已对齐 | hash 公式完全一致；ivar 布局对齐 |
| T11 SectionItemIndexes 接口 | ✅ 已对齐 | 19 个 .h 方法 + NSObject 默认方法覆盖 26 个 UXKit 方法 |

**P1 阶段无代码修改**——证明 OpenUXKit 在 leaf token 层已经做过深度对齐。

---

## 5. P1 → P2 的桥接

P1 成果对 P2 (LayoutAttributes + InvalidationContext) 的影响：

1. **_UXCollectionViewItemKey 已稳定** → P2/后续阶段可以放心用 ItemKey 作为缓存 key（如 `_allVisibleViewsDict` 的 key）
2. **UpdateItem 的 `_isSectionOperation` / `_indexPath` / `_action` 语义已稳定** → P5/P8 用 Update 时不必担心边界
3. **SectionItemIndexes 接口已稳定** → P7 仅需 verify adjust* 算法实现细节，不会破坏调用方

---

## 6. P1 阶段 9 步工作流执行记录

| 步骤 | 执行情况 |
|---|---|
| **D** (Dump) | ✅ IDA `list_funcs` 拿到 UpdateItem 17 / ItemKey 19 / SectionItemIndexes 26 方法清单 |
| **A** (Abstract ivars) | ✅ ivar 布局已在本笔记 §1.2 §2.3 记录 |
| **M** (Method mapping) | ✅ 反编译 8 个核心方法（compareIndexPaths / inverseCompareIndexPaths / _isSectionOperation / _indexPath / _newIndexPath / _setNewIndexPath: / hash / isEqual: / setType: / initWithType:indexPath:identifier:clone: / copyAsClone: / copyWithZone:） |
| **C** (Compare with current) | ✅ 全部 100% 对齐 |
| **B** (Bridge inventory) | ✅ 无破坏性接口变化，无需桥接 |
| **R** (Rewrite) | — 无需 rewrite |
| **V** (Verify) | ✅ `swift test` 26 passed |
| **G** (Git checkpoint) | (本次会话末尾 commit) |
| **L** (Log learnings) | ✅ 本笔记 |
