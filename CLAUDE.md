# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OpenUXKit is an open-source Objective-C implementation of Apple's private `UXKit.framework` for macOS. It provides UIKit-style APIs on top of AppKit, enabling navigation controllers, toolbars, and other iOS-like UI patterns on macOS. The API design mirrors the original UXKit API.

Two library products exist:
- **OpenUXKit** — the open-source reimplementation (primary development target)
- **UXKit** — a thin target that links against Apple's private `/System/Library/PrivateFrameworks/UXKit.framework` via a TBD stub

## Build Commands

```bash
# SPM build
swift build 2>&1 | xcsift

# SPM tests
swift test 2>&1 | xcsift

# Xcode build
xcodebuild -project OpenUXKit.xcodeproj -scheme OpenUXKit -configuration Debug build 2>&1 | xcsift
```

Platform requirement: macOS 11+ (Swift tools version 5.10).

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

- **`Sources/OpenUXKit/include/OpenUXKit/`** — public headers (symlinks), exposed to consumers
- **`Sources/OpenUXKit/PrivateHeaders/OpenUXKit/`** — internal headers (`+Internal.h`) and unimplemented class stubs; added via `cSettings: .headerSearchPath("PrivateHeaders")` in SPM
- **`+Internal.h` pattern** — every major class has a `ClassName+Internal.h` that exposes private properties/methods to sibling implementation files (e.g. `UXView+Internal.h`, `UXViewController+Internal.h`)

### Source Layout

```
Sources/OpenUXKit/
├── Categories/Public/        # NSView, NSWindow AppKit category extensions
├── Categories/Private/       # Private SPI access (NSView+PrivateSPI)
├── Commons/Public/           # UXBase.h, UXKitDefines.h
├── Commons/Private/          # extobjc macros, UXKitPrivateUtilites.h
├── Components/Public/        # Implemented components (.m files)
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

## Implementation Status

Completed: `UXView`, `UXViewController`, `UXBar`, `UXToolbar`, `UXBarItem`, `UXBarButtonItem`, `UXNavigationBar`, `UXNavigationController`, `UXNavigationItem`, `UXLabel`, `UXImageView`.

Unimplemented (header stubs only in `Unimplementation/`): `UXCollectionView` family, `UXTableView` family, `UXControl`, `UXSourceController`, `UXTabBarController`, `UXWindowController`, and various `_UX` internal classes.
