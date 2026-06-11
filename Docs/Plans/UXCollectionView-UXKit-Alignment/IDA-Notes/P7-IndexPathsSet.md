# P7 阶段反编译笔记：IndexPathsSet 选区数据子系统对齐

> P7 phase — verify S4 子系统三个类（`UXCollectionViewIndexPathsSet` / `UXCollectionViewMutableIndexPathsSet` / `_UXCollectionViewSectionItemIndexes`）的 ivar 布局与全部 85 个函数（含 block）的算法对齐 UXKit 26.4。这是 P9 Selection 痛点的数据结构地基，也是 P1 刻意搁置的 `adjust*` 算法体的收尾。
>
> **结论**：OpenUXKit 三个类**已 100% 算法对齐 UXKit 26.4，零代码修改**——与 P1（叶子 token）同款结局。本阶段实际产出为：① 全量方法级对照（85 个函数）；② plan 假设证伪 1 处（`intersectIndexPathsSet:` 机制）；③ 调用面合同（P8/P9 接线依据）；④ 5 个 IndexPathsSet 单测从 stub 转正并首跑全绿。
>
> **P7 阶段代码改动**（`git show --stat 3b257b0` 核对）：1 个文件，+299 / -10 行。
> - `Tests/OpenUXKitTests/Collection/IndexPathsSetTests.swift`：5 个 XCTSkip stub 替换为真实测试（测试 only，生产代码零改动）

---

## 1. ivar 矩阵（P7 冻结）

来源：导出头 `/Volumes/RE/Dyld-Shared-Cache/macOS/26.4/UXKit/ObjCHeaders/UXCollectionView{,Mutable}IndexPathsSet.h`、`_UXCollectionViewSectionItemIndexes.h` + `init` (0x1dbbfab68 / 0x1dbbf8df4) 反编译。

### 1.1 UXCollectionViewIndexPathsSet

| UXKit offset | UXKit ivar | OpenUXKit（`+Internal.h` @protected） | 对齐 |
|---|---|---|---|
| 8 | `_sectionIndexes`（NSMutableIndexSet） | 同名同型 | ✅ |
| 16 | `_sectionToItemIndexesMap`（NSMutableDictionary<NSNumber\*, _UXCollectionViewSectionItemIndexes\*>） | 同名同型 | ✅ |

`init` 中两个 ivar 任一分配失败则 release self 返回 nil——OpenUXKit 的两段 `if (!_ivar) return nil;` 在 ARC 下等价。

### 1.2 UXCollectionViewMutableIndexPathsSet

无自有 ivar（纯行为子类，全部状态在父类）。OpenUXKit 一致。✅

### 1.3 _UXCollectionViewSectionItemIndexes

| UXKit offset | UXKit ivar | OpenUXKit | 对齐 |
|---|---|---|---|
| 8 | `_itemIndexesSet`（NSMutableIndexSet） | 同（class extension 内） | ✅ |

**无 sorted-array 缓存**——P1 猜测的"可能存在排序数组缓存"不存在，该类就是 NSMutableIndexSet 的薄包装。

---

## 2. 方法算法对照（85 个函数全部反编译）

### 2.1 UXCollectionViewIndexPathsSet（35 个）

