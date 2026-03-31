# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OpenUXKit is an open-source Objective-C implementation of Apple's private `UXKit.framework` for macOS. It provides UIKit-style APIs on top of AppKit, enabling navigation controllers, toolbars, and other iOS-like UI patterns on macOS. The API design mirrors the original UXKit API.

Two library products exist:
- **OpenUXKit** — the open-source reimplementation (primary development target)
- **UXKit** — a thin target that links against Apple's private `/System/Library/PrivateFrameworks/UXKit.framework` via a TBD stub

An Xcode workspace (`OpenUXKit.xcworkspace`) aggregates the main project and example apps under `Examples/`.

## Build Commands

```bash
# SPM build (always update packages first)
swift package update && swift build 2>&1 | xcsift

# SPM tests
swift package update && swift test 2>&1 | xcsift

# Run a single test
swift test --filter OpenUXKitTests/testMethodName 2>&1 | xcsift

# Xcode build (framework target only — tests are SPM-only)
xcodebuild -project OpenUXKit.xcodeproj -scheme OpenUXKit -configuration Debug build 2>&1 | xcsift
```

Platform requirement: macOS 11+ (Swift tools version 5.10). No linter or formatter is configured.

## Architecture

### Core Design: AppKit Wrapper Layer

All `UX*` classes inherit from AppKit counterparts and add UIKit-style interfaces:

| OpenUXKit | Inherits From |
|---|---|
| `UXView` | `NSView` |
| `UXViewController` | `NSViewController` |
| `UXBar` / `UXToolbar` / `UXNavigationBar` | `UXView` → `NSView` |
| `UXNavigationController` / `UXTabBarController` | `UXViewController` |
| `UXWindowController` | `NSWindowController` |

### Header Organization (Public / Private / Internal)

The header system has two directories with distinct roles:

- **`Sources/OpenUXKit/PrivateHeaders/OpenUXKit/`** — contains **all** headers: public API, internal (`+Internal.h`), private classes (`_UX*`), and unimplemented stubs. This is the single source of truth for all `.h` files. Added to the compiler via `cSettings: .headerSearchPath("PrivateHeaders")` in SPM.
- **`Sources/OpenUXKit/include/OpenUXKit/`** — contains **only symlinks** to the ~20 public headers that consumers can import. Each symlink points back into the source tree (e.g., `UXView.h → ../../Components/Public/UXView.h`). This is what SPM exposes as the module's public interface.

The `+Internal.h` pattern: every major class has a `ClassName+Internal.h` that exposes private properties/methods for use by sibling `.m` files (e.g., `UXView+Internal.h`, `UXViewController+Internal.h`).

### Adding a New Class

