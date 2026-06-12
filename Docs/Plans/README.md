# OpenUXKit ↔ UXKit 26.4 对齐进度总览

把 OpenUXKit 的核心控制器/视图子系统对齐到 macOS 26.4 的私有 `UXKit.framework`（逆向基准：`/Volumes/Code/Dump/DyldSharedCaches/macOS/26.4/UXKit.i64` + `UXKit/ObjCHeaders/`）。每个子系统逐方法 `decompile` + 关键路径 `disasm` 双路核验。

| 子系统 | 状态 | 说明 | 文档 |
|---|---|---|---|
| **UXCollectionView 家族** | 🟡 进行中（P1–P11，P10b 余量） | 1:1 复刻内部数据结构/状态机，分 12 阶段增量替换 | [UXCollectionView-UXKit-Alignment/](./UXCollectionView-UXKit-Alignment/) |
| **UXSourceController** | ✅ 已对齐 + 已按子系统拆分 | 5 处实现差异（navigationController 返回值、navigate/remove 队列线程模型、Solarium leading inset） | [UXSourceController-UXKit-Alignment/](./UXSourceController-UXKit-Alignment/) |
| **UXNavigationController** | ✅ 已对齐 + 已按子系统拆分 | 核心栈/转场/toolbar 状态机已逐字一致；补齐 detached toolbars + scopeBar + liquid glass 外观 | [UXNavigationController-UXKit-Alignment/](./UXNavigationController-UXKit-Alignment/) |

状态图例：✅ 已验证对齐 ｜ 🟡 部分（有余量）｜ 🟢 仅形式对齐。

## 代码组织约定

为可维护性，已对齐且体量大的控制器按子系统拆为「主文件 + 每子系统一个 ObjC category」：

- **主文件**：`init`/`dealloc`/生命周期/`updateViewConstraints` + 所有 property accessor（含手写 lazy getter）+ 文件级全局/C 函数。
- **category**：各子系统的非 accessor 业务方法，文件名 `Class+Subsystem.m`。
- **`+Internal.h`**：声明所有被 category 访问的 backing ivar（property 自动合成复用同名 ivar，因此**无 `@dynamic`、不改公开 API**）、私有 readwrite property、协议 conformance、共享 C helper。
- category 文件以 `#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"` 抑制「category 实现宿主类协议方法」的良性告警。

## 验证基线

每个子系统改动后必须满足：`swift build` + `swift build --target UXKit`（TBD shim）+ `swift test` 全绿，公开 API 不破坏。