| 方法 | 地址 | UXKit 关键算法 | 对齐 |
|---|---|---|---|
| `init` | 0x1dbbfab68 | 分配 2 个 ivar，失败返回 nil | ✅ |
| `initWithIndexPath:` / `initWithIndexPaths:` / `initWithIndexPathsSet:` | 0x1dbbfab28 / a9bc / a97c | `[self init]` 后转发 `_addOneIndexPath:` / `_addIndexPathsSet:`；indexPaths 路径对非 NSIndexPath 元素走 NSAssertionHandler（**line 410**） | ✅（行号一致） |
| `+indexPathsSet*` 4 个工厂 | 0x1dbbfa588-a63c | alloc+init 转发 | ✅ |
| `_itemIndexesForSection:allowingCreation:` | 0x1dbbf98c0 | map 查 NSNumber key；creation 时新建 entry + `addIndex:` + **计数同步 assert（line 564）** | ✅ |
| `_removeItemIndexesForSection:` | 0x1dbbf97f4 | 删 entry + `removeIndex:` + 同步 assert（**line 582**） | ✅ |
| `_addOneIndexPath:` | 0x1dbbf962c | `indexAtPosition:0/1`，creation=YES，`addItem:` | ✅ |
| `_removeOneIndexPath:` | 0x1dbbf958c | creation=NO；`removeItem:` 后 `itemCount==0` → `_removeItemIndexesForSection:`（**空 section 清理**） | ✅ |
| `_addIndexPathsSet:` + block | 0x1dbbfa668 | 直接枚举对方 `_sectionToItemIndexesMap`（ivar 直访 `a3+2`）；key 非 NSNumber → NSNotFound；`addSectionItemIndexes:` 合并 | ✅ |
| `_enumerateSectionItemIndexesWithBlock:` + block | 0x1dbbf96a4 | 枚举 map；key 非 NSNumber 或 == NSNotFound 跳过；stop 经 __block 变量回传 | ✅ |
| `count` + block | 0x1dbbf9494 | 枚举累加 `itemCount`（每次 O(sections)，无缓存） | ✅ |
| `sections` | 0x1dbbf9468 | `[_sectionIndexes copy]` autorelease | ✅ |
| `allIndexPaths` + block | 0x1dbbf923c | `arrayWithCapacity:count` + 逐 section `itemIndexPathsForSection:`（**顺序随字典枚举，跨 section 无序**） | ✅ |
| `containsIndexPath:` | 0x1dbbf8e60 | nil → NO；creation=NO 查不到 → NO；`containsItem:` | ✅ |
| `itemsInSection:` / `indexPathsForSection:` | 0x1dbbf931c / 9408 | map 直查；**无 entry 返回 nil**（不是空集合） | ✅ |
| `indexPathsForSections:` | 0x1dbbf9374 | `firstIndex`/`indexGreaterThanIndex:` 游标循环聚合 | ✅ |
| `firstIndexPath` / `lastIndexPath` | 0x1dbbf918c / 90dc | `_sectionIndexes` first/last → 该 section 的 first/lastItem → `indexPathWithIndexes:length:2`；任一 NSNotFound → nil | ✅ |
| `enumerateIndexPathsUsingBlock:` + 2 block | 0x1dbbf8ee0 | 外层 section 枚举套内层 `enumerateItemsUsingBlock:`，栈上拼 `{section, item}` 建 NSIndexPath | ✅ |
| `copyWithZone:` | 0x1dbbfa664 | **thunk：`return objc_retain(self)`**（不可变值语义，同 `_UXCollectionViewItemKey`） | ✅（ARC `return self` 等价） |
| `mutableCopyWithZone:` | 0x1dbbf99a4 | `allIndexPaths` → `[Mutable allocWithZone:] initWithIndexPaths:`（**经数组重建，非逐 section 深拷**） | ✅ |
| `isEqual:` | 0x1dbbfa844 | 指针相等 → YES；`isKindOfClass:[UXCollectionViewIndexPathsSet class]`（**父类，mutable 互比可过**）→ `isEqualToIndexSet:` 对方 ivar 直访 → 逐 section 比 itemIndexes | ✅ |
| `description` | 0x1dbbfa75c | super + `" (%lu items)"` + 逐 section `" %lu:%@"` | ✅ |
| `dealloc` | 0x1dbbfa928 | release 2 ivar | ✅（ARC） |

**注**：UXKit 与 OpenUXKit 均**未 override `hash`**——`isEqual:` 改写而 hash 沿用指针 hash，二者以同样的方式违反 hash 合同（选区代码从不把 set 当字典 key，无实害）。

### 2.2 UXCollectionViewMutableIndexPathsSet（25 个）