1. Create the header `.h` in the appropriate `Sources/OpenUXKit/` subdirectory
2. Create the implementation `.m` in the same directory
3. The header is **automatically** available via PrivateHeaders (it's a flat directory that aggregates all headers)
4. If the class should be **public API**: add a symlink in `Sources/OpenUXKit/include/OpenUXKit/` pointing to the header. You can use the `symbollink.sh` script in that directory (regenerates all symlinks) or create one manually
5. Add the `#import` to `OpenUXKit.h` (the umbrella header)

### Source Layout

```
Sources/OpenUXKit/
├── Categories/Public/        # NSView, NSWindow AppKit category extensions
├── Categories/Private/       # Private SPI access (NSView+PrivateSPI)
├── Commons/Public/           # UXBase.h, UXKitDefines.h
├── Commons/Private/          # extobjc macros, UXKitPrivateUtilites.h
├── Components/Public/        # Implemented components (.h + .m files)
├── Components/Private/       # Internal components (_UXButton, etc.)
├── Protocols/Public/         # UXBarCommon, UXKitAppearance protocols
├── Transition & Animation/   # View controller transition controllers
├── Misc/Private/             # _UXNavigationRequest, _UXResizableImage, etc.
└── Unimplementation/         # Header-only stubs for not-yet-implemented classes
```

### View Controller Proxy Pattern

`UXView` holds a weak `viewControllerProxy` reference to its owning `UXViewController`, forwarding lifecycle events:

```objc
- (void)layout {
    [self.viewControllerProxy viewWillLayoutSubviews];
    [super layout];
    [self layoutSubviews];
    [self.viewControllerProxy viewDidLayoutSubviews];
}
```

### UXViewController Category Decomposition

`UXViewController` uses Objective-C categories to organize functionality:
- `(UXNavigationControllerItem)` — navigation stack properties
- `(Compatibility)` — UIKit-compatible lifecycle (`viewWillAppear:(BOOL)animated`)
- `(UXPopoverController)`, `(UXSourceController)`, `(UXTabBarController)`, `(UXWindowController)` — container integration
- `(UXViewControllerTransitioning)` — transition animation support

### Transition System

`Transition & Animation/` implements a full VC transition framework with `UXViewControllerAnimatedTransitioning` protocol:
- `UXIdentityTransitionController` — no animation
- `UXSlideTransitionController` — slide transitions
- `UXParallaxTransitionController` — parallax effect
- `UXZoomingCrossfadeTransitionController` — zoom crossfade
- `_UXViewControllerTransitionContext` — transition context implementation

### UXKit Target (Apple Private Framework Shim)

`Sources/UXKit/` links against Apple's private framework via `UXKit.tbd`. It shares the same public headers as OpenUXKit (via symlink: `include → ../OpenUXKit/include`). The only source file is `NSViewController+UXKitFixups.m`, which adds `transitionCoordinator` and `_ancestorViewControllerOfClass:` to `NSViewController` as compatibility shims.

## Code Conventions

### Naming
- Public classes: `UX` prefix (e.g. `UXView`, `UXNavigationController`)
- Private internal classes: `_UX` prefix (e.g. `_UXButton`, `_UXContainerView`)
- Internal extension headers: `ClassName+Internal.h`
- Private SPI methods: underscore-prefixed (e.g. `_ancestorViewControllerOfClass:`)

### Visibility Macros (`UXKitDefines.h`)
- `UXKIT_EXTERN` — public symbol export
- `UXKIT_PRIVATE_EXTERN` / `UXKIT_PRIVATE` — hidden symbols

### Utility Macros (`UXKitPrivateUtilites.h`)
- `auto` — maps to `__auto_type`
- `cast(cls, var)` — type cast shorthand
- `SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(code)` — silence performSelector warnings

### Swift Annotations
All public headers use `NS_SWIFT_UI_ACTOR` (MainActor), `NS_SWIFT_NAME(...)`, and `NS_SWIFT_DISABLE_ASYNC` for Swift interoperability.

### Third-party
Uses embedded **extobjc** macros (`@weakify`/`@strongify`, `@onExit`, `@keypath`) from `Commons/Private/`.

## Resource Search Paths

When looking for pre-exported headers or IDA databases for reverse engineering reference, search the following paths **in order** and use the first match:

| Priority | Description |
|----------|-------------|
| 1 | Primary local storage for Dyld Shared Cache exports |
|   | `/Volumes/RE/Dyld-Shared-Cache/macOS/<version>/`  |
|   | `/Volumes/Code/Dump/DyldSharedCaches/macOS/<version>/` |
| 2 | RuntimeViewer MCP / ida-pro-mcp Live MCP fallback when local files do not exist |

Each search path follows this directory layout:

```
<search-root>/<version>/
├── <Framework>/
│   ├── ObjCHeaders/          # RuntimeViewer exported ObjC headers (equivalent to get_type_interface)
│   └── SwiftInterfaces/      # RuntimeViewer exported Swift interfaces
├── <Framework>.i64           # IDA Pro database (e.g., UIKitCore.i64, AppKit.i64)
└── ...
```
