# OpenUXKit UXCollectionView 家族公开 API 合同（Examples 依赖快照）

> 通过 `rg -o '\bUX[A-Z][A-Za-z]*' Examples/OpenUXKit-Example-Swift/` 提取，作为 P0 起始时所有 Examples 实际依赖的 UX 公开符号。
>
> **重构期间这些符号只能扩展不能改名/删除**——它们是与 OpenUXKit-Example-Swift（含 6 个 Showcase）的契约。

## Collection 相关公开类（7 个）

| 符号 | 在 Showcase 中的引用次数 | 引用方式 | 当前文件路径 |
|---|---|---|---|
| `UXCollectionView` | 多次 | 继承基类 / `UXCollectionView(frame:collectionViewLayout:)` 初始化 / dataSource/delegate 属性 / register*/dequeue* 方法 | `Sources/OpenUXKit/Components/Public/UXCollectionView.{h,m}` |
| `UXCollectionViewCell` | 多次 | `final class XxxCell: UXCollectionViewCell` 子类化 / dequeue 返回类型 | `Sources/OpenUXKit/Components/Public/UXCollectionViewCell.{h,m}` |
| `UXCollectionReusableView` | 多次 | `final class XxxHeader: UXCollectionReusableView` 子类化 / viewForSupplementaryElementOfKind 返回类型 | `Sources/OpenUXKit/Components/Public/UXCollectionReusableView.{h,m}` |
| `UXCollectionViewController` | 1 次 | `final class XxxVC: UXCollectionViewController` 子类化 + override init/collectionView | `Sources/OpenUXKit/Components/Public/UXCollectionViewController.{h,m}` |
| `UXCollectionViewLayout` | 多次 | `layout: UXCollectionViewLayout` 参数类型（delegate 回调签名） | `Sources/OpenUXKit/Components/Public/UXCollectionViewLayout.{h,m}` |
| `UXCollectionViewFlowLayout` | 多次 | `UXCollectionViewFlowLayout()` 构造 + scrollDirection/itemSize/minimumLineSpacing/minimumInteritemSpacing/headerReferenceSize/footerReferenceSize/sectionInset 属性 | `Sources/OpenUXKit/Components/Public/UXCollectionViewFlowLayout.{h,m}` |
| `UXCollectionViewFlowLayoutInvalidationContext` | 1 次 | `UXCollectionViewFlowLayoutInvalidationContext()` 构造 → invalidateFlowLayoutDelegateMetrics/invalidateFlowLayoutAttributes 属性 → invalidateLayout(with:) | `Sources/OpenUXKit/Components/Public/UXCollectionViewFlowLayoutInvalidationContext.{h,m}` |

## Collection 相关公开协议（3 个）

| 协议 | 必需方法（Swift） | 可选方法（Examples 实际实现） |
|---|---|---|
| `UXCollectionViewDataSource` | `collectionView(_:numberOfItemsInSection:)` / `collectionView(_:cellForItemAt:)` | `numberOfSections(in:)` / `collectionView(_:viewForSupplementaryElementOfKind:at:)` |
| `UXCollectionViewDelegate` | (无必需) | `collectionView(_:didSelectItemAt:)` / `collectionView(_:didDeselectItemAt:)` |
| `UXCollectionViewDelegateFlowLayout` | (无必需) | `collectionView(_:layout:sizeForItemAt:)` / `collectionView(_:layout:referenceSizeForHeaderInSection:)` / `collectionView(_:layout:referenceSizeForFooterInSection:)` / `collectionView(_:layout:insetForSectionAt:)` / `collectionView(_:layout:minimumLineSpacingForSectionAt:)` / `collectionView(_:layout:minimumInteritemSpacingForSectionAt:)` |

## 字符串常量（2 个）

| 常量 | 字面值 | 必须保持 |
|---|---|---|
| `UXCollectionElementKindCell` | `"UXCollectionElementKindCell"` | 是 |
| `UXCollectionViewElementKindSectionHeader` | `"UXCollectionViewElementKindSectionHeader"` | 是 |
| `UXCollectionViewElementKindSectionFooter` | `"UXCollectionViewElementKindSectionFooter"` | 是 |

注：Examples 中以 string literal `"UXCollectionViewElementKindSectionHeader"` 字面写入 `register(_:forSupplementaryViewOfKind:withReuseIdentifier:)`，而不是用 const 符号。重构时若 const 符号改名，**字面字符串值不能变**。

## Swift 注解合约

每个公开类的 .h 顶部必须有：
- `NS_HEADER_AUDIT_BEGIN(nullability, sendability)` / `NS_HEADER_AUDIT_END(...)`
- 类声明前 `NS_SWIFT_UI_ACTOR`（确保 Swift 看到 `@MainActor`-isolated）
- `UXKIT_EXTERN`

每个 dequeue/register 方法的 Objective-C 签名（参考 `UXCollectionView.h:55-64`）：
```objc
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(nullable NSNib *)nib forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerClass:(nullable Class)viewClass forSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(nullable NSNib *)nib forSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier;
- (__kindof UXCollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
- (__kindof UXCollectionReusableView *)dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
```

每个 Swift 测试样本：
```swift
collectionView.register(SwatchCell.self, forCellWithReuseIdentifier: "Swatch")
let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Swatch", for: indexPath) as! SwatchCell
let header = collectionView.dequeueReusableSupplementaryView(ofKind: "UXCollectionViewElementKindSectionHeader", withReuseIdentifier: "SwatchHeader", for: indexPath) as! SwatchHeader
```

任何 phase 修改 .h 之前必须 `rg -nE 'symbol1|symbol2' Examples/ Tests/` 确认不破坏这些签名。

## 验证脚本（每 phase 末跑）

```bash
# 1. 确认 13 个符号都还在 OpenUXKit 公开 API surface
for sym in UXCollectionView UXCollectionViewCell UXCollectionReusableView \
           UXCollectionViewController UXCollectionViewLayout UXCollectionViewFlowLayout \
           UXCollectionViewFlowLayoutInvalidationContext \
           UXCollectionViewDataSource UXCollectionViewDelegate UXCollectionViewDelegateFlowLayout \
           UXCollectionViewElementKindSectionHeader UXCollectionViewElementKindSectionFooter \
           UXCollectionElementKindCell; do
  rg -l "\\b$sym\\b" Sources/OpenUXKit/include/OpenUXKit/ 2>&1 | head -1 || echo "MISSING: $sym"
done

# 2. Examples 编译通过
xcodebuild -workspace OpenUXKit.xcworkspace -scheme OpenUXKit-Example-Swift -configuration Debug build 2>&1 | xcsift
```