| 方法 | 地址 | UXKit 关键算法 | 对齐 |
|---|---|---|---|
| `addIndexPath:` / `removeIndexPath:` | 0x1dbbfa53c / a1e4 | nil 检查后转发 `_addOneIndexPath:` / `_removeOneIndexPath:`（tail-call thunk） | ✅ |
| `addIndexPaths:` / `removeIndexPaths:` | 0x1dbbfa3dc / a084 | fast enumeration + 非 NSIndexPath assert（**line 857 / 941**） | ✅（行号一致） |
| `addIndexPathsSet:` | 0x1dbbfa3d0 | nil 检查 + `_addIndexPathsSet:` | ✅ |
| `removeIndexPathsSet:` + block | 0x1dbbf9f5c | 枚举对方 map（ivar 直访）；creation=NO；`removeSectionItemIndexes:` 后 `itemCount==0` → `_removeItemIndexesForSection:`（**空 section 清理**） | ✅ |
| `addSection:itemsInRange:` | 0x1dbbfa33c | 守卫 `section <= NSIntegerMax-1 && length != 0 && location != NSNotFound`；creation=YES + `addItemsInRange:` + 冗余 `addIndexPaths:` 回灌（UXKit 原样冗余） | ✅（含冗余） |
| `removeSection:` | 0x1dbbfa258 | 直接删 map key + `removeIndex:`（无同步 assert） | ✅ |
| `removeSection:itemsInRange:` | 0x1dbbfa2ac | creation=NO；`removeItemsInRange:` 后空 → `removeSection:` | ✅ |
| `removeSections:` | 0x1dbbfa1f0 | 升序游标逐个 `removeSection:` | ✅ |
| `removeAllIndexPaths` | 0x1dbbf9f20 | `removeAllObjects` + `removeAllIndexes` | ✅ |
| `intersectIndexPathsSet:` + block | 0x1dbbf9e1c | **见 §3.1（plan 假设证伪）** | ✅ |
| `adjustForDeletionOfIndexPath:` / `adjustForInsertionOfIndexPath:` | 0x1dbbf99f0 / 9abc | nil 检查；creation=NO（**section 无 entry 则静默 no-op**）；转发叶子类 `adjustFor*OfItem:`；**无空 section 清理**（见 §3.3 quirk） | ✅ |
| `adjustForDeletionOfItems:inSection:` / `adjustForInsertionOfItems:inSection:` | 0x1dbbf9a6c / 9b38 | creation=NO + 转发叶子类批量 adjust | ✅ |
| `adjustForDeletionOfSection:` / `adjustForInsertionOfSection:` | 0x1dbbf9bf0 / 9d40 | `!= NSNotFound` 守卫 + 转发 `_adjustFor*OfSection:` | ✅ |
| `adjustForDeletionOfSections:` | 0x1dbbf9b88 | **降序**（`lastIndex`/`indexLessThanIndex:`）逐个 `_adjustForDeletionOfSection:` | ✅ |
| `adjustForInsertionOfSections:` | 0x1dbbf9cd8 | **升序**逐个 `_adjustForInsertionOfSection:` | ✅ |
| `_adjustForDeletionOfSection:` | 0x1dbbf9c04 | 见 §3.2 | ✅ |
| `_adjustForInsertionOfSection:` | 0x1dbbf9d54 | 见 §3.2 | ✅ |
| `copyWithZone:` | 0x1dbbfa548 | `[[UXCollectionViewIndexPathsSet allocWithZone:] initWithIndexPathsSet:self]`（mutable 的 copy 是不可变深快照） | ✅ |

### 2.3 _UXCollectionViewSectionItemIndexes（25 个）

| 方法 | 地址 | UXKit 关键算法 | 对齐 |
|---|---|---|---|
| `init` / `dealloc` | 0x1dbbf8df4 / 8da8 | 分配/释放 `_itemIndexesSet` | ✅ |
| `addItem:` / `removeItem:` / `containsItem:` / `addItemsInRange:` / `removeItemsInRange:` / `itemCount` / `firstItem` / `lastItem` | 0x1dbbf8b28 等 | NSMutableIndexSet 直转发（tail-call thunk） | ✅ |
| `addSectionItemIndexes:` / `removeSectionItemIndexes:` | 0x1dbbf8b0c / 8ae8 | **nil 检查**后 `addIndexes:` / `removeIndexes:`（对方 ivar 直访） | ✅ |
| `items` | 0x1dbbf8b38 | `[_itemIndexesSet copy]` autorelease | ✅ |
| `adjustForDeletionOfItem:` | 0x1dbbf89ec | `!= NSNotFound` 守卫；`removeIndex:item` + `shiftIndexesStartingAtIndex:item+1 by:-1`（被删位先移除，尾部左移补位） | ✅ |
| `adjustForDeletionOfItems:` + block | 0x1dbbf8914 | `enumerateRangesWithOptions:**NSEnumerationReverse**`；每 range：`removeIndexesInRange:` + `shift(location+length, -length)`（逆序保证前段 range 坐标不被先行 shift 污染） | ✅ |
| `adjustForInsertionOfItem:` | 0x1dbbf8acc | `!= NSNotFound` 守卫；`shift(item, +1)`（位于插入位的 index 也右移——`>=` 语义） | ✅ |
| `adjustForInsertionOfItems:` + block | 0x1dbbf8a44 | `enumerateRangesWithOptions:0`（**正序**）；每 range：`shift(location, +length)`（以最终坐标系逐段插入） | ✅ |
| `itemIndexPathsForSection:` | 0x1dbbf87ac | 游标循环 + 栈上 `{section, item}` 建 NSIndexPath | ✅ |
| `enumerateItemsUsingBlock:` | 0x1dbbf8884 | 游标循环 + stop 检查（非 block 枚举） | ✅ |
| `isEqual:` | 0x1dbbf8ce8 | 指针 → class → `isEqualToIndexSet:`（对方 ivar 直访） | ✅ |
| `copyWithZone:` | 0x1dbbf8d60 | alloc+init 后 `addIndexes:`（真深拷，与 IndexPathsSet 的 retain-self 形成对照） | ✅ |
| `description` + block | 0x1dbbf8b7c | `enumerateRangesUsingBlock:` 拼 `"0-3,5,7-9"` 风格 | ✅ |

---

## 3. 核心算法细节（P7 产出）

### 3.1 `intersectIndexPathsSet:`——plan 假设证伪

Plan §S4 假设：「先 section 求交，再逐 section item indexes 求交」。**反编译证明机制完全不同**（0x1dbbf9e1c）：

```
1. complement = [other mutableCopy]          # 从对方出发
2. [complement addIndexPathsSet:self]        # complement = self ∪ other
3. for indexPath in other:                   # 枚举对方
       if [self containsIndexPath:indexPath]:
           [complement removeIndexPath:indexPath]
   # 此时 complement = (self ∪ other) − (self ∩ other)，即对称差
4. [self removeIndexPathsSet:complement]     # self −= 对称差 → self = self ∩ other
```

结果语义仍是标准交集（OpenUXKit 实现与 UXKit 逐句一致，测试只断言结果 + section 清理副作用）。继 P6「plan 假设恰好相反」之后，这是第二处证明 plan 启发式描述不可直接当实现依据。

### 3.2 `_adjustForDeletionOfSection:` / `_adjustForInsertionOfSection:`

```
deletion(S):                                    insertion(S):
  for K in sectionIndexes 中 > S 的升序游标:        for K in sectionIndexes 中从 lastIndex 降序、K >= S:
      map[K-1] = map[K]; 删 map[K]                   map[K+1] = map[K]; 删 map[K]
  [sectionIndexes shift(S+1, -1)]                 [sectionIndexes shift(S, +1)]
```

- 字典 key 搬移期间游标只读 `_sectionIndexes`（循环内不改它），shift 留在循环外一次完成——搬移方向（删除升序 / 插入降序）保证不覆盖未处理 entry。
- `shiftIndexesStartingAtIndex:S+1 by:-1` 的 Foundation 语义会**顺带删除 index S**（左移把 [S, S+1) 区间挤掉），所以被删 section 自身一定从 `_sectionIndexes` 消失。
- 批量版本的处理顺序（删除降序 / 插入升序）正好让每一步都在「上一步完成后的坐标系」里执行，与 UpdateItem 排序后的回放顺序吻合。

### 3.3 空 section 清理合同（两类路径行为不同，均已测试钉死）

| 路径 | 项删空后是否移除 section entry |
|---|---|
| `_removeOneIndexPath:`（removeIndexPath(s):） | ✅ 移除（`_removeItemIndexesForSection:`） |
| `removeIndexPathsSet:` block / `intersectIndexPathsSet:`（末步走前者） | ✅ 移除 |
| `removeSection:itemsInRange:` | ✅ 移除（`removeSection:`） |
| **`adjustForDeletionOfIndexPath:` / `adjustForDeletionOfItems:inSection:`** | ❌ **不移除**——section entry 以空 item set 存活，`sections()` 仍含该 section、`count` 为 0 |

最后一行是反编译钉死的 UXKit quirk（OpenUXKit 原样一致），单测 `test_adjustForDeletionInsertion_shiftsTrailingSections` 已 pin，防止后人「顺手修复」造成偏差。

### 3.4 `_adjustForDeletionOfSection:` 的脏 key 隐患（调用方合同）

若被删 section S 自身在 map 中有 entry，且 S+1 **不在** map 中（无人搬入覆盖 S），则 S 的字典 entry 残留而 `_sectionIndexes` 已无 S → map 与 index set 计数失同步：`count` / `itemsInSection:S` 仍能读到已删 section 的项，且下一次 `_itemIndexesForSection:allowingCreation:YES` 会触发 line 564 同步 assert。**UXKit 与 OpenUXKit 此处逐句相同**，说明真实调用方必须先移除被删 section/item 的选区（`removeSection:` / `removeIndexPathsSet:`）再调 `adjustFor*`——这是 P8 `_updateWithItems:` / P9 选择路径接线时必须遵守的前置条件（测试只覆盖 S+1 有 entry 的安全用例，未 pin 失同步行为）。

---

## 4. P7 修复的偏差清单

**无**（0 处）。三个类的 85 个函数（35 + 25 + 25，含 block）全部逐句对齐，包括 5 处 NSAssertionHandler 的文件名/行号/文案（410 / 564 / 582 / 857 / 941）。

## 5. P7 保留的偏差

**无**。连 P5/P6 常见的「防御性增强」类偏差都不存在——该子系统应是 OpenUXKit 当初直接按反编译抄写的。

---

## 6. 调用面合同（xref 普查，P8/P9 接线依据）

### 6.1 `UXCollectionViewMutableIndexPathsSet` 实例化点（classref xref）

| UXKit 调用方 | 用途 |
|---|---|
| `_UXCollectionViewCommonInit` | 创建选区 ivar（OpenUXKit 对应 `_indexPathsForSelectedItems` / `_pendingDeselectionIndexPaths`，`UXCollectionView.m:171-172` 已一致） |
| `-[UXCollectionView mouseDragged:]` | lasso 选区累积 |
| `-[UXCollectionView setAllowsMultipleSelection:]` | 关多选时收敛选区 |
| `-[UXCollectionView _selectAllItems:notifyDelegate:]` | 全选构造 |
| `-[UXCollectionView _selectItemsInIndexPathsSet:byExtendingSelection:animated:scrollingKeyItem:toPosition:notifyDelegate:]` | 选择算法主入口（P9 4 路分支宿主） |
| `___37-[UXCollectionView _updateWithItems:]_block_invoke.608` | **P8 关键**：batchUpdates 后重建选区——新建 mutable set，`enumerateIndexPathsUsingBlock:` 把旧选区逐个经 update 映射 block 转换后写入，整体替换旧 set（不是原地 adjust） |

### 6.2 `UXCollectionViewIndexPathsSet`（不可变）引用点

选择/取消选择全家（`selectItem*` / `deselectItem*` / `_toggleSelectionState…` / `_selectRangeOfItems…` / `_performItemSelectionForKey:withModifiers:` / `_performItemSelectionForMouseEvent:onCell:atIndexPath:`）、`reloadData`、`setAllowsEmptySelection:`、3 个 accessibility 入口、`mouseDragged:`。即：**调用方以不可变 set 作参数语义传递，主类内部状态才用 mutable**——OpenUXKit 主类现状（`UXCollectionView.m:946-2309`）已遵守同一模式。

### 6.3 `_UXCollectionViewSectionItemIndexes`

仅被 IndexPathsSet 双类内部引用（`_itemIndexesForSection:allowingCreation:` 创建），无任何外部消费者——可视为 S4 的私有实现细节。

---

## 7. 遗留到后续 phase

| 项 | 所属 | 说明 |
|---|---|---|
| `_updateWithItems:` 的选区重建路径（block 608：枚举旧选区 → 经映射 block 转换 → 整体替换）目前 OpenUXKit 主类是否等价实现待查 | **P8** | 反编译主类 `_updateWithItems:` 时核对；注意 UXKit 这里**不是**用 `adjustFor*` 原地调整，而是 map-and-rebuild |
| `adjustFor*OfSection(s):` 的调用前置条件（先清被删 section 选区，避免 §3.4 脏 key）落在主类哪一步 | **P8/P9** | 反编译 `_endUpdates` / `_updateWithItems:` 链路时确认调用顺序 |
| Selection 算法 4 路分支（extending × animated × notify）与 lasso/keyboard-range 路径本体 | **P9** | S4 数据层已可信，`SelectionAlgorithmTests.swift` 的 4 个 stub 在 P9 转正 |

---

## 8. 测试

- `IndexPathsSetTests.swift` 5 个 stub 全部转正（commit `3b257b0`，+299/-10，纯测试改动）：
  - `test_emptySet_hasZeroCountAndNilFirstLast`：空集语义 + nil 参数 + 「无 entry 返回 nil 而非空集合」
  - `test_singleSection_addAndContains`：增删/重复添加/nil no-op + **空 section 清理**（`_removeOneIndexPath:` 路径）
  - `test_multiSection_sectionsAndItemsInSection`：多 section + `addSection:itemsInRange:` / `removeSection:itemsInRange:` / `removeSections:` + **copy 语义三连**（不可变 copy 返回 self、mutable copy 出不可变深快照、mutableCopy 独立可变）+ 跨类 `isEqual:` 双向
  - `test_intersect_keepsOnlyCommonIndexPaths`：交集结果 + section 清理 + 参数不被改写 + 空集/不相交边界（原 stub 名 `byPerSectionThenItemIndexes` 因 §3.1 证伪改名）
  - `test_adjustForDeletionInsertion_shiftsTrailingSections`：section 删除/插入 shift（含被删 section 自身有选区、占位 slot 插入、越尾插入 no-op、NSNotFound 守卫、批量降序/升序）+ item 级删除/插入（单个与批量 range）+ **§3.3 无清理 quirk pin**
- 私有类访问方式：测试内自建 `@objc protocol IndexPathsSetAPI` 镜像 + `NSClassFromString` + `unsafeBitCast`（objc_msgSend 按 selector 派发），生产模块表面零改动（这三个类在 UXKit 中同样不入公开伞头）。
- `swift build`：0 errors / 0 warnings；`swift test`：26 个用例 0 failures（**10 实跑通过，16 个 P8/P9 stub 维持 skip**，较 P6 净增 5 个实跑）；`xcodebuild OpenUXKit-Example-Swift Debug build`：成功（仅历史 storyboard warning）。

---

## 9. P7 阶段 9 步工作流执行记录

| 步骤 | 执行情况 |
|---|---|
| **D** (Dump) | ✅ `list_funcs` 枚举三类 85 个函数（35 + 25 + 25，含 block）；同步读 3 个导出头 |
| **A** (Abstract ivars) | ✅ §1 三类 ivar 矩阵（2 + 0 + 1 个 ivar，全部对齐） |
| **M** (Method mapping) | ✅ 85 个函数全部反编译（含全部 block_invoke） |
| **C** (Compare) | ✅ 逐方法对照，**零偏差**；assert 行号 5 处一致 |
| **B** (Bridge inventory) | ✅ classref xref 普查（§6）+ rg 全仓：OpenUXKit 调用面仅 `UXCollectionView.m` / `+Internal.h`，与 UXKit 调用面同构；无签名变更，零桥接 |
| **R** (Rewrite) | — 无需 rewrite（"already aligned" 结局） |
| **V** (Verify) | ✅ build / test（5 个新测试首跑全绿）/ Example xcodebuild 全绿 |
| **G** (Git checkpoint) | ✅ `3b257b0` test(collection)；docs commit 见本笔记提交 |
| **L** (Log learnings) | ✅ 本笔记（§3.1 假设证伪、§3.3 quirk、§3.4 调用方合同） |
